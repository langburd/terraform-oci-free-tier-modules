variable "profile1" {
  description = "OCI config profile name for the first tenancy. Must exist in ~/.oci/config."
  type        = string

  validation {
    condition     = length(trimspace(var.profile1)) > 0
    error_message = "profile1 must not be empty."
  }
}

variable "profile2" {
  description = "OCI config profile name for the second tenancy. Must exist in ~/.oci/config."
  type        = string

  validation {
    condition     = length(trimspace(var.profile2)) > 0
    error_message = "profile2 must not be empty."
  }
}

variable "budget_amount" {
  description = "Monthly budget cap in the currency of your OCI rate card. Applied to both tenancies."
  type        = number
  default     = 1

  validation {
    condition     = var.budget_amount > 0
    error_message = "budget_amount must be a positive number."
  }
}

variable "alert_recipients" {
  description = "Comma-separated email address(es) to notify when forecasted spend is on track to exceed the budget."
  type        = string

  validation {
    condition     = length(trimspace(var.alert_recipients)) > 0
    error_message = "alert_recipients must not be empty."
  }
}
