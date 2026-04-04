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
