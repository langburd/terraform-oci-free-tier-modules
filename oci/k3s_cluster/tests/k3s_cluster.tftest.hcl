# Note: action blocks cannot be executed in terraform test (plan-only)
# These tests verify variable validations only.

mock_provider "ansible" {}
mock_provider "random" {}

variables {
  server_ips           = ["1.2.3.4"]
  ssh_private_key_path = "/tmp/test-key"
}

run "creates_cluster_with_defaults" {
  command = plan

  assert {
    condition     = local.api_endpoint == "1.2.3.4"
    error_message = "API endpoint should default to first server IP"
  }

  assert {
    condition     = ansible_playbook.k3s_server["0"].name == "1.2.3.4"
    error_message = "Server playbook name should be the IP address (index-keyed for_each, name = each.value)"
  }
}

run "uses_custom_api_endpoint" {
  command = plan

  variables {
    api_endpoint = "5.6.7.8"
  }

  assert {
    condition     = local.api_endpoint == "5.6.7.8"
    error_message = "Should use custom api_endpoint when provided"
  }
}

run "rejects_empty_server_ips" {
  command = plan

  variables {
    server_ips = []
  }

  expect_failures = [
    var.server_ips,
  ]
}

run "rejects_invalid_k3s_version" {
  command = plan

  variables {
    k3s_version = "1.31.12+k3s1"
  }

  expect_failures = [
    var.k3s_version,
  ]
}
