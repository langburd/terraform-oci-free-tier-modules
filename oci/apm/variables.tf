variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the APM domain."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "apm_display_name" {
  description = "(Optional) (Updatable) Display name of the APM domain."
  type        = string
  default     = "apm-domain"
}

variable "apm_description" {
  description = "(Optional) (Updatable) Description of the APM domain."
  type        = string
  default     = null
}

variable "is_free_tier" {
  description = "(Optional) Indicates whether this is an Always Free resource. Defaults to true to keep within OCI Free Tier limits."
  type        = bool
  default     = true
}

variable "apm_defined_tags" {
  description = "Defined tags for the APM domain resource."
  type        = map(string)
  default     = {}
}

variable "apm_freeform_tags" {
  description = "Free-form tags for the APM domain resource."
  type        = map(string)
  default     = {}
}
