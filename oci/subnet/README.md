# oci/subnet

Terraform module managing a single OCI subnet within a VCN.

## Usage

```hcl
module "subnet" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/subnet/vX.Y.Z"

  compartment_id    = "ocid1.compartment.oc1..xxx"
  vcn_id            = "ocid1.vcn.oc1..xxx"
  subnet_cidr_block = "10.0.1.0/24"
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | 6.37.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_subnet.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_subnet) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_domain"></a> [availability\_domain](#input\_availability\_domain) | (Optional) The availability domain for the subnet. Omit (null) for a regional subnet, which spans all ADs and is recommended. | `string` | `null` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment in which to create the subnet. | `string` | n/a | yes |
| <a name="input_prohibit_internet_ingress"></a> [prohibit\_internet\_ingress](#input\_prohibit\_internet\_ingress) | (Optional) (Updatable) Whether to disallow ingress from the internet. Set to true for private subnets. | `bool` | `false` | no |
| <a name="input_route_table_id"></a> [route\_table\_id](#input\_route\_table\_id) | (Optional) (Updatable) The OCID of the route table to attach to the subnet. Defaults to the VCN's default route table when null. | `string` | `null` | no |
| <a name="input_security_list_ids"></a> [security\_list\_ids](#input\_security\_list\_ids) | (Optional) (Updatable) List of security list OCIDs to associate with the subnet. Defaults to the VCN's default security list when null. | `list(string)` | `null` | no |
| <a name="input_subnet_cidr_block"></a> [subnet\_cidr\_block](#input\_subnet\_cidr\_block) | (Required) The CIDR block assigned to the subnet (e.g. 10.0.1.0/24). | `string` | n/a | yes |
| <a name="input_subnet_defined_tags"></a> [subnet\_defined\_tags](#input\_subnet\_defined\_tags) | (Optional) (Updatable) Defined tags for the subnet. | `map(string)` | `{}` | no |
| <a name="input_subnet_display_name"></a> [subnet\_display\_name](#input\_subnet\_display\_name) | (Optional) (Updatable) A user-friendly name for the subnet. | `string` | `"subnet"` | no |
| <a name="input_subnet_dns_label"></a> [subnet\_dns\_label](#input\_subnet\_dns\_label) | (Optional) A DNS label for the subnet. Must be lowercase, start with a letter, max 15 chars (e.g. 'web', 'db01', 'private1'). Used to form FQDNs for VNICs in the subnet. Set to null to omit. | `string` | `null` | no |
| <a name="input_subnet_freeform_tags"></a> [subnet\_freeform\_tags](#input\_subnet\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the subnet. | `map(string)` | `{}` | no |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | (Required) The OCID of the VCN in which to create the subnet. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subnet_cidr_block"></a> [subnet\_cidr\_block](#output\_subnet\_cidr\_block) | The CIDR block assigned to the subnet. |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | OCID of the subnet. |
<!-- END_TF_DOCS -->
