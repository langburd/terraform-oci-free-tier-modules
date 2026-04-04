resource "oci_database_autonomous_database" "this" {
  compartment_id              = var.compartment_id
  db_name                     = var.db_name
  admin_password              = var.admin_password
  db_workload                 = var.db_workload
  is_free_tier                = var.is_free_tier
  compute_model               = var.compute_model
  compute_count               = var.compute_count
  data_storage_size_in_gb     = var.data_storage_size_in_gb
  db_version                  = var.db_version
  whitelisted_ips             = length(var.whitelisted_ips) > 0 ? var.whitelisted_ips : null
  is_mtls_connection_required = var.is_mtls_connection_required
  display_name                = var.display_name
  defined_tags                = var.autonomous_database_defined_tags
  freeform_tags               = var.autonomous_database_freeform_tags
}
