mock_provider "oci" {}

variables {
  budget_compartment_id = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  budget_targets        = ["ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
}

run "creates_budget_with_defaults" {
  command = plan

  assert {
    condition     = oci_budget_budget.this.amount == 1
    error_message = "Budget amount should default to 1"
  }

  assert {
    condition     = oci_budget_budget.this.reset_period == "MONTHLY"
    error_message = "Budget reset period should default to MONTHLY"
  }

  assert {
    condition     = oci_budget_budget.this.processing_period_type == "MONTH"
    error_message = "Budget processing period type should default to MONTH"
  }
}

run "creates_alert_rule_by_default" {
  command = plan

  assert {
    condition     = length(oci_budget_alert_rule.this) == 1
    error_message = "Alert rule should be created by default"
  }
}

run "skips_alert_rule_when_disabled" {
  command = plan

  variables {
    create_alert_rule = false
  }

  assert {
    condition     = length(oci_budget_alert_rule.this) == 0
    error_message = "Alert rule should not be created when create_alert_rule is false"
  }
}

run "rejects_invalid_compartment_ocid" {
  command = plan

  variables {
    budget_compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.budget_compartment_id,
  ]
}

run "rejects_zero_budget_amount" {
  command = plan

  variables {
    budget_amount = 0
  }

  expect_failures = [
    var.budget_amount,
  ]
}

run "rejects_invalid_threshold_type" {
  command = plan

  variables {
    alert_threshold_type = "INVALID"
  }

  expect_failures = [
    var.alert_threshold_type,
  ]
}
