variable "compartment_id" {
  description = "OCID of the compartment in which to create the node pool."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID."
  }
}

variable "cluster_id" {
  description = "OCID of the OKE cluster to which this node pool belongs."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.cluster_id))
    error_message = "cluster_id must be a valid OCI OCID."
  }
}

variable "node_pool_name" {
  description = "Display name for the node pool."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the node pool (e.g. v1.32.1)."
  type        = string
  validation {
    condition     = can(regex("^v", var.kubernetes_version))
    error_message = "kubernetes_version must start with 'v' (e.g. v1.32.1)."
  }
}

variable "image_id" {
  description = "OCID of the node image to use."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.image_id))
    error_message = "image_id must be a valid OCI OCID."
  }
}

variable "subnet_id" {
  description = "OCID of the subnet in which nodes will be placed."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.subnet_id))
    error_message = "subnet_id must be a valid OCI OCID."
  }
}

variable "node_shape" {
  description = "Shape of each node. Only Flex and Micro free-tier shapes are supported."
  type        = string
  default     = "VM.Standard.A1.Flex"
  validation {
    condition     = contains(["VM.Standard.A1.Flex", "VM.Standard.E2.1.Micro"], var.node_shape)
    error_message = "node_shape must be one of: VM.Standard.A1.Flex, VM.Standard.E2.1.Micro."
  }
}

variable "node_shape_ocpus" {
  description = "Number of OCPUs per node (only applies to Flex shapes)."
  type        = number
  default     = 1
  validation {
    condition     = var.node_shape_ocpus >= 1 && var.node_shape_ocpus <= 4
    error_message = "node_shape_ocpus must be between 1 and 4."
  }
}

variable "node_shape_memory_in_gbs" {
  description = "Memory in GBs per node (only applies to Flex shapes)."
  type        = number
  default     = 6
  validation {
    condition     = var.node_shape_memory_in_gbs >= 1 && var.node_shape_memory_in_gbs <= 24
    error_message = "node_shape_memory_in_gbs must be between 1 and 24."
  }
}

variable "node_count" {
  description = "Total number of nodes across all ADs."
  type        = number
  default     = 2
  validation {
    condition     = var.node_count >= 1
    error_message = "node_count must be at least 1."
  }
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GBs for each node."
  type        = number
  default     = 50
  validation {
    condition     = var.boot_volume_size_in_gbs >= 50 && var.boot_volume_size_in_gbs <= 200
    error_message = "boot_volume_size_in_gbs must be between 50 and 200."
  }
}

variable "nsg_ids" {
  description = "List of NSG OCIDs to associate with node pool VNICs."
  type        = list(string)
  default     = []
}

variable "ssh_public_key" {
  description = "SSH public key to inject into nodes. Must start with 'ssh-' or 'ecdsa-', or be null."
  type        = string
  default     = null
  validation {
    condition     = var.ssh_public_key == null || can(regex("^(ssh-|ecdsa-)", var.ssh_public_key))
    error_message = "ssh_public_key must be null or start with 'ssh-' or 'ecdsa-'."
  }
}

variable "node_pool_defined_tags" {
  description = "Defined tags to apply to the node pool."
  type        = map(string)
  default     = {}
}

variable "node_pool_freeform_tags" {
  description = "Freeform tags to apply to the node pool."
  type        = map(string)
  default     = {}
}
