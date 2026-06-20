output "email_domain_id" {
  description = "OCID of the email domain."
  value       = oci_email_email_domain.this.id
}

output "sender_id" {
  description = "OCID of the email sender."
  value       = oci_email_sender.this.id
}

output "dkim_id" {
  description = "OCID of the DKIM resource. Returns null when create_dkim is false."
  value       = var.create_dkim ? oci_email_dkim.this[0].id : null
}

output "dkim_cname_record_value" {
  description = "The DNS CNAME record value for DKIM verification. Returns null when create_dkim is false."
  value       = try(oci_email_dkim.this[0].cname_record_value, null)
}
