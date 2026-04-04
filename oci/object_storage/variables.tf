variable "compartment_id" {
  description = "(Required) Compartment OCID where the bucket will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "bucket_name" {
  description = "(Required) Name of the object storage bucket. Only a-zA-Z0-9._- characters are allowed."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.bucket_name))
    error_message = "bucket_name may contain only the characters a-zA-Z0-9._-"
  }
}

variable "bucket_access_type" {
  description = "(Optional) (Updatable) Access type for the bucket. Supported values: NoPublicAccess, ObjectRead, ObjectReadWithoutList. Set allow_public_access = true before using ObjectRead or ObjectReadWithoutList."
  type        = string
  default     = "NoPublicAccess"
  validation {
    condition     = contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], var.bucket_access_type)
    error_message = "Supported values are: NoPublicAccess, ObjectRead, ObjectReadWithoutList."
  }
  validation {
    condition     = var.bucket_access_type == "NoPublicAccess" || var.allow_public_access == true
    error_message = "allow_public_access must be set to true before using ObjectRead or ObjectReadWithoutList access types."
  }
}

variable "allow_public_access" {
  description = "(Optional) Safety guard: must be set to true before bucket_access_type can be set to ObjectRead or ObjectReadWithoutList. Defaults to false to prevent accidental public exposure."
  type        = bool
  default     = false
}

variable "storage_tier" {
  description = "(Optional) Storage tier for the bucket. Supported values: Standard, Archive. NOTE: This attribute is immutable after bucket creation."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Archive"], var.storage_tier)
    error_message = "Supported values are: Standard, Archive."
  }
}

variable "versioning" {
  description = "(Optional) (Updatable) Versioning state for the bucket. Defaults to Enabled for data protection. Supported values: Enabled, Suspended, Disabled."
  type        = string
  default     = "Enabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning)
    error_message = "Supported values are: Enabled, Suspended, Disabled."
  }
}

variable "auto_tiering" {
  description = "(Optional) (Updatable) Auto tiering status for the bucket. Supported values: Disabled, InfrequentAccess."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "InfrequentAccess"], var.auto_tiering)
    error_message = "Supported values are: Disabled, InfrequentAccess."
  }
}

variable "object_events_enabled" {
  description = "(Optional) (Updatable) Whether object-level events are emitted for this bucket. Defaults to true to enable audit trails."
  type        = bool
  default     = true
}

variable "bucket_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the bucket."
  type        = map(string)
  default     = {}
}

variable "bucket_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the bucket."
  type        = map(string)
  default     = {}
}

variable "kms_key_id" {
  description = "(Optional) The OCID of a KMS key for customer-managed encryption (CMK). Null uses Oracle-managed encryption. Note: CMK requires a paid OCI Vault -- free-tier users should leave this null."
  type        = string
  default     = null
  validation {
    condition     = var.kms_key_id == null || can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.kms_key_id))
    error_message = "kms_key_id must be a valid OCI OCID or null."
  }
}
