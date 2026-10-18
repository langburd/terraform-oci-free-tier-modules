variable "compartment_id" {
  description = "(Required) OCID of the compartment in which to create the certificate authority."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "kms_key_id" {
  description = "(Required) OCID of the KMS key used to protect the certificate authority's private key."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*(\\.[a-z0-9-]+)?\\.[a-z0-9]+$", var.kms_key_id))
    error_message = "kms_key_id must be a valid OCI OCID (e.g. ocid1.key.oc1..aaaaaa...)."
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

  validation {
    condition     = contains(["ROOT_CA_GENERATED_INTERNALLY", "SUBORDINATE_CA_ISSUED_BY_INTERNAL_CA"], var.ca_config_type)
    error_message = "ca_config_type must be one of: ROOT_CA_GENERATED_INTERNALLY, SUBORDINATE_CA_ISSUED_BY_INTERNAL_CA."
  }
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
  description = "(Optional) RFC3339 timestamp after which the CA certificate is no longer valid. Defaults to 3 years from plan time. Must include non-zero fractional seconds (e.g. .001Z); the API rejects timestamps without them. Rotate CA certificates before expiry -- use OCI Certificate Authority rotation features for seamless renewal."
  type        = string
  default     = null

  validation {
    condition     = var.ca_validity_time_of_validity_not_after == null || can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d*[1-9]\\d*Z$", var.ca_validity_time_of_validity_not_after))
    error_message = "ca_validity_time_of_validity_not_after must be RFC3339 UTC with non-zero fractional seconds (e.g. 2036-10-18T00:00:00.001Z): the Certificates API rejects timestamps without fractional seconds and the provider strips .000."
  }
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

  validation {
    condition     = contains(["ISSUED_BY_INTERNAL_CA", "MANAGED_EXTERNALLY_ISSUED_BY_INTERNAL_CA", "IMPORTED"], var.certificate_config_type)
    error_message = "certificate_config_type must be one of: ISSUED_BY_INTERNAL_CA, MANAGED_EXTERNALLY_ISSUED_BY_INTERNAL_CA, IMPORTED."
  }
}

variable "certificate_common_name" {
  description = "(Optional) Common name (CN) for the certificate subject. Required when create_certificate is true."
  type        = string
  default     = null

  validation {
    condition     = !var.create_certificate || var.certificate_common_name != null
    error_message = "certificate_common_name must be set when create_certificate is true."
  }
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
  description = "(Optional) RFC3339 timestamp after which the certificate is no longer valid. Defaults to 1 year from plan time. Must include non-zero fractional seconds (e.g. .001Z); the API rejects timestamps without them. Certificates should be rotated annually or sooner -- automate renewal to avoid service outages."
  type        = string
  default     = null

  validation {
    condition     = var.certificate_validity_time_of_validity_not_after == null || can(regex("^\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}\\.\\d*[1-9]\\d*Z$", var.certificate_validity_time_of_validity_not_after))
    error_message = "certificate_validity_time_of_validity_not_after must be RFC3339 UTC with non-zero fractional seconds (e.g. 2036-10-18T00:00:00.001Z): the Certificates API rejects timestamps without fractional seconds and the provider strips .000."
  }
}

variable "certificate_subject_alternative_names" {
  description = "(Optional) Subject alternative names for the certificate, as a list of { type, value } objects. type is DNS or IP."
  type = list(object({
    type  = string
    value = string
  }))
  default = []

  validation {
    condition     = alltrue([for san in var.certificate_subject_alternative_names : contains(["DNS", "IP"], san.type)])
    error_message = "Each certificate_subject_alternative_names type must be one of: DNS, IP."
  }

  validation {
    condition = alltrue([
      for san in var.certificate_subject_alternative_names :
      san.type == "IP" ? can(cidrhost("${san.value}/32", 0)) : (
        san.type == "DNS" ? can(regex("^(\\*\\.)?[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?(\\.[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?)*$", san.value)) : true
      )
    ])
    error_message = "Each certificate_subject_alternative_names value must be an IP address (type IP) or a non-empty hostname without whitespace, optionally prefixed with *. (type DNS)."
  }
}

variable "certificate_renewal_rule" {
  description = "(Optional) Automatic renewal rule for the certificate: renewal_interval and advance_renewal_period as ISO-8601 durations (e.g. P365D and P30D). Null disables automatic renewal."
  type = object({
    renewal_interval       = string
    advance_renewal_period = string
  })
  default = null

  validation {
    condition = var.certificate_renewal_rule == null || alltrue([
      for d in [var.certificate_renewal_rule.renewal_interval, var.certificate_renewal_rule.advance_renewal_period] :
      d == null || can(regex("^P(\\d+[YMWD])+$", d))
    ])
    error_message = "certificate_renewal_rule renewal_interval and advance_renewal_period must be ISO-8601 durations such as P365D, P30D or P1Y."
  }
}

variable "create_kms_policy" {
  description = "(Optional) Whether to create the IAM policy that lets the certificate authority use kms_key_id. Static boolean; the policy is created before the CA."
  type        = bool
  default     = false
}

variable "kms_compartment_id" {
  description = "(Optional) OCID of the compartment holding the KMS key, when it differs from compartment_id. With create_kms_policy, the policy is created there. Defaults to compartment_id."
  type        = string
  default     = null

  validation {
    condition     = var.kms_compartment_id == null || can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.kms_compartment_id))
    error_message = "kms_compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...) or null."
  }
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
