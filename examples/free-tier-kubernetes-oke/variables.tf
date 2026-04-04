variable "oci_config_profile" {
  description = "(Required) OCI CLI config file profile name to use for authentication."
  type        = string
}

variable "compartment_name" {
  description = "Name of the OCI compartment to create."
  type        = string
  default     = "free-tier-kubernetes-oke"
}

variable "cluster_name" {
  description = "Name of the OKE cluster."
  type        = string
  default     = "free-tier-oke"
}

variable "kubernetes_version" {
  description = "Kubernetes version for the OKE cluster and node pool. Must start with 'v' (e.g. 'v1.32.1')."
  type        = string
  default     = "v1.32.1"
}

variable "node_count" {
  description = "Number of worker nodes in the node pool. Each node uses 50 GB boot volume; max 4 nodes (200 GB total free tier limit)."
  type        = number
  default     = 2
}

variable "node_ocpus" {
  description = "Number of OCPUs per worker node. Total across all nodes must not exceed 4 (free tier limit)."
  type        = number
  default     = 1
}

variable "node_memory_in_gbs" {
  description = "Memory in GB per worker node. Total across all nodes must not exceed 24 GB (free tier limit)."
  type        = number
  default     = 6
}

variable "boot_volume_size_in_gbs" {
  description = "Boot volume size in GB for each worker node. Total must not exceed 200 GB (free tier block storage limit)."
  type        = number
  default     = 50
}

variable "ssh_public_key" {
  description = "SSH public key to authorize on worker nodes for debugging access."
  type        = string
  default     = null
  sensitive   = true
}
