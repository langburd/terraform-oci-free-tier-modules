# examples/free-tier-compute-stack

Demonstrates a complete OCI Always Free compute stack: identity, networking (VCN + subnets), compute, and block storage.

## Architecture

- **Identity**: Creates a dedicated compartment
- **VCN**: Virtual Cloud Network with Internet Gateway
- **Subnets**: Public subnet (for compute) and private subnet
- **Compute**: AMD Micro (VM.Standard.E2.1.Micro) instance on public subnet
- **Block Volume**: 50 GB data volume attached to the compute instance

## Bastion (Phase 3)

Bastion access is included in `main.tf` but commented out. It requires the `oci/bastion` module from Phase 3.

## Usage

This example authenticates via the `oci_config_profile` Terraform variable, which reads credentials from your local `~/.oci/config` file. This approach is recommended for local development.

```hcl
# terraform.tfvars
oci_config_profile  = "DEFAULT"
ssh_authorized_keys = "ssh-rsa AAAA..."
```

Run:

```sh
terraform init
terraform plan
terraform apply
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_block_volume"></a> [block\_volume](#module\_block\_volume) | ../../oci/block_volume | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_compute"></a> [compute](#module\_compute) | ../../oci/compute | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |
| <a name="module_private_subnet"></a> [private\_subnet](#module\_private\_subnet) | ../../oci/subnet | n/a |
| <a name="module_public_subnet"></a> [public\_subnet](#module\_public\_subnet) | ../../oci/subnet | n/a |
| <a name="module_vcn"></a> [vcn](#module\_vcn) | ../../oci/vcn | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_core_images.oracle_linux](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create. | `string` | `"free-tier-compute"` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | (Optional) SSH public key to authorize on compute instances. If null, SSH key authentication is disabled. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_block_volume_id"></a> [block\_volume\_id](#output\_block\_volume\_id) | OCID of the block volume attached to the compute instance. |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_compute_instance_id"></a> [compute\_instance\_id](#output\_compute\_instance\_id) | OCID of the compute instance. |
| <a name="output_compute_public_ip"></a> [compute\_public\_ip](#output\_compute\_public\_ip) | Public IP address of the compute instance. |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the VCN. |
<!-- END_TF_DOCS -->
