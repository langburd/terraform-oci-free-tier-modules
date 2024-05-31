
output "root_compartment_id" {
  description = "The OCID of the root compartment"
  value       = data.oci_identity_compartment.root_compartment.id
}
