locals {
  kms_compartment_id = coalesce(var.kms_compartment_id, var.compartment_id)
  # The Certificates API rejects timeOfValidityNotAfter without fractional seconds and the
  # provider drops a ".000" fraction, so defaults carry a non-zero ".001Z" fraction.
  # Default CA validity: 3 years from plan time (26280h = 365.25 days * 3 * 24h)
  ca_not_after = var.ca_validity_time_of_validity_not_after != null ? var.ca_validity_time_of_validity_not_after : formatdate("YYYY-MM-DD'T'hh:mm:ss'.001Z'", timeadd(plantimestamp(), "26280h"))
  # Default cert validity: 1 year from plan time (8766h = 365.25 days * 24h)
  cert_not_after = var.certificate_validity_time_of_validity_not_after != null ? var.certificate_validity_time_of_validity_not_after : formatdate("YYYY-MM-DD'T'hh:mm:ss'.001Z'", timeadd(plantimestamp(), "8766h"))
}

# The CA signs with its KMS key as the certificateauthority principal. Without this
# grant CA creation fails with an authorization error.
resource "oci_identity_policy" "kms" {
  count = var.create_kms_policy ? 1 : 0

  compartment_id = local.kms_compartment_id
  name           = "${var.ca_name}-kms-access"
  description    = "Let the certificate authority ${var.ca_name} use its KMS key."
  defined_tags   = var.certificates_defined_tags
  freeform_tags  = var.certificates_freeform_tags

  statements = [
    "Allow any-user to use keys in compartment id ${local.kms_compartment_id} where all {request.principal.type = 'certificateauthority', target.key.id = '${var.kms_key_id}'}",
  ]

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_certificates_management_certificate_authority" "this" {
  compartment_id = var.compartment_id
  name           = var.ca_name
  kms_key_id     = var.kms_key_id
  defined_tags   = var.certificates_defined_tags
  freeform_tags  = var.certificates_freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }

  depends_on = [oci_identity_policy.kms]

  certificate_authority_config {
    config_type       = var.ca_config_type
    signing_algorithm = var.ca_signing_algorithm

    subject {
      common_name = var.ca_common_name
    }

    validity {
      time_of_validity_not_after = local.ca_not_after
    }
  }
}

resource "oci_certificates_management_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  compartment_id = var.compartment_id
  name           = var.certificate_name
  defined_tags   = var.certificates_defined_tags
  freeform_tags  = var.certificates_freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }

  dynamic "certificate_rules" {
    for_each = var.certificate_renewal_rule == null ? [] : [var.certificate_renewal_rule]
    content {
      rule_type              = "CERTIFICATE_RENEWAL_RULE"
      renewal_interval       = certificate_rules.value.renewal_interval
      advance_renewal_period = certificate_rules.value.advance_renewal_period
    }
  }

  certificate_config {
    config_type                     = var.certificate_config_type
    issuer_certificate_authority_id = oci_certificates_management_certificate_authority.this.id
    certificate_profile_type        = var.certificate_profile_type
    key_algorithm                   = var.certificate_key_algorithm

    subject {
      common_name = var.certificate_common_name
    }

    dynamic "subject_alternative_names" {
      for_each = var.certificate_subject_alternative_names
      content {
        type  = subject_alternative_names.value.type
        value = subject_alternative_names.value.value
      }
    }

    validity {
      time_of_validity_not_after = local.cert_not_after
    }
  }
}
