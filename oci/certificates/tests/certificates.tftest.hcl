mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  kms_key_id     = "ocid1.key.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  ca_name        = "test-root-ca"
  ca_common_name = "Test Root CA"
}

run "creates_ca_only_by_default" {
  command = plan

  assert {
    condition     = oci_certificates_management_certificate_authority.this.name == "test-root-ca"
    error_message = "CA name should match the provided ca_name"
  }

  assert {
    condition     = oci_certificates_management_certificate_authority.this.certificate_authority_config[0].config_type == "ROOT_CA_GENERATED_INTERNALLY"
    error_message = "CA config type should default to ROOT_CA_GENERATED_INTERNALLY"
  }

  assert {
    condition     = length(oci_certificates_management_certificate.this) == 0
    error_message = "No certificate should be created by default"
  }
}

run "creates_certificate_when_enabled" {
  command = plan

  variables {
    create_certificate      = true
    certificate_name        = "test-cert"
    certificate_common_name = "test.example.com"
  }

  assert {
    condition     = length(oci_certificates_management_certificate.this) == 1
    error_message = "One certificate should be created when create_certificate is true"
  }
}

run "rejects_invalid_kms_key_id" {
  command = plan

  variables {
    kms_key_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.kms_key_id,
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

run "rejects_invalid_ca_config_type" {
  command = plan
  variables {
    ca_config_type = "INVALID"
  }
  expect_failures = [var.ca_config_type]
}

run "rejects_invalid_certificate_config_type" {
  command = plan
  variables {
    certificate_config_type = "INVALID"
  }
  expect_failures = [var.certificate_config_type]
}

run "rejects_certificate_without_common_name" {
  command = plan
  variables {
    create_certificate      = true
    certificate_common_name = null
  }
  expect_failures = [var.certificate_common_name]
}
