# OCI Monitoring Module

Terraform module creating an OCI Monitoring Alarm resource.

## Usage Example

```hcl
module "monitoring" {
  source = "../../oci/monitoring"

  compartment_id        = "<compartment_ocid>"
  alarm_display_name    = "high-cpu-alarm"
  metric_compartment_id = "<compartment_ocid>"
  alarm_namespace       = "oci_computeagent"
  alarm_query           = "CpuUtilization[1m].mean() > 80"
  alarm_severity        = "WARNING"
  destinations          = ["<topic_ocid>"]
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
| [oci_monitoring_alarm.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/monitoring_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_body"></a> [alarm\_body](#input\_alarm\_body) | (Optional) (Updatable) The human-readable content of the delivered alarm notification. | `string` | `null` | no |
| <a name="input_alarm_defined_tags"></a> [alarm\_defined\_tags](#input\_alarm\_defined\_tags) | Defined tags for the alarm resource. | `map(string)` | `{}` | no |
| <a name="input_alarm_display_name"></a> [alarm\_display\_name](#input\_alarm\_display\_name) | (Required) A user-friendly name for the alarm. | `string` | n/a | yes |
| <a name="input_alarm_freeform_tags"></a> [alarm\_freeform\_tags](#input\_alarm\_freeform\_tags) | Free-form tags for the alarm resource. | `map(string)` | `{}` | no |
| <a name="input_alarm_is_enabled"></a> [alarm\_is\_enabled](#input\_alarm\_is\_enabled) | (Optional) (Updatable) Whether the alarm is enabled. Defaults to true. | `bool` | `true` | no |
| <a name="input_alarm_namespace"></a> [alarm\_namespace](#input\_alarm\_namespace) | (Required) The source service or application emitting the metric that is evaluated by the alarm. For example: oci\_computeagent. | `string` | n/a | yes |
| <a name="input_alarm_query"></a> [alarm\_query](#input\_alarm\_query) | (Required) The Monitoring Query Language (MQL) expression that defines the metric being evaluated by the alarm. For example: CpuUtilization[1m].mean() > 80. | `string` | n/a | yes |
| <a name="input_alarm_severity"></a> [alarm\_severity](#input\_alarm\_severity) | (Optional) (Updatable) The perceived type of response required when the alarm is in the firing state. Valid values: CRITICAL, ERROR, WARNING, INFO. | `string` | `"WARNING"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment containing the alarm. | `string` | n/a | yes |
| <a name="input_destinations"></a> [destinations](#input\_destinations) | (Required) A list of destinations to which the notifications for this alarm are sent. Each destination is a topic OCID. | `list(string)` | n/a | yes |
| <a name="input_metric_compartment_id"></a> [metric\_compartment\_id](#input\_metric\_compartment\_id) | (Required) The OCID of the compartment containing the metric being evaluated by the alarm. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alarm_id"></a> [alarm\_id](#output\_alarm\_id) | OCID of the monitoring alarm. |
| <a name="output_alarm_state"></a> [alarm\_state](#output\_alarm\_state) | The current lifecycle state of the alarm. |
<!-- END_TF_DOCS -->
