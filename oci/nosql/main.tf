resource "oci_nosql_table" "this" {
  compartment_id = var.compartment_id
  name           = var.table_name
  ddl_statement  = var.ddl_statement
  defined_tags   = var.nosql_defined_tags
  freeform_tags  = var.nosql_freeform_tags

  table_limits {
    max_read_units     = var.table_limits_max_read_units
    max_write_units    = var.table_limits_max_write_units
    max_storage_in_gbs = var.table_limits_max_storage_in_gbs
  }
}

resource "oci_nosql_index" "this" {
  for_each = var.indexes

  name             = each.key
  table_name_or_id = oci_nosql_table.this.id
  compartment_id   = var.compartment_id

  dynamic "keys" {
    for_each = each.value.keys
    content {
      column_name     = keys.value.column_name
      json_field_type = keys.value.json_field_type
    }
  }
}
