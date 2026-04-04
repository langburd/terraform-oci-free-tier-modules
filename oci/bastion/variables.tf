variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the bastion."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "bastion_name" {
  description = "(Required) Name of the bastion. Must be alphanumeric."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9]*$", var.bastion_name))
    error_message = "bastion_name must be alphanumeric and start with a letter."
  }
}

variable "bastion_type" {
  description = "(Optional) Type of the bastion. Supported values: STANDARD."
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD"], var.bastion_type)
    error_message = "Supported values are: STANDARD."
  }
}

variable "target_subnet_id" {
  description = "(Required) OCID of the subnet that the bastion connects to."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.target_subnet_id))
    error_message = "target_subnet_id must be a valid OCI OCID (e.g. ocid1.subnet.oc1..aaaaaa...)."
  }
}

variable "client_cidr_block_allow_list" {
  description = "(Optional) List of CIDR blocks allowed to connect to the bastion."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "max_session_ttl_in_seconds" {
  description = "(Optional) Maximum session TTL in seconds. Valid range: 1800-10800."
  type        = number
  default     = 10800

  validation {
    condition     = var.max_session_ttl_in_seconds >= 1800 && var.max_session_ttl_in_seconds <= 10800
    error_message = "max_session_ttl_in_seconds must be between 1800 and 10800."
  }
}

variable "bastion_defined_tags" {
  description = "(Optional) Defined tags for the bastion."
  type        = map(string)
  default     = {}
}

variable "bastion_freeform_tags" {
  description = "(Optional) Free-form tags for the bastion."
  type        = map(string)
  default     = {}
}
