# OCI Budget Module

Terraform module creating OCI Budget and Alert Rule resources.

## Usage Example

```hcl
module "oci_budget" {
  source = "./oci-budget-module"

  # OCI Provider configuration
  tenancy_ocid     = "<tenancy_ocid>"
  user_ocid        = "<user_ocid>"
  fingerprint      = "<fingerprint>"
  private_key_path = "~/.oci/private_key.pem"
  region           = "us-ashburn-1"

  # Budget configuration
  budget_compartment_id = "<compartment_ocid>"
  budget_amount         = "1000"
  budget_reset_period   = "MONTHLY"
  budget_target_type    = "COMPARTMENT"
  budget_target         = "<target_compartment_ocid>"
  budget_display_name   = "Monthly Budget"

  # Alert rule configuration
  alert_type           = "ACTUAL"
  threshold            = 80
  threshold_type       = "PERCENTAGE"
  recipients           = ["admin@example.com"]
  alert_display_name   = "80% Budget Alert"
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_budget_alert_rule.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/budget_alert_rule) | resource |
| [oci_budget_budget.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/budget_budget) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_defined_tags"></a> [alert\_defined\_tags](#input\_alert\_defined\_tags) | Defined tags for the alert rule. | `map(string)` | `{}` | no |
| <a name="input_alert_description"></a> [alert\_description](#input\_alert\_description) | Description for alert rule. | `string` | `""` | no |
| <a name="input_alert_display_name"></a> [alert\_display\_name](#input\_alert\_display\_name) | Display name of the alert rule. | `string` | `"Alert on $0.01 forecast spend"` | no |
| <a name="input_alert_freeform_tags"></a> [alert\_freeform\_tags](#input\_alert\_freeform\_tags) | Free-form tags for the alert rule. | `map(string)` | `{}` | no |
| <a name="input_alert_message"></a> [alert\_message](#input\_alert\_message) | Custom message for alert notification. | `string` | `""` | no |
| <a name="input_alert_recipients"></a> [alert\_recipients](#input\_alert\_recipients) | The delimited list of email addresses to receive the alert when it triggers. Delimiter characters can be a comma, space, TAB, or semicolon. | `string` | `""` | no |
| <a name="input_alert_threshold"></a> [alert\_threshold](#input\_alert\_threshold) | Threshold value for triggering the alert. | `number` | `1` | no |
| <a name="input_alert_threshold_type"></a> [alert\_threshold\_type](#input\_alert\_threshold\_type) | Type of threshold. | `string` | `"PERCENTAGE"` | no |
| <a name="input_alert_type"></a> [alert\_type](#input\_alert\_type) | Type of alert rule. | `string` | `"FORECAST"` | no |
| <a name="input_budget_amount"></a> [budget\_amount](#input\_budget\_amount) | (Required) (Updatable) The amount of the budget expressed as a whole number in the currency of the customer's rate card. | `number` | `1` | no |
| <a name="input_budget_compartment_id"></a> [budget\_compartment\_id](#input\_budget\_compartment\_id) | Compartment OCID for the budget. | `string` | n/a | yes |
| <a name="input_budget_defined_tags"></a> [budget\_defined\_tags](#input\_budget\_defined\_tags) | Defined tags for the budget. | `map(string)` | `{}` | no |
| <a name="input_budget_description"></a> [budget\_description](#input\_budget\_description) | Description of the budget. | `string` | `""` | no |
| <a name="input_budget_display_name"></a> [budget\_display\_name](#input\_budget\_display\_name) | Display name for the budget. | `string` | `"MonthlyBudget"` | no |
| <a name="input_budget_freeform_tags"></a> [budget\_freeform\_tags](#input\_budget\_freeform\_tags) | Free-form tags for the budget. | `map(string)` | `{}` | no |
| <a name="input_budget_processing_period_start_offset"></a> [budget\_processing\_period\_start\_offset](#input\_budget\_processing\_period\_start\_offset) | (Optional) (Updatable) The number of days offset from the first day of the month, at which the budget processing period starts. In months that have fewer days than this value, processing will begin on the last day of that month. For example, for a value of 12, processing starts every month on the 12th at midnight. | `number` | `1` | no |
| <a name="input_budget_processing_period_type"></a> [budget\_processing\_period\_type](#input\_budget\_processing\_period\_type) | Processing period type (INVOICE or MONTH). | `string` | `"MONTH"` | no |
| <a name="input_budget_reset_period"></a> [budget\_reset\_period](#input\_budget\_reset\_period) | (Required) (Updatable) The reset period for the budget. Valid value is MONTHLY. | `string` | `"MONTHLY"` | no |
| <a name="input_budget_target_type"></a> [budget\_target\_type](#input\_budget\_target\_type) | The type of target for the budget. | `string` | `"COMPARTMENT"` | no |
| <a name="input_budget_targets"></a> [budget\_targets](#input\_budget\_targets) | (Optional) The list of targets on which the budget is applied. If targetType is 'COMPARTMENT', the targets contain the list of compartment OCIDs. If targetType is 'TAG', the targets contain the list of cost tracking tag identifiers in the form of '{tagNamespace}.{tagKey}.{tagValue}'. Curerntly, the array should contain exactly one item. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alert_rule_id"></a> [alert\_rule\_id](#output\_alert\_rule\_id) | OCID of the budget alert rule. |
| <a name="output_budget_id"></a> [budget\_id](#output\_budget\_id) | OCID of the budget resource. |
<!-- END_TF_DOCS -->
