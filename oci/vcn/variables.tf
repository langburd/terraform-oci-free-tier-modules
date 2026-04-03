variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the VCN."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vcn_cidr_blocks" {
  description = "(Optional) (Updatable) The list of one or more IPv4 CIDR blocks for the VCN."
  type        = list(string)
  default     = ["10.0.0.0/16"]
  validation {
    condition     = alltrue([for cidr in var.vcn_cidr_blocks : can(cidrhost(cidr, 0))])
    error_message = "Each element of vcn_cidr_blocks must be a valid CIDR block."
  }
}

variable "vcn_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the VCN."
  type        = map(string)
  default     = {}
}

variable "vcn_display_name" {
  description = "(Optional) (Updatable) A user-friendly name for the VCN."
  type        = string
  default     = "vcn"
}

variable "vcn_dns_label" {
  description = "(Optional) A DNS label for the VCN, used in conjunction with the VNIC's hostname and subnet's DNS label to form a fully qualified domain name (FQDN). Must match ^[a-z][a-z0-9]{0,14}$ or be null."
  type        = string
  default     = null
  validation {
    condition     = var.vcn_dns_label == null || can(regex("^[a-z][a-z0-9]{0,14}$", var.vcn_dns_label))
    error_message = "vcn_dns_label must be null or match ^[a-z][a-z0-9]{0,14}$ (lowercase, starts with a letter, max 15 chars)."
  }
}

variable "vcn_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the VCN."
  type        = map(string)
  default     = {}
}

variable "create_internet_gateway" {
  description = "(Optional) Whether to create an Internet Gateway and public route table."
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "(Optional) Whether to create a NAT Gateway and private route table."
  type        = bool
  default     = false
}

variable "create_service_gateway" {
  description = "(Optional) Whether to create a Service Gateway. When enabled, a service route is added to the public and/or private route tables."
  type        = bool
  default     = false
}
