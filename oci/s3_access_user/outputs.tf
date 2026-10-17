output "user_id" {
  description = "OCID of the IAM user."
  value       = oci_identity_user.this.id
}

output "group_id" {
  description = "OCID of the IAM group."
  value       = oci_identity_group.this.id
}

output "access_key_id" {
  description = "S3-compatible access key ID."
  value       = oci_identity_customer_secret_key.this.id
}

output "secret_access_key" {
  description = "S3-compatible secret access key. Only available at creation time."
  value       = oci_identity_customer_secret_key.this.key
  sensitive   = true
}
