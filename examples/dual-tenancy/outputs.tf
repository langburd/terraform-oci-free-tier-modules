output "compartment1_id" {
  description = "OCID of the compartment created in the first tenancy."
  value       = module.compartment1.compartment_id
}

output "compartment2_id" {
  description = "OCID of the compartment created in the second tenancy."
  value       = module.compartment2.compartment_id
}

output "budget1_id" {
  description = "OCID of the budget for the first tenancy."
  value       = module.budget1.budget_id
}

output "budget2_id" {
  description = "OCID of the budget for the second tenancy."
  value       = module.budget2.budget_id
}
