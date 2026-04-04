# OCI Vault Module

Terraform module creating an OCI KMS Vault and optional KMS Key.

## Free Tier Notes

- `vault_type = "DEFAULT"` is the free tier option. **Do not change to `VIRTUAL_PRIVATE`** — it incurs significant cost and cannot be changed after creation.
- Use `key_protection_mode = "SOFTWARE"` for unlimited free key versions. HSM protection mode may incur cost.
- Auto-rotation is only available for `VIRTUAL_PRIVATE` vaults and is not supported in free tier.

## Usage Example

```hcl
module "vault" {
  source = "../../oci/vault"

  compartment_id = "<compartment_ocid>"
  vault_display_name = "my-vault"
  key_display_name   = "my-encryption-key"
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_kms_key.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_key) | resource |
| [oci_kms_vault.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/kms_vault) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment in which to create the vault. | `string` | n/a | yes |
| <a name="input_create_key"></a> [create\_key](#input\_create\_key) | (Optional) Whether to create a KMS key in the vault. | `bool` | `true` | no |
| <a name="input_key_algorithm"></a> [key\_algorithm](#input\_key\_algorithm) | (Optional) Algorithm for the KMS key. Supported values: AES, RSA, ECDSA. | `string` | `"AES"` | no |
| <a name="input_key_display_name"></a> [key\_display\_name](#input\_key\_display\_name) | (Optional) Display name for the KMS key. | `string` | `"key"` | no |
| <a name="input_key_length"></a> [key\_length](#input\_key\_length) | (Optional) Key length in bytes. For AES: 16, 24, or 32. For RSA: 256, 384, or 512. For ECDSA: 32, 48, or 66. | `number` | `32` | no |
| <a name="input_key_protection_mode"></a> [key\_protection\_mode](#input\_key\_protection\_mode) | (Optional) Protection mode for the key. SOFTWARE allows unlimited free key versions. HSM uses hardware security module. | `string` | `"SOFTWARE"` | no |
| <a name="input_vault_defined_tags"></a> [vault\_defined\_tags](#input\_vault\_defined\_tags) | (Optional) Defined tags for the vault and key. | `map(string)` | `{}` | no |
| <a name="input_vault_display_name"></a> [vault\_display\_name](#input\_vault\_display\_name) | (Optional) Display name for the vault. | `string` | `"vault"` | no |
| <a name="input_vault_freeform_tags"></a> [vault\_freeform\_tags](#input\_vault\_freeform\_tags) | (Optional) Free-form tags for the vault and key. | `map(string)` | `{}` | no |
| <a name="input_vault_type"></a> [vault\_type](#input\_vault\_type) | (Optional) Type of vault. DEFAULT is free tier. WARNING: VIRTUAL\_PRIVATE vault type incurs cost and cannot be changed after creation. | `string` | `"DEFAULT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | OCID of the KMS key. Returns null when create\_key is false. |
| <a name="output_vault_crypto_endpoint"></a> [vault\_crypto\_endpoint](#output\_vault\_crypto\_endpoint) | Crypto endpoint of the vault for encryption/decryption operations. |
| <a name="output_vault_id"></a> [vault\_id](#output\_vault\_id) | OCID of the vault. |
| <a name="output_vault_management_endpoint"></a> [vault\_management\_endpoint](#output\_vault\_management\_endpoint) | Management endpoint of the vault for key management operations. |
<!-- END_TF_DOCS -->
