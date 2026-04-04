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
  vcn_display_name        = "free-tier-web-app-vcn"
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

# Fetch the latest Oracle Linux 8 image for VM.Standard.E2.1.Micro (AMD free tier).
data "oci_core_images" "oracle_linux" {
  compartment_id           = module.compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "compute_1" {
  source                = "../../oci/compute"
  compartment_id        = module.compartment.compartment_id
  subnet_id             = module.private_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux.images[0].id
  instance_display_name = "web-server-1"
  shape                 = "VM.Standard.E2.1.Micro"
  ssh_authorized_keys   = var.ssh_authorized_keys
  assign_public_ip      = false

  compute_freeform_tags = {
    "example" = "free-tier-web-app"
    "role"    = "web"
  }
}

module "compute_2" {
  source                = "../../oci/compute"
  compartment_id        = module.compartment.compartment_id
  subnet_id             = module.private_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux.images[0].id
  instance_display_name = "web-server-2"
  shape                 = "VM.Standard.E2.1.Micro"
  ssh_authorized_keys   = var.ssh_authorized_keys
  assign_public_ip      = false

  compute_freeform_tags = {
    "example" = "free-tier-web-app"
    "role"    = "web"
  }
}

module "load_balancer" {
  source = "../../oci/load_balancer"

  compartment_id  = module.compartment.compartment_id
  subnet_ids      = [module.public_subnet.subnet_id]
  lb_display_name = "web-app-lb"

  backends = {
    "web1" = {
      ip_address = module.compute_1.instance_private_ip
      port       = 80
    }
    "web2" = {
      ip_address = module.compute_2.instance_private_ip
      port       = 80
    }
  }

  lb_freeform_tags = {
    "example" = "free-tier-web-app"
  }
}
