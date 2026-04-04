# Free Tier Web App Example

Demonstrates a two-tier web application architecture using OCI free tier resources:

- VCN with Internet Gateway
- Public subnet (load balancer) + Private subnet (compute instances)
- 2x AMD Micro compute instances (VM.Standard.E2.1.Micro)
- Flexible load balancer (10 Mbps, free tier)

## Usage

```hcl
# terraform.tfvars
oci_config_profile  = "DEFAULT"
compartment_name    = "free-tier-web-app"
ssh_authorized_keys = "ssh-rsa AAAA..."
```

```bash
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
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_compute_1"></a> [compute\_1](#module\_compute\_1) | ../../oci/compute | n/a |
| <a name="module_compute_2"></a> [compute\_2](#module\_compute\_2) | ../../oci/compute | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ../../oci/load_balancer | n/a |
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
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create. | `string` | `"free-tier-web-app"` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | (Optional) SSH public key to authorize on compute instances. If null, SSH key authentication is disabled. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | OCID of the load balancer. |
| <a name="output_load_balancer_ip_addresses"></a> [load\_balancer\_ip\_addresses](#output\_load\_balancer\_ip\_addresses) | IP address details of the load balancer. |
| <a name="output_vcn_id"></a> [vcn\_id](#output\_vcn\_id) | OCID of the VCN. |
| <a name="output_web_server_1_id"></a> [web\_server\_1\_id](#output\_web\_server\_1\_id) | OCID of web server instance 1. |
| <a name="output_web_server_2_id"></a> [web\_server\_2\_id](#output\_web\_server\_2\_id) | OCID of web server instance 2. |
<!-- END_TF_DOCS -->
