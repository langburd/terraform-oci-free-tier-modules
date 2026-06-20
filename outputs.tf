output "apm_domain_id" {
  description = "OCID of the APM domain."
  value       = oci_apm_apm_domain.this.id
}

output "data_upload_endpoint" {
  description = "The endpoint where APM agents send data."
  value       = oci_apm_apm_domain.this.data_upload_endpoint
}
