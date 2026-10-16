output "service_connector_id" {
  description = "OCID of the service connector."
  value       = oci_sch_service_connector.this.id
}

output "connector_state" {
  description = "The current lifecycle state of the service connector."
  value       = oci_sch_service_connector.this.state
}
