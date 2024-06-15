output "root_compartment_id" {
  description = "The OCID of the root compartment"
  value       = module.compartment.root_compartment_id
}

output "oci_profile_data" {
  description = "The OCI profile data"
  value       = local.oci_profile_data
}
