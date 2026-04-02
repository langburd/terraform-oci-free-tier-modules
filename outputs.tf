output "alert_rule_id" {
  description = "OCID of the budget alert rule."
  value       = oci_budget_alert_rule.this.id
}

output "budget_id" {
  description = "OCID of the budget resource."
  value       = oci_budget_budget.this.id
}
