locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

module "vault" {
  source = "../../oci/vault"

  compartment_id      = module.compartment.compartment_id
  vault_display_name  = "free-tier-vault"
  key_display_name    = "free-tier-key"
  key_algorithm       = "AES"
  key_length          = 32
  key_protection_mode = "SOFTWARE"

  vault_freeform_tags = {
    "example" = "free-tier-security"
  }
}

module "certificates" {
  source = "../../oci/certificates"

  compartment_id = module.compartment.compartment_id
  kms_key_id     = module.vault.key_id
  ca_name        = "free-tier-root-ca"
  ca_common_name = "Free Tier Root CA"

  create_certificate      = true
  certificate_name        = "free-tier-tls-cert"
  certificate_common_name = var.certificate_common_name

  certificates_freeform_tags = {
    "example" = "free-tier-security"
  }
}
