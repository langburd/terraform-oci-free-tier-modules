resource "oci_identity_compartment" "this" {
  compartment_id = var.oci_root_compartment
  defined_tags   = var.compartment_defined_tags
  description    = var.compartment_description
  enable_delete  = var.compartment_enable_delete
  freeform_tags  = var.compartment_freeform_tags
  name           = var.compartment_name
}
