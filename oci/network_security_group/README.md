# OCI Network Security Group Module

Terraform module creating an OCI Network Security Group with configurable security rules.

## Usage Example

```hcl
module "api_endpoint_nsg" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/network_security_group/v1.0.0"

  compartment_id   = "<compartment_ocid>"
  vcn_id           = "<vcn_ocid>"
  nsg_display_name = "api-endpoint-nsg"

  ingress_rules = {
    allow_workers_api = {
      protocol    = "6"
      source      = "10.0.2.0/24"
      tcp_options = { destination_port_range = { min = 6443, max = 6443 } }
      description = "Worker-to-API"
    }
  }

  egress_rules = {
    allow_all_outbound = {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "All outbound"
    }
  }
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
| [oci_core_network_security_group.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group) | resource |
| [oci_core_network_security_group_security_rule.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group_security_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | Compartment OCID where the NSG will be created. | `string` | n/a | yes |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | Map of egress (outbound) security rules. Each rule's `destination` field specifies the destination CIDR; `source` is not used for egress. | <pre>map(object({<br/>    protocol         = string<br/>    source           = optional(string)<br/>    source_type      = optional(string, "CIDR_BLOCK")<br/>    destination      = optional(string)<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    tcp_options = optional(object({<br/>      destination_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>    }))<br/>    udp_options = optional(object({<br/>      destination_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>    }))<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number) # null = all codes<br/>    }))<br/>    description = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | Map of ingress (inbound) security rules. Each rule's `source` field specifies the source CIDR; `destination` is not used for ingress. | <pre>map(object({<br/>    protocol         = string<br/>    source           = optional(string)<br/>    source_type      = optional(string, "CIDR_BLOCK")<br/>    destination      = optional(string)<br/>    destination_type = optional(string, "CIDR_BLOCK")<br/>    tcp_options = optional(object({<br/>      destination_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>    }))<br/>    udp_options = optional(object({<br/>      destination_port_range = object({<br/>        min = number<br/>        max = number<br/>      })<br/>    }))<br/>    icmp_options = optional(object({<br/>      type = number<br/>      code = optional(number) # null = all codes<br/>    }))<br/>    description = optional(string, "")<br/>  }))</pre> | `{}` | no |
| <a name="input_nsg_defined_tags"></a> [nsg\_defined\_tags](#input\_nsg\_defined\_tags) | Defined tags for the Network Security Group. | `map(string)` | `{}` | no |
| <a name="input_nsg_display_name"></a> [nsg\_display\_name](#input\_nsg\_display\_name) | Display name for the Network Security Group. | `string` | `"nsg"` | no |
| <a name="input_nsg_freeform_tags"></a> [nsg\_freeform\_tags](#input\_nsg\_freeform\_tags) | Free-form tags for the Network Security Group. | `map(string)` | `{}` | no |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | VCN OCID in which the NSG will be created. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_id"></a> [nsg\_id](#output\_nsg\_id) | OCID of the Network Security Group. |
<!-- END_TF_DOCS -->
