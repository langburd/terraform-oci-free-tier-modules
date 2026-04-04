# OCI Network Load Balancer Module

Terraform module creating an OCI Network Load Balancer with backend set, listener, and optional backends.

Unlike the flexible load balancer, the NLB uses a single subnet (not a list) and operates at Layer 4.

## Usage Example

```hcl
module "network_load_balancer" {
  source = "../../oci/network_load_balancer"

  compartment_id = "<compartment_ocid>"
  subnet_id      = "<subnet_ocid>"

  backends = {
    "app1" = { ip_address = "10.0.2.10", port = 8080 }
    "app2" = { ip_address = "10.0.2.11", port = 8080 }
  }
}
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_network_load_balancer_backend.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_backend) | resource |
| [oci_network_load_balancer_backend_set.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_backend_set) | resource |
| [oci_network_load_balancer_listener.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_listener) | resource |
| [oci_network_load_balancer_network_load_balancer.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/network_load_balancer_network_load_balancer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_set_name"></a> [backend\_set\_name](#input\_backend\_set\_name) | (Optional) Name of the backend set. | `string` | `"backend-set"` | no |
| <a name="input_backend_set_policy"></a> [backend\_set\_policy](#input\_backend\_set\_policy) | (Optional) Load balancing policy. Supported values: FIVE\_TUPLE, THREE\_TUPLE, TWO\_TUPLE. | `string` | `"FIVE_TUPLE"` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | (Optional) Map of backends to add to the backend set. Keys are unique identifiers; values specify ip\_address and port. | <pre>map(object({<br/>    ip_address = string<br/>    port       = number<br/>  }))</pre> | `{}` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment in which to create the network load balancer. | `string` | n/a | yes |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | (Optional) Port for the health checker. 0 means use listener port. | `number` | `0` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | (Optional) Protocol for the health checker. Supported values: TCP, HTTP, HTTPS, UDP, DNS. | `string` | `"TCP"` | no |
| <a name="input_is_private"></a> [is\_private](#input\_is\_private) | (Optional) Whether the network load balancer is private (no public IP). | `bool` | `false` | no |
| <a name="input_listener_name"></a> [listener\_name](#input\_listener\_name) | (Optional) Name of the listener. | `string` | `"listener"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | (Optional) Port for the listener. | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | (Optional) Protocol for the listener. | `string` | `"TCP"` | no |
| <a name="input_nlb_defined_tags"></a> [nlb\_defined\_tags](#input\_nlb\_defined\_tags) | (Optional) Defined tags for the network load balancer. | `map(string)` | `{}` | no |
| <a name="input_nlb_display_name"></a> [nlb\_display\_name](#input\_nlb\_display\_name) | (Optional) Display name for the network load balancer. | `string` | `"network-load-balancer"` | no |
| <a name="input_nlb_freeform_tags"></a> [nlb\_freeform\_tags](#input\_nlb\_freeform\_tags) | (Optional) Free-form tags for the network load balancer. | `map(string)` | `{}` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) OCID of the subnet for the network load balancer. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_network_load_balancer_id"></a> [network\_load\_balancer\_id](#output\_network\_load\_balancer\_id) | OCID of the network load balancer. |
| <a name="output_nlb_ip_addresses"></a> [nlb\_ip\_addresses](#output\_nlb\_ip\_addresses) | List of IP address objects assigned to the network load balancer. |
<!-- END_TF_DOCS -->
