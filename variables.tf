variable "compartment_id" {
  description = "(Required) The OCID of the compartment where the NoSQL table will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "table_name" {
  description = "(Required) A user-friendly name for the table. Table name must contain only letters, numbers, and underscores."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_]+$", var.table_name))
    error_message = "table_name may only contain letters, numbers, and underscores."
  }
}

variable "ddl_statement" {
  description = "(Required) Represents the table schema information as a DDL statement, e.g. 'CREATE TABLE foo (id INTEGER, name STRING, PRIMARY KEY(id))'."
  type        = string
}

variable "table_limits_max_read_units" {
  description = "(Optional) (Updatable) Maximum number of read units for the table. Valid range: 1-50."
  type        = number
  default     = 50
  validation {
    condition     = var.table_limits_max_read_units >= 1 && var.table_limits_max_read_units <= 50
    error_message = "table_limits_max_read_units must be between 1 and 50."
  }
}

variable "table_limits_max_write_units" {
  description = "(Optional) (Updatable) Maximum number of write units for the table. Valid range: 1-50."
  type        = number
  default     = 50
  validation {
    condition     = var.table_limits_max_write_units >= 1 && var.table_limits_max_write_units <= 50
    error_message = "table_limits_max_write_units must be between 1 and 50."
  }
}

variable "table_limits_max_storage_in_gbs" {
  description = "(Optional) (Updatable) Maximum storage capacity in gigabytes for the table. Valid range: 1-25."
  type        = number
  default     = 25
  validation {
    condition     = var.table_limits_max_storage_in_gbs >= 1 && var.table_limits_max_storage_in_gbs <= 25
    error_message = "table_limits_max_storage_in_gbs must be between 1 and 25."
  }
}

variable "indexes" {
  description = "(Optional) A map of indexes to create on the table. Each index must specify a list of key columns."
  type = map(object({
    keys = list(object({
      column_name     = string
      json_field_type = optional(string)
    }))
  }))
  default = {}
}

variable "nosql_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the NoSQL table resource."
  type        = map(string)
  default     = {}
}

variable "nosql_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the NoSQL table resource."
  type        = map(string)
  default     = {}
}
