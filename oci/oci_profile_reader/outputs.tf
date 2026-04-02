output "oci_profile_data" {
  description = "The data from the OCI profile (sensitive fields like key_file and fingerprint are excluded)"
  value = {
    for k, v in local.oci_profiles[var.profile_name] :
    k => v if !contains(["fingerprint", "key_file", "passphrase"], k)
  }

  precondition {
    condition     = contains(keys(local.oci_profiles), var.profile_name)
    error_message = "Profile '${var.profile_name}' not found in ~/.oci/config. Available profiles: ${join(", ", keys(local.oci_profiles))}"
  }
}
