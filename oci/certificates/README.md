# OCI Certificates Module

Terraform module creating an OCI Certificate Authority and optional Certificate.

## Usage Example

```hcl
module "certificates" {
  source = "../../oci/certificates"

  compartment_id = "<compartment_ocid>"
  ca_name        = "my-root-ca"
  ca_common_name = "My Root CA"

  create_certificate      = true
  certificate_name        = "my-tls-cert"
  certificate_common_name = "app.example.com"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.0, < 7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.0, < 7.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_certificates_management_certificate.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/certificates_management_certificate) | resource |
| [oci_certificates_management_certificate_authority.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/certificates_management_certificate_authority) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ca_common_name"></a> [ca\_common\_name](#input\_ca\_common\_name) | (Required) Common name (CN) for the certificate authority subject. | `string` | n/a | yes |
| <a name="input_ca_config_type"></a> [ca\_config\_type](#input\_ca\_config\_type) | (Optional) Configuration type for the certificate authority. | `string` | `"ROOT_CA_GENERATED_INTERNALLY"` | no |
| <a name="input_ca_name"></a> [ca\_name](#input\_ca\_name) | (Required) Name of the certificate authority. | `string` | n/a | yes |
| <a name="input_ca_signing_algorithm"></a> [ca\_signing\_algorithm](#input\_ca\_signing\_algorithm) | (Optional) Signing algorithm for the certificate authority. | `string` | `"SHA256_WITH_RSA"` | no |
| <a name="input_ca_validity_time_of_validity_not_after"></a> [ca\_validity\_time\_of\_validity\_not\_after](#input\_ca\_validity\_time\_of\_validity\_not\_after) | (Optional) RFC3339 timestamp after which the CA certificate is no longer valid. | `string` | `"2035-01-01T00:00:00Z"` | no |
| <a name="input_certificate_common_name"></a> [certificate\_common\_name](#input\_certificate\_common\_name) | (Optional) Common name (CN) for the certificate subject. Required when create\_certificate is true. | `string` | `null` | no |
| <a name="input_certificate_config_type"></a> [certificate\_config\_type](#input\_certificate\_config\_type) | (Optional) Configuration type for the certificate. | `string` | `"ISSUED_BY_INTERNAL_CA"` | no |
| <a name="input_certificate_key_algorithm"></a> [certificate\_key\_algorithm](#input\_certificate\_key\_algorithm) | (Optional) Key algorithm for the certificate. | `string` | `"RSA4096"` | no |
| <a name="input_certificate_name"></a> [certificate\_name](#input\_certificate\_name) | (Optional) Name of the certificate. | `string` | `"certificate"` | no |
| <a name="input_certificate_profile_type"></a> [certificate\_profile\_type](#input\_certificate\_profile\_type) | (Optional) Profile type for the certificate. | `string` | `"TLS_SERVER_OR_CLIENT"` | no |
| <a name="input_certificate_validity_time_of_validity_not_after"></a> [certificate\_validity\_time\_of\_validity\_not\_after](#input\_certificate\_validity\_time\_of\_validity\_not\_after) | (Optional) RFC3339 timestamp after which the certificate is no longer valid. | `string` | `"2034-01-01T00:00:00Z"` | no |
| <a name="input_certificates_defined_tags"></a> [certificates\_defined\_tags](#input\_certificates\_defined\_tags) | (Optional) Defined tags for the certificate authority and certificate. | `map(string)` | `{}` | no |
| <a name="input_certificates_freeform_tags"></a> [certificates\_freeform\_tags](#input\_certificates\_freeform\_tags) | (Optional) Free-form tags for the certificate authority and certificate. | `map(string)` | `{}` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment in which to create the certificate authority. | `string` | n/a | yes |
| <a name="input_create_certificate"></a> [create\_certificate](#input\_create\_certificate) | (Optional) Whether to create a certificate issued by the certificate authority. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_authority_id"></a> [certificate\_authority\_id](#output\_certificate\_authority\_id) | OCID of the certificate authority. |
| <a name="output_certificate_id"></a> [certificate\_id](#output\_certificate\_id) | OCID of the certificate. Returns null when create\_certificate is false. |
<!-- END_TF_DOCS -->
