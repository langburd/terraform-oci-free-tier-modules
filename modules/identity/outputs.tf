
output "root_compartment_id" {
  description = "The OCID of the root compartment"
  value       = data.oci_identity_compartment.root_compartment.id
}

output "compartment_id" {
  description = "The OCID of the compartment"
  value       = oci_identity_compartment.this.id
}

output "compartment_name" {
  description = "The name of the compartment"
  value       = oci_identity_compartment.this.name
}

output "compartment_description" {
  description = "The description of the compartment"
  value       = oci_identity_compartment.this.description
}

output "compartment_freeform_tags" {
  description = "The freeform tags of the compartment"
  value       = oci_identity_compartment.this.freeform_tags
}

output "compartment_defined_tags" {
  description = "The defined tags of the compartment"
  value       = oci_identity_compartment.this.defined_tags
}
