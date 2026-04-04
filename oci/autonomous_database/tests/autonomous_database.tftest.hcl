mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  db_name        = "mydb"
  admin_password = "WelcomePassword123#"
}

run "creates_autonomous_database_with_defaults" {
  command = plan

  assert {
    condition     = oci_database_autonomous_database.this.db_workload == "OLTP"
    error_message = "db_workload should default to OLTP"
  }

  assert {
    condition     = oci_database_autonomous_database.this.is_free_tier == true
    error_message = "is_free_tier should default to true"
  }

  assert {
    condition     = oci_database_autonomous_database.this.compute_model == "ECPU"
    error_message = "compute_model should default to ECPU"
  }

  assert {
    condition     = oci_database_autonomous_database.this.data_storage_size_in_gb == 20
    error_message = "data_storage_size_in_gb should default to 20"
  }

  assert {
    condition     = oci_database_autonomous_database.this.is_mtls_connection_required == false
    error_message = "is_mtls_connection_required should default to false"
  }
}

run "creates_dw_workload" {
  command = plan

  variables {
    db_workload = "DW"
  }

  assert {
    condition     = oci_database_autonomous_database.this.db_workload == "DW"
    error_message = "db_workload should be DW"
  }
}

run "rejects_db_name_too_long" {
  command = plan

  variables {
    db_name = "toolongdbname123"
  }

  expect_failures = [
    var.db_name,
  ]
}

run "rejects_db_name_non_alphanumeric" {
  command = plan

  variables {
    db_name = "my-db"
  }

  expect_failures = [
    var.db_name,
  ]
}

run "rejects_db_name_starting_with_number" {
  command = plan

  variables {
    db_name = "1mydb"
  }

  expect_failures = [
    var.db_name,
  ]
}

run "rejects_data_storage_above_20" {
  command = plan

  variables {
    data_storage_size_in_gb = 21
  }

  expect_failures = [
    var.data_storage_size_in_gb,
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

run "rejects_invalid_db_workload" {
  command = plan

  variables {
    db_workload = "INVALID"
  }

  expect_failures = [
    var.db_workload,
  ]
}

run "rejects_invalid_compute_model" {
  command = plan
  variables {
    compute_model = "INVALID"
  }
  expect_failures = [var.compute_model]
}
