mock_provider "oci" {}

variables {
  compartment_id        = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  alarm_display_name    = "test-alarm"
  metric_compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  alarm_namespace       = "oci_computeagent"
  alarm_query           = "CpuUtilization[1m].mean() > 80"
  destinations          = ["ocid1.onstopic.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
}

run "creates_alarm_with_defaults" {
  command = plan

  assert {
    condition     = oci_monitoring_alarm.this.severity == "WARNING"
    error_message = "Default alarm severity should be WARNING"
  }

  assert {
    condition     = oci_monitoring_alarm.this.is_enabled == true
    error_message = "Alarm should be enabled by default"
  }
}

run "creates_critical_alarm" {
  command = plan

  variables {
    alarm_severity = "CRITICAL"
  }

  assert {
    condition     = oci_monitoring_alarm.this.severity == "CRITICAL"
    error_message = "Alarm severity should be CRITICAL"
  }
}

run "creates_disabled_alarm" {
  command = plan

  variables {
    alarm_is_enabled = false
  }

  assert {
    condition     = oci_monitoring_alarm.this.is_enabled == false
    error_message = "Alarm should be disabled when alarm_is_enabled is false"
  }
}

run "rejects_invalid_severity" {
  command = plan

  variables {
    alarm_severity = "UNKNOWN"
  }

  expect_failures = [
    var.alarm_severity,
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
