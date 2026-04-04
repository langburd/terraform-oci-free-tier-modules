variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the load balancer."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "lb_display_name" {
  description = "(Optional) Display name for the load balancer."
  type        = string
  default     = "load-balancer"
}

variable "subnet_ids" {
  description = "(Required) List of subnet OCIDs for the load balancer. Must contain at least one element."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 1
    error_message = "subnet_ids must contain at least one subnet OCID."
  }
}

variable "is_private" {
  description = "(Optional) Whether the load balancer is private (no public IP)."
  type        = bool
  default     = false
}

variable "backend_set_name" {
  description = "(Optional) Name of the backend set."
  type        = string
  default     = "backend-set"
}

variable "backend_set_policy" {
  description = "(Optional) Load balancing policy. Supported values: ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH."
  type        = string
  default     = "ROUND_ROBIN"

  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "IP_HASH"], var.backend_set_policy)
    error_message = "Supported values are: ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH."
  }
}

variable "health_check_protocol" {
  description = "(Optional) Protocol for the health checker. Supported values: HTTP, HTTPS, TCP."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.health_check_protocol)
    error_message = "Supported values are: HTTP, HTTPS, TCP."
  }
}

variable "health_check_port" {
  description = "(Optional) Port for the health checker."
  type        = number
  default     = 80
}

variable "health_check_url_path" {
  description = "(Optional) URL path for the health checker (HTTP/HTTPS only)."
  type        = string
  default     = "/"
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
  description = "(Optional) Protocol for the listener."
  type        = string
  default     = "HTTP"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP", "UDP"], var.listener_protocol)
    error_message = "listener_protocol must be one of: HTTP, HTTPS, TCP, UDP."
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

variable "lb_defined_tags" {
  description = "(Optional) Defined tags for the load balancer."
  type        = map(string)
  default     = {}
}

variable "lb_freeform_tags" {
  description = "(Optional) Free-form tags for the load balancer."
  type        = map(string)
  default     = {}
}
