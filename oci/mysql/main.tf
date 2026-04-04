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
