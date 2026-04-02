variable "create_alert_rule" {
  description = "Whether to create a budget alert rule. Note: alert variable validations (alert_type, alert_threshold, etc.) are always enforced by Terraform regardless of this setting."
  type        = bool
  default     = true
}

variable "alert_defined_tags" {
  description = "Defined tags for the alert rule."
  type        = map(string)
  default     = {}
}

variable "alert_description" {
  description = "Description for alert rule."
  type        = string
  default     = ""
}

variable "alert_display_name" {
  description = "Display name of the alert rule. Only a-zA-Z0-9.-_ characters are allowed."
  type        = string
  default     = "Alert_on_0.01_forecast_spend"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.alert_display_name))
    error_message = "alert_display_name may contain only the characters a-zA-Z0-9.-_"
  }
}

variable "alert_freeform_tags" {
  description = "Free-form tags for the alert rule."
  type        = map(string)
  default     = {}
}

variable "alert_message" {
  description = "Custom message for alert notification."
  type        = string
  default     = ""
}

variable "alert_recipients" {
  description = "The delimited list of email addresses to receive the alert when it triggers. Delimiter characters can be a comma, space, TAB, or semicolon."
  type        = string
  default     = ""
}

variable "alert_threshold" {
  description = "Threshold value for triggering the alert."
  type        = number
  default     = 1
  validation {
    condition     = var.alert_threshold > 0
    error_message = "alert_threshold must be greater than 0."
  }
}

variable "alert_threshold_type" {
  description = "Type of threshold."
  type        = string
  default     = "PERCENTAGE"
  validation {
    condition     = contains(["PERCENTAGE", "ABSOLUTE"], var.alert_threshold_type)
    error_message = "Supported values are: PERCENTAGE, ABSOLUTE."
  }
}

variable "alert_type" {
  description = "Type of alert rule."
  type        = string
  default     = "FORECAST"
  validation {
    condition     = contains(["ACTUAL", "FORECAST"], var.alert_type)
    error_message = "Supported values are: ACTUAL, FORECAST."
  }
}

variable "budget_amount" {
  description = "(Required) (Updatable) The amount of the budget expressed as a whole number in the currency of the customer's rate card."
  type        = number
  default     = 1
  validation {
    condition     = var.budget_amount >= 1
    error_message = "The amount of the budget must be equal or greater than 1."
  }
  validation {
    condition     = floor(var.budget_amount) == var.budget_amount
    error_message = "budget_amount must be a whole number (no decimals)."
  }
}

variable "budget_compartment_id" {
  description = "Compartment OCID for the budget. Must be the root tenancy OCID."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.budget_compartment_id))
    error_message = "budget_compartment_id must be a valid OCI OCID (e.g. ocid1.tenancy.oc1..aaaaaa...)."
  }
}

variable "budget_defined_tags" {
  description = "Defined tags for the budget."
  type        = map(string)
  default     = {}
}

variable "budget_description" {
  description = "Description of the budget."
  type        = string
  default     = ""
}

variable "budget_display_name" {
  description = "Display name for the budget. Only a-zA-Z0-9.-_ characters are allowed."
  type        = string
  default     = "MonthlyBudget"
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.budget_display_name))
    error_message = "budget_display_name may contain only the characters a-zA-Z0-9.-_"
  }
}

variable "budget_freeform_tags" {
  description = "Free-form tags for the budget."
  type        = map(string)
  default     = {}
}

variable "budget_processing_period_start_offset" {
  description = "(Optional) (Updatable) The number of days offset from the first day of the month, at which the budget processing period starts. In months that have fewer days than this value, processing will begin on the last day of that month. For example, for a value of 12, processing starts every month on the 12th at midnight. Valid values: 1 to 28."
  type        = number
  default     = 1
  validation {
    condition     = var.budget_processing_period_start_offset >= 1 && var.budget_processing_period_start_offset <= 28
    error_message = "budget_processing_period_start_offset must be between 1 and 28."
  }
}

variable "budget_processing_period_type" {
  description = "Processing period type (INVOICE or MONTH)."
  type        = string
  default     = "MONTH"
  validation {
    condition     = contains(["INVOICE", "MONTH"], var.budget_processing_period_type)
    error_message = "Supported values are: INVOICE, MONTH."
  }
}

variable "budget_reset_period" {
  description = "(Required) (Updatable) The reset period for the budget. Valid value is MONTHLY."
  type        = string
  default     = "MONTHLY"
  validation {
    condition     = contains(["MONTHLY"], var.budget_reset_period)
    error_message = "Supported values are: MONTHLY."
  }
}

variable "budget_target_type" {
  description = "The type of target for the budget."
  type        = string
  default     = "COMPARTMENT"
  validation {
    condition     = contains(["COMPARTMENT", "TAG"], var.budget_target_type)
    error_message = "Supported values are: COMPARTMENT, TAG."
  }
}

variable "budget_targets" {
  description = "(Required) The list of targets on which the budget is applied. If targetType is 'COMPARTMENT', the targets contain the list of compartment OCIDs. If targetType is 'TAG', the targets contain the list of cost tracking tag identifiers in the form of '{tagNamespace}.{tagKey}.{tagValue}'. Currently, the array should contain exactly one item."
  type        = list(string)
  validation {
    condition     = length(var.budget_targets) == 1
    error_message = "budget_targets must contain exactly one item."
  }
}
