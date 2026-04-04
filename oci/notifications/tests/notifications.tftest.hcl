mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  topic_name     = "my-alerts"
}

run "creates_topic_with_no_subscriptions" {
  command = plan

  assert {
    condition     = oci_ons_notification_topic.this.name == "my-alerts"
    error_message = "Topic name should be my-alerts"
  }

  assert {
    condition     = length(oci_ons_subscription.this) == 0
    error_message = "No subscriptions should be created by default"
  }
}

run "creates_topic_with_email_subscription" {
  command = plan

  variables {
    subscriptions = {
      admin_email = {
        protocol = "EMAIL"
        endpoint = "admin@example.com"
      }
    }
  }

  assert {
    condition     = length(oci_ons_subscription.this) == 1
    error_message = "One subscription should be created"
  }
}

run "creates_topic_with_multiple_subscriptions" {
  command = plan

  variables {
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

  assert {
    condition     = length(oci_ons_subscription.this) == 2
    error_message = "Two subscriptions should be created"
  }
}

run "rejects_invalid_compartment_ocid" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.compartment_id,
  ]
}

run "rejects_invalid_topic_name" {
  command = plan
  variables {
    topic_name = "invalid topic name!"
  }
  expect_failures = [var.topic_name]
}

run "rejects_invalid_subscription_protocol" {
  command = plan

  variables {
    subscriptions = {
      bad_sub = {
        protocol = "INVALID_PROTOCOL"
        endpoint = "test@example.com"
      }
    }
  }

  expect_failures = [
    var.subscriptions,
  ]
}
