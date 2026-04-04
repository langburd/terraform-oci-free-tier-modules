mock_provider "oci" {}

variables {
  compartment_id   = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  bastion_name     = "MyBastion"
  target_subnet_id = "ocid1.subnet.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_bastion_with_defaults" {
  command = plan

  assert {
    condition     = oci_bastion_bastion.this.bastion_type == "STANDARD"
    error_message = "Bastion type should default to STANDARD"
  }

  assert {
    condition     = oci_bastion_bastion.this.max_session_ttl_in_seconds == 10800
    error_message = "Max session TTL should default to 10800"
  }

  assert {
    condition     = oci_bastion_bastion.this.name == "MyBastion"
    error_message = "Bastion name should match the provided bastion_name"
  }
}

run "creates_bastion_with_custom_ttl" {
  command = plan

  variables {
    max_session_ttl_in_seconds = 3600
  }

  assert {
    condition     = oci_bastion_bastion.this.max_session_ttl_in_seconds == 3600
    error_message = "Max session TTL should be the custom value"
  }
}

run "rejects_ttl_below_minimum" {
  command = plan

  variables {
    max_session_ttl_in_seconds = 1799
  }

  expect_failures = [
    var.max_session_ttl_in_seconds,
  ]
}

run "rejects_ttl_above_maximum" {
  command = plan

  variables {
    max_session_ttl_in_seconds = 10801
  }

  expect_failures = [
    var.max_session_ttl_in_seconds,
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
