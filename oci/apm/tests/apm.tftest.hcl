mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_apm_domain_with_defaults" {
  command = plan

  assert {
    condition     = oci_apm_apm_domain.this.is_free_tier == true
    error_message = "APM domain should default to free tier"
  }

  assert {
    condition     = oci_apm_apm_domain.this.display_name == "apm-domain"
    error_message = "Default APM display name should be apm-domain"
  }
}

run "creates_apm_domain_with_custom_name" {
  command = plan

  variables {
    apm_display_name = "my-custom-apm"
  }

  assert {
    condition     = oci_apm_apm_domain.this.display_name == "my-custom-apm"
    error_message = "APM display name should match the input"
  }
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
