resource "oci_load_balancer_load_balancer" "this" {
  compartment_id = var.compartment_id
  display_name   = var.lb_display_name
  shape          = "flexible"
  subnet_ids     = var.subnet_ids
  is_private     = var.is_private
  defined_tags   = var.lb_defined_tags
  freeform_tags  = var.lb_freeform_tags

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }
}

resource "oci_load_balancer_backend_set" "this" {
  load_balancer_id = oci_load_balancer_load_balancer.this.id
  name             = var.backend_set_name
  policy           = var.backend_set_policy

  health_checker {
    protocol = var.health_check_protocol
    port     = var.health_check_port
    url_path = var.health_check_protocol == "TCP" ? null : var.health_check_url_path
  }
}

resource "oci_load_balancer_listener" "this" {
  load_balancer_id         = oci_load_balancer_load_balancer.this.id
  name                     = var.listener_name
  default_backend_set_name = oci_load_balancer_backend_set.this.name
  port                     = var.listener_port
  protocol                 = var.listener_protocol
}

resource "oci_load_balancer_backend" "this" {
  for_each = var.backends

  load_balancer_id = oci_load_balancer_load_balancer.this.id
  backendset_name  = oci_load_balancer_backend_set.this.name
  ip_address       = each.value.ip_address
  port             = each.value.port
}
