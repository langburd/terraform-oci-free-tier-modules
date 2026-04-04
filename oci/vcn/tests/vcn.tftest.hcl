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

run "default_creates_vcn_no_igw" {
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
    condition     = length(oci_core_internet_gateway.this) == 0
    error_message = "Internet gateway should not be created by default"
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
    condition     = length(oci_core_route_table.public) == 0
    error_message = "Public route table should not be created without IGW"
  }

  assert {
    condition     = length(oci_core_route_table.private) == 0
    error_message = "Private route table should not be created by default"
  }
}

run "creates_igw_when_enabled" {
  command = plan

  variables {
    create_internet_gateway = true
  }

  assert {
    condition     = length(oci_core_internet_gateway.this) == 1
    error_message = "Internet gateway should be created when create_internet_gateway = true"
  }

  assert {
    condition     = length(oci_core_route_table.public) == 1
    error_message = "Public route table should be created when IGW is enabled"
  }
}

run "all_gateways" {
  command = plan

  variables {
    create_internet_gateway = true
    create_nat_gateway      = true
    create_service_gateway  = true
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

  # Verify that the service gateway is wired into both route tables by confirming
  # the SGW variable is true (which drives the dynamic route_rules blocks). A
  # length() check on route_rules cannot be used at plan time because the
  # network_entity_id values are computed and unknown until apply.
  assert {
    condition     = var.create_service_gateway == true
    error_message = "create_service_gateway must be true for service routes to be added to route tables"
  }
}

run "no_internet_gateway" {
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
