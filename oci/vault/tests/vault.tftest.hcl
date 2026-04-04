mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_vault_and_key_with_defaults" {
  command = plan

  assert {
    condition     = oci_kms_vault.this.display_name == "vault"
    error_message = "Vault display name should default to vault"
  }

  assert {
    condition     = oci_kms_vault.this.vault_type == "DEFAULT"
    error_message = "Vault type should default to DEFAULT for free tier"
  }

  assert {
    condition     = length(oci_kms_key.this) == 1
    error_message = "Key should be created by default"
  }

  assert {
    condition     = oci_kms_key.this[0].protection_mode == "SOFTWARE"
    error_message = "Key protection mode should default to SOFTWARE"
  }
}

run "skips_key_when_disabled" {
  command = plan

  variables {
    create_key = false
  }

  assert {
    condition     = length(oci_kms_key.this) == 0
    error_message = "Key should not be created when create_key is false"
  }
}

run "creates_key_with_hsm_protection" {
  command = plan

  variables {
    key_protection_mode = "HSM"
  }

  assert {
    condition     = oci_kms_key.this[0].protection_mode == "HSM"
    error_message = "Key protection mode should be HSM when specified"
  }
}

run "rejects_invalid_key_algorithm" {
  command = plan

  variables {
    key_algorithm = "INVALID"
  }

  expect_failures = [
    var.key_algorithm,
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

run "rejects_invalid_vault_type" {
  command = plan
  variables {
    vault_type = "INVALID_TYPE"
  }
  expect_failures = [var.vault_type]
}
