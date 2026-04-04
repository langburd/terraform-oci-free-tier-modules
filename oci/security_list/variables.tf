variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the security list."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vcn_id" {
  description = "(Required) The OCID of the VCN in which to create the security list."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vcn_id))
    error_message = "vcn_id must be a valid OCI OCID (e.g. ocid1.vcn.oc1..aaaaaa...)."
  }
}

variable "security_list_display_name" {
  description = "(Optional) (Updatable) A user-friendly name for the security list."
  type        = string
  default     = "security-list"
}

variable "ingress_security_rules" {
  description = "(Optional) (Updatable) List of ingress security rules."
  type = list(object({
    protocol    = string
    source      = string
    source_type = optional(string, "CIDR_BLOCK")
    description = optional(string, "")
    tcp_options = optional(object({
      min = number
      max = number
    }))
    udp_options = optional(object({
      min = number
      max = number
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number)
    }))
    stateless = optional(bool, false)
  }))
  default = []
}

variable "egress_security_rules" {
  description = "(Optional) (Updatable) List of egress security rules."
  type = list(object({
    protocol         = string
    destination      = string
    destination_type = optional(string, "CIDR_BLOCK")
    description      = optional(string, "")
    tcp_options = optional(object({
      min = number
      max = number
    }))
    udp_options = optional(object({
      min = number
      max = number
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number)
    }))
    stateless = optional(bool, false)
  }))
  default = []
}

variable "security_list_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the security list."
  type        = map(string)
  default     = {}
}

variable "security_list_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the security list."
  type        = map(string)
  default     = {}
}
