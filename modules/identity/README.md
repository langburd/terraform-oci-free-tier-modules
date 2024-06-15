# identity module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.1 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 5.46.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 5.46.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_identity_compartment.root_compartment](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_compartment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_oci_root_compartment"></a> [oci\_root\_compartment](#input\_oci\_root\_compartment) | The tenancy OCID a.k.a. root compartment, see README for CLI command to retrieve it. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_root_compartment_id"></a> [root\_compartment\_id](#output\_root\_compartment\_id) | The OCID of the root compartment |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
