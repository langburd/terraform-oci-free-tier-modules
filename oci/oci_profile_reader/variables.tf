variable "profile_name" {
  description = "The name of the OCI profile to read"
  default     = "DEFAULT"
  type        = string
  validation {
    condition     = length(var.profile_name) > 0
    error_message = "profile_name must not be empty."
  }
}
