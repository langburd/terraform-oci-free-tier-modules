# variable "tenancy_ocid" {
#   description = "The OCID of the tenancy."
#   type        = string
# }

# # variable "user_ocid" {
# #   description = "The OCID of the user."
# #   type        = string
# # }

# # variable "fingerprint" {
# #   description = "The fingerprint of the public key used for SSH access."
# #   type        = string
# # }

# # variable "private_key_path" {
# #   description = "The path to the private key used for SSH access."
# #   type        = string
# # }

# variable "ssh_public_key" {
#   description = "The public key used for SSH access."
#   type        = string
#   default     = ""
# }

variable "compartment_ocid" {
  description = "The OCID of the compartment."
  type        = string
}

# # variable "region" {
# #   description = "The region to create resources."
# #   type        = string
# # }

# # provider "oci" {
# #   region           = var.region
# #   tenancy_ocid     = var.tenancy_ocid
# #   user_ocid        = var.user_ocid
# #   fingerprint      = var.fingerprint
# #   private_key_path = var.private_key_path
# # }

# variable "instance_shape" {
#   description = "The shape of the instance."
#   type        = string
#   default     = "VM.Standard.A1.Flex" # Or VM.Standard.E2.1.Micro
# }

# variable "instance_shape_config_memory_in_gbs" {
#   description = "The amount of memory in GBs for the instance."
#   type        = number
#   default     = 6
# }

# variable "instance_ocpus" {
#   description = "The number of OCPUs for the instance."
#   type        = number
#   default     = 1
# }
