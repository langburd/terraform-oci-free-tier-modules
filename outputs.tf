output "alarm_id" {
  description = "OCID of the monitoring alarm."
  value       = oci_monitoring_alarm.this.id
}

output "alarm_state" {
  description = "The current lifecycle state of the alarm."
  value       = oci_monitoring_alarm.this.state
}
