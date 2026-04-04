resource "oci_kms_vault" "this" {
  compartment_id = var.compartment_id
  display_name   = var.vault_display_name
  vault_type     = var.vault_type
  defined_tags   = var.vault_defined_tags
  freeform_tags  = var.vault_freeform_tags
}

resource "oci_kms_key" "this" {
  count = var.create_key ? 1 : 0

  compartment_id      = var.compartment_id
  display_name        = var.key_display_name
  management_endpoint = oci_kms_vault.this.management_endpoint
  defined_tags        = var.vault_defined_tags
  freeform_tags       = var.vault_freeform_tags

  key_shape {
    algorithm = var.key_algorithm
    length    = var.key_length
  }

  protection_mode = var.key_protection_mode
}
