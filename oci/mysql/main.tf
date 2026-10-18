# OCI MySQL HeatWave enforces TLS encryption for all client connections at the
# service level. There is no ssl_mode attribute in oci_mysql_mysql_db_system --
# TLS cannot be disabled via Terraform configuration.
# OCI MySQL HeatWave encrypts data at rest by default using Oracle-managed keys.
# Customer-managed key (CMK) encryption is not available for the Always Free tier
# and is not exposed as a variable in this module.
locals {
  is_free = var.shape_name == "MySQL.Free"
}

resource "oci_mysql_mysql_db_system" "this" {
  compartment_id      = var.compartment_id
  subnet_id           = var.subnet_id
  availability_domain = var.availability_domain
  shape_name          = var.shape_name
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  display_name        = var.mysql_display_name
  is_highly_available = var.is_highly_available
  nsg_ids             = var.nsg_ids
  hostname_label      = var.hostname_label
  defined_tags        = var.mysql_defined_tags
  freeform_tags       = var.mysql_freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }

  # Always Free (MySQL.Free) rejects a backup policy on create ("Cannot specify backup
  # policy ... for an Always Free DB system") and has fixed 50 GB storage with fixed
  # 1-day automatic backups, so neither is sent for that shape.
  data_storage_size_in_gb = local.is_free ? null : var.data_storage_size_in_gb

  dynamic "backup_policy" {
    for_each = local.is_free ? [] : [var.backup_is_enabled]
    content {
      is_enabled = backup_policy.value
    }
  }

  dynamic "maintenance" {
    for_each = var.maintenance_window_start_time == null ? [] : [var.maintenance_window_start_time]
    content {
      window_start_time = maintenance.value
    }
  }

  deletion_policy {
    is_delete_protected        = var.is_delete_protected
    final_backup               = var.final_backup
    automatic_backup_retention = var.automatic_backup_retention
  }
}
