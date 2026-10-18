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
    condition     = length(oci_mysql_mysql_db_system.this.backup_policy) == 0
    error_message = "MySQL.Free must not send a backup_policy block (the API rejects it for Always Free)"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.is_highly_available == false
    error_message = "is_highly_available should default to false"
  }


  assert {
    condition     = oci_mysql_mysql_db_system.this.deletion_policy[0].is_delete_protected == true
    error_message = "deletion protection should be enabled"
  }
}

run "paid_shape_sends_storage_and_backup_policy" {
  command = plan

  variables {
    shape_name = "MySQL.2"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.data_storage_size_in_gb == 50
    error_message = "data_storage_size_in_gb should default to 50 on paid shapes"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.backup_policy[0].is_enabled == true
    error_message = "backup should be enabled by default on paid shapes"
  }
}

run "creates_mysql_with_backup_disabled" {
  command = plan

  variables {
    shape_name        = "MySQL.2"
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

run "rejects_highly_available" {
  command = plan
  variables {
    is_highly_available = true
  }
  expect_failures = [var.is_highly_available]
}

run "rejects_weak_admin_password" {
  command = plan

  variables {
    admin_password = "weakpass"
  }

  expect_failures = [
    var.admin_password,
  ]
}

run "maintenance_block_omitted_by_default" {
  command = plan

  assert {
    condition     = length(oci_mysql_mysql_db_system.this.maintenance) == 0
    error_message = "maintenance block should be omitted by default"
  }
}

run "creates_mysql_with_network_maintenance_and_deletion_settings" {
  command = plan

  variables {
    nsg_ids                       = ["ocid1.networksecuritygroup.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
    hostname_label                = "vaultwarden-mysql"
    maintenance_window_start_time = "sun 02:00"
    is_delete_protected           = true
    final_backup                  = "REQUIRE_FINAL_BACKUP"
    automatic_backup_retention    = "RETAIN"
  }

  assert {
    condition     = contains(oci_mysql_mysql_db_system.this.nsg_ids, "ocid1.networksecuritygroup.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
    error_message = "nsg_ids should be passed through"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.hostname_label == "vaultwarden-mysql"
    error_message = "hostname_label should be passed through"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.maintenance[0].window_start_time == "sun 02:00"
    error_message = "maintenance window_start_time should be passed through"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.deletion_policy[0].final_backup == "REQUIRE_FINAL_BACKUP"
    error_message = "final_backup should be passed through"
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.deletion_policy[0].automatic_backup_retention == "RETAIN"
    error_message = "automatic_backup_retention should be passed through"
  }
}

run "allows_disabling_delete_protection" {
  command = plan

  variables {
    is_delete_protected = false
  }

  assert {
    condition     = oci_mysql_mysql_db_system.this.deletion_policy[0].is_delete_protected == false
    error_message = "is_delete_protected should be configurable"
  }
}

run "rejects_invalid_nsg_ocid" {
  command = plan

  variables {
    nsg_ids = ["not-a-valid-ocid"]
  }

  expect_failures = [
    var.nsg_ids,
  ]
}

run "rejects_invalid_hostname_label" {
  command = plan

  variables {
    hostname_label = "1-starts-with-digit"
  }

  expect_failures = [
    var.hostname_label,
  ]
}

run "rejects_invalid_maintenance_window" {
  command = plan

  variables {
    maintenance_window_start_time = "sunday 2am"
  }

  expect_failures = [
    var.maintenance_window_start_time,
  ]
}

run "rejects_invalid_final_backup" {
  command = plan

  variables {
    final_backup = "ALWAYS"
  }

  expect_failures = [
    var.final_backup,
  ]
}

run "rejects_invalid_automatic_backup_retention" {
  command = plan

  variables {
    automatic_backup_retention = "KEEP"
  }

  expect_failures = [
    var.automatic_backup_retention,
  ]
}
