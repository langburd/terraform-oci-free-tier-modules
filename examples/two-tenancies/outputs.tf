output "root_compartment1_id" {
  description = "The OCID of the root compartment for the first tenancy"
  value       = module.compartment1.root_compartment_id
}

output "root_compartment2_id" {
  description = "The OCID of the root compartment for the second tenancy"
  value       = module.compartment2.root_compartment_id
}
