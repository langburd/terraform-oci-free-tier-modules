variable "compartment_id" {
  description = "Compartment OCID where the bucket will be created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "bucket_name" {
  description = "Name of the object storage bucket. Only a-zA-Z0-9._- characters are allowed."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.bucket_name))
    error_message = "bucket_name may contain only the characters a-zA-Z0-9._-"
  }
}

variable "bucket_access_type" {
  description = "Access type for the bucket. Supported values: NoPublicAccess, ObjectRead, ObjectReadWithoutList."
  type        = string
  default     = "NoPublicAccess"
  validation {
    condition     = contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], var.bucket_access_type)
    error_message = "Supported values are: NoPublicAccess, ObjectRead, ObjectReadWithoutList."
  }
}

variable "storage_tier" {
  description = "Storage tier for the bucket. Supported values: Standard, Archive. NOTE: This attribute is immutable after bucket creation."
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Archive"], var.storage_tier)
    error_message = "Supported values are: Standard, Archive."
  }
}

variable "versioning" {
  description = "Versioning state for the bucket. Supported values: Enabled, Suspended, Disabled."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.versioning)
    error_message = "Supported values are: Enabled, Suspended, Disabled."
  }
}

variable "auto_tiering" {
  description = "Auto tiering status for the bucket. Supported values: Disabled, InfrequentAccess."
  type        = string
  default     = "Disabled"
  validation {
    condition     = contains(["Disabled", "InfrequentAccess"], var.auto_tiering)
    error_message = "Supported values are: Disabled, InfrequentAccess."
  }
}

variable "object_events_enabled" {
  description = "Whether object-level events are emitted for this bucket."
  type        = bool
  default     = false
}

variable "bucket_defined_tags" {
  description = "Defined tags for the bucket."
  type        = map(string)
  default     = {}
}

variable "bucket_freeform_tags" {
  description = "Free-form tags for the bucket."
  type        = map(string)
  default     = {}
}
