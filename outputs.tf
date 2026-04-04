output "table_id" {
  description = "OCID of the NoSQL table resource."
  value       = oci_nosql_table.this.id
}

output "table_name" {
  description = "The name of the NoSQL table."
  value       = oci_nosql_table.this.name
}
