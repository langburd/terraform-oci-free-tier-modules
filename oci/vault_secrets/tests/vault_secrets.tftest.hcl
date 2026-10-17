mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  vault_id       = "ocid1.vault.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  key_id         = "ocid1.key.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  secrets = {
    app-password = {
      content     = "s3cret"
      description = "App password."
    }
    app-token = {
      content = "t0ken"
    }
  }
}

run "creates_one_secret_per_entry" {
  command = plan

  assert {
    condition     = length(oci_vault_secret.this) == 2
    error_message = "one secret per map entry"
  }

  assert {
    condition     = oci_vault_secret.this["app-password"].secret_name == "app-password"
    error_message = "secret_name should be the map key"
  }

  assert {
    condition     = one(oci_vault_secret.this["app-password"].secret_content).content == base64encode("s3cret")
    error_message = "content should be base64-encoded"
  }

  assert {
    condition     = one(oci_vault_secret.this["app-password"].secret_content).content_type == "BASE64"
    error_message = "content_type should be BASE64"
  }

  assert {
    condition     = oci_vault_secret.this["app-password"].description == "App password."
    error_message = "description should be passed through"
  }

  assert {
    condition     = oci_vault_secret.this["app-token"].vault_id == var.vault_id && oci_vault_secret.this["app-token"].key_id == var.key_id
    error_message = "secrets should use the given vault and key"
  }
}

run "rejects_invalid_secret_name" {
  command = plan

  variables {
    secrets = {
      "bad name" = {
        content = "x"
      }
    }
  }

  expect_failures = [
    var.secrets,
  ]
}

run "rejects_invalid_vault_ocid" {
  command = plan

  variables {
    vault_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.vault_id,
  ]
}
