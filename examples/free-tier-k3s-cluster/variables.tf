variable "oci_config_profile" {
  description = "(Required) OCI CLI config file profile name to use for authentication."
  type        = string
}

variable "compartment_name" {
  description = "Name of the OCI compartment to create."
  type        = string
  default     = "free-tier-k3s-cluster"
}

variable "k3s_version" {
  description = "K3s version to install. Must start with 'v' (e.g. 'v1.31.12+k3s1')."
  type        = string
  default     = "v1.31.12+k3s1"
}
