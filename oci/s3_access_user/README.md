# OCI S3 Access User Module

Terraform module creating an IAM user with an S3-compatible access key (Customer Secret Key) that can
read and write objects in selected Object Storage buckets only.

Creates: IAM user and group (in the tenancy), group membership, a policy in the bucket compartment
(`read buckets` + `manage objects`, both limited by `target.bucket.name`), and a Customer Secret Key.

## Notes

- The S3-compatible endpoint is `https://<namespace>.compat.objectstorage.<region>.oraclecloud.com`;
  use path-style addressing.
- `secret_access_key` is only returned at creation time and is stored in Terraform state: keep the state
  encrypted, and copy the key into a secret store (e.g. with the `vault_secrets` module) for consumers.
- A user can hold at most two Customer Secret Keys.

## Usage Example

```hcl
module "s3_access_user" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/s3_access_user/v1.0.0"

  tenancy_id     = "<tenancy_ocid>"
  compartment_id = "<bucket_compartment_ocid>"
  name           = "app-s3"
  bucket_names   = ["app-data"]
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
| [oci_identity_customer_secret_key.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_customer_secret_key) | resource |
| [oci_identity_group.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_group) | resource |
| [oci_identity_policy.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_identity_user.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user) | resource |
| [oci_identity_user_group_membership.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_user_group_membership) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_names"></a> [bucket\_names](#input\_bucket\_names) | (Required) Buckets the key may read and write objects in. | `list(string)` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment holding the buckets. The access policy is created there. | `string` | n/a | yes |
| <a name="input_defined_tags"></a> [defined\_tags](#input\_defined\_tags) | (Optional) (Updatable) Defined tags for the user, group and policy. | `map(string)` | `{}` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description for the IAM user, group and policy. | `string` | `"S3-compatible access to selected Object Storage buckets."` | no |
| <a name="input_email"></a> [email](#input\_email) | (Optional) Email address of the IAM user. Some identity-domain tenancies require one. | `string` | `null` | no |
| <a name="input_freeform_tags"></a> [freeform\_tags](#input\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the user, group and policy. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the IAM user, group, policy and customer secret key. Must be unique in the tenancy. | `string` | n/a | yes |
| <a name="input_tenancy_id"></a> [tenancy\_id](#input\_tenancy\_id) | (Required) OCID of the tenancy, where the IAM user and group are created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_key_id"></a> [access\_key\_id](#output\_access\_key\_id) | S3-compatible access key ID. |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | OCID of the IAM group. |
| <a name="output_secret_access_key"></a> [secret\_access\_key](#output\_secret\_access\_key) | S3-compatible secret access key. Only available at creation time. |
| <a name="output_user_id"></a> [user\_id](#output\_user\_id) | OCID of the IAM user. |
<!-- END_TF_DOCS -->
