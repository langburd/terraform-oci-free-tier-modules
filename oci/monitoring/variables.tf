variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the alarm."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "alarm_display_name" {
  description = "(Required) A user-friendly name for the alarm."
  type        = string
}

variable "metric_compartment_id" {
  description = "(Required) The OCID of the compartment containing the metric being evaluated by the alarm."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.metric_compartment_id))
    error_message = "metric_compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "alarm_namespace" {
  description = "(Required) The source service or application emitting the metric that is evaluated by the alarm. For example: oci_computeagent."
  type        = string
}

variable "alarm_query" {
  description = "(Required) The Monitoring Query Language (MQL) expression that defines the metric being evaluated by the alarm. For example: CpuUtilization[1m].mean() > 80."
  type        = string
}

variable "alarm_severity" {
  description = "(Optional) (Updatable) The perceived type of response required when the alarm is in the firing state. Valid values: CRITICAL, ERROR, WARNING, INFO."
  type        = string
  default     = "WARNING"

  validation {
    condition     = contains(["CRITICAL", "ERROR", "WARNING", "INFO"], var.alarm_severity)
    error_message = "alarm_severity must be one of: CRITICAL, ERROR, WARNING, INFO."
  }
}

variable "alarm_is_enabled" {
  description = "(Optional) (Updatable) Whether the alarm is enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "destinations" {
  description = "(Required) A list of destinations to which the notifications for this alarm are sent. Each destination is a topic OCID."
  type        = list(string)

  validation {
    condition = alltrue([
      for d in var.destinations :
      can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", d))
    ])
    error_message = "Each destination must be a valid OCI OCID (e.g. ocid1.onstopic.oc1..aaaaaa...)."
  }
}

variable "alarm_body" {
  description = "(Optional) (Updatable) The human-readable content of the delivered alarm notification."
  type        = string
  default     = null
}

variable "alarm_defined_tags" {
  description = "Defined tags for the alarm resource."
  type        = map(string)
  default     = {}
}

variable "alarm_freeform_tags" {
  description = "Free-form tags for the alarm resource."
  type        = map(string)
  default     = {}
}
