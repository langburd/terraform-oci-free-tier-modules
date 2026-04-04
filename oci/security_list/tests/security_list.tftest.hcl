mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  vcn_id         = "ocid1.vcn.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_empty_security_list_with_defaults" {
  command = plan

  assert {
    condition     = oci_core_security_list.this.display_name == "security-list"
    error_message = "display_name should default to 'security-list'"
  }

  assert {
    condition     = length(oci_core_security_list.this.ingress_security_rules) == 0
    error_message = "Expected 0 ingress rules by default"
  }

  assert {
    condition     = length(oci_core_security_list.this.egress_security_rules) == 0
    error_message = "Expected 0 egress rules by default"
  }
}

run "creates_tcp_ingress_rules" {
  command = plan

  variables {
    ingress_security_rules = [
      {
        protocol    = "6"
        source      = "10.0.0.0/16"
        description = "Intra-VCN all TCP"
      },
      {
        protocol    = "6"
        source      = "0.0.0.0/0"
        tcp_options = { min = 22, max = 22 }
        description = "SSH"
      },
    ]
  }

  assert {
    condition     = length(oci_core_security_list.this.ingress_security_rules) == 2
    error_message = "Expected 2 ingress rules"
  }

  assert {
    condition     = contains([for r in oci_core_security_list.this.ingress_security_rules : r.source], "10.0.0.0/16")
    error_message = "Expected ingress rule with source 10.0.0.0/16"
  }
}

run "creates_icmp_rules" {
  command = plan

  variables {
    ingress_security_rules = [
      {
        protocol     = "1"
        source       = "0.0.0.0/0"
        description  = "ICMP ping"
        icmp_options = { type = 8, code = 0 }
      },
    ]
  }

  assert {
    condition     = length(oci_core_security_list.this.ingress_security_rules) == 1
    error_message = "Expected 1 ICMP ingress rule"
  }

  assert {
    condition     = one([for r in oci_core_security_list.this.ingress_security_rules : r.protocol]) == "1"
    error_message = "Expected protocol '1' (ICMP)"
  }
}

run "creates_egress_rules" {
  command = plan

  variables {
    egress_security_rules = [
      {
        protocol    = "all"
        destination = "0.0.0.0/0"
        description = "All outbound"
      },
    ]
  }

  assert {
    condition     = length(oci_core_security_list.this.egress_security_rules) == 1
    error_message = "Expected 1 egress rule"
  }

  assert {
    condition     = one([for r in oci_core_security_list.this.egress_security_rules : r.destination]) == "0.0.0.0/0"
    error_message = "Expected egress destination 0.0.0.0/0"
  }
}

run "creates_stateless_rules" {
  command = plan

  variables {
    ingress_security_rules = [
      {
        protocol    = "6"
        source      = "10.0.0.0/8"
        description = "Stateless intra-cluster"
        stateless   = true
      },
    ]
  }

  assert {
    condition     = one([for r in oci_core_security_list.this.ingress_security_rules : r.stateless]) == true
    error_message = "Expected stateless = true"
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

run "rejects_invalid_vcn_ocid" {
  command = plan

  variables {
    vcn_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.vcn_id,
  ]
}
