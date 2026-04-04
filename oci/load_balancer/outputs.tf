output "load_balancer_id" {
  description = "OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.this.id
}

output "load_balancer_ip_addresses" {
  description = "List of IP address objects assigned to the load balancer."
  value       = oci_load_balancer_load_balancer.this.ip_address_details
}
