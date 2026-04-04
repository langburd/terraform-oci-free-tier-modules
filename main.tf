locals {
  # Read the file and split it into lines
  config_lines = split("\n", file(pathexpand("~/.oci/config")))

  # Filter out commented and empty lines, strip whitespace (including \r from Windows line endings)
  non_commented_lines = [
    for line in local.config_lines : trimspace(line)
    if trimspace(line) != "" && !startswith(trimspace(line), "#")
  ]

  # Extract profile headers from the lines
  profile_headers = [
    for line in local.non_commented_lines :
    flatten(regexall("\\[([\\w]+)\\]", line))
  ]

  # Get indices of profile headers
  profile_indices = compact([
    for i in range(length(local.profile_headers)) :
    length(local.profile_headers[i]) > 0 ? i : ""
  ])

  # Map profile names to their corresponding lines
  profiles = {
    for i in range(length(local.profile_indices)) :
    element(local.profile_headers, local.profile_indices[i])[0] => slice(
      local.non_commented_lines,
      local.profile_indices[i] + 1,
      length(local.profile_indices) > i + 1 ? local.profile_indices[i + 1] : length(local.non_commented_lines)
    )
  }

  # Construct the OCI profiles from the lines
  oci_profiles = {
    for profile_name, profile_lines in local.profiles :
    profile_name => {
      for line in [for l in profile_lines : l if can(regex("^\\w+\\s*=", l))] :
      trimspace(flatten(regexall("^(\\w+)\\s*=\\s*(.+)$", line))[0]) =>
      trimspace(flatten(regexall("^(\\w+)\\s*=\\s*(.+)$", line))[1])
    }
  }
}
