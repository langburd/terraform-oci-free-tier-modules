locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "k8s_compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

module "k8s_vcn" {
  source                  = "../../oci/vcn"
  compartment_id          = module.k8s_compartment.compartment_id
  vcn_display_name        = "k8s-vcn"
  vcn_dns_label           = "k8svcn"
  vcn_cidr_blocks         = ["10.0.0.0/16"]
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
}

module "api_endpoint_subnet" {
  source            = "../../oci/subnet"
  compartment_id    = module.k8s_compartment.compartment_id
  vcn_id            = module.k8s_vcn.vcn_id
  subnet_cidr_block = "10.0.1.0/24"
  route_table_id    = module.k8s_vcn.public_route_table_id
  subnet_dns_label  = "apiep"
}

module "worker_subnet" {
  source                    = "../../oci/subnet"
  compartment_id            = module.k8s_compartment.compartment_id
  vcn_id                    = module.k8s_vcn.vcn_id
  subnet_cidr_block         = "10.0.2.0/24"
  route_table_id            = module.k8s_vcn.private_route_table_id
  subnet_dns_label          = "workers"
  prohibit_internet_ingress = true
}

module "lb_subnet" {
  source            = "../../oci/subnet"
  compartment_id    = module.k8s_compartment.compartment_id
  vcn_id            = module.k8s_vcn.vcn_id
  subnet_cidr_block = "10.0.3.0/24"
  route_table_id    = module.k8s_vcn.public_route_table_id
  subnet_dns_label  = "lbsub"
}

module "api_endpoint_nsg" {
  source           = "../../oci/network_security_group"
  compartment_id   = module.k8s_compartment.compartment_id
  vcn_id           = module.k8s_vcn.vcn_id
  nsg_display_name = "oke-api-endpoint-nsg"

  ingress_rules = {
    workers_to_api = {
      protocol    = "6"
      source      = "10.0.2.0/24"
      source_type = "CIDR_BLOCK"
      tcp_options = { destination_port_range = { min = 6443, max = 6443 } }
      description = "Worker nodes to Kubernetes API"
    }
    workers_to_api_12250 = {
      protocol    = "6"
      source      = "10.0.2.0/24"
      source_type = "CIDR_BLOCK"
      tcp_options = { destination_port_range = { min = 12250, max = 12250 } }
      description = "Worker nodes to OKE control plane"
    }
    external_kubectl = {
      protocol    = "6"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      tcp_options = { destination_port_range = { min = 6443, max = 6443 } }
      description = "External kubectl access"
    }
    path_mtu_icmp = {
      protocol     = "1"
      source       = "10.0.2.0/24"
      source_type  = "CIDR_BLOCK"
      icmp_options = { type = 3, code = 4 }
      description  = "Path MTU discovery from workers"
    }
  }

  egress_rules = {
    api_to_workers = {
      protocol         = "6"
      destination      = "10.0.2.0/24"
      destination_type = "CIDR_BLOCK"
      description      = "API endpoint to worker nodes"
    }
    api_to_oci_services = {
      protocol         = "6"
      destination      = "all-iad-services-in-oracle-services-network"
      destination_type = "SERVICE_CIDR_BLOCK"
      tcp_options      = { destination_port_range = { min = 443, max = 443 } }
      description      = "OKE cluster to OCI services"
    }
  }
}

module "worker_nsg" {
  source           = "../../oci/network_security_group"
  compartment_id   = module.k8s_compartment.compartment_id
  vcn_id           = module.k8s_vcn.vcn_id
  nsg_display_name = "oke-worker-nsg"

  ingress_rules = {
    worker_to_worker = {
      protocol    = "all"
      source      = "10.0.2.0/24"
      source_type = "CIDR_BLOCK"
      description = "Inter-worker communication"
    }
    api_to_workers = {
      protocol    = "6"
      source      = "10.0.1.0/24"
      source_type = "CIDR_BLOCK"
      description = "API endpoint to worker nodes"
    }
    path_mtu_icmp = {
      protocol     = "1"
      source       = "0.0.0.0/0"
      source_type  = "CIDR_BLOCK"
      icmp_options = { type = 3, code = 4 }
      description  = "Path MTU discovery"
    }
  }

  egress_rules = {
    worker_to_worker = {
      protocol         = "all"
      destination      = "10.0.2.0/24"
      destination_type = "CIDR_BLOCK"
      description      = "Inter-worker communication"
    }
    worker_to_internet = {
      protocol         = "6"
      destination      = "0.0.0.0/0"
      destination_type = "CIDR_BLOCK"
      description      = "Internet access via NAT"
    }
    worker_to_api_6443 = {
      protocol         = "6"
      destination      = "10.0.1.0/24"
      destination_type = "CIDR_BLOCK"
      tcp_options      = { destination_port_range = { min = 6443, max = 6443 } }
      description      = "Worker to Kubernetes API"
    }
    worker_to_api_12250 = {
      protocol         = "6"
      destination      = "10.0.1.0/24"
      destination_type = "CIDR_BLOCK"
      tcp_options      = { destination_port_range = { min = 12250, max = 12250 } }
      description      = "Worker to OKE control plane"
    }
    worker_to_oci_services = {
      protocol         = "6"
      destination      = "all-iad-services-in-oracle-services-network"
      destination_type = "SERVICE_CIDR_BLOCK"
      description      = "Worker to OCI services"
    }
  }
}

module "lb_nsg" {
  source           = "../../oci/network_security_group"
  compartment_id   = module.k8s_compartment.compartment_id
  vcn_id           = module.k8s_vcn.vcn_id
  nsg_display_name = "oke-lb-nsg"

  ingress_rules = {
    http_ingress = {
      protocol    = "6"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      tcp_options = { destination_port_range = { min = 80, max = 80 } }
      description = "HTTP ingress"
    }
    https_ingress = {
      protocol    = "6"
      source      = "0.0.0.0/0"
      source_type = "CIDR_BLOCK"
      tcp_options = { destination_port_range = { min = 443, max = 443 } }
      description = "HTTPS ingress"
    }
  }

  egress_rules = {
    lb_to_nodeport = {
      protocol         = "6"
      destination      = "10.0.2.0/24"
      destination_type = "CIDR_BLOCK"
      tcp_options      = { destination_port_range = { min = 30000, max = 32767 } }
      description      = "LB to NodePort services"
    }
    lb_to_healthcheck = {
      protocol         = "6"
      destination      = "10.0.2.0/24"
      destination_type = "CIDR_BLOCK"
      tcp_options      = { destination_port_range = { min = 10256, max = 10256 } }
      description      = "kube-proxy health check"
    }
  }
}

# This data source fetches the latest Oracle Linux 8 image for VM.Standard.A1.Flex.
# If this fails with an index error, verify images for this shape exist in your region:
# oci compute image list --compartment-id <tenancy-ocid> \
#   --operating-system "Oracle Linux" --operating-system-version 8
data "oci_core_images" "oracle_linux_arm" {
  compartment_id           = module.k8s_compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "oke_cluster" {
  source                = "../../oci/oke_cluster"
  compartment_id        = module.k8s_compartment.compartment_id
  vcn_id                = module.k8s_vcn.vcn_id
  cluster_name          = var.cluster_name
  kubernetes_version    = var.kubernetes_version
  endpoint_subnet_id    = module.api_endpoint_subnet.subnet_id
  endpoint_nsg_ids      = [module.api_endpoint_nsg.nsg_id]
  service_lb_subnet_ids = [module.lb_subnet.subnet_id]
}

module "oke_node_pool" {
  source                   = "../../oci/oke_node_pool"
  compartment_id           = module.k8s_compartment.compartment_id
  cluster_id               = module.oke_cluster.cluster_id
  node_pool_name           = "${var.cluster_name}-arm-pool"
  kubernetes_version       = var.kubernetes_version
  image_id                 = data.oci_core_images.oracle_linux_arm.images[0].id
  subnet_id                = module.worker_subnet.subnet_id
  node_shape               = "VM.Standard.A1.Flex"
  node_shape_ocpus         = var.node_ocpus
  node_shape_memory_in_gbs = var.node_memory_in_gbs
  node_count               = var.node_count
  boot_volume_size_in_gbs  = var.boot_volume_size_in_gbs
  nsg_ids                  = [module.worker_nsg.nsg_id]
  ssh_public_key           = var.ssh_public_key
}
