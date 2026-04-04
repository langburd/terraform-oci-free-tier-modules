# oci_profile_reader module

> **Security Warning:** This module reads OCI profile data from `~/.oci/config` and exposes it as outputs. While sensitive fields (fingerprint, key_file, passphrase) are excluded from outputs, the non-sensitive profile data (tenancy_ocid, user_ocid, region) will be stored in Terraform state. Ensure your state backend is secured (e.g., remote state with access controls). Do not use this module in pipelines where the state file is accessible to untrusted parties.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_profile_name"></a> [profile\_name](#input\_profile\_name) | The name of the OCI profile to read | `string` | `"DEFAULT"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_oci_profile_data"></a> [oci\_profile\_data](#output\_oci\_profile\_data) | The data from the OCI profile (sensitive fields fingerprint, key\_file, and passphrase are excluded) |
<!-- END_TF_DOCS -->
