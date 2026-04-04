# dual-tenancy

Demonstrates managing resources across two separate OCI tenancies simultaneously: creating a compartment and a monthly spend budget in each.

## Modules used

- [`oci_profile_reader`](../../oci/oci_profile_reader): reads a named profile from `~/.oci/config` to extract the tenancy OCID
- [`identity`](../../oci/identity): creates a compartment under the tenancy root
- [`budget`](../../oci/budget): sets a monthly spend cap with a forecast email alert

## Prerequisites

Both profiles must exist in `~/.oci/config`. Run `oci setup config` to create or add profiles.

## Usage

Edit `terraform.tfvars` with your profile names and alert email, then:

```sh
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_budget1"></a> [budget1](#module\_budget1) | ../../oci/budget | n/a |
| <a name="module_budget2"></a> [budget2](#module\_budget2) | ../../oci/budget | n/a |
| <a name="module_compartment1"></a> [compartment1](#module\_compartment1) | ../../oci/identity | n/a |
| <a name="module_compartment2"></a> [compartment2](#module\_compartment2) | ../../oci/identity | n/a |
| <a name="module_oci_profile_reader1"></a> [oci\_profile\_reader1](#module\_oci\_profile\_reader1) | ../../oci/oci_profile_reader | n/a |
| <a name="module_oci_profile_reader2"></a> [oci\_profile\_reader2](#module\_oci\_profile\_reader2) | ../../oci/oci_profile_reader | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_recipients"></a> [alert\_recipients](#input\_alert\_recipients) | Comma-separated email address(es) to notify when forecasted spend is on track to exceed the budget. | `string` | n/a | yes |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | Monthly budget cap in the currency of your OCI rate card. Applied to both tenancies. | `number` | `1` | no |
| <a name="input_profile1"></a> [profile1](#input\_profile1) | OCI config profile name for the first tenancy. Must exist in ~/.oci/config. | `string` | n/a | yes |
| <a name="input_profile2"></a> [profile2](#input\_profile2) | OCI config profile name for the second tenancy. Must exist in ~/.oci/config. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_budget1_id"></a> [budget1\_id](#output\_budget1\_id) | OCID of the budget for the first tenancy. |
| <a name="output_budget2_id"></a> [budget2\_id](#output\_budget2\_id) | OCID of the budget for the second tenancy. |
| <a name="output_compartment1_id"></a> [compartment1\_id](#output\_compartment1\_id) | OCID of the compartment created in the first tenancy. |
| <a name="output_compartment2_id"></a> [compartment2\_id](#output\_compartment2\_id) | OCID of the compartment created in the second tenancy. |
<!-- END_TF_DOCS -->
