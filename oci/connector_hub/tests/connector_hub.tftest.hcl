mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  source_kind    = "logging"
  target_kind    = "objectStorage"

  source_log_sources = [
    {
      compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
  ]

  target_object_storage_bucket    = "my-logs-bucket"
  target_object_storage_namespace = "my-namespace"
}

run "creates_logging_to_object_storage_connector" {
  command = plan

  assert {
    condition     = oci_sch_service_connector.this.display_name == "service-connector"
    error_message = "Default display name should be service-connector"
  }

  assert {
    condition     = oci_sch_service_connector.this.state == "ACTIVE"
    error_message = "Connector should be ACTIVE by default"
  }
}

run "creates_logging_to_notifications_connector" {
  command = plan

  variables {
    target_kind     = "notifications"
    target_topic_id = "ocid1.onstopic.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = oci_sch_service_connector.this.target[0].kind == "notifications"
    error_message = "Target kind should be notifications"
  }
}

run "rejects_invalid_source_kind" {
  command = plan

  variables {
    source_kind = "invalid"
  }

  expect_failures = [
    var.source_kind,
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
