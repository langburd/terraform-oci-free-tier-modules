# Free Tier ARM Server Example

Demonstrates deploying an OCI A1 Flex ARM compute instance at maximum free tier allocation (4 OCPUs, 24 GB RAM) with a 50 GB block volume.

## What this example creates

- OCI compartment
- VCN with Internet Gateway and NAT Gateway
- Public subnet
- A1 Flex compute instance (4 OCPUs, 24 GB RAM)
- 50 GB block volume attached to the instance

## Usage

```hcl
oci_config_profile  = "DEFAULT"
compartment_name    = "free-tier-arm-server"
ssh_authorized_keys = "<your-public-ssh-key>"
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_block_volume"></a> [block\_volume](#module\_block\_volume) | ../../oci/block_volume | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ../../oci/compute | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |
| <a name="module_public_subnet"></a> [public\_subnet](#module\_public\_subnet) | ../../oci/subnet | n/a |
| <a name="module_vcn"></a> [vcn](#module\_vcn) | ../../oci/vcn | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_core_images.oracle_linux_arm](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create. | `string` | `"free-tier-arm-server"` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | (Optional) SSH public key to authorize on compute instances. If null, SSH key authentication is disabled. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_block_volume_id"></a> [block\_volume\_id](#output\_block\_volume\_id) | OCID of the 50 GB block volume attached to the instance. |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_compute_instance_id"></a> [compute\_instance\_id](#output\_compute\_instance\_id) | OCID of the A1 Flex compute instance. |
| <a name="output_compute_public_ip"></a> [compute\_public\_ip](#output\_compute\_public\_ip) | Public IP address of the compute instance. |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the VCN. |
<!-- END_TF_DOCS -->
