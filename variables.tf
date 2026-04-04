variable "compartment_id" {
  description = "(Required) The OCID of the compartment where the Autonomous Database will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "db_name" {
  description = "(Required) The database name. Must start with a letter, be alphanumeric only, and be at most 14 characters."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]{0,13}$", var.db_name))
    error_message = "db_name must start with a letter, contain only alphanumeric characters, and be at most 14 characters long."
  }
}

variable "admin_password" {
  description = "(Required) The password for the ADMIN user. Must be 12 to 30 characters and contain at least one uppercase, one lowercase, and one numeric character."
  type        = string
  sensitive   = true
}

variable "db_workload" {
  description = "(Optional) (Updatable) The Autonomous Database workload type. Valid values: OLTP, DW, AJD, APEX."
  type        = string
  default     = "OLTP"
  validation {
    condition     = contains(["OLTP", "DW", "AJD", "APEX"], var.db_workload)
    error_message = "db_workload must be one of: OLTP, DW, AJD, APEX."
  }
}

variable "is_free_tier" {
  description = "(Optional) Indicates if the database is an Always Free resource. Always Free databases have no additional charges."
  type        = bool
  default     = true
}

variable "compute_model" {
  description = "(Optional) The compute model of the Autonomous Database (ECPU or OCPU). For Always Free, only ECPU is supported."
  type        = string
  default     = "ECPU"
  validation {
    condition     = contains(["ECPU", "OCPU"], var.compute_model)
    error_message = "compute_model must be one of: ECPU, OCPU."
  }
}

variable "compute_count" {
  description = "(Optional) The number of compute units (ECPUs or OCPUs) for the Autonomous Database. Minimum is 2 per provider API requirements."
  type        = number
  default     = 2
}

variable "data_storage_size_in_gb" {
  description = "(Optional) The size, in gigabytes, of the data volume that will be created and attached to the database. Always Free databases are fixed at 20 GB."
  type        = number
  default     = 20
  validation {
    condition     = var.data_storage_size_in_gb >= 1 && var.data_storage_size_in_gb <= 20
    error_message = "data_storage_size_in_gb must be <= 20 for Always Free tier databases."
  }
}

variable "db_version" {
  description = "(Optional) A valid Oracle Database version for Autonomous Database. If not specified, the latest version is used."
  type        = string
  default     = null
}

variable "whitelisted_ips" {
  description = "(Optional) (Updatable) The client IP access control list (ACL). This feature is available for databases on shared Exadata infrastructure."
  type        = list(string)
  default     = []
}

variable "is_mtls_connection_required" {
  description = "(Optional) (Updatable) Indicates whether the Autonomous Database requires mTLS connections. Set to false to allow TLS connections."
  type        = bool
  default     = false
}

variable "display_name" {
  description = "(Optional) (Updatable) The user-friendly name for the Autonomous Database."
  type        = string
  default     = "autonomous-database"
}

variable "autonomous_database_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the Autonomous Database resource."
  type        = map(string)
  default     = {}
}

variable "autonomous_database_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the Autonomous Database resource."
  type        = map(string)
  default     = {}
}
