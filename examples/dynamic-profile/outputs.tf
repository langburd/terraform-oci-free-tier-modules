output "compartment_id" {
  description = "The OCID of the compartment"
  value       = module.compartment.compartment_id
}

output "oci_profile_data" {
  description = "The OCI profile data"
  value       = local.oci_profile_data
}
