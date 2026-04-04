variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the service connector."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "connector_display_name" {
  description = "(Optional) (Updatable) A user-friendly name for the service connector."
  type        = string
  default     = "service-connector"
}

variable "connector_description" {
  description = "(Optional) (Updatable) The description of the service connector."
  type        = string
  default     = null
}

variable "source_kind" {
  description = "(Required) The type of source for the service connector. Valid values: logging, monitoring, streaming."
  type        = string

  validation {
    condition     = contains(["logging", "monitoring", "streaming"], var.source_kind)
    error_message = "source_kind must be one of: logging, monitoring, streaming."
  }
}

variable "target_kind" {
  description = "(Required) The type of target for the service connector. Valid values: objectStorage, notifications, streaming, monitoring, functions, loggingAnalytics."
  type        = string

  validation {
    condition     = contains(["objectStorage", "notifications", "streaming", "monitoring", "functions", "loggingAnalytics"], var.target_kind)
    error_message = "target_kind must be one of: objectStorage, notifications, streaming, monitoring, functions, loggingAnalytics."
  }
}

variable "source_log_sources" {
  description = "(Optional) List of log sources for logging source kind. Each entry specifies compartment_id and optionally log_group_id and log_id."
  type = list(object({
    compartment_id = string
    log_group_id   = optional(string)
    log_id         = optional(string)
  }))
  default = []
}

variable "target_object_storage_bucket" {
  description = "(Optional) The target object storage bucket name. Required when target_kind is objectStorage."
  type        = string
  default     = null
}

variable "target_object_storage_namespace" {
  description = "(Optional) The target object storage namespace. Required when target_kind is objectStorage."
  type        = string
  default     = null
}

variable "target_topic_id" {
  description = "(Optional) The OCID of the target notifications topic. Required when target_kind is notifications."
  type        = string
  default     = null
}

variable "connector_state" {
  description = "(Optional) (Updatable) The target state for the service connector. Valid values: ACTIVE, INACTIVE."
  type        = string
  default     = "ACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.connector_state)
    error_message = "connector_state must be one of: ACTIVE, INACTIVE."
  }
}

variable "connector_defined_tags" {
  description = "Defined tags for the service connector resource."
  type        = map(string)
  default     = {}
}

variable "connector_freeform_tags" {
  description = "Free-form tags for the service connector resource."
  type        = map(string)
  default     = {}
}
