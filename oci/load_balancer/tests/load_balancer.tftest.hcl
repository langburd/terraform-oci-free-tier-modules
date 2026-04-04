mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  subnet_ids     = ["ocid1.subnet.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
}

run "creates_load_balancer_with_defaults" {
  command = plan

  assert {
    condition     = oci_load_balancer_load_balancer.this.shape == "flexible"
    error_message = "Load balancer shape should be flexible"
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.display_name == "load-balancer"
    error_message = "Load balancer display name should default to load-balancer"
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.is_private == false
    error_message = "Load balancer should be public by default"
  }

  assert {
    condition     = oci_load_balancer_backend_set.this.policy == "ROUND_ROBIN"
    error_message = "Backend set policy should default to ROUND_ROBIN"
  }

  assert {
    condition     = oci_load_balancer_listener.this.port == 443
    error_message = "Listener port should default to 443"
  }

  assert {
    condition     = oci_load_balancer_listener.this.protocol == "HTTPS"
    error_message = "Listener protocol should default to HTTPS"
  }

  assert {
    condition     = length(oci_load_balancer_backend.this) == 0
    error_message = "No backends should be created by default"
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.shape_details[0].minimum_bandwidth_in_mbps == 10
    error_message = "Minimum bandwidth must be 10 Mbps for free tier"
  }

  assert {
    condition     = oci_load_balancer_load_balancer.this.shape_details[0].maximum_bandwidth_in_mbps == 10
    error_message = "Maximum bandwidth must be 10 Mbps for free tier"
  }
}

run "creates_backends_when_provided" {
  command = plan

  variables {
    backends = {
      "web1" = { ip_address = "10.0.1.10", port = 8080 }
      "web2" = { ip_address = "10.0.1.11", port = 8080 }
    }
  }

  assert {
    condition     = length(oci_load_balancer_backend.this) == 2
    error_message = "Two backends should be created"
  }
}

run "rejects_invalid_policy" {
  command = plan

  variables {
    backend_set_policy = "INVALID_POLICY"
  }

  expect_failures = [
    var.backend_set_policy,
  ]
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

run "default_listener_uses_https" {
  command = plan

  assert {
    condition     = oci_load_balancer_listener.this.protocol == "HTTPS"
    error_message = "Listener protocol should default to HTTPS"
  }

  assert {
    condition     = oci_load_balancer_listener.this.port == 443
    error_message = "Listener port should default to 443 for HTTPS"
  }
}
