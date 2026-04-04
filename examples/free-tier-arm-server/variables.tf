variable "oci_config_profile" {
  description = "(Required) OCI CLI config file profile name to use for authentication."
  type        = string
}

variable "compartment_name" {
  description = "(Optional) Name of the OCI compartment to create."
  type        = string
  default     = "free-tier-arm-server"
}

variable "ssh_authorized_keys" {
  description = "(Optional) SSH public key to authorize on compute instances. If null, SSH key authentication is disabled."
  type        = string
  default     = null
  sensitive   = true
}
