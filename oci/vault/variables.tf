variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the vault."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vault_display_name" {
  description = "(Optional) Display name for the vault."
  type        = string
  default     = "vault"
}

variable "vault_type" {
  description = "(Optional) Type of vault. DEFAULT is free tier. WARNING: VIRTUAL_PRIVATE vault type incurs cost and cannot be changed after creation."
  type        = string
  default     = "DEFAULT"

  validation {
    condition     = contains(["DEFAULT", "VIRTUAL_PRIVATE"], var.vault_type)
    error_message = "Supported values are: DEFAULT, VIRTUAL_PRIVATE. WARNING: VIRTUAL_PRIVATE incurs cost and cannot be changed after creation."
  }
}

variable "create_key" {
  description = "(Optional) Whether to create a KMS key in the vault."
  type        = bool
  default     = true
}

variable "key_display_name" {
  description = "(Optional) Display name for the KMS key."
  type        = string
  default     = "key"
}

variable "key_algorithm" {
  description = "(Optional) Algorithm for the KMS key. Supported values: AES, RSA, ECDSA."
  type        = string
  default     = "AES"

  validation {
    condition     = contains(["AES", "RSA", "ECDSA"], var.key_algorithm)
    error_message = "Supported values are: AES, RSA, ECDSA."
  }
}

variable "key_length" {
  description = "(Optional) Key length in bytes. For AES: 16, 24, or 32. For RSA: 256, 384, or 512. For ECDSA: 32, 48, or 66."
  type        = number
  default     = 32
}

variable "key_protection_mode" {
  description = "(Optional) Protection mode for the key. SOFTWARE (default) is free and suitable for development. HSM (hardware security module) is recommended for production workloads handling sensitive data, but incurs cost and limits key version counts."
  type        = string
  default     = "SOFTWARE"

  validation {
    condition     = contains(["SOFTWARE", "HSM"], var.key_protection_mode)
    error_message = "Supported values are: SOFTWARE, HSM."
  }
}

variable "vault_defined_tags" {
  description = "(Optional) Defined tags for the vault and key."
  type        = map(string)
  default     = {}
}

variable "vault_freeform_tags" {
  description = "(Optional) Free-form tags for the vault and key."
  type        = map(string)
  default     = {}
}
