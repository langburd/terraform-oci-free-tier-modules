mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  cpe_ip_address = "203.0.113.1"
  static_routes  = ["10.0.0.0/8"]
}

run "creates_drg_cpe_ipsec_without_vcn_attachment" {
  command = plan

  assert {
    condition     = oci_core_drg.this.display_name == "drg"
    error_message = "Default DRG display name should be drg"
  }

  assert {
    condition     = oci_core_cpe.this.ip_address == "203.0.113.1"
    error_message = "CPE IP address should match input"
  }

  assert {
    condition     = length(oci_core_drg_attachment.this) == 0
    error_message = "DRG attachment should not be created when vcn_id is null"
  }
}

run "creates_drg_attachment_when_vcn_id_provided" {
  command = plan

  variables {
    vcn_id = "ocid1.vcn.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = length(oci_core_drg_attachment.this) == 1
    error_message = "DRG attachment should be created when vcn_id is provided"
  }
}

run "rejects_invalid_ip_address" {
  command = plan

  variables {
    cpe_ip_address = "not-an-ip"
  }

  expect_failures = [
    var.cpe_ip_address,
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
