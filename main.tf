resource "oci_monitoring_alarm" "this" {
  compartment_id        = var.compartment_id
  display_name          = var.alarm_display_name
  metric_compartment_id = var.metric_compartment_id
  namespace             = var.alarm_namespace
  query                 = var.alarm_query
  severity              = var.alarm_severity
  is_enabled            = var.alarm_is_enabled
  destinations          = var.destinations
  body                  = var.alarm_body
  defined_tags          = var.alarm_defined_tags
  freeform_tags         = var.alarm_freeform_tags
}
