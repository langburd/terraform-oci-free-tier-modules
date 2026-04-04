data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

resource "oci_containerengine_node_pool" "this" {
  compartment_id     = var.compartment_id
  cluster_id         = var.cluster_id
  name               = var.node_pool_name
  kubernetes_version = var.kubernetes_version
  defined_tags       = var.node_pool_defined_tags
  freeform_tags      = var.node_pool_freeform_tags
  ssh_public_key     = var.ssh_public_key

  node_shape = var.node_shape

  dynamic "node_shape_config" {
    for_each = var.node_shape == "VM.Standard.A1.Flex" ? [1] : []
    content {
      ocpus         = var.node_shape_ocpus
      memory_in_gbs = var.node_shape_memory_in_gbs
    }
  }

  node_source_details {
    image_id                = var.image_id
    source_type             = "IMAGE"
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  node_config_details {
    size                                = var.node_count
    nsg_ids                             = var.nsg_ids
    is_pv_encryption_in_transit_enabled = var.is_pv_encryption_in_transit_enabled

    # Nodes are distributed round-robin across all available Availability Domains
    # in the region. OCI schedules `node_count` nodes evenly across the ADs listed
    # here, so the actual count per AD may not be equal if node_count is not a
    # multiple of the number of ADs.
    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.this.availability_domains
      content {
        availability_domain = placement_configs.value.name
        subnet_id           = var.subnet_id
      }
    }
  }
}
