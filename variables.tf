variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the logging resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "log_group_display_name" {
  description = "(Optional) (Updatable) The display name of the log group."
  type        = string
  default     = "log-group"
}

variable "logs" {
  description = "(Optional) Map of logs to create. Keys are used as display names. Use log_type 'SERVICE' for service logs or 'CUSTOM' for custom logs. Note: AUDIT logs are managed at the tenancy level through OCI Audit settings and should NOT be created here -- use this module for SERVICE and CUSTOM log types only."
  type = map(object({
    log_type           = string
    source_service     = optional(string)
    source_resource    = optional(string)
    source_category    = optional(string)
    is_enabled         = optional(bool, true)
    retention_duration = optional(number, 30)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.logs :
      v.retention_duration >= 30 && v.retention_duration <= 180 && v.retention_duration % 30 == 0
    ])
    error_message = "retention_duration must be a multiple of 30 between 30 and 180 (e.g. 30, 60, 90, 120, 150, 180)."
  }

  validation {
    condition = alltrue([
      for k, v in var.logs :
      contains(["CUSTOM", "SERVICE", "AUDIT"], v.log_type)
    ])
    error_message = "log_type must be one of: CUSTOM, SERVICE, AUDIT."
  }
}

variable "logging_defined_tags" {
  description = "Defined tags for the logging resources."
  type        = map(string)
  default     = {}
}

variable "logging_freeform_tags" {
  description = "Free-form tags for the logging resources."
  type        = map(string)
  default     = {}
}
