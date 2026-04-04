resource "oci_core_subnet" "this" {
  cidr_block                = var.subnet_cidr_block
  compartment_id            = var.compartment_id
  vcn_id                    = var.vcn_id
  availability_domain       = var.availability_domain
  display_name              = var.subnet_display_name
  dns_label                 = var.subnet_dns_label
  prohibit_internet_ingress = var.prohibit_internet_ingress
  route_table_id            = var.route_table_id
  security_list_ids         = var.security_list_ids

  defined_tags  = var.subnet_defined_tags
  freeform_tags = var.subnet_freeform_tags
}
