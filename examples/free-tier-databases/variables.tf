variable "oci_config_profile" {
  description = "(Required) OCI CLI config file profile name to use for authentication."
  type        = string
}

variable "compartment_name" {
  description = "(Optional) Name of the OCI compartment to create for database resources."
  type        = string
  default     = "free-tier-databases"
}

variable "adb_admin_password" {
  description = "(Required) The ADMIN user password for the Autonomous Database. Must be 12-30 characters with at least one uppercase, lowercase, and numeric character."
  type        = string
  sensitive   = true
}

variable "mysql_admin_password" {
  description = "(Required) The admin user password for the MySQL DB System."
  type        = string
  sensitive   = true
}
