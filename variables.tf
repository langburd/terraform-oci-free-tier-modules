variable "compartment_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for this resource. Each key is predefined and scoped to a namespace."
  type        = map(string)
  default     = {}
}

variable "compartment_description" {
  description = "(Required) (Updatable) The description you assign to the compartment during creation. Does not have to be unique, and it's changeable."
  type        = string
  default     = "This is a compartment."
}

variable "compartment_enable_delete" {
  description = "(Optional) Defaults to true. If set to false the provider will implicitly import the compartment if there is a name collision, and will not actually delete the compartment on destroy or removal of the resource declaration. If set to true, the provider will throw an error on a name collision with another compartment, and will attempt to delete the compartment on destroy or removal of the resource declaration."
  type        = bool
  default     = true
}

variable "compartment_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace."
  type        = map(string)
  default     = {}
}

variable "compartment_name" {
  description = "(Optional) (Updatable) The name you assign to the compartment during creation. The name must be unique across all compartments in the parent compartment. Avoid entering confidential information."
  type        = string
  default     = "My Compartment"
  validation {
    condition     = length(var.compartment_name) > 0 && length(var.compartment_name) <= 100
    error_message = "compartment_name must be between 1 and 100 characters."
  }
}

variable "oci_root_compartment" {
  description = "The tenancy OCID a.k.a. root compartment, see README for CLI command to retrieve it."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.oci_root_compartment))
    error_message = "oci_root_compartment must be a valid OCI OCID (e.g. ocid1.tenancy.oc1..aaaaaa...)."
  }
}
