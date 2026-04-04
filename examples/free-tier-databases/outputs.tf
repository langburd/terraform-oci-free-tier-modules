output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "autonomous_database_id" {
  description = "OCID of the Autonomous Database."
  value       = module.autonomous_database.autonomous_database_id
}

output "autonomous_db_name" {
  description = "The database name of the Autonomous Database."
  value       = module.autonomous_database.db_name
}

output "mysql_db_system_id" {
  description = "OCID of the MySQL DB System."
  value       = module.mysql.mysql_db_system_id
}

output "nosql_table_id" {
  description = "OCID of the NoSQL table."
  value       = module.nosql.table_id
}

output "nosql_table_name" {
  description = "Name of the NoSQL table."
  value       = module.nosql.table_name
}
