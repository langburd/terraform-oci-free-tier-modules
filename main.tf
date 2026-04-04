resource "oci_logging_log_group" "this" {
  compartment_id = var.compartment_id
  display_name   = var.log_group_display_name
  defined_tags   = var.logging_defined_tags
  freeform_tags  = var.logging_freeform_tags
}

resource "oci_logging_log" "this" {
  for_each = var.logs

  display_name       = each.key
  log_group_id       = oci_logging_log_group.this.id
  log_type           = each.value.log_type
  is_enabled         = each.value.is_enabled
  retention_duration = each.value.retention_duration
  defined_tags       = var.logging_defined_tags
  freeform_tags      = var.logging_freeform_tags

  dynamic "configuration" {
    for_each = each.value.log_type == "SERVICE" ? [1] : []

    content {
      source {
        category    = each.value.source_category
        resource    = each.value.source_resource
        service     = each.value.source_service
        source_type = "OCISERVICE"
      }
    }
  }
}
