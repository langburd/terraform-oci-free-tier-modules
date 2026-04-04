variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the certificate authority."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "ca_name" {
  description = "(Required) Name of the certificate authority."
  type        = string
}

variable "ca_config_type" {
  description = "(Optional) Configuration type for the certificate authority."
  type        = string
  default     = "ROOT_CA_GENERATED_INTERNALLY"
}

variable "ca_common_name" {
  description = "(Required) Common name (CN) for the certificate authority subject."
  type        = string
}

variable "ca_signing_algorithm" {
  description = "(Optional) Signing algorithm for the certificate authority."
  type        = string
  default     = "SHA256_WITH_RSA"
}

variable "ca_validity_time_of_validity_not_after" {
  description = "(Optional) RFC3339 timestamp after which the CA certificate is no longer valid."
  type        = string
  default     = "2035-01-01T00:00:00Z"
}

variable "create_certificate" {
  description = "(Optional) Whether to create a certificate issued by the certificate authority."
  type        = bool
  default     = false
}

variable "certificate_name" {
  description = "(Optional) Name of the certificate."
  type        = string
  default     = "certificate"
}

variable "certificate_config_type" {
  description = "(Optional) Configuration type for the certificate."
  type        = string
  default     = "ISSUED_BY_INTERNAL_CA"
}

variable "certificate_common_name" {
  description = "(Optional) Common name (CN) for the certificate subject. Required when create_certificate is true."
  type        = string
  default     = null
}

variable "certificate_profile_type" {
  description = "(Optional) Profile type for the certificate."
  type        = string
  default     = "TLS_SERVER_OR_CLIENT"
}

variable "certificate_key_algorithm" {
  description = "(Optional) Key algorithm for the certificate."
  type        = string
  default     = "RSA4096"
}

variable "certificate_validity_time_of_validity_not_after" {
  description = "(Optional) RFC3339 timestamp after which the certificate is no longer valid."
  type        = string
  default     = "2034-01-01T00:00:00Z"
}

variable "certificates_defined_tags" {
  description = "(Optional) Defined tags for the certificate authority and certificate."
  type        = map(string)
  default     = {}
}

variable "certificates_freeform_tags" {
  description = "(Optional) Free-form tags for the certificate authority and certificate."
  type        = map(string)
  default     = {}
}
