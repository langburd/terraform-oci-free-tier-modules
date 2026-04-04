variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the network load balancer."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "nlb_display_name" {
  description = "(Optional) Display name for the network load balancer."
  type        = string
  default     = "network-load-balancer"
}

variable "subnet_id" {
  description = "(Required) OCID of the subnet for the network load balancer."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid OCI OCID (e.g. ocid1.subnet.oc1..aaaaaa...)."
  }
}

variable "is_private" {
  description = "(Optional) Whether the network load balancer is private (no public IP)."
  type        = bool
  default     = false
}

variable "backend_set_name" {
  description = "(Optional) Name of the backend set."
  type        = string
  default     = "backend-set"
}

variable "backend_set_policy" {
  description = "(Optional) Load balancing policy. Supported values: FIVE_TUPLE, THREE_TUPLE, TWO_TUPLE."
  type        = string
  default     = "FIVE_TUPLE"

  validation {
    condition     = contains(["FIVE_TUPLE", "THREE_TUPLE", "TWO_TUPLE"], var.backend_set_policy)
    error_message = "Supported values are: FIVE_TUPLE, THREE_TUPLE, TWO_TUPLE."
  }
}

variable "health_check_protocol" {
  description = "(Optional) Protocol for the health checker. Supported values: TCP, HTTP, HTTPS, UDP, DNS."
  type        = string
  default     = "TCP"

  validation {
    condition     = contains(["TCP", "HTTP", "HTTPS", "UDP", "DNS"], var.health_check_protocol)
    error_message = "Supported values are: TCP, HTTP, HTTPS, UDP, DNS."
  }
}

variable "health_check_port" {
  description = "(Optional) Port for the health checker. 0 means use the listener port. Note: this port is not validated against backend ports configured in the backends map."
  type        = number
  default     = 0
}

variable "listener_name" {
  description = "(Optional) Name of the listener."
  type        = string
  default     = "listener"
}

variable "listener_port" {
  description = "(Optional) Port for the listener."
  type        = number
  default     = 80
}

variable "listener_protocol" {
  description = "(Optional) Protocol for the listener. Use TCP or UDP for specific protocols. ANY accepts all traffic on the configured port -- use with caution."
  type        = string
  default     = "TCP"

  validation {
    condition     = contains(["TCP", "UDP", "TCP_AND_UDP", "ANY"], var.listener_protocol)
    error_message = "listener_protocol must be one of: TCP, UDP, TCP_AND_UDP, ANY."
  }
}

variable "backends" {
  description = "(Optional) Map of backends to add to the backend set. Keys are unique identifiers; values specify ip_address and port."
  type = map(object({
    ip_address = string
    port       = number
  }))
  default = {}
}

variable "nlb_defined_tags" {
  description = "(Optional) Defined tags for the network load balancer."
  type        = map(string)
  default     = {}
}

variable "nlb_freeform_tags" {
  description = "(Optional) Free-form tags for the network load balancer."
  type        = map(string)
  default     = {}
}
