variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the subnet."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vcn_id" {
  description = "(Required) The OCID of the VCN in which to create the subnet."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vcn_id))
    error_message = "vcn_id must be a valid OCI OCID (e.g. ocid1.vcn.oc1..aaaaaa...)."
  }
}

variable "subnet_cidr_block" {
  description = "(Required) The CIDR block assigned to the subnet (e.g. 10.0.1.0/24)."
  type        = string
  validation {
    condition     = can(cidrhost(var.subnet_cidr_block, 0))
    error_message = "subnet_cidr_block must be a valid CIDR block."
  }
}

variable "subnet_display_name" {
  description = "(Optional) (Updatable) A user-friendly name for the subnet."
  type        = string
  default     = "subnet"
}

variable "subnet_dns_label" {
  description = "(Optional) A DNS label for the subnet. Must match ^[a-z][a-z0-9]{0,14}$ or be null."
  type        = string
  default     = null
  validation {
    condition     = var.subnet_dns_label == null || can(regex("^[a-z][a-z0-9]{0,14}$", var.subnet_dns_label))
    error_message = "subnet_dns_label must start with a lowercase letter, contain only lowercase letters and digits, and be 1-15 characters, or be null."
  }
}

variable "prohibit_internet_ingress" {
  description = "(Optional) (Updatable) Whether to disallow ingress from the internet. Set to true for private subnets."
  type        = bool
  default     = false
}

variable "route_table_id" {
  description = "(Optional) (Updatable) The OCID of the route table to attach to the subnet. Defaults to the VCN's default route table when null."
  type        = string
  default     = null
  validation {
    condition     = var.route_table_id == null || can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.route_table_id))
    error_message = "route_table_id must be a valid OCI OCID or null."
  }
}

variable "security_list_ids" {
  description = "(Optional) (Updatable) List of security list OCIDs to associate with the subnet. Defaults to the VCN's default security list when null."
  type        = list(string)
  default     = null
  validation {
    condition     = alltrue([for id in coalesce(var.security_list_ids, []) : can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", id))])
    error_message = "Each element of security_list_ids must be a valid OCI OCID."
  }
}

variable "availability_domain" {
  description = "(Optional) The availability domain for the subnet. Omit (null) for a regional subnet, which spans all ADs and is recommended."
  type        = string
  default     = null
  validation {
    condition     = var.availability_domain == null || try(length(trimspace(var.availability_domain)) > 0, false)
    error_message = "availability_domain must be null or a non-empty string."
  }
}

variable "subnet_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the subnet."
  type        = map(string)
  default     = {}
}

variable "subnet_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the subnet."
  type        = map(string)
  default     = {}
}
