variable "compartment_defined_tags" {
  default     = {}
  description = "(Optional) (Updatable) Defined tags for this resource. Each key is predefined and scoped to a namespace."
  type        = map(string)
}

variable "compartment_description" {
  default     = "This is a compartment."
  description = "(Required) (Updatable) The description you assign to the compartment during creation. Does not have to be unique, and it's changeable."
  type        = string
}

variable "compartment_enable_delete" {
  default     = true
  description = "(Optional) Defaults to false. If omitted or set to false the provider will implicitly import the compartment if there is a name collision, and will not actually delete the compartment on destroy or removal of the resource declaration. If set to true, the provider will throw an error on a name collision with another compartment, and will attempt to delete the compartment on destroy or removal of the resource declaration."
  type        = bool
}

variable "compartment_freeform_tags" {
  default     = {}
  description = "(Optional) (Updatable) Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace."
  type        = map(string)
}

variable "compartment_name" {
  default     = "My Compartment"
  description = "(Required) (Updatable) The name you assign to the compartment during creation. The name must be unique across all compartments in the parent compartment. Avoid entering confidential information."
  type        = string
}

variable "oci_root_compartment" {
  description = "The tenancy OCID a.k.a. root compartment, see README for CLI command to retrieve it."
  type        = string
}
