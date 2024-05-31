output "oci_profile_data" {
  description = "The data from the OCI profile"
  value       = local.oci_profiles[var.profile_name]
}
