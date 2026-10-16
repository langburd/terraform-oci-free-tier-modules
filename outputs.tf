output "nsg_id" {
  description = "OCID of the Network Security Group."
  value       = oci_core_network_security_group.this.id
}
