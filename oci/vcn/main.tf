data "oci_core_services" "this" {}

locals {
  service = try(
    [for s in data.oci_core_services.this.services : s if can(regex("All .* Services In Oracle Services Network", s.name))][0],
    null
  )
}

resource "oci_core_vcn" "this" {
  compartment_id = var.compartment_id
  cidr_blocks    = var.vcn_cidr_blocks
  defined_tags   = var.vcn_defined_tags
  display_name   = var.vcn_display_name
  dns_label      = var.vcn_dns_label
  freeform_tags  = var.vcn_freeform_tags
}

resource "oci_core_internet_gateway" "this" {
  count = var.create_internet_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-igw"
  enabled        = true
  freeform_tags  = var.vcn_freeform_tags
}

resource "oci_core_nat_gateway" "this" {
  count = var.create_nat_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-natgw"
  freeform_tags  = var.vcn_freeform_tags
}

resource "oci_core_service_gateway" "this" {
  count = var.create_service_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-sgw"
  freeform_tags  = var.vcn_freeform_tags

  services {
    service_id = local.service.id
  }

  lifecycle {
    precondition {
      condition     = local.service != null
      error_message = "No OCI service matching 'All .* Services In Oracle Services Network' was found in this region. Cannot create service gateway."
    }
  }
}

resource "oci_core_route_table" "public" {
  count = var.create_internet_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-public-rt"
  freeform_tags  = var.vcn_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
  }

  dynamic "route_rules" {
    for_each = var.create_service_gateway ? [1] : []
    content {
      destination       = local.service.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this[0].id
    }
  }
}

resource "oci_core_route_table" "private" {
  count = var.create_nat_gateway ? 1 : 0

  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-private-rt"
  freeform_tags  = var.vcn_freeform_tags

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this[0].id
  }

  dynamic "route_rules" {
    for_each = var.create_service_gateway ? [1] : []
    content {
      destination       = local.service.cidr_block
      destination_type  = "SERVICE_CIDR_BLOCK"
      network_entity_id = oci_core_service_gateway.this[0].id
    }
  }
}

# This security list is intentionally created empty (no ingress or egress rules).
# It serves as a starter resource for consumers to reference as a subnet's default
# security list. Add rules via the oci_core_security_list_management resource or
# by defining ingress_security_rules / egress_security_rules blocks in a separate
# oci_core_security_list resource.
resource "oci_core_security_list" "this" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.this.id
  defined_tags   = var.vcn_defined_tags
  display_name   = "${var.vcn_display_name}-security-list"
  freeform_tags  = var.vcn_freeform_tags
}
