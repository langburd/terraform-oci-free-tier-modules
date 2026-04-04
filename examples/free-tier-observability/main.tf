locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

# Notifications topic for alarm destinations
resource "oci_ons_notification_topic" "alarms" {
  compartment_id = module.compartment.compartment_id
  name           = "observability-alarms"
  description    = "Notification topic for observability alarms"
}

module "monitoring" {
  source = "../../oci/monitoring"

  compartment_id        = module.compartment.compartment_id
  alarm_display_name    = "high-cpu-alarm"
  metric_compartment_id = module.compartment.compartment_id
  alarm_namespace       = "oci_computeagent"
  alarm_query           = "CpuUtilization[1m].mean() > 80"
  alarm_severity        = "WARNING"
  destinations          = [oci_ons_notification_topic.alarms.id]

  alarm_freeform_tags = {
    "example" = "free-tier-observability"
  }
}

module "logging" {
  source = "../../oci/logging"

  compartment_id         = module.compartment.compartment_id
  log_group_display_name = "observability-log-group"

  logs = {
    "custom-app-log" = {
      log_type           = "CUSTOM"
      retention_duration = 30
    }
  }

  logging_freeform_tags = {
    "example" = "free-tier-observability"
  }
}

module "apm" {
  source = "../../oci/apm"

  compartment_id   = module.compartment.compartment_id
  apm_display_name = "observability-apm"
  is_free_tier     = true

  apm_freeform_tags = {
    "example" = "free-tier-observability"
  }
}

module "connector_hub" {
  source = "../../oci/connector_hub"

  compartment_id         = module.compartment.compartment_id
  connector_display_name = "logs-to-notifications"
  connector_description  = "Forwards log group entries to the alarms notification topic"
  source_kind            = "logging"
  target_kind            = "notifications"

  source_log_sources = [
    {
      compartment_id = module.compartment.compartment_id
      log_group_id   = module.logging.log_group_id
    }
  ]

  target_topic_id = oci_ons_notification_topic.alarms.id

  connector_freeform_tags = {
    "example" = "free-tier-observability"
  }
}
