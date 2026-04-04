mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  subnet_id      = "ocid1.subnet.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_nlb_with_defaults" {
  command = plan

  assert {
    condition     = oci_network_load_balancer_network_load_balancer.this.display_name == "network-load-balancer"
    error_message = "NLB display name should default to network-load-balancer"
  }

  assert {
    condition     = oci_network_load_balancer_network_load_balancer.this.is_private == false
    error_message = "NLB should be public by default"
  }

  assert {
    condition     = oci_network_load_balancer_backend_set.this.policy == "FIVE_TUPLE"
    error_message = "Backend set policy should default to FIVE_TUPLE"
  }

  assert {
    condition     = oci_network_load_balancer_listener.this.port == 80
    error_message = "Listener port should default to 80"
  }

  assert {
    condition     = length(oci_network_load_balancer_backend.this) == 0
    error_message = "No backends should be created by default"
  }

  assert {
    condition     = oci_network_load_balancer_listener.this.protocol == "TCP"
    error_message = "Listener protocol should default to TCP"
  }
}

run "creates_backends_when_provided" {
  command = plan

  variables {
    backends = {
      "app1" = { ip_address = "10.0.2.10", port = 8080 }
      "app2" = { ip_address = "10.0.2.11", port = 8080 }
    }
  }

  assert {
    condition     = length(oci_network_load_balancer_backend.this) == 2
    error_message = "Two backends should be created"
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

run "rejects_invalid_policy" {
  command = plan

  variables {
    backend_set_policy = "INVALID_POLICY"
  }

  expect_failures = [
    var.backend_set_policy,
  ]
}
