output "secret_ids" {
  description = "Map of secret name to secret OCID."
  value       = { for name, s in oci_vault_secret.this : name => s.id }
}
