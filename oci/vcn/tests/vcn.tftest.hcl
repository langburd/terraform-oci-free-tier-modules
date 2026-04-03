mock_provider "oci" {
  mock_data "oci_core_services" {
    defaults = {
      services = [
        {
          cidr_block  = "all-iad-services-in-oracle-services-network"
          description = "All IAD Services In Oracle Services Network"
          id          = "ocid1.service.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          name        = "All IAD Services In Oracle Services Network"
        }
      ]
    }
  }
}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "default_creates_vcn_and_igw" {
  command = plan

  assert {
    condition     = oci_core_vcn.this.compartment_id == "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    error_message = "VCN compartment_id should match the input variable"
  }

  assert {
    condition     = oci_core_vcn.this.display_name == "vcn"
    error_message = "VCN display_name should default to 'vcn'"
  }

  assert {
    condition     = length(oci_core_internet_gateway.this) == 1
    error_message = "Internet gateway should be created by default"
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 0
    error_message = "NAT gateway should not be created by default"
  }

  assert {
    condition     = length(oci_core_service_gateway.this) == 0
    error_message = "Service gateway should not be created by default"
  }

  assert {
    condition     = length(oci_core_route_table.public) == 1
    error_message = "Public route table should be created when IGW is enabled"
  }

  assert {
    condition     = length(oci_core_route_table.private) == 0
    error_message = "Private route table should not be created by default"
  }
}

run "all_gateways" {
  command = plan

  variables {
    create_nat_gateway     = true
    create_service_gateway = true
  }

  assert {
    condition     = length(oci_core_internet_gateway.this) == 1
    error_message = "Internet gateway should be created"
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 1
    error_message = "NAT gateway should be created"
  }

  assert {
    condition     = length(oci_core_service_gateway.this) == 1
    error_message = "Service gateway should be created"
  }

  assert {
    condition     = length(oci_core_route_table.public) == 1
    error_message = "Public route table should be created"
  }

  assert {
    condition     = length(oci_core_route_table.private) == 1
    error_message = "Private route table should be created"
  }
}

run "no_gateways" {
  command = plan

  variables {
    create_internet_gateway = false
  }

  assert {
    condition     = length(oci_core_internet_gateway.this) == 0
    error_message = "Internet gateway should not be created"
  }

  assert {
    condition     = length(oci_core_nat_gateway.this) == 0
    error_message = "NAT gateway should not be created"
  }

  assert {
    condition     = length(oci_core_service_gateway.this) == 0
    error_message = "Service gateway should not be created"
  }

  assert {
    condition     = length(oci_core_route_table.public) == 0
    error_message = "Public route table should not be created"
  }

  assert {
    condition     = length(oci_core_route_table.private) == 0
    error_message = "Private route table should not be created"
  }

  assert {
    condition     = oci_core_security_list.this.compartment_id == var.compartment_id
    error_message = "Security list should always be created in the correct compartment"
  }
}

run "custom_cidr" {
  command = plan

  variables {
    vcn_cidr_blocks = ["192.168.0.0/20"]
  }

  assert {
    condition     = oci_core_vcn.this.cidr_blocks == tolist(["192.168.0.0/20"])
    error_message = "VCN cidr_blocks should use the custom CIDR"
  }
}

run "rejects_invalid_dns_label" {
  command = plan

  variables {
    vcn_dns_label = "INVALID-DNS"
  }

  expect_failures = [
    var.vcn_dns_label,
  ]
}

run "rejects_invalid_compartment_id" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.compartment_id,
  ]
}
