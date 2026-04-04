# OCI MySQL HeatWave enforces TLS encryption for all client connections at the
# service level. There is no ssl_mode attribute in oci_mysql_mysql_db_system --
# TLS cannot be disabled via Terraform configuration.
# OCI MySQL HeatWave encrypts data at rest by default using Oracle-managed keys.
# Customer-managed key (CMK) encryption is not available for the Always Free tier
# and is not exposed as a variable in this module.
resource "oci_mysql_mysql_db_system" "this" {
  compartment_id      = var.compartment_id
  subnet_id           = var.subnet_id
  availability_domain = var.availability_domain
  shape_name          = var.shape_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  display_name        = var.mysql_display_name
  is_highly_available = var.is_highly_available
  defined_tags        = var.mysql_defined_tags
  freeform_tags       = var.mysql_freeform_tags

  data_storage_size_in_gb = var.data_storage_size_in_gb

  backup_policy {
    is_enabled = var.backup_is_enabled
  }

  deletion_policy {
    is_delete_protected = true
  }
}
