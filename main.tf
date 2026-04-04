resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = var.nsg_display_name
  defined_tags   = var.nsg_defined_tags
  freeform_tags  = var.nsg_freeform_tags
}

resource "oci_core_network_security_group_security_rule" "this" {
  for_each = merge(
    { for k, v in var.ingress_rules : "ingress_${k}" => merge(v, { direction = "INGRESS" }) },
    { for k, v in var.egress_rules : "egress_${k}" => merge(v, { direction = "EGRESS" }) }
  )

  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = each.value.direction
  protocol                  = each.value.protocol
  description               = each.value.description
  source                    = each.value.direction == "INGRESS" ? lookup(each.value, "source", null) : null
  source_type               = each.value.direction == "INGRESS" ? lookup(each.value, "source_type", "CIDR_BLOCK") : null
  destination               = each.value.direction == "EGRESS" ? lookup(each.value, "destination", null) : null
  destination_type          = each.value.direction == "EGRESS" ? lookup(each.value, "destination_type", "CIDR_BLOCK") : null

  dynamic "tcp_options" {
    for_each = each.value.tcp_options != null ? [each.value.tcp_options] : []
    content {
      destination_port_range {
        min = tcp_options.value.destination_port_range.min
        max = tcp_options.value.destination_port_range.max
      }
    }
  }

  dynamic "udp_options" {
    for_each = each.value.udp_options != null ? [each.value.udp_options] : []
    content {
      destination_port_range {
        min = udp_options.value.destination_port_range.min
        max = udp_options.value.destination_port_range.max
      }
    }
  }

  dynamic "icmp_options" {
    for_each = each.value.icmp_options != null ? [each.value.icmp_options] : []
    content {
      type = icmp_options.value.type
      code = icmp_options.value.code
    }
  }
}
