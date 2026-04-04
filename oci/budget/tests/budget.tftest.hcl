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

run "rejects_empty_budget_targets" {
  command = plan

  variables {
    budget_targets = []
  }

  expect_failures = [
    var.budget_targets,
  ]
}

run "rejects_multiple_budget_targets" {
  command = plan

  variables {
    budget_targets = [
      "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      "ocid1.compartment.oc1..bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb",
    ]
  }

  expect_failures = [
    var.budget_targets,
  ]
}

run "rejects_invalid_alert_display_name" {
  command = plan

  variables {
    alert_display_name = "Invalid Name With Spaces"
  }

  expect_failures = [
    var.alert_display_name,
  ]
}

run "rejects_invalid_budget_display_name" {
  command = plan

  variables {
    budget_display_name = "Invalid Name With Spaces"
  }

  expect_failures = [
    var.budget_display_name,
  ]
}

run "rejects_zero_alert_threshold" {
  command = plan

  variables {
    alert_threshold = 0
  }

  expect_failures = [
    var.alert_threshold,
  ]
}

run "rejects_invalid_alert_type" {
  command = plan

  variables {
    alert_type = "INVALID"
  }

  expect_failures = [
    var.alert_type,
  ]
}

run "rejects_invalid_budget_processing_period_type" {
  command = plan

  variables {
    budget_processing_period_type = "INVALID"
  }

  expect_failures = [
    var.budget_processing_period_type,
  ]
}

run "rejects_invalid_budget_target_type" {
  command = plan

  variables {
    budget_target_type = "INVALID"
  }

  expect_failures = [
    var.budget_target_type,
  ]
}

run "rejects_below_min_processing_period_start_offset" {
  command = plan

  variables {
    budget_processing_period_start_offset = 0
  }

  expect_failures = [
    var.budget_processing_period_start_offset,
  ]
}

run "rejects_above_max_processing_period_start_offset" {
  command = plan

  variables {
    budget_processing_period_start_offset = 29
  }

  expect_failures = [
    var.budget_processing_period_start_offset,
  ]
}

run "rejects_fractional_budget_amount" {
  command = plan

  variables {
    budget_amount = 1.5
  }

  expect_failures = [
    var.budget_amount,
  ]
}

run "rejects_invalid_email_in_alert_recipients" {
  command = plan

  variables {
    alert_recipients = "not-an-email"
  }

  expect_failures = [
    var.alert_recipients,
  ]
}
