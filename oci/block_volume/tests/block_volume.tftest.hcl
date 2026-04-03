mock_provider "oci" {}

variables {
  compartment_id      = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  availability_domain = "nFuS:US-ASHBURN-AD-1"
}

run "default_volume_no_attachment" {
  command = plan

  assert {
    condition     = tostring(oci_core_volume.this.size_in_gbs) == "50"
    error_message = "Default volume size should be 50 GB"
  }

  assert {
    condition     = length(oci_core_volume_attachment.this) == 0
    error_message = "No attachment should be created when instance_id is null"
  }
}

run "with_attachment" {
  command = plan

  variables {
    instance_id = "ocid1.instance.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  assert {
    condition     = length(oci_core_volume_attachment.this) == 1
    error_message = "Attachment should be created when instance_id is provided"
  }

  assert {
    condition     = oci_core_volume_attachment.this[0].attachment_type == "paravirtualized"
    error_message = "Default attachment_type should be paravirtualized"
  }
}

run "rejects_volume_size_above_200" {
  command = plan

  variables {
    volume_size_in_gbs = 201
  }

  expect_failures = [
    var.volume_size_in_gbs,
  ]
}

run "rejects_vpus_not_multiple_of_10" {
  command = plan

  variables {
    vpus_per_gb = 15
  }

  expect_failures = [
    var.vpus_per_gb,
  ]
}

run "rejects_invalid_instance_id" {
  command = plan

  variables {
    instance_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.instance_id,
  ]
}

run "rejects_volume_size_below_50" {
  command = plan

  variables {
    volume_size_in_gbs = 49
  }

  expect_failures = [
    var.volume_size_in_gbs,
  ]
}

run "rejects_invalid_attachment_type" {
  command = plan

  variables {
    attachment_type = "nvme"
  }

  expect_failures = [
    var.attachment_type,
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
