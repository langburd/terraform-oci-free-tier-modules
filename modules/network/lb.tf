# /* Load Balancer */

# resource "oci_load_balancer_load_balancer" "free_load_balancer" {
#   #Required
#   compartment_id = var.compartment_ocid
#   display_name   = "alwaysFreeLoadBalancer"
#   shape          = "flexible"
#   shape_details {
#     maximum_bandwidth_in_mbps = 10
#     minimum_bandwidth_in_mbps = 10
#   }

#   subnet_ids = [
#     oci_core_subnet.test_subnet.id,
#   ]
# }

# resource "oci_load_balancer_backend_set" "free_load_balancer_backend_set" {
#   name             = "lbBackendSet1"
#   load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
#   policy           = "ROUND_ROBIN"

#   health_checker {
#     port                = "80"
#     protocol            = "HTTP"
#     response_body_regex = ".*"
#     url_path            = "/"
#   }

#   session_persistence_configuration {
#     cookie_name      = "lb-session1"
#     disable_fallback = true
#   }
# }

# resource "oci_load_balancer_backend" "free_load_balancer_test_backend0" {
#   #Required
#   backendset_name  = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
#   ip_address       = oci_core_instance.free_instance0.public_ip
#   load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
#   port             = "80"
# }

# resource "oci_load_balancer_backend" "free_load_balancer_test_backend1" {
#   #Required
#   backendset_name  = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
#   ip_address       = oci_core_instance.free_instance1.public_ip
#   load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
#   port             = "80"
# }

# resource "oci_load_balancer_hostname" "test_hostname1" {
#   #Required
#   hostname         = "app.free.com"
#   load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
#   name             = "hostname1"
# }

# resource "oci_load_balancer_listener" "load_balancer_listener0" {
#   load_balancer_id         = oci_load_balancer_load_balancer.free_load_balancer.id
#   name                     = "http"
#   default_backend_set_name = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
#   hostname_names           = [oci_load_balancer_hostname.test_hostname1.name]
#   port                     = 80
#   protocol                 = "HTTP"
#   rule_set_names           = [oci_load_balancer_rule_set.test_rule_set.name]

#   connection_configuration {
#     idle_timeout_in_seconds = "240"
#   }
# }

# resource "oci_load_balancer_rule_set" "test_rule_set" {
#   items {
#     action = "ADD_HTTP_REQUEST_HEADER"
#     header = "example_header_name"
#     value  = "example_header_value"
#   }

#   items {
#     action          = "CONTROL_ACCESS_USING_HTTP_METHODS"
#     allowed_methods = ["GET", "POST"]
#     status_code     = "405"
#   }

#   load_balancer_id = oci_load_balancer_load_balancer.free_load_balancer.id
#   name             = "test_rule_set_name"
# }

# resource "tls_private_key" "example" {
#   algorithm   = "ECDSA"
#   ecdsa_curve = "P384"
# }

# resource "tls_self_signed_cert" "example" {
#   private_key_pem = tls_private_key.example.private_key_pem

#   subject {
#     organization = "Oracle"
#     country      = "US"
#     locality     = "Austin"
#     province     = "TX"
#   }

#   validity_period_hours = 8760 # 1 year

#   allowed_uses = [
#     "key_encipherment",
#     "digital_signature",
#     "server_auth",
#     "client_auth",
#     "cert_signing"
#   ]

#   is_ca_certificate = true
# }

# resource "oci_load_balancer_certificate" "load_balancer_certificate" {
#   load_balancer_id   = oci_load_balancer_load_balancer.free_load_balancer.id
#   ca_certificate     = tls_self_signed_cert.example.cert_pem
#   certificate_name   = "certificate1"
#   private_key        = tls_private_key.example.private_key_pem
#   public_certificate = tls_self_signed_cert.example.cert_pem

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "oci_load_balancer_listener" "load_balancer_listener1" {
#   load_balancer_id         = oci_load_balancer_load_balancer.free_load_balancer.id
#   name                     = "https"
#   default_backend_set_name = oci_load_balancer_backend_set.free_load_balancer_backend_set.name
#   port                     = 443
#   protocol                 = "HTTP"

#   ssl_configuration {
#     certificate_name        = oci_load_balancer_certificate.load_balancer_certificate.certificate_name
#     verify_peer_certificate = false
#   }
# }

# output "lb_public_ip" {
#   description = "The public IP address of the load balancer."
#   value       = [oci_load_balancer_load_balancer.free_load_balancer.ip_address_details]
# }

# data "oci_core_vnic_attachments" "app_vnics" {
#   compartment_id      = var.compartment_ocid
#   availability_domain = data.oci_identity_availability_domain.ad.name
#   instance_id         = oci_core_instance.free_instance0.id
# }

# data "oci_core_vnic" "app_vnic" {
#   vnic_id = data.oci_core_vnic_attachments.app_vnics.vnic_attachments[0]["vnic_id"]
# }

# # See https://docs.oracle.com/iaas/images/
# data "oci_core_images" "test_images" {
#   compartment_id           = var.compartment_ocid
#   operating_system         = "Oracle Linux"
#   operating_system_version = "8"
#   shape                    = var.instance_shape
#   sort_by                  = "TIMECREATED"
#   sort_order               = "DESC"
# }

# output "app" {
#   description = "URL of the application."
#   value       = "http://${data.oci_core_vnic.app_vnic.public_ip_address}"
# }
