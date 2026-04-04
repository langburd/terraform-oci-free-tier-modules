resource "oci_core_drg" "this" {
  compartment_id = var.compartment_id
  display_name   = var.drg_display_name
  defined_tags   = var.vpn_defined_tags
  freeform_tags  = var.vpn_freeform_tags
}

resource "oci_core_drg_attachment" "this" {
  count = var.vcn_id != null ? 1 : 0

  drg_id       = oci_core_drg.this.id
  display_name = var.drg_attachment_display_name

  network_details {
    id   = var.vcn_id
    type = "VCN"
  }
}

resource "oci_core_cpe" "this" {
  compartment_id = var.compartment_id
  ip_address     = var.cpe_ip_address
  display_name   = var.cpe_display_name
  defined_tags   = var.vpn_defined_tags
  freeform_tags  = var.vpn_freeform_tags
}

resource "oci_core_ipsec" "this" {
  compartment_id = var.compartment_id
  cpe_id         = oci_core_cpe.this.id
  drg_id         = oci_core_drg.this.id
  display_name   = var.ipsec_display_name
  static_routes  = var.static_routes
  defined_tags   = var.vpn_defined_tags
  freeform_tags  = var.vpn_freeform_tags
}
