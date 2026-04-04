output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "vault_id" {
  description = "OCID of the vault."
  value       = module.vault.vault_id
}

output "vault_crypto_endpoint" {
  description = "Crypto endpoint of the vault."
  value       = module.vault.vault_crypto_endpoint
}

output "vault_management_endpoint" {
  description = "Management endpoint of the vault."
  value       = module.vault.vault_management_endpoint
}

output "key_id" {
  description = "OCID of the KMS key."
  value       = module.vault.key_id
}

output "certificate_authority_id" {
  description = "OCID of the certificate authority."
  value       = module.certificates.certificate_authority_id
}

output "certificate_id" {
  description = "OCID of the TLS certificate."
  value       = module.certificates.certificate_id
}
