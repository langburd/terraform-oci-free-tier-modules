mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  table_name     = "my_table"
  ddl_statement  = "CREATE TABLE my_table (id INTEGER, name STRING, PRIMARY KEY(id))"
}

run "creates_table_with_defaults" {
  command = plan

  assert {
    condition     = oci_nosql_table.this.name == "my_table"
    error_message = "Table name should be my_table"
  }

  assert {
    condition     = oci_nosql_table.this.table_limits[0].max_read_units == 50
    error_message = "max_read_units should default to 50"
  }

  assert {
    condition     = oci_nosql_table.this.table_limits[0].max_write_units == 50
    error_message = "max_write_units should default to 50"
  }

  assert {
    condition     = oci_nosql_table.this.table_limits[0].max_storage_in_gbs == 25
    error_message = "max_storage_in_gbs should default to 25"
  }

  assert {
    condition     = length(oci_nosql_index.this) == 0
    error_message = "No indexes should be created by default"
  }
}

run "creates_table_with_indexes" {
  command = plan

  variables {
    indexes = {
      name_idx = {
        keys = [
          { column_name = "name" }
        ]
      }
    }
  }

  assert {
    condition     = length(oci_nosql_index.this) == 1
    error_message = "One index should be created"
  }
}

run "rejects_storage_above_25" {
  command = plan

  variables {
    table_limits_max_storage_in_gbs = 26
  }

  expect_failures = [
    var.table_limits_max_storage_in_gbs,
  ]
}

run "rejects_read_units_above_50" {
  command = plan

  variables {
    table_limits_max_read_units = 51
  }

  expect_failures = [
    var.table_limits_max_read_units,
  ]
}

run "rejects_invalid_compartment_ocid" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.compartment_id,
  ]
}

run "rejects_invalid_table_name" {
  command = plan

  variables {
    table_name = "my-table"
  }

  expect_failures = [
    var.table_name,
  ]
}
