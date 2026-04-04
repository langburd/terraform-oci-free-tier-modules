output "bastion_id" {
  description = "OCID of the bastion."
  value       = oci_bastion_bastion.this.id
}

output "bastion_name" {
  description = "Name of the bastion."
  value       = oci_bastion_bastion.this.name
}
