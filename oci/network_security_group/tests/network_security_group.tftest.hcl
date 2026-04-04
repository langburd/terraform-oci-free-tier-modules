mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  vcn_id         = "ocid1.vcn.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "creates_empty_nsg_with_defaults" {
  command = plan

  assert {
    condition     = oci_core_network_security_group.this.display_name == "nsg"
    error_message = "NSG display_name should default to 'nsg'"
  }

  assert {
    condition     = length(oci_core_network_security_group_security_rule.this) == 0
    error_message = "No security rules should be created when none are provided"
  }
}

run "creates_tcp_ingress_rules" {
  command = plan

  variables {
    ingress_rules = {
      allow_ssh = {
        protocol    = "6"
        source      = "0.0.0.0/0"
        tcp_options = { destination_port_range = { min = 22, max = 22 } }
        description = "Allow SSH"
      }
      allow_https = {
        protocol    = "6"
        source      = "0.0.0.0/0"
        tcp_options = { destination_port_range = { min = 443, max = 443 } }
        description = "Allow HTTPS"
      }
    }
  }

  assert {
    condition     = length(oci_core_network_security_group_security_rule.this) == 2
    error_message = "Expected 2 ingress rules to be created"
  }

  assert {
    condition     = oci_core_network_security_group_security_rule.this["ingress_allow_ssh"].direction == "INGRESS"
    error_message = "Rule direction should be INGRESS"
  }

  assert {
    condition     = oci_core_network_security_group_security_rule.this["ingress_allow_ssh"].source == "0.0.0.0/0"
    error_message = "Rule source should be 0.0.0.0/0"
  }
}

run "creates_icmp_rules" {
  command = plan

  variables {
    ingress_rules = {
      allow_icmp = {
        protocol     = "1"
        source       = "0.0.0.0/0"
        icmp_options = { type = 3, code = 4 }
        description  = "Allow ICMP type 3 code 4"
      }
    }
  }

  assert {
    condition     = length(oci_core_network_security_group_security_rule.this) == 1
    error_message = "Expected 1 ICMP rule to be created"
  }
}

run "creates_egress_rules" {
  command = plan

  variables {
    egress_rules = {
      allow_all_outbound = {
        protocol    = "all"
        destination = "0.0.0.0/0"
        description = "All outbound traffic"
      }
      allow_tcp_outbound = {
        protocol    = "6"
        destination = "10.0.0.0/8"
        tcp_options = { destination_port_range = { min = 443, max = 443 } }
        description = "Allow TCP outbound to internal"
      }
    }
  }

  assert {
    condition     = length(oci_core_network_security_group_security_rule.this) == 2
    error_message = "Expected 2 egress rules to be created"
  }

  assert {
    condition     = oci_core_network_security_group_security_rule.this["egress_allow_all_outbound"].direction == "EGRESS"
    error_message = "Rule direction should be EGRESS"
  }

  assert {
    condition     = oci_core_network_security_group_security_rule.this["egress_allow_all_outbound"].destination == "0.0.0.0/0"
    error_message = "Rule destination should be 0.0.0.0/0"
  }
}

run "creates_mixed_ingress_and_egress_rules" {
  command = plan

  variables {
    ingress_rules = {
      allow_ssh = {
        protocol    = "6"
        source      = "0.0.0.0/0"
        tcp_options = { destination_port_range = { min = 22, max = 22 } }
        description = "Allow SSH"
      }
      allow_https = {
        protocol    = "6"
        source      = "0.0.0.0/0"
        tcp_options = { destination_port_range = { min = 443, max = 443 } }
        description = "Allow HTTPS"
      }
    }
    egress_rules = {
      allow_all_outbound = {
        protocol    = "all"
        destination = "0.0.0.0/0"
        description = "All outbound traffic"
      }
    }
  }

  assert {
    condition     = length(oci_core_network_security_group_security_rule.this) == 3
    error_message = "Expected 3 rules total (2 ingress + 1 egress)"
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
