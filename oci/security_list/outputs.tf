output "security_list_id" {
  description = "OCID of the security list."
  value       = oci_core_security_list.this.id
}
