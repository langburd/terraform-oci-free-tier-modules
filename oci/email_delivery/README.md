# OCI Email Delivery Module

Terraform module creating OCI Email Delivery resources including an email domain, sender, and optional DKIM record.

## Usage Example

```hcl
module "email_delivery" {
  source = "../../oci/email_delivery"

  compartment_id       = "<compartment_ocid>"
  email_domain_name    = "example.com"
  sender_email_address = "noreply@example.com"
  create_dkim          = true
  dkim_name            = "dkim"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_email_dkim.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/email_dkim) | resource |
| [oci_email_email_domain.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/email_email_domain) | resource |
| [oci_email_sender.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/email_sender) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the email delivery resources. | `string` | n/a | yes |
| <a name="input_create_dkim"></a> [create\_dkim](#input\_create\_dkim) | (Optional) Whether to create a DKIM record for the email domain. Defaults to true. | `bool` | `true` | no |
| <a name="input_dkim_name"></a> [dkim\_name](#input\_dkim\_name) | (Optional) The name of the DKIM selector. Used as the DKIM selector prefix. | `string` | `"dkim"` | no |
| <a name="input_email_defined_tags"></a> [email\_defined\_tags](#input\_email\_defined\_tags) | Defined tags for the email delivery resources. | `map(string)` | `{}` | no |
| <a name="input_email_domain_name"></a> [email\_domain\_name](#input\_email\_domain\_name) | (Required) The name of the email domain (e.g. example.com). | `string` | n/a | yes |
| <a name="input_email_freeform_tags"></a> [email\_freeform\_tags](#input\_email\_freeform\_tags) | Free-form tags for the email delivery resources. | `map(string)` | `{}` | no |
| <a name="input_sender_email_address"></a> [sender\_email\_address](#input\_sender\_email\_address) | (Required) The email address of the sender. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dkim_cname_record_value"></a> [dkim\_cname\_record\_value](#output\_dkim\_cname\_record\_value) | The DNS CNAME record value for DKIM verification. Returns null when create\_dkim is false. |
| <a name="output_dkim_id"></a> [dkim\_id](#output\_dkim\_id) | OCID of the DKIM resource. Returns null when create\_dkim is false. |
| <a name="output_email_domain_id"></a> [email\_domain\_id](#output\_email\_domain\_id) | OCID of the email domain. |
| <a name="output_sender_id"></a> [sender\_id](#output\_sender\_id) | OCID of the email sender. |
<!-- END_TF_DOCS -->
