terraform {
  required_version = ">= 1.0.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 6.0.0"
    }
    env = {
      source  = "tchupp/env"
      version = "~> 0.0.2"
    }
  }
}

provider "env" {}

provider "oci" {
  config_file_profile = local.profile
}

data "env_variable" "oci_cli_profile" {
  name = "OCI_CLI_PROFILE"
}

# This terraform code parses the ~/.oci/config file to populate configured profiles into terraform allowing values in there to be used in terraform
# If OCI_CLI_PROFILE is set to a profile name, that profile is used
# If OCI_CLI_PROFILE is not set, the first profile in the list of profiles is used
locals {
  # Read the file and split it into lines
  config_lines = split("\n", file(pathexpand("~/.oci/config")))

  # Extract profile headers from the lines
  profile_headers = [
    for line in local.config_lines :
    flatten(regexall("\\[([\\w]+)\\]", line))
  ]

  # Get indices of profile headers
  profile_indices = compact([
    for i in range(length(local.profile_headers)) :
    length(local.profile_headers[i]) > 0 ? i : ""
  ])

  # Get the indices for the next profile headers
  next_profile_indices = concat(
    slice(local.profile_indices, 1, length(local.profile_indices)),
    [length(local.config_lines)]
  )

  # Map profile names to their corresponding lines
  profiles = {
    for i in range(length(local.profile_indices)) :
    element(local.profile_headers, local.profile_indices[i])[0] => slice(
      local.config_lines,
      local.profile_indices[i] + 1,
      local.next_profile_indices[i] - 1
    )
  }

  # Construct the OCI profiles from the lines
  oci_profiles = {
    for profile_name, profile_lines in local.profiles :
    profile_name => {
      for line in compact(profile_lines) :
      flatten(regexall("(\\w+)=(.+)$", line))[0] => flatten(regexall("(\\w+)=(.+)$", line))[1]
    }
  }

  # Create a list of profiles with their details
  oci_profiles_list = [
    for i in range(length(local.profile_indices)) :
    {
      name = element(local.profile_headers, local.profile_indices[i])[0],
      profile = {
        for line in compact(local.profiles[element(local.profile_headers, local.profile_indices[i])[0]]) :
        flatten(regexall("(\\w+)=(.+)$", line))[0] => flatten(regexall("(\\w+)=(.+)$", line))[1]
      }
    }
  ]

  # Determine the profile to use based on the OCI_CLI_PROFILE environment variable
  profile = data.env_variable.oci_cli_profile.value == "" ? local.oci_profiles_list[0].name : data.env_variable.oci_cli_profile.value

  # Filter the profile data to exclude certain keys
  oci_profile_data = {
    for k, v in local.oci_profiles[local.profile] :
    k => v if !contains(["fingerprint", "key_file", "passphrase"], k)
  }
}
