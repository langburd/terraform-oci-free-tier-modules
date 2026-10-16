output "certificate_authority_id" {
  description = "OCID of the certificate authority."
  value       = oci_certificates_management_certificate_authority.this.id
}

output "certificate_id" {
  description = "OCID of the certificate. Returns null when create_certificate is false."
  value       = var.create_certificate ? oci_certificates_management_certificate.this[0].id : null
}
