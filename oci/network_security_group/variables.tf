variable "compartment_id" {
  description = "Compartment OCID where the NSG will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vcn_id" {
  description = "VCN OCID in which the NSG will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vcn_id))
    error_message = "vcn_id must be a valid OCI OCID (e.g. ocid1.vcn.oc1..aaaaaa...)."
  }
}

variable "nsg_display_name" {
  description = "Display name for the Network Security Group."
  type        = string
  default     = "nsg"
}

variable "ingress_rules" {
  description = "Map of ingress (inbound) security rules. Each rule's `source` field specifies the source CIDR; `destination` is not used for ingress."
  type = map(object({
    protocol         = string
    source           = optional(string)
    source_type      = optional(string, "CIDR_BLOCK")
    destination      = optional(string)
    destination_type = optional(string, "CIDR_BLOCK")
    tcp_options = optional(object({
      destination_port_range = object({
        min = number
        max = number
      })
    }))
    udp_options = optional(object({
      destination_port_range = object({
        min = number
        max = number
      })
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number) # null = all codes
    }))
    description = optional(string, "")
  }))
  default = {}
}

variable "egress_rules" {
  description = "Map of egress (outbound) security rules. Each rule's `destination` field specifies the destination CIDR; `source` is not used for egress."
  type = map(object({
    protocol         = string
    source           = optional(string)
    source_type      = optional(string, "CIDR_BLOCK")
    destination      = optional(string)
    destination_type = optional(string, "CIDR_BLOCK")
    tcp_options = optional(object({
      destination_port_range = object({
        min = number
        max = number
      })
    }))
    udp_options = optional(object({
      destination_port_range = object({
        min = number
        max = number
      })
    }))
    icmp_options = optional(object({
      type = number
      code = optional(number) # null = all codes
    }))
    description = optional(string, "")
  }))
  default = {}
}

variable "nsg_defined_tags" {
  description = "Defined tags for the Network Security Group."
  type        = map(string)
  default     = {}
}

variable "nsg_freeform_tags" {
  description = "Free-form tags for the Network Security Group."
  type        = map(string)
  default     = {}
}
