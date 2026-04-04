# OCI Notifications Module

Terraform module creating an OCI Notification Service topic with optional subscriptions.

## Important

- **Topic names must be unique across the entire tenancy**, not just the compartment.
- Subscriptions support these protocols: `EMAIL`, `HTTPS`, `SLACK`, `PAGERDUTY`, `GFC`
- Tags are applied to the topic resource only; subscriptions do not support tags

## Usage Example

```hcl
module "notifications" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/notifications/v1.0.0"

  compartment_id    = "<compartment_ocid>"
  topic_name        = "my-alerts"
  topic_description = "Alert notifications for my application"

  subscriptions = {
    admin_email = {
      protocol = "EMAIL"
      endpoint = "admin@example.com"
    }
    webhook = {
      protocol = "HTTPS"
      endpoint = "https://hooks.example.com/notify"
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
| [oci_ons_notification_topic.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_notification_topic) | resource |
| [oci_ons_subscription.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/ons_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment where the notification topic will be created. | `string` | n/a | yes |
| <a name="input_notifications_defined_tags"></a> [notifications\_defined\_tags](#input\_notifications\_defined\_tags) | (Optional) (Updatable) Defined tags for the notification topic resource. | `map(string)` | `{}` | no |
| <a name="input_notifications_freeform_tags"></a> [notifications\_freeform\_tags](#input\_notifications\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the notification topic resource. | `map(string)` | `{}` | no |
| <a name="input_subscriptions"></a> [subscriptions](#input\_subscriptions) | (Optional) A map of subscriptions to create on the topic. Each subscription requires a protocol and endpoint. Supported protocols: EMAIL, HTTPS, SLACK, PAGERDUTY, GFC. | <pre>map(object({<br/>    protocol = string<br/>    endpoint = string<br/>  }))</pre> | `{}` | no |
| <a name="input_topic_description"></a> [topic\_description](#input\_topic\_description) | (Optional) (Updatable) The description of the topic. | `string` | `null` | no |
| <a name="input_topic_name"></a> [topic\_name](#input\_topic\_name) | (Required) The name of the topic. Topic names must be unique across the entire tenancy. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_subscription_ids"></a> [subscription\_ids](#output\_subscription\_ids) | A map of subscription keys to their OCIDs. |
| <a name="output_topic_arn"></a> [topic\_arn](#output\_topic\_arn) | The API endpoint (topic ARN) of the notification topic. |
| <a name="output_topic_id"></a> [topic\_id](#output\_topic\_id) | OCID of the notification topic resource. |
<!-- END_TF_DOCS -->
