data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_id
}

locals {
  metadata = merge(
    var.ssh_authorized_keys != null ? { "ssh_authorized_keys" = var.ssh_authorized_keys } : {},
    var.user_data != null ? { "user_data" = var.user_data } : {}
  )
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_id
  availability_domain = data.oci_identity_availability_domains.this.availability_domains[var.availability_domain_number - 1].name
  display_name        = var.instance_display_name
  shape               = var.shape
  metadata            = local.metadata

  dynamic "shape_config" {
    for_each = contains(["VM.Standard.A1.Flex"], var.shape) ? [1] : []
    content {
      ocpus         = var.shape_ocpus
      memory_in_gbs = var.shape_memory_in_gbs
    }
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = var.assign_public_ip
    nsg_ids          = var.nsg_ids
  }

  launch_options {
    is_pv_encryption_in_transit_enabled = true
  }

  instance_options {
    are_legacy_imds_endpoints_disabled = true
  }

  defined_tags  = var.compute_defined_tags
  freeform_tags = var.compute_freeform_tags
}
