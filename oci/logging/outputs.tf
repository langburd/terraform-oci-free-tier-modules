output "log_group_id" {
  description = "OCID of the log group."
  value       = oci_logging_log_group.this.id
}

output "log_ids" {
  description = "Map of log display names to their OCIDs."
  value       = { for k, v in oci_logging_log.this : k => v.id }
}
