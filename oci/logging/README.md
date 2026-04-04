# OCI Logging Module

Terraform module creating OCI Logging resources including a log group and optional logs.

## Usage Example

```hcl
module "logging" {
  source = "../../oci/logging"

  compartment_id         = "<compartment_ocid>"
  log_group_display_name = "my-log-group"

  logs = {
    "audit-log" = {
      log_type = "AUDIT"
    }
    "compute-service-log" = {
      log_type           = "SERVICE"
      source_service     = "compute"
      source_resource    = "<instance_ocid>"
      source_category    = "console_connection"
      retention_duration = 60
    }
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
| [oci_logging_log.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log) | resource |
| [oci_logging_log_group.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/logging_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the logging resources. | `string` | n/a | yes |
| <a name="input_log_group_display_name"></a> [log\_group\_display\_name](#input\_log\_group\_display\_name) | (Optional) (Updatable) The display name of the log group. | `string` | `"log-group"` | no |
| <a name="input_logging_defined_tags"></a> [logging\_defined\_tags](#input\_logging\_defined\_tags) | Defined tags for the logging resources. | `map(string)` | `{}` | no |
| <a name="input_logging_freeform_tags"></a> [logging\_freeform\_tags](#input\_logging\_freeform\_tags) | Free-form tags for the logging resources. | `map(string)` | `{}` | no |
| <a name="input_logs"></a> [logs](#input\_logs) | (Optional) Map of logs to create. Keys are used as display names. | <pre>map(object({<br/>    log_type           = string<br/>    source_service     = optional(string)<br/>    source_resource    = optional(string)<br/>    source_category    = optional(string)<br/>    is_enabled         = optional(bool, true)<br/>    retention_duration = optional(number, 30)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_log_group_id"></a> [log\_group\_id](#output\_log\_group\_id) | OCID of the log group. |
| <a name="output_log_ids"></a> [log\_ids](#output\_log\_ids) | Map of log display names to their OCIDs. |
<!-- END_TF_DOCS -->
