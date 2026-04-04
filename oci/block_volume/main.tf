resource "oci_core_volume" "this" {
  compartment_id      = var.compartment_id
  availability_domain = var.availability_domain
  display_name        = var.volume_display_name
  size_in_gbs         = var.volume_size_in_gbs
  vpus_per_gb         = var.vpus_per_gb
  backup_policy_id    = var.backup_policy_id
  kms_key_id          = var.kms_key_id

  defined_tags  = var.volume_defined_tags
  freeform_tags = var.volume_freeform_tags
}

resource "oci_core_volume_attachment" "this" {
  count = var.instance_id != null ? 1 : 0

  attachment_type = var.attachment_type
  instance_id     = var.instance_id
  volume_id       = oci_core_volume.this.id
  is_read_only    = var.is_read_only
}
