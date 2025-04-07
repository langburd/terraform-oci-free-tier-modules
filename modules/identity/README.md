# identity module

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.15.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.15.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_compartment) | resource |
| [oci_identity_compartments.existing](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartments) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_defined_tags"></a> [compartment\_defined\_tags](#input\_compartment\_defined\_tags) | (Optional) (Updatable) Defined tags for this resource. Each key is predefined and scoped to a namespace. | `map(string)` | `{}` | no |
| <a name="input_compartment_description"></a> [compartment\_description](#input\_compartment\_description) | (Required) (Updatable) The description you assign to the compartment during creation. Does not have to be unique, and it's changeable. | `string` | `"This is a compartment."` | no |
| <a name="input_compartment_enable_delete"></a> [compartment\_enable\_delete](#input\_compartment\_enable\_delete) | (Optional) Defaults to false. If omitted or set to false the provider will implicitly import the compartment if there is a name collision, and will not actually delete the compartment on destroy or removal of the resource declaration. If set to true, the provider will throw an error on a name collision with another compartment, and will attempt to delete the compartment on destroy or removal of the resource declaration. | `bool` | `true` | no |
| <a name="input_compartment_freeform_tags"></a> [compartment\_freeform\_tags](#input\_compartment\_freeform\_tags) | (Optional) (Updatable) Free-form tags for this resource. Each tag is a simple key-value pair with no predefined name, type, or namespace. | `map(string)` | `{}` | no |
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Required) (Updatable) The name you assign to the compartment during creation. The name must be unique across all compartments in the parent compartment. Avoid entering confidential information. | `string` | `"My Compartment"` | no |
| <a name="input_oci_root_compartment"></a> [oci\_root\_compartment](#input\_oci\_root\_compartment) | The tenancy OCID a.k.a. root compartment, see README for CLI command to retrieve it. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compartment_defined_tags"></a> [compartment\_defined\_tags](#output\_compartment\_defined\_tags) | The defined tags of the compartment |
| <a name="output_compartment_description"></a> [compartment\_description](#output\_compartment\_description) | The description of the compartment |
| <a name="output_compartment_freeform_tags"></a> [compartment\_freeform\_tags](#output\_compartment\_freeform\_tags) | The freeform tags of the compartment |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | The OCID of the compartment |
| <a name="output_compartment_name"></a> [compartment\_name](#output\_compartment\_name) | The name of the compartment |
| <a name="output_root_compartment_id"></a> [root\_compartment\_id](#output\_root\_compartment\_id) | The OCID of the root compartment |
<!-- END_TF_DOCS -->
