# OCI MySQL HeatWave enforces TLS encryption for all client connections at the
# service level. There is no ssl_mode attribute in oci_mysql_mysql_db_system --
# TLS cannot be disabled via Terraform configuration.
# OCI MySQL HeatWave encrypts data at rest by default using Oracle-managed keys.
# Customer-managed key (CMK) encryption is not available for the Always Free tier
# and is not exposed as a variable in this module.
locals {
  is_free                    = var.shape_name == "MySQL.Free"
  network_compartment_id     = coalesce(var.network_compartment_id, var.compartment_id)
  certificate_compartment_id = coalesce(var.certificate_compartment_id, var.compartment_id)
  rp_condition               = "where all {request.principal.type = 'mysqldbsystem', request.resource.compartment.id = '${var.compartment_id}'}"
}

# With NSGs, the DB system itself (resource principal type mysqldbsystem) creates its
# VNIC and adds it to the NSGs. Without this grant creation fails with
# CreateInternalVnic 404 / AuthorizationFailed and the DB system ends up FAILED, even
# when the caller is a tenancy administrator. Statements from the MySQL HeatWave
# "Mandatory Policies" page.
resource "oci_identity_policy" "nsg" {
  count = length(var.nsg_ids) > 0 ? 1 : 0

  compartment_id = local.network_compartment_id
  name           = "${var.mysql_display_name}-nsg-access"
  description    = "Let MySQL DB systems in the DB compartment create VNICs and join NSGs."
  defined_tags   = var.mysql_defined_tags
  freeform_tags  = var.mysql_freeform_tags

  statements = [
    "Allow any-user to {NETWORK_SECURITY_GROUP_UPDATE_MEMBERS} in compartment id ${local.network_compartment_id} ${local.rp_condition}",
    "Allow any-user to {VNIC_CREATE, VNIC_UPDATE, VNIC_ASSOCIATE_NETWORK_SECURITY_GROUP, VNIC_DISASSOCIATE_NETWORK_SECURITY_GROUP} in compartment id ${local.network_compartment_id} ${local.rp_condition}",
  ]

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# With BYOC the DB system reads its leaf certificate (and chain) from OCI Certificates
# as the mysqldbsystem resource principal.
# count keys off the static generation type: certificate_id is apply-time for callers.
resource "oci_identity_policy" "certificates" {
  count = var.certificate_generation_type == "BYOC" ? 1 : 0

  compartment_id = local.certificate_compartment_id
  name           = "${var.mysql_display_name}-certificate-access"
  description    = "Let MySQL DB systems in the DB compartment read their BYOC leaf certificate."
  defined_tags   = var.mysql_defined_tags
  freeform_tags  = var.mysql_freeform_tags

  statements = [
    "Allow any-user to read leaf-certificate-family in compartment id ${local.certificate_compartment_id} ${local.rp_condition}",
  ]

  lifecycle {
    ignore_changes = [defined_tags]
  }
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

  depends_on = [oci_identity_policy.nsg, oci_identity_policy.certificates]

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

  # Only sent for BYOC so the SYSTEM default leaves existing DB systems untouched.
  dynamic "secure_connections" {
    for_each = var.certificate_generation_type == "BYOC" ? [var.certificate_id] : []
    content {
      certificate_generation_type = var.certificate_generation_type
      certificate_id              = secure_connections.value
    }
  }

  deletion_policy {
    is_delete_protected        = var.is_delete_protected
    final_backup               = var.final_backup
    automatic_backup_retention = var.automatic_backup_retention
  }
}
