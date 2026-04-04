# OCI Load Balancer Module

Terraform module creating an OCI flexible Load Balancer with backend set, listener, and optional backends.

The shape is hardcoded to `flexible` with 10 Mbps minimum and maximum bandwidth to enforce free tier limits.

## Usage Example

```hcl
module "load_balancer" {
  source = "../../oci/load_balancer"

  compartment_id = "<compartment_ocid>"
  subnet_ids     = ["<public_subnet_ocid>"]

  backends = {
    "web1" = { ip_address = "10.0.1.10", port = 8080 }
    "web2" = { ip_address = "10.0.1.11", port = 8080 }
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
| [oci_load_balancer_backend.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_backend) | resource |
| [oci_load_balancer_backend_set.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_backend_set) | resource |
| [oci_load_balancer_listener.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_listener) | resource |
| [oci_load_balancer_load_balancer.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/load_balancer_load_balancer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_set_name"></a> [backend\_set\_name](#input\_backend\_set\_name) | (Optional) Name of the backend set. | `string` | `"backend-set"` | no |
| <a name="input_backend_set_policy"></a> [backend\_set\_policy](#input\_backend\_set\_policy) | (Optional) Load balancing policy. Supported values: ROUND\_ROBIN, LEAST\_CONNECTIONS, IP\_HASH. | `string` | `"ROUND_ROBIN"` | no |
| <a name="input_backends"></a> [backends](#input\_backends) | (Optional) Map of backends to add to the backend set. Keys are unique identifiers; values specify ip\_address and port. | <pre>map(object({<br/>    ip_address = string<br/>    port       = number<br/>  }))</pre> | `{}` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) OCID of the compartment in which to create the load balancer. | `string` | n/a | yes |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | (Optional) Port for the health checker. | `number` | `80` | no |
| <a name="input_health_check_protocol"></a> [health\_check\_protocol](#input\_health\_check\_protocol) | (Optional) Protocol for the health checker. Supported values: HTTP, HTTPS, TCP. | `string` | `"HTTP"` | no |
| <a name="input_health_check_url_path"></a> [health\_check\_url\_path](#input\_health\_check\_url\_path) | (Optional) URL path for the health checker (HTTP/HTTPS only). | `string` | `"/"` | no |
| <a name="input_is_private"></a> [is\_private](#input\_is\_private) | (Optional) Whether the load balancer is private (no public IP). | `bool` | `false` | no |
| <a name="input_lb_defined_tags"></a> [lb\_defined\_tags](#input\_lb\_defined\_tags) | (Optional) Defined tags for the load balancer. | `map(string)` | `{}` | no |
| <a name="input_lb_display_name"></a> [lb\_display\_name](#input\_lb\_display\_name) | (Optional) Display name for the load balancer. | `string` | `"load-balancer"` | no |
| <a name="input_lb_freeform_tags"></a> [lb\_freeform\_tags](#input\_lb\_freeform\_tags) | (Optional) Free-form tags for the load balancer. | `map(string)` | `{}` | no |
| <a name="input_listener_name"></a> [listener\_name](#input\_listener\_name) | (Optional) Name of the listener. | `string` | `"listener"` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | (Optional) Port for the listener. | `number` | `80` | no |
| <a name="input_listener_protocol"></a> [listener\_protocol](#input\_listener\_protocol) | (Optional) Protocol for the listener. | `string` | `"HTTP"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | (Required) List of subnet OCIDs for the load balancer. Must contain at least one element. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | OCID of the load balancer. |
| <a name="output_load_balancer_ip_addresses"></a> [load\_balancer\_ip\_addresses](#output\_load\_balancer\_ip\_addresses) | List of IP address objects assigned to the load balancer. |
<!-- END_TF_DOCS -->
