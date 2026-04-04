# OCI APM Module

Terraform module creating an OCI Application Performance Monitoring (APM) domain.

## Usage Example

```hcl
module "apm" {
  source = "../../oci/apm"

  compartment_id   = "<compartment_ocid>"
  apm_display_name = "my-apm-domain"
  is_free_tier     = true
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 8.0, < 9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 8.0, < 9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_apm_apm_domain.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/apm_apm_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apm_defined_tags"></a> [apm\_defined\_tags](#input\_apm\_defined\_tags) | Defined tags for the APM domain resource. | `map(string)` | `{}` | no |
| <a name="input_apm_description"></a> [apm\_description](#input\_apm\_description) | (Optional) (Updatable) Description of the APM domain. | `string` | `null` | no |
| <a name="input_apm_display_name"></a> [apm\_display\_name](#input\_apm\_display\_name) | (Optional) (Updatable) Display name of the APM domain. | `string` | `"apm-domain"` | no |
| <a name="input_apm_freeform_tags"></a> [apm\_freeform\_tags](#input\_apm\_freeform\_tags) | Free-form tags for the APM domain resource. | `map(string)` | `{}` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the APM domain. | `string` | n/a | yes |
| <a name="input_is_free_tier"></a> [is\_free\_tier](#input\_is\_free\_tier) | (Optional) Indicates whether this is an Always Free resource. Defaults to true to keep within OCI Free Tier limits. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_apm_domain_id"></a> [apm\_domain\_id](#output\_apm\_domain\_id) | OCID of the APM domain. |
| <a name="output_data_upload_endpoint"></a> [data\_upload\_endpoint](#output\_data\_upload\_endpoint) | The endpoint where APM agents send data. |
<!-- END_TF_DOCS -->
