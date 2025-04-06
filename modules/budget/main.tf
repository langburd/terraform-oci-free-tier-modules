resource "oci_budget_budget" "this" {
  amount                                = var.budget_amount
  budget_processing_period_start_offset = var.budget_processing_period_start_offset
  compartment_id                        = var.budget_compartment_id
  defined_tags                          = var.budget_defined_tags
  description                           = var.budget_description
  display_name                          = var.budget_display_name
  freeform_tags                         = var.budget_freeform_tags
  processing_period_type                = var.budget_processing_period_type
  reset_period                          = var.budget_reset_period
  target_type                           = var.budget_target_type
  targets                               = var.budget_targets
}

resource "oci_budget_alert_rule" "this" {
  budget_id      = oci_budget_budget.this.id
  defined_tags   = var.alert_defined_tags
  description    = var.alert_description
  display_name   = var.alert_display_name
  freeform_tags  = var.alert_freeform_tags
  message        = var.alert_message
  recipients     = var.alert_recipients
  threshold      = var.alert_threshold
  threshold_type = var.alert_threshold_type
  type           = var.alert_type
}
