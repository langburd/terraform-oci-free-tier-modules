# Free Tier Observability Example

Demonstrates OCI observability services using Monitoring, Logging, APM, and Connector Hub modules.

## What this example creates

- OCI compartment
- Notifications topic for alarm routing
- Monitoring alarm (CPU utilization > 80%)
- Log group with one custom log
- APM domain (free tier)
- Service connector routing log entries to the notification topic

## Usage

```hcl
oci_config_profile = "DEFAULT"
compartment_name   = "free-tier-observability"
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_apm"></a> [apm](#module\_apm) | ../../oci/apm | n/a |
| <a name="module_compartment"></a> [compartment](#module\_compartment) | ../../oci/identity | n/a |
| <a name="module_connector_hub"></a> [connector\_hub](#module\_connector\_hub) | ../../oci/connector_hub | n/a |
| <a name="module_logging"></a> [logging](#module\_logging) | ../../oci/logging | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ../../oci/monitoring | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_ons_notification_topic.alarms](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | (Optional) Name of the OCI compartment to create. | `string` | `"free-tier-observability"` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_id"></a> [alarm\_id](#output\_alarm\_id) | OCID of the monitoring alarm. |
| <a name="output_apm_data_upload_endpoint"></a> [apm\_data\_upload\_endpoint](#output\_apm\_data\_upload\_endpoint) | APM data upload endpoint for agent configuration. |
| <a name="output_apm_domain_id"></a> [apm\_domain\_id](#output\_apm\_domain\_id) | OCID of the APM domain. |
| <a name="output_compartment_id"></a> [compartment\_id](#output\_compartment\_id) | OCID of the created compartment. |
| <a name="output_log_group_id"></a> [log\_group\_id](#output\_log\_group\_id) | OCID of the log group. |
| <a name="output_notification_topic_id"></a> [notification\_topic\_id](#output\_notification\_topic\_id) | OCID of the notifications topic for alarms. |
| <a name="output_service_connector_id"></a> [service\_connector\_id](#output\_service\_connector\_id) | OCID of the service connector. |
<!-- END_TF_DOCS -->
