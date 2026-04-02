variable "profile_name" {
  description = "The name of the OCI profile to read"
  type        = string
  default     = "DEFAULT"
  validation {
    condition     = length(var.profile_name) > 0 && trimspace(var.profile_name) != ""
    error_message = "profile_name must not be empty or whitespace-only."
  }
}
