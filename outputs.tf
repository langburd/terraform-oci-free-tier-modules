output "drg_id" {
  description = "OCID of the Dynamic Routing Gateway."
  value       = oci_core_drg.this.id
}

output "cpe_id" {
  description = "OCID of the Customer-Premises Equipment resource."
  value       = oci_core_cpe.this.id
}

output "ipsec_connection_id" {
  description = "OCID of the IPSec connection."
  value       = oci_core_ipsec.this.id
}
