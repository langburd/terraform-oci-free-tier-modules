mock_provider "oci" {}

variables {
  compartment_id      = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  subnet_id           = "ocid1.subnet.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  availability_domain = "Uocm:PHX-AD-1"
  admin_password      = "WelcomePassword123#"
}

run "creates_mysql_with_defaults" {
  command = plan

  assert {
    condition     = oci_mysql_mysql_db_system.this.shape_name == "MySQL.Free"
    error_message = "shape_name should default to MySQL.Free"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.admin_username == "admin"
    error_message = "admin_username should default to admin"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.data_storage_size_in_gb == 50
    error_message = "data_storage_size_in_gb should default to 50"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.is_highly_available == false
    error_message = "is_highly_available should default to false"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.backup_policy[0].is_enabled == true
    error_message = "backup should be enabled by default"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.deletion_policy[0].is_delete_protected == true
    error_message = "deletion protection should be enabled"
  }
}

run "creates_mysql_with_backup_disabled" {
  command = plan

  variables {
    backup_is_enabled = false
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.backup_policy[0].is_enabled == false
    error_message = "backup should be disabled when backup_is_enabled is false"
  }
}

run "rejects_storage_above_50" {
  command = plan

  variables {
    data_storage_size_in_gb = 51
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

run "rejects_invalid_subnet_ocid" {
  command = plan

  variables {
    subnet_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.subnet_id,
  ]
}
