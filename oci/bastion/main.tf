resource "oci_bastion_bastion" "this" {
  bastion_type                 = var.bastion_type
  compartment_id               = var.compartment_id
  name                         = var.bastion_name
  target_subnet_id             = var.target_subnet_id
  client_cidr_block_allow_list = var.client_cidr_block_allow_list
  max_session_ttl_in_seconds   = var.max_session_ttl_in_seconds
  defined_tags                 = var.bastion_defined_tags
  freeform_tags                = var.bastion_freeform_tags
}
