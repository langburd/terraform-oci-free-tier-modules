# oci/block_volume

Terraform module creating an OCI block volume with optional instance attachment.

## Usage

```hcl
module "block_volume" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/block_volume/v1.0.0"

  compartment_id      = "ocid1.compartment.oc1..xxx"
  availability_domain = "nFuS:US-ASHBURN-AD-1"
}
```

### With instance attachment

```hcl
module "block_volume" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/block_volume/v1.0.0"

  compartment_id      = "ocid1.compartment.oc1..xxx"
  availability_domain = "nFuS:US-ASHBURN-AD-1"
  instance_id         = "ocid1.instance.oc1.iad.xxx"
  attachment_type     = "paravirtualized"
}
```

## Notes

**Free Tier Storage Limit:** OCI Free Tier includes 200GB total block storage, which includes boot volumes. There is no cross-module enforcement — manually track total boot + block volume consumption across all instances.

**VPUs:** Values of 20 VPUs/GB and above are Higher/Ultra High Performance and may incur charges outside of free tier entitlements.

**Note:** `is_read_only` is only applied when `instance_id` is provided. It is silently ignored when creating a standalone volume without attachment.

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
| [oci_core_volume.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume) | resource |
| [oci_core_volume_attachment.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_attachment) | resource |
| [oci_core_volume_backup_policy_assignment.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_volume_backup_policy_assignment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attachment_type"></a> [attachment\_type](#input\_attachment\_type) | (Optional) The type of volume attachment. Must be 'iscsi' or 'paravirtualized'. | `string` | `"paravirtualized"` | no |
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain) | (Required) The availability domain in which to create the block volume. | `string` | n/a | yes |
| <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id) | (Optional) The OCID of a backup policy to assign to the volume. Null disables automated backups. Note: automated backups require paid storage -- free-tier users should leave this null. | `string` | `null` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment in which to create the block volume. | `string` | n/a | yes |
| <a name="input_create_attachment"></a> [create\_attachment](#input\_create\_attachment) | (Optional) Whether to create a volume attachment to the instance specified by instance\_id. | `bool` | `false` | no |
| <a name="input_instance_id"></a> [instance\_id](#input\_instance\_id) | (Optional) The OCID of the instance to attach this volume to. Required when create\_attachment is true. | `string` | `null` | no |
| <a name="input_is_read_only"></a> [is\_read\_only](#input\_is\_read\_only) | (Optional) Whether the attachment is read-only. | `bool` | `false` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | (Optional) The OCID of a KMS key to use for volume encryption (customer-managed key). Null uses Oracle-managed encryption. Note: CMK requires a paid OCI Vault -- free-tier users should leave this null. | `string` | `null` | no |
| <a name="input_volume_defined_tags"></a> [volume\_defined\_tags](#input\_volume\_defined\_tags) | (Optional) (Updatable) Defined tags for the block volume. | `map(string)` | `{}` | no |
| <a name="input_volume_display_name"></a> [volume\_display\_name](#input\_volume\_display\_name) | (Optional) A user-friendly name for the block volume. | `string` | `"block-volume"` | no |
| <a name="input_volume_freeform_tags"></a> [volume\_freeform\_tags](#input\_volume\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the block volume. | `map(string)` | `{}` | no |
| <a name="input_volume_size_in_gbs"></a> [volume\_size\_in\_gbs](#input\_volume\_size\_in\_gbs) | (Optional) Size of the block volume in GBs. Defaults to 50 to stay within Free Tier limits (200GB total including boot volumes). | `number` | `50` | no |
| <a name="input_vpus_per_gb"></a> [vpus\_per\_gb](#input\_vpus\_per\_gb) | (Optional) Volume performance units per GB. Must be a multiple of 10 between 0 and 120. Values of 0 and 10 are included in the Always Free tier. Values of 20 (Higher Performance) and above may incur charges. | `number` | `10` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_policy_assignment_id"></a> [backup\_policy\_assignment\_id](#output\_backup\_policy\_assignment\_id) | OCID of the volume backup policy assignment. Returns null when no backup\_policy\_id is provided. |
| <a name="output_volume_attachment_id"></a> [volume\_attachment\_id](#output\_volume\_attachment\_id) | OCID of the volume attachment. Returns null when no instance\_id is provided. |
| <a name="output_volume_id"></a> [volume\_id](#output\_volume\_id) | OCID of the block volume. |
<!-- END_TF_DOCS -->
