variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the block volume."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "availability_domain" {
  description = "(Required) The availability domain in which to create the block volume."
  type        = string
  validation {
    condition     = length(trimspace(var.availability_domain)) > 0
    error_message = "availability_domain must be a non-empty string."
  }
}

variable "volume_display_name" {
  description = "(Optional) A user-friendly name for the block volume."
  type        = string
  default     = "block-volume"
}

variable "volume_size_in_gbs" {
  description = "(Optional) Size of the block volume in GBs. Defaults to 50 to stay within Free Tier limits (200GB total including boot volumes)."
  type        = number
  default     = 50
  validation {
    condition     = var.volume_size_in_gbs >= 50 && var.volume_size_in_gbs <= 200
    error_message = "volume_size_in_gbs must be between 50 and 200."
  }
}

variable "vpus_per_gb" {
  description = "(Optional) Volume performance units per GB. Must be a multiple of 10 between 0 and 120. Values of 0 and 10 are included in the Always Free tier. Values of 20 (Higher Performance) and above may incur charges."
  type        = number
  default     = 10
  validation {
    condition     = var.vpus_per_gb >= 0 && var.vpus_per_gb <= 120 && var.vpus_per_gb % 10 == 0
    error_message = "vpus_per_gb must be 0, 10, 20, 30, ..., 120. Values above 20 are Ultra High Performance and may incur charges."
  }
}

variable "instance_id" {
  description = "(Optional) The OCID of the instance to attach this volume to. When null, no volume attachment is created."
  type        = string
  default     = null
  validation {
    condition     = var.instance_id == null || can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.instance_id))
    error_message = "instance_id must be a valid OCI OCID (e.g. ocid1.instance.oc1..aaaaaa...) or null."
  }
}

variable "attachment_type" {
  description = "(Optional) The type of volume attachment. Must be 'iscsi' or 'paravirtualized'."
  type        = string
  default     = "paravirtualized"
  validation {
    condition     = contains(["iscsi", "paravirtualized"], var.attachment_type)
    error_message = "attachment_type must be one of: iscsi, paravirtualized."
  }
}

variable "is_read_only" {
  description = "(Optional) Whether the attachment is read-only."
  type        = bool
  default     = false
}

variable "volume_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the block volume."
  type        = map(string)
  default     = {}
}

variable "volume_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the block volume."
  type        = map(string)
  default     = {}
}
