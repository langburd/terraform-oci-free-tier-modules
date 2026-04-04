output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "vcn_id" {
  description = "OCID of the VCN."
  value       = module.vcn.vcn_id
}

output "load_balancer_id" {
  description = "OCID of the load balancer."
  value       = module.load_balancer.load_balancer_id
}

output "load_balancer_ip_addresses" {
  description = "IP address details of the load balancer."
  value       = module.load_balancer.load_balancer_ip_addresses
}

output "web_server_1_id" {
  description = "OCID of web server instance 1."
  value       = module.compute_1.instance_id
}

output "web_server_2_id" {
  description = "OCID of web server instance 2."
  value       = module.compute_2.instance_id
}
