output "subnet_id" {
  description = "OCID of the subnet."
  value       = oci_core_subnet.this.id
}

output "subnet_cidr_block" {
  description = "The CIDR block assigned to the subnet."
  value       = oci_core_subnet.this.cidr_block
}
