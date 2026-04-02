data "oci_identity_compartments" "all_compartments" {
  compartment_id = var.oci_root_compartment
  name           = var.compartment_name
}

locals {
  create_compartment = length(data.oci_identity_compartments.all_compartments.compartments) == 0
}

resource "oci_identity_compartment" "this" {
  count = local.create_compartment ? 1 : 0

  compartment_id = var.oci_root_compartment
  defined_tags   = var.compartment_defined_tags
  description    = var.compartment_description
  enable_delete  = var.compartment_enable_delete
  freeform_tags  = var.compartment_freeform_tags
  name           = var.compartment_name
}
