output "volume_id" {
  description = "OCID of the block volume."
  value       = oci_core_volume.this.id
}

output "volume_attachment_id" {
  description = "OCID of the volume attachment. Returns null when no instance_id is provided."
  value       = try(oci_core_volume_attachment.this[0].id, null)
}

output "backup_policy_assignment_id" {
  description = "OCID of the volume backup policy assignment. Returns null when no backup_policy_id is provided."
  value       = try(oci_core_volume_backup_policy_assignment.this[0].id, null)
}
