mock_provider "oci" {}

variables {
  compartment_id    = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  vcn_id            = "ocid1.vcn.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  subnet_cidr_block = "10.0.1.0/24"
}

run "default_creates_public_regional_subnet" {
  command = plan

  assert {
    condition     = oci_core_subnet.this.prohibit_internet_ingress == false
    error_message = "prohibit_internet_ingress should default to false"
  }

  assert {
    condition     = oci_core_subnet.this.display_name == "subnet"
    error_message = "display_name should default to 'subnet'"
  }

  assert {
    condition     = var.availability_domain == null
    error_message = "availability_domain should default to null (regional subnet)"
  }

  assert {
    condition     = oci_core_subnet.this.cidr_block == "10.0.1.0/24"
    error_message = "cidr_block should match the input variable"
  }
}

run "private_subnet" {
  command = plan

  variables {
    prohibit_internet_ingress = true
  }

  assert {
    condition     = oci_core_subnet.this.prohibit_internet_ingress == true
    error_message = "prohibit_internet_ingress should be true for private subnets"
  }
}

run "with_route_table_and_security_list" {
  command = plan

  variables {
    route_table_id    = "ocid1.routetable.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    security_list_ids = ["ocid1.securitylist.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"]
  }

  assert {
    condition     = oci_core_subnet.this.route_table_id == "ocid1.routetable.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    error_message = "route_table_id should be set when provided"
  }

  assert {
    condition     = oci_core_subnet.this.security_list_ids == toset(["ocid1.securitylist.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"])
    error_message = "security_list_ids should be set when provided"
  }
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

run "rejects_invalid_dns_label" {
  command = plan

  variables {
    subnet_dns_label = "INVALID-DNS"
  }

  expect_failures = [
    var.subnet_dns_label,
  ]
}
