mock_provider "oci" {
  mock_data "oci_identity_availability_domains" {
    defaults = {
      availability_domains = [
        {
          compartment_id = "ocid1.compartment.oc1..aaaaaaaafakecompartmentid"
          id             = "ocid1.availabilitydomain.oc1..aaaaaaaafakead1"
          name           = "fake-AD-1"
        }
      ]
    }
  }
}

variables {
  compartment_id     = "ocid1.compartment.oc1..aaaaaaaafakecompartmentid"
  cluster_id         = "ocid1.cluster.oc1.phx.aaaaaaaafakeclusterid"
  node_pool_name     = "test-pool"
  kubernetes_version = "v1.32.1"
  image_id           = "ocid1.image.oc1.phx.aaaaaaaafakeimageid"
  subnet_id          = "ocid1.subnet.oc1.phx.aaaaaaaafakesubnetid"
}

run "creates_node_pool_with_defaults" {
  command = plan

  assert {
    condition     = oci_containerengine_node_pool.this.node_shape == "VM.Standard.A1.Flex"
    error_message = "Default node shape should be VM.Standard.A1.Flex"
  }

  assert {
    condition     = oci_containerengine_node_pool.this.node_config_details[0].size == 2
    error_message = "Default node count should be 2"
  }
}

run "creates_micro_node_pool" {
  command = plan

  variables {
    node_shape = "VM.Standard.E2.1.Micro"
  }

  assert {
    condition     = oci_containerengine_node_pool.this.node_shape == "VM.Standard.E2.1.Micro"
    error_message = "Node shape should be VM.Standard.E2.1.Micro"
  }
}

run "creates_custom_ocpu_memory" {
  command = plan

  variables {
    node_shape_ocpus         = 2
    node_shape_memory_in_gbs = 12
  }

  assert {
    condition     = oci_containerengine_node_pool.this.node_shape_config[0].ocpus == 2
    error_message = "node_shape_ocpus should be 2"
  }

  assert {
    condition     = oci_containerengine_node_pool.this.node_shape_config[0].memory_in_gbs == 12
    error_message = "node_shape_memory_in_gbs should be 12"
  }
}

run "rejects_invalid_boot_volume_size" {
  command = plan

  variables {
    boot_volume_size_in_gbs = 49
  }

  expect_failures = [var.boot_volume_size_in_gbs]
}

run "rejects_invalid_node_shape" {
  command = plan

  variables {
    node_shape = "VM.Standard.E3.Flex"
  }

  expect_failures = [var.node_shape]
}

run "rejects_invalid_cluster_id_ocid" {
  command = plan

  variables {
    cluster_id = "not-a-valid-ocid"
  }

  expect_failures = [var.cluster_id]
}

run "rejects_invalid_ssh_key" {
  command = plan

  variables {
    ssh_public_key = "invalid-key"
  }

  expect_failures = [var.ssh_public_key]
}
