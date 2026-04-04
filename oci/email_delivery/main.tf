resource "oci_email_email_domain" "this" {
  compartment_id = var.compartment_id
  name           = var.email_domain_name
  defined_tags   = var.email_defined_tags
  freeform_tags  = var.email_freeform_tags
}

resource "oci_email_sender" "this" {
  compartment_id = var.compartment_id
  email_address  = var.sender_email_address
  defined_tags   = var.email_defined_tags
  freeform_tags  = var.email_freeform_tags
}

resource "oci_email_dkim" "this" {
  count = var.create_dkim ? 1 : 0

  email_domain_id = oci_email_email_domain.this.id
  name            = var.dkim_name
  defined_tags    = var.email_defined_tags
  freeform_tags   = var.email_freeform_tags
}
