output "mysql_db_system_id" {
  description = "OCID of the MySQL DB System resource."
  value       = oci_mysql_mysql_db_system.this.id
}

output "mysql_ip_address" {
  description = "The IP address of the primary endpoint of the MySQL DB System."
  value       = oci_mysql_mysql_db_system.this.ip_address
}

output "mysql_port" {
  description = "The port for primary endpoint of the MySQL DB System to listen on."
  value       = oci_mysql_mysql_db_system.this.port
}
