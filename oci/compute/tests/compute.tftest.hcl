mock_provider "oci" {
  mock_data "oci_identity_availability_domains" {
    defaults = {
      availability_domains = [
        {
          compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          id             = "ocid1.availabilitydomain.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
          name           = "nFuS:US-ASHBURN-AD-1"
        }
      ]
    }
  }
}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  image_id       = "ocid1.image.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  subnet_id      = "ocid1.subnet.oc1.iad.aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
}

run "amd_micro_defaults" {
  command = plan

  assert {
    condition     = oci_core_instance.this.shape == "VM.Standard.E2.1.Micro"
    error_message = "Default shape should be VM.Standard.E2.1.Micro"
  }

  assert {
    condition     = length(oci_core_instance.this.shape_config) == 0
    error_message = "AMD Micro shape should not render a shape_config block"
  }

  assert {
    condition     = oci_core_instance.this.display_name == "instance"
    error_message = "Default display_name should be 'instance'"
  }

  assert {
    condition     = oci_core_instance.this.create_vnic_details[0].assign_public_ip == "false"
    error_message = "assign_public_ip should default to false"
  }

  assert {
    condition     = oci_core_instance.this.launch_options[0].is_pv_encryption_in_transit_enabled == true
    error_message = "PV encryption in transit should be enabled"
  }

  assert {
    condition     = oci_core_instance.this.instance_options[0].are_legacy_imds_endpoints_disabled == true
    error_message = "Legacy IMDS endpoints should be disabled"
  }
}

run "a1_flex_shape_config" {
  command = plan

  variables {
    shape = "VM.Standard.A1.Flex"
  }

  assert {
    condition     = oci_core_instance.this.shape == "VM.Standard.A1.Flex"
    error_message = "Shape should be VM.Standard.A1.Flex"
  }

  assert {
    condition     = length(oci_core_instance.this.shape_config) == 1
    error_message = "A1 Flex shape should render a shape_config block"
  }

  assert {
    condition     = oci_core_instance.this.shape_config[0].ocpus == 1
    error_message = "Default shape_config ocpus should be 1"
  }

  assert {
    condition     = oci_core_instance.this.shape_config[0].memory_in_gbs == 6
    error_message = "Default shape_config memory_in_gbs should be 6"
  }
}

run "rejects_invalid_shape" {
  command = plan

  variables {
    shape = "VM.Standard.E3.Flex"
  }

  expect_failures = [
    var.shape,
  ]
}

run "rejects_boot_volume_below_50" {
  command = plan

  variables {
    boot_volume_size_in_gbs = 49
  }

  expect_failures = [
    var.boot_volume_size_in_gbs,
  ]
}

run "rejects_boot_volume_above_200" {
  command = plan

  variables {
    boot_volume_size_in_gbs = 201
  }

  expect_failures = [
    var.boot_volume_size_in_gbs,
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

run "rejects_invalid_ssh_key" {
  command = plan

  variables {
    ssh_authorized_keys = "not-a-valid-key-format"
  }

  expect_failures = [
    var.ssh_authorized_keys,
  ]
}
