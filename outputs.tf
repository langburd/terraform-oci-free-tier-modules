output "network_load_balancer_id" {
  description = "OCID of the network load balancer."
  value       = oci_network_load_balancer_network_load_balancer.this.id
}

output "nlb_ip_addresses" {
  description = "List of IP address objects assigned to the network load balancer."
  value       = oci_network_load_balancer_network_load_balancer.this.ip_addresses
}
