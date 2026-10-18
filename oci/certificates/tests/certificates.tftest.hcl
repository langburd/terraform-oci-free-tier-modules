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

run "no_kms_policy_or_rules_by_default" {
  command = plan
  variables {
    create_certificate      = true
    certificate_common_name = "test.example.com"
  }

  assert {
    condition     = length(oci_identity_policy.kms) == 0
    error_message = "No KMS policy should be created by default"
  }

  assert {
    condition     = length(oci_certificates_management_certificate.this[0].certificate_rules) == 0
    error_message = "No renewal rule should be set by default"
  }

  assert {
    condition     = length(oci_certificates_management_certificate.this[0].certificate_config[0].subject_alternative_names) == 0
    error_message = "No SANs should be set by default"
  }
}

run "sans_and_renewal_rule_reach_certificate" {
  command = plan
  variables {
    create_certificate      = true
    certificate_common_name = "db.example.com"
    certificate_subject_alternative_names = [
      { type = "DNS", value = "db.example.com" },
      { type = "IP", value = "10.0.0.5" },
    ]
    certificate_renewal_rule = {
      renewal_interval       = "P365D"
      advance_renewal_period = "P30D"
    }
  }

  assert {
    condition     = length(oci_certificates_management_certificate.this[0].certificate_config[0].subject_alternative_names) == 2
    error_message = "Both SANs should reach the certificate"
  }

  assert {
    condition     = one([for s in oci_certificates_management_certificate.this[0].certificate_config[0].subject_alternative_names : s.value if s.type == "DNS"]) == "db.example.com"
    error_message = "DNS SAN value should be passed through"
  }

  assert {
    condition     = oci_certificates_management_certificate.this[0].certificate_rules[0].rule_type == "CERTIFICATE_RENEWAL_RULE"
    error_message = "Renewal rule type should be CERTIFICATE_RENEWAL_RULE"
  }

  assert {
    condition     = oci_certificates_management_certificate.this[0].certificate_rules[0].renewal_interval == "P365D" && oci_certificates_management_certificate.this[0].certificate_rules[0].advance_renewal_period == "P30D"
    error_message = "Renewal interval and advance period should be passed through"
  }
}

run "creates_kms_policy_when_enabled" {
  command = plan
  variables {
    create_kms_policy = true
  }

  assert {
    condition     = length(oci_identity_policy.kms) == 1
    error_message = "One KMS policy should be created when create_kms_policy is true"
  }

  assert {
    condition     = oci_identity_policy.kms[0].statements == tolist(["Allow any-user to use keys in compartment id ${var.compartment_id} where all {request.principal.type = 'certificateauthority', target.key.id = '${var.kms_key_id}'}"])
    error_message = "Policy should restrict to the CA principal and the specific key"
  }

  assert {
    condition     = oci_identity_policy.kms[0].compartment_id == var.compartment_id
    error_message = "Policy defaults to compartment_id"
  }
}

run "kms_policy_in_separate_kms_compartment" {
  command = plan
  variables {
    create_kms_policy  = true
    kms_compartment_id = "ocid1.compartment.oc1..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
  }

  assert {
    condition     = oci_identity_policy.kms[0].compartment_id == "ocid1.compartment.oc1..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    error_message = "Policy should live in the KMS compartment"
  }

  assert {
    condition     = strcontains(oci_identity_policy.kms[0].statements[0], "in compartment id ocid1.compartment.oc1..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb where")
    error_message = "Statement should target the KMS compartment"
  }
}

run "rejects_invalid_san_type" {
  command = plan
  variables {
    certificate_subject_alternative_names = [{ type = "EMAIL", value = "a@b.c" }]
  }
  expect_failures = [var.certificate_subject_alternative_names]
}

run "rejects_invalid_kms_compartment_ocid" {
  command = plan
  variables {
    kms_compartment_id = "not-a-valid-ocid"
  }
  expect_failures = [var.kms_compartment_id]
}

run "accepts_regional_key_ocid_with_vault_segment" {
  command = plan
  variables {
    kms_key_id        = "ocid1.key.oc1.il-jerusalem-1.hzvnkg7paacmw.abwxiljruallpysu6vcbyjiodvxetmbzi7tsisbxteqgzib2xj7ev7jlsnwa"
    create_kms_policy = true
  }

  assert {
    condition     = strcontains(oci_identity_policy.kms[0].statements[0], "target.key.id = 'ocid1.key.oc1.il-jerusalem-1.hzvnkg7paacmw.abwxiljruallpysu6vcbyjiodvxetmbzi7tsisbxteqgzib2xj7ev7jlsnwa'")
    error_message = "Real key OCID with a vault segment should be accepted and reach the policy"
  }
}

run "default_validity_has_nonzero_fractional_seconds" {
  command = plan
  variables {
    create_certificate      = true
    certificate_common_name = "test.example.com"
  }

  assert {
    condition     = can(regex("\\.001Z$", oci_certificates_management_certificate_authority.this.certificate_authority_config[0].validity[0].time_of_validity_not_after))
    error_message = "Default CA validity must end in .001Z (the API rejects timestamps without fractional seconds)"
  }

  assert {
    condition     = can(regex("\\.001Z$", oci_certificates_management_certificate.this[0].certificate_config[0].validity[0].time_of_validity_not_after))
    error_message = "Default certificate validity must end in .001Z"
  }
}

run "accepts_validity_with_nonzero_fraction" {
  command = plan
  variables {
    ca_validity_time_of_validity_not_after          = "2036-10-18T00:00:00.001Z"
    certificate_validity_time_of_validity_not_after = "2036-10-18T00:00:00.001Z"
  }
}

run "rejects_ca_validity_without_fraction" {
  command = plan
  variables {
    ca_validity_time_of_validity_not_after = "2036-10-18T00:00:00Z"
  }
  expect_failures = [var.ca_validity_time_of_validity_not_after]
}

run "rejects_ca_validity_with_zero_fraction" {
  command = plan
  variables {
    ca_validity_time_of_validity_not_after = "2036-10-18T00:00:00.000Z"
  }
  expect_failures = [var.ca_validity_time_of_validity_not_after]
}

run "rejects_certificate_validity_without_fraction" {
  command = plan
  variables {
    certificate_validity_time_of_validity_not_after = "2036-10-18T00:00:00Z"
  }
  expect_failures = [var.certificate_validity_time_of_validity_not_after]
}

run "rejects_certificate_validity_with_zero_fraction" {
  command = plan
  variables {
    certificate_validity_time_of_validity_not_after = "2036-10-18T00:00:00.000Z"
  }
  expect_failures = [var.certificate_validity_time_of_validity_not_after]
}
