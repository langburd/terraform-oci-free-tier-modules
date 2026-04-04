variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the VPN resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "drg_display_name" {
  description = "(Optional) (Updatable) Display name for the Dynamic Routing Gateway."
  type        = string
  default     = "drg"
}

variable "vcn_id" {
  description = "(Optional) The OCID of the VCN to attach the DRG to. When provided, a DRG attachment is created."
  type        = string
  default     = null

  validation {
    condition     = var.vcn_id == null || can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vcn_id))
    error_message = "vcn_id must be a valid OCI OCID or null."
  }
}

variable "cpe_ip_address" {
  description = "(Required) The public IP address of the on-premises Customer-Premises Equipment (CPE)."
  type        = string

  validation {
    condition     = can(regex("^(\\d{1,3}\\.){3}\\d{1,3}$", var.cpe_ip_address))
    error_message = "cpe_ip_address must be a valid IPv4 address (e.g. 203.0.113.1)."
  }
}

variable "cpe_display_name" {
  description = "(Optional) (Updatable) Display name for the Customer-Premises Equipment resource."
  type        = string
  default     = "cpe"
}

variable "ipsec_display_name" {
  description = "(Optional) (Updatable) Display name for the IPSec connection."
  type        = string
  default     = "ipsec-connection"
}

variable "static_routes" {
  description = "(Required) Static routes for the IPSec connection. List of CIDR blocks representing the on-premises networks."
  type        = list(string)
}

variable "vpn_defined_tags" {
  description = "Defined tags for the VPN resources."
  type        = map(string)
  default     = {}
}

variable "vpn_freeform_tags" {
  description = "Free-form tags for the VPN resources."
  type        = map(string)
  default     = {}
}
