# OCI VPN Module

Terraform module creating OCI Site-to-Site VPN resources: a Dynamic Routing Gateway (DRG), Customer-Premises Equipment (CPE), and IPSec connection. Optionally attaches the DRG to a VCN.

## Usage Example

```hcl
module "vpn" {
  source = "../../oci/vpn"

  compartment_id  = "<compartment_ocid>"
  cpe_ip_address  = "203.0.113.1"
  static_routes   = ["10.0.0.0/8"]
  vcn_id          = "<vcn_ocid>"
}
```

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
| [oci_core_cpe.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_cpe) | resource |
| [oci_core_drg.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg) | resource |
| [oci_core_drg_attachment.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_drg_attachment) | resource |
| [oci_core_ipsec.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_ipsec) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the VPN resources. | `string` | n/a | yes |
| <a name="input_cpe_display_name"></a> [cpe\_display\_name](#input\_cpe\_display\_name) | (Optional) (Updatable) Display name for the Customer-Premises Equipment resource. | `string` | `"cpe"` | no |
| <a name="input_cpe_ip_address"></a> [cpe\_ip\_address](#input\_cpe\_ip\_address) | (Required) The public IP address of the on-premises Customer-Premises Equipment (CPE). | `string` | n/a | yes |
| <a name="input_drg_attachment_display_name"></a> [drg\_attachment\_display\_name](#input\_drg\_attachment\_display\_name) | Display name for the DRG VCN attachment. | `string` | `"drg-attachment"` | no |
| <a name="input_drg_display_name"></a> [drg\_display\_name](#input\_drg\_display\_name) | (Optional) (Updatable) Display name for the Dynamic Routing Gateway. | `string` | `"drg"` | no |
| <a name="input_ipsec_display_name"></a> [ipsec\_display\_name](#input\_ipsec\_display\_name) | (Optional) (Updatable) Display name for the IPSec connection. | `string` | `"ipsec-connection"` | no |
| <a name="input_static_routes"></a> [static\_routes](#input\_static\_routes) | (Required) Static routes for the IPSec connection. List of CIDR blocks representing the on-premises networks. | `list(string)` | n/a | yes |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | (Optional) The OCID of the VCN to attach the DRG to. When provided, a DRG attachment is created. | `string` | `null` | no |
| <a name="input_vpn_defined_tags"></a> [vpn\_defined\_tags](#input\_vpn\_defined\_tags) | Defined tags for the VPN resources. | `map(string)` | `{}` | no |
| <a name="input_vpn_freeform_tags"></a> [vpn\_freeform\_tags](#input\_vpn\_freeform\_tags) | Free-form tags for the VPN resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpe_id"></a> [cpe\_id](#output\_cpe\_id) | OCID of the Customer-Premises Equipment resource. |
| <a name="output_drg_id"></a> [drg\_id](#output\_drg\_id) | OCID of the Dynamic Routing Gateway. |
| <a name="output_ipsec_connection_id"></a> [ipsec\_connection\_id](#output\_ipsec\_connection\_id) | OCID of the IPSec connection. |
<!-- END_TF_DOCS -->
