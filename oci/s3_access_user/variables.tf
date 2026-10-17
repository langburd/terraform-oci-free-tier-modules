variable "tenancy_id" {
  description = "(Required) OCID of the tenancy, where the IAM user and group are created."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.tenancy_id))
    error_message = "tenancy_id must be a valid OCI OCID (e.g. ocid1.tenancy.oc1..aaaaaa...)."
  }
}

variable "compartment_id" {
  description = "(Required) OCID of the compartment holding the buckets. The access policy is created there."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "name" {
  description = "(Required) Name of the IAM user, group, policy and customer secret key. Must be unique in the tenancy."
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]{1,100}$", var.name))
    error_message = "name may contain only a-zA-Z0-9._- (max 100 characters)."
  }
}

variable "bucket_names" {
  description = "(Required) Buckets the key may read and write objects in."
  type        = list(string)
  validation {
    condition     = length(var.bucket_names) > 0 && alltrue([for b in var.bucket_names : can(regex("^[a-zA-Z0-9._-]+$", b))])
    error_message = "bucket_names must be a non-empty list of bucket names (a-zA-Z0-9._- only)."
  }
}

variable "description" {
  description = "(Optional) Description for the IAM user, group and policy."
  type        = string
  default     = "S3-compatible access to selected Object Storage buckets."
}

variable "email" {
  description = "(Optional) Email address of the IAM user. Some identity-domain tenancies require one."
  type        = string
  default     = null
}

variable "defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the user, group and policy."
  type        = map(string)
  default     = {}
}

variable "freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the user, group and policy."
  type        = map(string)
  default     = {}
}
