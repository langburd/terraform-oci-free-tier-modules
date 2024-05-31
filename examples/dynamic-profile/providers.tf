terraform {
  required_version = ">= 1.0.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.44.0"
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
  cflines           = split("\n", file(pathexpand("~/.oci/config")))
  ocipf             = [for line in local.cflines : flatten(regexall("\\[([\\w]+)\\]", line))]
  ociln             = compact([for i in range(length(local.ocipf)) : length(local.ocipf[i]) > 0 ? i : ""])
  ociln2            = concat(slice(local.ociln, 1, length(local.ociln)), [length(local.cflines)])
  ocilns            = { for i in range(length(local.ociln)) : element(local.ocipf, local.ociln[i])[0] => slice(local.cflines, local.ociln[i] + 1, local.ociln2[i] - 1) }
  oci_profiles      = { for k, v in local.ocilns : k => { for line in compact(v) : flatten(regexall("(\\w+)=(.+)$", line))[0] => flatten(regexall("(\\w+)=(.+)$", line))[1] } }
  oci_profiles_list = [for i in range(length(local.ociln)) : { name = element(local.ocipf, local.ociln[i])[0], profile = { for line in compact(local.ocilns[element(local.ocipf, local.ociln[i])[0]]) : flatten(regexall("(\\w+)=(.+)$", line))[0] => flatten(regexall("(\\w+)=(.+)$", line))[1] } }]
  profile           = data.env_variable.oci_cli_profile.value == "" ? local.oci_profiles_list[0].name : data.env_variable.oci_cli_profile.value
  oci_profile_data  = { for k, v in local.oci_profiles[local.profile] : k => v if !contains(["fingerprint", "key_file", "passphrase"], k) }
}
