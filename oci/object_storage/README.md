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

**Important:** `storage_tier` is immutable after bucket creation. Changing this value will destroy and recreate the bucket, deleting all objects.

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
| [oci_objectstorage_bucket.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/objectstorage_bucket) | resource |
| [oci_objectstorage_namespace.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/objectstorage_namespace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_tiering"></a> [auto\_tiering](#input\_auto\_tiering) | (Optional) (Updatable) Auto tiering status for the bucket. Supported values: Disabled, InfrequentAccess. | `string` | `"Disabled"` | no |
| <a name="input_bucket_access_type"></a> [bucket\_access\_type](#input\_bucket\_access\_type) | (Optional) (Updatable) Access type for the bucket. Supported values: NoPublicAccess, ObjectRead, ObjectReadWithoutList. | `string` | `"NoPublicAccess"` | no |
| <a name="input_bucket_defined_tags"></a> [bucket\_defined\_tags](#input\_bucket\_defined\_tags) | (Optional) (Updatable) Defined tags for the bucket. | `map(string)` | `{}` | no |
| <a name="input_bucket_freeform_tags"></a> [bucket\_freeform\_tags](#input\_bucket\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the bucket. | `map(string)` | `{}` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | (Required) Name of the object storage bucket. Only a-zA-Z0-9.\_- characters are allowed. | `string` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) Compartment OCID where the bucket will be created. | `string` | n/a | yes |
| <a name="input_object_events_enabled"></a> [object\_events\_enabled](#input\_object\_events\_enabled) | (Optional) (Updatable) Whether object-level events are emitted for this bucket. | `bool` | `false` | no |
| <a name="input_storage_tier"></a> [storage\_tier](#input\_storage\_tier) | (Optional) Storage tier for the bucket. Supported values: Standard, Archive. NOTE: This attribute is immutable after bucket creation. | `string` | `"Standard"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) (Updatable) Versioning state for the bucket. Supported values: Enabled, Suspended, Disabled. | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket ID of the object storage bucket. |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the object storage bucket. |
| <a name="output_bucket_namespace"></a> [bucket\_namespace](#output\_bucket\_namespace) | Object storage namespace for the bucket. |
<!-- END_TF_DOCS -->
