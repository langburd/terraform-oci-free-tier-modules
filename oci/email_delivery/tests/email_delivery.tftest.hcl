mock_provider "oci" {}

variables {
  compartment_id       = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  email_domain_name    = "example.com"
  sender_email_address = "noreply@example.com"
}

run "creates_domain_sender_and_dkim_by_default" {
  command = plan

  assert {
    condition     = oci_email_email_domain.this.name == "example.com"
    error_message = "Email domain name should match input"
  }

  assert {
    condition     = oci_email_sender.this.email_address == "noreply@example.com"
    error_message = "Sender email address should match input"
  }

  assert {
    condition     = length(oci_email_dkim.this) == 1
    error_message = "DKIM resource should be created by default"
  }
}

run "skips_dkim_when_disabled" {
  command = plan

  variables {
    create_dkim = false
  }

  assert {
    condition     = length(oci_email_dkim.this) == 0
    error_message = "DKIM resource should not be created when create_dkim is false"
  }
}

run "rejects_invalid_email_address" {
  command = plan

  variables {
    sender_email_address = "not-an-email"
  }

  expect_failures = [
    var.sender_email_address,
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
