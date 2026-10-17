variable "compartment_id" {
  description = "(Required) OCID of the compartment where the secrets are created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vault_id" {
  description = "(Required) OCID of the vault holding the secrets."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vault_id))
    error_message = "vault_id must be a valid OCI OCID (e.g. ocid1.vault.oc1..aaaaaa...)."
  }
}

variable "key_id" {
  description = "(Required) OCID of the master encryption key used to encrypt the secrets."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.key_id))
    error_message = "key_id must be a valid OCI OCID (e.g. ocid1.key.oc1..aaaaaa...)."
  }
}

variable "secrets" {
  description = "(Required) Secrets to create, keyed by secret name. content is the plain-text value (base64-encoded by the module); a change creates a new secret version."
  type = map(object({
    content     = string
    description = optional(string)
  }))
  sensitive = true
  validation {
    condition     = alltrue([for name in keys(var.secrets) : can(regex("^[a-zA-Z0-9._-]{1,255}$", name))])
    error_message = "Secret names may contain only a-zA-Z0-9._- (max 255 characters)."
  }
}

variable "defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the secrets."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the secrets."
  type        = map(string)
  default     = {}
}
