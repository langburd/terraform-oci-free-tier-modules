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
  vcn_display_name        = "free-tier-compute-vcn"
  vcn_cidr_blocks         = ["10.0.0.0/16"]
  create_internet_gateway = true
  create_nat_gateway      = false
}

module "public_subnet" {
  source              = "../../oci/subnet"
  compartment_id      = module.compartment.compartment_id
  vcn_id              = module.vcn.vcn_id
  subnet_cidr_block   = "10.0.1.0/24"
  subnet_display_name = "public-subnet"
  route_table_id      = module.vcn.public_route_table_id
}

module "private_subnet" {
  source                    = "../../oci/subnet"
  compartment_id            = module.compartment.compartment_id
  vcn_id                    = module.vcn.vcn_id
  subnet_cidr_block         = "10.0.2.0/24"
  subnet_display_name       = "private-subnet"
  prohibit_internet_ingress = true
}

data "oci_core_images" "oracle_linux" {
  compartment_id           = module.compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "compute" {
  source                = "../../oci/compute"
  compartment_id        = module.compartment.compartment_id
  subnet_id             = module.public_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux.images[0].id
  instance_display_name = "free-tier-amd-micro"
  shape                 = "VM.Standard.E2.1.Micro"
  ssh_authorized_keys   = var.ssh_authorized_keys
  assign_public_ip      = true

  compute_freeform_tags = {
    "example" = "free-tier-compute-stack"
  }
}

# Bastion module is part of Phase 3 and not yet available.
# Uncomment when oci/bastion module is released.
# module "bastion" {
#   source                       = "../../oci/bastion"
#   compartment_id               = module.compartment.compartment_id
#   target_subnet_id             = module.public_subnet.subnet_id
#   bastion_name                 = "free-tier-bastion"
#   bastion_type                 = "STANDARD"
#   client_cidr_block_allow_list = ["0.0.0.0/0"]
# }
