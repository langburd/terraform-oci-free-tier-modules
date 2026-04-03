output "security_list_id" {
  description = "OCID of the security list created by this module. Note: this is not the OCI-managed default security list auto-created with the VCN; that OCID is available via the vcn_id output on the VCN resource itself."
  value       = oci_core_security_list.this.id
}

output "internet_gateway_id" {
  description = "OCID of the Internet Gateway. Returns null when create_internet_gateway is false."
  value       = try(oci_core_internet_gateway.this[0].id, null)
}

output "nat_gateway_id" {
  description = "OCID of the NAT Gateway. Returns null when create_nat_gateway is false."
  value       = try(oci_core_nat_gateway.this[0].id, null)
}

output "private_route_table_id" {
  description = "OCID of the private route table. Returns null when create_nat_gateway is false."
  value       = try(oci_core_route_table.private[0].id, null)
}

output "public_route_table_id" {
  description = "OCID of the public route table. Returns null when create_internet_gateway is false."
  value       = try(oci_core_route_table.public[0].id, null)
}

output "service_gateway_id" {
  description = "OCID of the Service Gateway. Returns null when create_service_gateway is false."
  value       = try(oci_core_service_gateway.this[0].id, null)
}

output "vcn_cidr_blocks" {
  description = "The list of IPv4 CIDR blocks assigned to the VCN."
  value       = oci_core_vcn.this.cidr_blocks
}

output "vcn_id" {
  description = "OCID of the VCN."
  value       = oci_core_vcn.this.id
}
