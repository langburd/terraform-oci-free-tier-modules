# OCI Object Storage Module

Terraform module creating an OCI Object Storage bucket.

## Usage Example

```hcl
module "object_storage" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/object_storage/v1.0.0"

  compartment_id     = "<compartment_ocid>"
  bucket_name        = "my-bucket"
  bucket_access_type = "NoPublicAccess"
  storage_tier       = "Standard"
  versioning         = "Disabled"
}
```

## Notes

- **Old versions:** with `versioning = "Enabled"`, set `previous_version_retention_days` (plus `region`) to delete
  non-current versions after that many days. The module also creates the IAM policy that lets the regional
  Object Storage service (`objectstorage-<region>`) run the rule on this bucket; without it OCI accepts the
  lifecycle policy but never applies it.

**Important:** `storage_tier` is immutable after bucket creation. Changing this value will destroy and recreate the bucket, deleting all objects.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 9.0, < 10.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 9.0, < 10.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [oci_identity_policy.lifecycle](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/identity_policy) | resource |
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_objectstorage_object_lifecycle_policy.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_object_lifecycle_policy) | resource |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_allow_public_access"></a> [allow\_public\_access](#input\_allow\_public\_access) | (Optional) Safety guard: must be set to true before bucket\_access\_type can be set to ObjectRead or ObjectReadWithoutList. Defaults to false to prevent accidental public exposure. | `bool` | `false` | no |
| <a name="input_auto_tiering"></a> [auto\_tiering](#input\_auto\_tiering) | (Optional) (Updatable) Auto tiering status for the bucket. Supported values: Disabled, InfrequentAccess. | `string` | `"Disabled"` | no |
| <a name="input_bucket_access_type"></a> [bucket\_access\_type](#input\_bucket\_access\_type) | (Optional) (Updatable) Access type for the bucket. Supported values: NoPublicAccess, ObjectRead, ObjectReadWithoutList. Set allow\_public\_access = true before using ObjectRead or ObjectReadWithoutList. | `string` | `"NoPublicAccess"` | no |
| <a name="input_bucket_defined_tags"></a> [bucket\_defined\_tags](#input\_bucket\_defined\_tags) | (Optional) (Updatable) Defined tags for the bucket. | `map(string)` | `{}` | no |
| <a name="input_bucket_freeform_tags"></a> [bucket\_freeform\_tags](#input\_bucket\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the bucket. | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Required) Name of the object storage bucket. Only a-zA-Z0-9.\_- characters are allowed. | `string` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) Compartment OCID where the bucket will be created. | `string` | n/a | yes |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) The OCID of a KMS key for customer-managed encryption (CMK). Null uses Oracle-managed encryption. Note: CMK requires a paid OCI Vault -- free-tier users should leave this null. | `string` | `null` | no |
| <a name="input_object_events_enabled"></a> [object\_events\_enabled](#input\_object\_events\_enabled) | (Optional) (Updatable) Whether object-level events are emitted for this bucket. Defaults to true to enable audit trails. | `bool` | `true` | no |
| <a name="input_previous_version_retention_days"></a> [previous\_version\_retention\_days](#input\_previous\_version\_retention\_days) | (Optional) Delete non-current object versions this many days after they stop being current. Creates a lifecycle policy plus the IAM policy the regional Object Storage service needs to run it (requires region). Only takes effect on a bucket with versioning enabled. Null disables both. | `number` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) Region identifier of the bucket (e.g. il-jerusalem-1). Required with previous\_version\_retention\_days, to grant the regional Object Storage service access. | `string` | `null` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | (Optional) Storage tier for the bucket. Supported values: Standard, Archive. NOTE: This attribute is immutable after bucket creation. | `string` | `"Standard"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) (Updatable) Versioning state for the bucket. Defaults to Enabled for data protection. Supported values: Enabled, Suspended, Disabled. | `string` | `"Enabled"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket ID of the object storage bucket. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the object storage bucket. |
| <a name="output_bucket_namespace"></a> [bucket\_namespace](#output\_bucket\_namespace) | Object storage namespace for the bucket. |
<!-- END_TF_DOCS -->
