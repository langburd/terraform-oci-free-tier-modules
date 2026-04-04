# OCI Security List Module

Terraform module creating an OCI Security List with configurable ingress and egress rules.

## Usage Example

```hcl
module "k3s_security_list" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/security_list/v1.0.0"

  compartment_id             = "<compartment_ocid>"
  vcn_id                     = "<vcn_ocid>"
  security_list_display_name = "k3s-security-list"

  ingress_security_rules = [
    {
      protocol    = "6"
      source      = "10.0.0.0/16"
      description = "Intra-VCN all TCP"
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      tcp_options = { min = 22, max = 22 }
      description = "SSH"
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      tcp_options = { min = 6443, max = 6443 }
      description = "K3s API"
    },
  ]

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "All outbound"
    },
  ]
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_security_list.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_security_list) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment in which to create the security list. | `string` | n/a | yes |
| <a name="input_egress_security_rules"></a> [egress\_security\_rules](#input\_egress\_security\_rules) | (Optional) (Updatable) List of egress security rules. | <pre>list(object({<br/>    protocol         = string<br/>    destination      = string<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    description      = optional(string, "")<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number)<br/>    }))<br/>    stateless = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_ingress_security_rules"></a> [ingress\_security\_rules](#input\_ingress\_security\_rules) | (Optional) (Updatable) List of ingress security rules. | <pre>list(object({<br/>    protocol    = string<br/>    source      = string<br/>    source_type = optional(string, "CIDR_BLOCK")<br/>    description = optional(string, "")<br/>    tcp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    udp_options = optional(object({<br/>      min = number<br/>      max = number<br/>    }))<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number)<br/>    }))<br/>    stateless = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_security_list_defined_tags"></a> [security\_list\_defined\_tags](#input\_security\_list\_defined\_tags) | (Optional) (Updatable) Defined tags for the security list. | `map(string)` | `{}` | no |
| <a name="input_security_list_display_name"></a> [security\_list\_display\_name](#input\_security\_list\_display\_name) | (Optional) (Updatable) A user-friendly name for the security list. | `string` | `"security-list"` | no |
| <a name="input_security_list_freeform_tags"></a> [security\_list\_freeform\_tags](#input\_security\_list\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the security list. | `map(string)` | `{}` | no |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | (Required) The OCID of the VCN in which to create the security list. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_security_list_id"></a> [security\_list\_id](#output\_security\_list\_id) | OCID of the security list. |
<!-- END_TF_DOCS -->
