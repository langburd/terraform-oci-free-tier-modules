data "oci_identity_compartments" "existing" {
  compartment_id = var.oci_root_compartment
  name           = var.compartment_name
}

locals {
  compartment_exists = length(data.oci_identity_compartments.existing.compartments) > 0
}

resource "oci_identity_compartment" "this" {
  count = local.compartment_exists ? 0 : 1

  compartment_id = var.oci_root_compartment
  defined_tags   = var.compartment_defined_tags
  description    = var.compartment_description
  enable_delete  = var.compartment_enable_delete
  freeform_tags  = var.compartment_freeform_tags
  name           = var.compartment_name
}

locals {
  compartment_defined_tags  = local.compartment_exists ? data.oci_identity_compartments.existing.compartments[0].defined_tags : oci_identity_compartment.this[0].defined_tags
  compartment_description   = local.compartment_exists ? data.oci_identity_compartments.existing.compartments[0].description : oci_identity_compartment.this[0].description
  compartment_freeform_tags = local.compartment_exists ? data.oci_identity_compartments.existing.compartments[0].freeform_tags : oci_identity_compartment.this[0].freeform_tags
  compartment_id            = local.compartment_exists ? data.oci_identity_compartments.existing.compartments[0].id : oci_identity_compartment.this[0].id
  compartment_name          = local.compartment_exists ? data.oci_identity_compartments.existing.compartments[0].name : oci_identity_compartment.this[0].name
}
