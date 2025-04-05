
output "root_compartment_id" {
  description = "The OCID of the root compartment"
  value       = var.oci_root_compartment
}

output "compartment_id" {
  description = "The OCID of the compartment"
  value       = try(data.oci_identity_compartments.all_compartments.compartments[0].id, oci_identity_compartment.this[0].id)
}

output "compartment_name" {
  description = "The name of the compartment"
  value       = try(data.oci_identity_compartments.all_compartments.compartments[0].name, oci_identity_compartment.this[0].name)
}

output "compartment_description" {
  description = "The description of the compartment"
  value       = try(data.oci_identity_compartments.all_compartments.compartments[0].description, oci_identity_compartment.this[0].description)
}

output "compartment_freeform_tags" {
  description = "The freeform tags of the compartment"
  value       = try(data.oci_identity_compartments.all_compartments.compartments[0].freeform_tags, oci_identity_compartment.this[0].freeform_tags)
}

output "compartment_defined_tags" {
  description = "The defined tags of the compartment"
  value       = try(data.oci_identity_compartments.all_compartments.compartments[0].defined_tags, oci_identity_compartment.this[0].defined_tags)
}
