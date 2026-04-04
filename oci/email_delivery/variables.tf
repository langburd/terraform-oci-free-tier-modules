variable "compartment_id" {
  description = "(Required) The OCID of the compartment containing the email delivery resources."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "email_domain_name" {
  description = "(Required) The name of the email domain (e.g. example.com)."
  type        = string
}

variable "sender_email_address" {
  description = "(Required) The email address of the sender."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.sender_email_address))
    error_message = "sender_email_address must be a valid email address (e.g. noreply@example.com)."
  }
}

variable "create_dkim" {
  description = "(Optional) Whether to create a DKIM record for the email domain. Defaults to true."
  type        = bool
  default     = true
}

variable "dkim_name" {
  description = "(Optional) The name of the DKIM selector. Used as the DKIM selector prefix."
  type        = string
  default     = "dkim"
}

variable "email_defined_tags" {
  description = "Defined tags for the email delivery resources."
  type        = map(string)
  default     = {}
}

variable "email_freeform_tags" {
  description = "Free-form tags for the email delivery resources."
  type        = map(string)
  default     = {}
}
