variable "compartment_id" {
  description = "(Required) The OCID of the compartment where the MySQL DB System will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "subnet_id" {
  description = "(Required) The OCID of the subnet the MySQL DB System is associated with."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid OCI OCID (e.g. ocid1.subnet.oc1..aaaaaa...)."
  }
}

variable "availability_domain" {
  description = "(Required) The availability domain on which to deploy the Read/Write endpoint. This should be the name of the availability domain (e.g. 'Uocm:PHX-AD-1'). Always Free MySQL is only available in the home region."
  type        = string
}

variable "admin_password" {
  description = "(Required) The password for the administrative user. The password must be between 8 and 32 characters long, and must contain at least 1 numeric character, 1 lowercase character, 1 uppercase character, and 1 special character."
  type        = string
  sensitive   = true
  validation {
    condition = (
      length(var.admin_password) >= 8 &&
      length(var.admin_password) <= 32 &&
      can(regex("[A-Z]", var.admin_password)) &&
      can(regex("[a-z]", var.admin_password)) &&
      can(regex("[0-9]", var.admin_password)) &&
      can(regex("[^a-zA-Z0-9]", var.admin_password))
    )
    error_message = "admin_password must be 8-32 characters and contain at least one uppercase letter, one lowercase letter, one digit, and one special character."
  }
}

variable "shape_name" {
  description = "(Optional) The name of the shape. The shape determines the resources allocated to the MySQL DB System. For Always Free, use 'MySQL.Free'. Shape availability varies by region."
  type        = string
  default     = "MySQL.Free"
}

variable "admin_username" {
  description = "(Optional) The username for the administrative user."
  type        = string
  default     = "admin"
}

variable "data_storage_size_in_gb" {
  description = "(Optional) Initial size of the data volume in gigabytes that will be created and attached. Must be <= 50 for Always Free tier."
  type        = number
  default     = 50
  validation {
    condition     = var.data_storage_size_in_gb <= 50
    error_message = "data_storage_size_in_gb must be <= 50 for Always Free tier MySQL."
  }
}

variable "backup_is_enabled" {
  description = "(Optional) Whether to enable automatic backups for the MySQL DB System."
  type        = bool
  default     = true
}

variable "is_highly_available" {
  description = "(Optional) Specifies if the DB System is highly available. Must be false for Always Free tier."
  type        = bool
  default     = false
  validation {
    condition     = var.is_highly_available == false
    error_message = "is_highly_available must be false for the Always Free MySQL tier."
  }
}

variable "mysql_display_name" {
  description = "(Optional) (Updatable) The user-friendly name for the MySQL DB System."
  type        = string
  default     = "mysql"
}

variable "mysql_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the MySQL DB System resource."
  type        = map(string)
  default     = {}
}

variable "mysql_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the MySQL DB System resource."
  type        = map(string)
  default     = {}
}

variable "nsg_ids" {
  description = "(Optional) (Updatable) OCIDs of the Network Security Groups the DB System's endpoint is added to."
  type        = list(string)
  default     = []
  validation {
    condition     = alltrue([for id in var.nsg_ids : can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", id))])
    error_message = "Each nsg_ids entry must be a valid OCI OCID (e.g. ocid1.networksecuritygroup.oc1..aaaaaa...)."
  }
}

variable "hostname_label" {
  description = "(Optional) Hostname for the DB System's primary endpoint. Together with the subnet and VCN DNS labels it forms the FQDN (e.g. mysql.db.myvcn.oraclevcn.com). Null leaves the endpoint without a DNS name."
  type        = string
  default     = null
  validation {
    condition     = var.hostname_label == null || can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}$", var.hostname_label))
    error_message = "hostname_label must start with a letter and contain only letters, digits and hyphens (max 63 characters)."
  }
}

variable "maintenance_window_start_time" {
  description = "(Optional) (Updatable) Start of the weekly 2-hour maintenance window, as \"{day-of-week} {HH:MM}\" in UTC (e.g. \"sun 02:00\"). Null lets OCI choose."
  type        = string
  default     = null
  validation {
    condition     = var.maintenance_window_start_time == null || can(regex("^(?i)(mon|tue|wed|thu|fri|sat|sun) ([01][0-9]|2[0-3]):[0-5][0-9]$", var.maintenance_window_start_time))
    error_message = "maintenance_window_start_time must look like \"sun 02:00\" (day mon-sun, 24h UTC time)."
  }
}

variable "is_delete_protected" {
  description = "(Optional) (Updatable) Whether the DB System is protected against deletion. Must be set to false (and applied) before the DB System can be destroyed."
  type        = bool
  default     = true
}

variable "final_backup" {
  description = "(Optional) (Updatable) Whether a final backup is taken when the DB System is deleted. Supported values: SKIP_FINAL_BACKUP, REQUIRE_FINAL_BACKUP. Null keeps the OCI default."
  type        = string
  default     = null
  validation {
    condition     = var.final_backup == null || contains(["SKIP_FINAL_BACKUP", "REQUIRE_FINAL_BACKUP"], coalesce(var.final_backup, "SKIP_FINAL_BACKUP"))
    error_message = "Supported values are: SKIP_FINAL_BACKUP, REQUIRE_FINAL_BACKUP."
  }
}

variable "automatic_backup_retention" {
  description = "(Optional) (Updatable) Whether automatic backups are kept or deleted when the DB System is deleted. Supported values: DELETE, RETAIN. Null keeps the OCI default."
  type        = string
  default     = null
  validation {
    condition     = var.automatic_backup_retention == null || contains(["DELETE", "RETAIN"], coalesce(var.automatic_backup_retention, "DELETE"))
    error_message = "Supported values are: DELETE, RETAIN."
  }
}
