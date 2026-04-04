variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the compute instance."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "availability_domain_number" {
  description = "(Optional) 1-indexed availability domain number used to select the AD for the instance."
  type        = number
  default     = 1
  validation {
    condition     = var.availability_domain_number >= 1 && var.availability_domain_number <= 3
    error_message = "availability_domain_number must be between 1 and 3."
  }
}

variable "shape" {
  description = "(Optional) The shape of the instance. Must be one of the supported Free Tier shapes."
  type        = string
  default     = "VM.Standard.E2.1.Micro"
  validation {
    condition     = contains(["VM.Standard.E2.1.Micro", "VM.Standard.A1.Flex"], var.shape)
    error_message = "shape must be one of: VM.Standard.E2.1.Micro, VM.Standard.A1.Flex."
  }
}

variable "shape_ocpus" {
  description = "(Optional) Number of OCPUs for Flex shapes. Ignored for fixed shapes."
  type        = number
  default     = 1
  validation {
    condition     = var.shape_ocpus >= 1 && var.shape_ocpus <= 4
    error_message = "shape_ocpus must be between 1 and 4."
  }
}

variable "shape_memory_in_gbs" {
  description = "(Optional) Amount of memory in GBs for Flex shapes. Ignored for fixed shapes."
  type        = number
  default     = 6
  validation {
    condition     = var.shape_memory_in_gbs >= 1 && var.shape_memory_in_gbs <= 24
    error_message = "shape_memory_in_gbs must be between 1 and 24."
  }
}

variable "image_id" {
  description = "(Required) The OCID of the image to use for the instance boot volume."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.image_id))
    error_message = "image_id must be a valid OCI OCID (e.g. ocid1.image.oc1..aaaaaa...)."
  }
}

variable "subnet_id" {
  description = "(Required) The OCID of the subnet in which to place the instance's primary VNIC."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid OCI OCID (e.g. ocid1.subnet.oc1..aaaaaa...)."
  }
}

variable "assign_public_ip" {
  description = "(Optional) Whether to assign a public IP to the instance's primary VNIC. Defaults to false (secure). Set to true only when the instance must be reachable from the internet."
  type        = bool
  default     = false
}

variable "ssh_authorized_keys" {
  description = "(Optional) One or more public SSH keys to place in the instance's authorized_keys file. Null omits the key from instance metadata."
  type        = string
  default     = null
  sensitive   = true
  validation {
    condition     = var.ssh_authorized_keys == null || can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256) ", var.ssh_authorized_keys))
    error_message = "ssh_authorized_keys must be null or start with a valid key type prefix (ssh-rsa, ssh-ed25519, or ecdsa-sha2-nistp256)."
  }
}

variable "user_data" {
  description = "(Optional) Base64-encoded cloud-init user data to pass to the instance. Treat cloud-init scripts as trusted code — they run as root on first boot and are visible in the OCI console. Null omits user_data from instance metadata."
  type        = string
  default     = null
}

variable "boot_volume_size_in_gbs" {
  description = "(Optional) Size of the boot volume in GBs."
  type        = number
  default     = 50
  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 200
    error_message = "boot_volume_size_in_gbs must be between 50 and 200."
  }
}

variable "instance_display_name" {
  description = "(Optional) A user-friendly name for the instance."
  type        = string
  default     = "instance"
}

variable "nsg_ids" {
  description = "(Optional) List of Network Security Group OCIDs to associate with the instance's primary VNIC."
  type        = list(string)
  default     = []
}

variable "compute_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the compute instance."
  type        = map(string)
  default     = {}
}

variable "compute_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the compute instance."
  type        = map(string)
  default     = {}
}
