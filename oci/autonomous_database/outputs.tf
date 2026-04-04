output "autonomous_database_id" {
  description = "OCID of the Autonomous Database resource."
  value       = oci_database_autonomous_database.this.id
}

output "connection_strings" {
  description = "The connection string used to connect to the Autonomous Database."
  value       = oci_database_autonomous_database.this.connection_strings
}

output "connection_urls" {
  description = "The URLs for accessing Oracle Application Express (APEX) and SQL Developer Web with a browser from a Compute instance."
  value       = oci_database_autonomous_database.this.connection_urls
}

output "db_name" {
  description = "The database name."
  value       = oci_database_autonomous_database.this.db_name
}
