# OCI Bastion Module

Terraform module creating an OCI Bastion service for secure SSH access to private resources.

## Prerequisites

The bastion must be placed in a **public subnet** that has:

- An Internet Gateway attached to the VCN
- A route rule sending `0.0.0.0/0` traffic to the Internet Gateway

The `target_subnet_id` should point to the private subnet containing the resources you want to reach.

## Usage Example

```hcl
module "bastion" {
  source = "../../oci/bastion"

  compartment_id               = "<compartment_ocid>"
  bastion_name                 = "MyBastion"
  target_subnet_id             = "<private_subnet_ocid>"
  client_cidr_block_allow_list = ["203.0.113.0/24"]
  max_session_ttl_in_seconds   = 3600
}
```

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
| [oci_bastion_bastion.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/bastion_bastion) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bastion_defined_tags"></a> [bastion\_defined\_tags](#input\_bastion\_defined\_tags) | (Optional) Defined tags for the bastion. | `map(string)` | `{}` | no |
| <a name="input_bastion_freeform_tags"></a> [bastion\_freeform\_tags](#input\_bastion\_freeform\_tags) | (Optional) Free-form tags for the bastion. | `map(string)` | `{}` | no |
| <a name="input_bastion_name"></a> [bastion\_name](#input\_bastion\_name) | (Required) Name of the bastion. Must be alphanumeric. | `string` | n/a | yes |
| <a name="input_bastion_type"></a> [bastion\_type](#input\_bastion\_type) | (Optional) Type of the bastion. Supported values: STANDARD. | `string` | `"STANDARD"` | no |
| <a name="input_client_cidr_block_allow_list"></a> [client\_cidr\_block\_allow\_list](#input\_client\_cidr\_block\_allow\_list) | (Required) List of CIDR blocks allowed to connect to the bastion. Must not be empty -- callers must provide at least one explicit CIDR. Using 0.0.0.0/0 exposes the bastion to all internet traffic. | `list(string)` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment in which to create the bastion. | `string` | n/a | yes |
| <a name="input_max_session_ttl_in_seconds"></a> [max\_session\_ttl\_in\_seconds](#input\_max\_session\_ttl\_in\_seconds) | (Optional) Maximum session TTL in seconds. Defaults to 1800 (30 minutes) for security. Valid range: 1800-10800. Increase to 10800 (3 hours) only if your workflow requires longer sessions. | `number` | `1800` | no |
| <a name="input_target_subnet_id"></a> [target\_subnet\_id](#input\_target\_subnet\_id) | (Required) OCID of the subnet that the bastion connects to. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bastion_id"></a> [bastion\_id](#output\_bastion\_id) | OCID of the bastion. |
| <a name="output_bastion_name"></a> [bastion\_name](#output\_bastion\_name) | Name of the bastion. |
<!-- END_TF_DOCS -->
