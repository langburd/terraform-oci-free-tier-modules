output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "notification_topic_id" {
  description = "OCID of the notifications topic for alarms."
  value       = oci_ons_notification_topic.alarms.id
}

output "alarm_id" {
  description = "OCID of the monitoring alarm."
  value       = module.monitoring.alarm_id
}

output "log_group_id" {
  description = "OCID of the log group."
  value       = module.logging.log_group_id
}

output "apm_domain_id" {
  description = "OCID of the APM domain."
  value       = module.apm.apm_domain_id
}

output "apm_data_upload_endpoint" {
  description = "APM data upload endpoint for agent configuration."
  value       = module.apm.data_upload_endpoint
}

output "service_connector_id" {
  description = "OCID of the service connector."
  value       = module.connector_hub.service_connector_id
}
