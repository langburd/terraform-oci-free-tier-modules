locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

module "vcn" {
  source                  = "../../oci/vcn"
  compartment_id          = module.compartment.compartment_id
  vcn_display_name        = "free-tier-arm-vcn"
  vcn_cidr_blocks         = ["10.0.0.0/16"]
  create_internet_gateway = true
  create_nat_gateway      = true

  vcn_freeform_tags = {
    "example" = "free-tier-arm-server"
  }
}

module "public_subnet" {
  source              = "../../oci/subnet"
  compartment_id      = module.compartment.compartment_id
  vcn_id              = module.vcn.vcn_id
  subnet_cidr_block   = "10.0.1.0/24"
  subnet_display_name = "arm-public-subnet"
  route_table_id      = module.vcn.public_route_table_id
}

# This data source fetches the latest Oracle Linux 8 image for VM.Standard.A1.Flex.
# If this fails with an index error, verify images for this shape exist in your region:
# oci compute image list --compartment-id <tenancy-ocid> \
#   --operating-system "Oracle Linux" --operating-system-version 8
data "oci_core_images" "oracle_linux_arm" {
  compartment_id           = module.compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# A1 Flex — maximum free tier allocation: 4 OCPUs, 24 GB RAM
module "compute" {
  source = "../../oci/compute"

  compartment_id        = module.compartment.compartment_id
  subnet_id             = module.public_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux_arm.images[0].id
  instance_display_name = "free-tier-arm-server"
  shape                 = "VM.Standard.A1.Flex"
  shape_ocpus           = 4
  shape_memory_in_gbs   = 24
  ssh_authorized_keys   = var.ssh_authorized_keys
  assign_public_ip      = true

  compute_freeform_tags = {
    "example" = "free-tier-arm-server"
  }
}

module "block_volume" {
  source = "../../oci/block_volume"

  compartment_id      = module.compartment.compartment_id
  availability_domain = module.compute.availability_domain
  instance_id         = module.compute.instance_id
  volume_display_name = "arm-server-data-volume"
  volume_size_in_gbs  = 50

  volume_freeform_tags = {
    "example" = "free-tier-arm-server"
  }
}
