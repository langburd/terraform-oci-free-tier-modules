resource "oci_certificates_management_certificate_authority" "this" {
  compartment_id = var.compartment_id
  name           = var.ca_name
  defined_tags   = var.certificates_defined_tags
  freeform_tags  = var.certificates_freeform_tags

  certificate_authority_config {
    config_type       = var.ca_config_type
    signing_algorithm = var.ca_signing_algorithm

    subject {
      common_name = var.ca_common_name
    }

    validity {
      time_of_validity_not_after = var.ca_validity_time_of_validity_not_after
    }
  }
}

resource "oci_certificates_management_certificate" "this" {
  count = var.create_certificate ? 1 : 0

  compartment_id = var.compartment_id
  name           = var.certificate_name
  defined_tags   = var.certificates_defined_tags
  freeform_tags  = var.certificates_freeform_tags

  certificate_config {
    config_type                     = var.certificate_config_type
    issuer_certificate_authority_id = oci_certificates_management_certificate_authority.this.id
    certificate_profile_type        = var.certificate_profile_type
    key_algorithm                   = var.certificate_key_algorithm

    subject {
      common_name = var.certificate_common_name
    }

    validity {
      time_of_validity_not_after = var.certificate_validity_time_of_validity_not_after
    }
  }
}
