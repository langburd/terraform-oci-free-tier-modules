# OCI Connector Hub Module

Terraform module creating an OCI Service Connector Hub resource.

## Notes

- IAM policies granting the Service Connector Hub service access to source and target resources must be created by the caller.
- Connectors automatically deactivate after 7 or more consecutive days of continuous failures.

## Usage Example

```hcl
module "connector_hub" {
  source = "../../oci/connector_hub"

  compartment_id = "<compartment_ocid>"
  source_kind    = "logging"
  target_kind    = "notifications"

  source_log_sources = [
    {
      compartment_id = "<compartment_ocid>"
    }
  ]

  target_topic_id = "<topic_ocid>"
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
| [oci_sch_service_connector.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/sch_service_connector) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the service connector. | `string` | n/a | yes |
| <a name="input_connector_defined_tags"></a> [connector\_defined\_tags](#input\_connector\_defined\_tags) | Defined tags for the service connector resource. | `map(string)` | `{}` | no |
| <a name="input_connector_description"></a> [connector\_description](#input\_connector\_description) | (Optional) (Updatable) The description of the service connector. | `string` | `null` | no |
| <a name="input_connector_display_name"></a> [connector\_display\_name](#input\_connector\_display\_name) | (Optional) (Updatable) A user-friendly name for the service connector. | `string` | `"service-connector"` | no |
| <a name="input_connector_freeform_tags"></a> [connector\_freeform\_tags](#input\_connector\_freeform\_tags) | Free-form tags for the service connector resource. | `map(string)` | `{}` | no |
| <a name="input_connector_state"></a> [connector\_state](#input\_connector\_state) | (Optional) (Updatable) The target state for the service connector. Valid values: ACTIVE, INACTIVE. | `string` | `"ACTIVE"` | no |
| <a name="input_source_kind"></a> [source\_kind](#input\_source\_kind) | (Required) The type of source for the service connector. Valid values: logging, monitoring, streaming. | `string` | n/a | yes |
| <a name="input_source_log_sources"></a> [source\_log\_sources](#input\_source\_log\_sources) | (Optional) List of log sources for logging source kind. Each entry specifies compartment\_id and optionally log\_group\_id and log\_id. | <pre>list(object({<br/>    compartment_id = string<br/>    log_group_id   = optional(string)<br/>    log_id         = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_target_kind"></a> [target\_kind](#input\_target\_kind) | (Required) The type of target for the service connector. Valid values: objectStorage, notifications, streaming, monitoring, functions, loggingAnalytics. | `string` | n/a | yes |
| <a name="input_target_object_storage_bucket"></a> [target\_object\_storage\_bucket](#input\_target\_object\_storage\_bucket) | (Optional) The target object storage bucket name. Required when target\_kind is objectStorage. | `string` | `null` | no |
| <a name="input_target_object_storage_namespace"></a> [target\_object\_storage\_namespace](#input\_target\_object\_storage\_namespace) | (Optional) The target object storage namespace. Required when target\_kind is objectStorage. | `string` | `null` | no |
| <a name="input_target_topic_id"></a> [target\_topic\_id](#input\_target\_topic\_id) | (Optional) The OCID of the target notifications topic. Required when target\_kind is notifications. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connector_state"></a> [connector\_state](#output\_connector\_state) | The current lifecycle state of the service connector. |
| <a name="output_service_connector_id"></a> [service\_connector\_id](#output\_service\_connector\_id) | OCID of the service connector. |
<!-- END_TF_DOCS -->
