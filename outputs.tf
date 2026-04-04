output "vault_id" {
  description = "OCID of the vault."
  value       = oci_kms_vault.this.id
}

output "vault_crypto_endpoint" {
  description = "Crypto endpoint of the vault for encryption/decryption operations."
  value       = oci_kms_vault.this.crypto_endpoint
}

output "vault_management_endpoint" {
  description = "Management endpoint of the vault for key management operations."
  value       = oci_kms_vault.this.management_endpoint
}

output "key_id" {
  description = "OCID of the KMS key. Returns null when create_key is false."
  value       = var.create_key ? oci_kms_key.this[0].id : null
}
