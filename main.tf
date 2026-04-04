resource "oci_apm_apm_domain" "this" {
  compartment_id = var.compartment_id
  display_name   = var.apm_display_name
  description    = var.apm_description
  is_free_tier   = var.is_free_tier
  defined_tags   = var.apm_defined_tags
  freeform_tags  = var.apm_freeform_tags
}
