output "compartment_defined_tags" {
  description = "The defined tags of the compartment"
  value       = local.compartment_defined_tags
}

output "compartment_description" {
  description = "The description of the compartment"
  value       = local.compartment_description
}

output "compartment_freeform_tags" {
  description = "The freeform tags of the compartment"
  value       = local.compartment_freeform_tags
}

output "compartment_id" {
  description = "The OCID of the compartment"
  value       = local.compartment_id
}

output "compartment_name" {
  description = "The name of the compartment"
  value       = local.compartment_name
}

output "root_compartment_id" {
  description = "The OCID of the root compartment"
  value       = var.oci_root_compartment
}
