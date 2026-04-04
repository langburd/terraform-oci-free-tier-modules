resource "oci_sch_service_connector" "this" {
  compartment_id = var.compartment_id
  display_name   = var.connector_display_name
  description    = var.connector_description
  state          = var.connector_state
  defined_tags   = var.connector_defined_tags
  freeform_tags  = var.connector_freeform_tags

  source {
    kind = var.source_kind

    dynamic "log_sources" {
      for_each = var.source_kind == "logging" ? var.source_log_sources : []

      content {
        compartment_id = log_sources.value.compartment_id
        log_group_id   = log_sources.value.log_group_id
        log_id         = log_sources.value.log_id
      }
    }
  }

  target {
    kind      = var.target_kind
    bucket    = var.target_kind == "objectStorage" ? var.target_object_storage_bucket : null
    namespace = var.target_kind == "objectStorage" ? var.target_object_storage_namespace : null
    topic_id  = var.target_kind == "notifications" ? var.target_topic_id : null
  }
}
