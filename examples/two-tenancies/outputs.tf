output "compartment1_id" {
  description = "The OCID of the compartment for the first tenancy"
  value       = module.compartment1.compartment_id
}

output "compartment2_id" {
  description = "The OCID of the compartment for the second tenancy"
  value       = module.compartment2.compartment_id
}
