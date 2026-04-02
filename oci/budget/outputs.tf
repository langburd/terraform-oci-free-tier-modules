output "alert_rule_id" {
  description = "OCID of the budget alert rule. Returns null when create_alert_rule is false."
  value       = var.create_alert_rule ? oci_budget_alert_rule.this[0].id : null
}

output "budget_id" {
  description = "OCID of the budget resource."
  value       = oci_budget_budget.this.id
}
