# OCI Vault Secrets Module

Terraform module creating secrets in an existing OCI Vault (see the `vault` module), one per map entry.

## Notes

- Map keys are the secret names and are not sensitive; contents are. Pass plain text: the module
  base64-encodes it.
- Changing a content creates a new secret version. Removing an entry schedules the secret for deletion.
- Contents are stored in Terraform state: keep the state encrypted.

## Usage Example

```hcl
module "vault_secrets" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/vault_secrets/v1.0.0"

  compartment_id = "<compartment_ocid>"
  vault_id       = module.vault.vault_id
  key_id         = module.vault.key_id

  secrets = {
    app-db-password = {
      content     = random_password.db.result
      description = "Application database password."
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 9.0, < 10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 9.0, < 10.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_vault_secret.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/vault_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment where the secrets are created. | `string` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | (Optional) (Updatable) Defined tags for the secrets. | `map(string)` | `{}` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the secrets. | `map(string)` | `{}` | no |
| <a name="input_key_id"></a> [key\_id](#input\_key\_id) | (Required) OCID of the master encryption key used to encrypt the secrets. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | (Required) Secrets to create, keyed by secret name. content is the plain-text value (base64-encoded by the module); a change creates a new secret version. | <pre>map(object({<br/>    content     = string<br/>    description = optional(string)<br/>  }))</pre> | n/a | yes |
| <a name="input_vault_id"></a> [vault\_id](#input\_vault\_id) | (Required) OCID of the vault holding the secrets. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_ids"></a> [secret\_ids](#output\_secret\_ids) | Map of secret name to secret OCID. |
<!-- END_TF_DOCS -->
