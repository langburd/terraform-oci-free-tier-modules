resource "oci_network_load_balancer_network_load_balancer" "this" {
  compartment_id = var.compartment_id
  display_name   = var.nlb_display_name
  subnet_id      = var.subnet_id
  is_private     = var.is_private
  defined_tags   = var.nlb_defined_tags
  freeform_tags  = var.nlb_freeform_tags
}

resource "oci_network_load_balancer_backend_set" "this" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = var.backend_set_name
  policy                   = var.backend_set_policy

  health_checker {
    protocol = var.health_check_protocol
    port     = var.health_check_port
  }
}

resource "oci_network_load_balancer_listener" "this" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  name                     = var.listener_name
  default_backend_set_name = oci_network_load_balancer_backend_set.this.name
  port                     = var.listener_port
  protocol                 = var.listener_protocol
}

resource "oci_network_load_balancer_backend" "this" {
  for_each = var.backends

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.this.id
  backend_set_name         = oci_network_load_balancer_backend_set.this.name
  ip_address               = each.value.ip_address
  port                     = each.value.port
  name                     = each.key
}
