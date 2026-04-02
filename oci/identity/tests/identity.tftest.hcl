mock_provider "oci" {}

variables {
  oci_root_compartment = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_compartment_with_defaults" {
  command = plan

  assert {
    condition     = oci_identity_compartment.this.name == "My Compartment"
    error_message = "Compartment name should default to 'My Compartment'"
  }

  assert {
    condition     = oci_identity_compartment.this.enable_delete == true
    error_message = "enable_delete should default to true"
  }
}

run "creates_compartment_with_custom_name" {
  command = plan

  variables {
    compartment_name        = "Custom-Compartment"
    compartment_description = "A custom compartment"
  }

  assert {
    condition     = oci_identity_compartment.this.name == "Custom-Compartment"
    error_message = "Compartment name should match input"
  }

  assert {
    condition     = oci_identity_compartment.this.description == "A custom compartment"
    error_message = "Compartment description should match input"
  }
}

run "rejects_invalid_root_compartment_ocid" {
  command = plan

  variables {
    oci_root_compartment = "not-a-valid-ocid"
  }

  expect_failures = [
    var.oci_root_compartment,
  ]
}

run "rejects_empty_compartment_name" {
  command = plan

  variables {
    compartment_name = ""
  }

  expect_failures = [
    var.compartment_name,
  ]
}

run "rejects_too_long_compartment_name" {
  command = plan

  variables {
    compartment_name = "aaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeeaaaaaaaaaabbbbbbbbbbccccccccccddddddddddeeeeeeeeeef"
  }

  expect_failures = [
    var.compartment_name,
  ]
}
