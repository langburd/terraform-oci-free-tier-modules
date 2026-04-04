# Free Tier Security Example

Demonstrates OCI security services using free tier resources:

- KMS Vault (DEFAULT type, free tier) with a SOFTWARE-protected AES-256 key
- Certificate Authority (Root CA) with a TLS server/client certificate

## Usage

```hcl
# terraform.tfvars
oci_config_profile      = "DEFAULT"
compartment_name        = "free-tier-security"
certificate_common_name = "app.example.com"
```

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- The vault type is `DEFAULT` (free tier). Do not change to `VIRTUAL_PRIVATE` as it incurs cost.
- `SOFTWARE` protection mode provides unlimited free key versions.
- Auto-rotation is not available in the free tier (requires `VIRTUAL_PRIVATE` vault).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificates"></a> [certificates](#module\_certificates) | ../../oci/certificates | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |
| <a name="module_vault"></a> [vault](#module\_vault) | ../../oci/vault | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_common_name"></a> [certificate\_common\_name](#input\_certificate\_common\_name) | (Optional) Common name (CN) for the TLS certificate subject. | `string` | `"app.example.com"` | no |
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create. | `string` | `"free-tier-security"` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_authority_id"></a> [certificate\_authority\_id](#output\_certificate\_authority\_id) | OCID of the certificate authority. |
| <a name="output_certificate_id"></a> [certificate\_id](#output\_certificate\_id) | OCID of the TLS certificate. |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | OCID of the KMS key. |
| <a name="output_vault_crypto_endpoint"></a> [vault\_crypto\_endpoint](#output\_vault\_crypto\_endpoint) | Crypto endpoint of the vault. |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | OCID of the vault. |
| <a name="output_vault_management_endpoint"></a> [vault\_management\_endpoint](#output\_vault\_management\_endpoint) | Management endpoint of the vault. |
<!-- END_TF_DOCS -->
