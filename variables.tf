variable "compartment_id" {
  description = "(Required) The OCID of the compartment where the notification topic will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "topic_name" {
  description = "(Required) The name of the topic. Topic names must be unique across the entire tenancy."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,256}$", var.topic_name))
    error_message = "topic_name must be 1–256 characters and contain only letters, numbers, hyphens, and underscores."
  }
}

variable "topic_description" {
  description = "(Optional) (Updatable) The description of the topic."
  type        = string
  default     = null
}

variable "subscriptions" {
  description = "(Optional) A map of subscriptions to create on the topic. Each subscription requires a protocol and endpoint. Supported protocols: EMAIL, HTTPS, SLACK, PAGERDUTY, GFC."
  type = map(object({
    protocol = string
    endpoint = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.subscriptions :
      contains(["EMAIL", "HTTPS", "SLACK", "PAGERDUTY", "GFC"], v.protocol)
    ])
    error_message = "Each subscription protocol must be one of: EMAIL, HTTPS, SLACK, PAGERDUTY, GFC."
  }
}

variable "notifications_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the notification topic resource."
  type        = map(string)
  default     = {}
}

variable "notifications_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the notification topic resource."
  type        = map(string)
  default     = {}
}
