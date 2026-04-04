mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_log_group_with_defaults" {
  command = plan

  assert {
    condition     = oci_logging_log_group.this.display_name == "log-group"
    error_message = "Default log group display name should be log-group"
  }

  assert {
    condition     = length(oci_logging_log.this) == 0
    error_message = "No logs should be created by default"
  }
}

run "creates_custom_log" {
  command = plan

  variables {
    logs = {
      "my-custom-log" = {
        log_type = "CUSTOM"
      }
    }
  }

  assert {
    condition     = length(oci_logging_log.this) == 1
    error_message = "One log should be created"
  }

  assert {
    condition     = oci_logging_log.this["my-custom-log"].log_type == "CUSTOM"
    error_message = "Log type should be CUSTOM"
  }
}

run "creates_service_log" {
  command = plan

  variables {
    logs = {
      "compute-service-log" = {
        log_type        = "SERVICE"
        source_service  = "compute"
        source_resource = "ocid1.instance.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        source_category = "console_connection"
      }
    }
  }

  assert {
    condition     = length(oci_logging_log.this) == 1
    error_message = "One service log should be created"
  }

  assert {
    condition     = oci_logging_log.this["compute-service-log"].log_type == "SERVICE"
    error_message = "Log type should be SERVICE"
  }
}

run "rejects_invalid_retention_non_multiple_of_30" {
  command = plan

  variables {
    logs = {
      "bad-retention-log" = {
        log_type           = "CUSTOM"
        retention_duration = 45
      }
    }
  }

  expect_failures = [
    var.logs,
  ]
}

run "rejects_invalid_retention_above_max" {
  command = plan

  variables {
    logs = {
      "bad-retention-log" = {
        log_type           = "CUSTOM"
        retention_duration = 210
      }
    }
  }

  expect_failures = [
    var.logs,
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
