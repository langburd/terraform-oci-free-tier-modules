locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "k3s_compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

module "k3s_vcn" {
  source                  = "../../oci/vcn"
  compartment_id          = module.k3s_compartment.compartment_id
  vcn_display_name        = "k3s-vcn"
  vcn_cidr_blocks         = ["10.0.0.0/16"]
  create_internet_gateway = true
  vcn_dns_label           = "k3svcn"
}

module "k3s_subnet" {
  source              = "../../oci/subnet"
  compartment_id      = module.k3s_compartment.compartment_id
  vcn_id              = module.k3s_vcn.vcn_id
  subnet_cidr_block   = "10.0.0.0/24"
  subnet_display_name = "k3s-subnet"
  route_table_id      = module.k3s_vcn.public_route_table_id
  subnet_dns_label    = "k3ssub"
}

module "k3s_security_list" {
  source                     = "../../oci/security_list"
  compartment_id             = module.k3s_compartment.compartment_id
  vcn_id                     = module.k3s_vcn.vcn_id
  security_list_display_name = "k3s-security-list"

  ingress_security_rules = [
    {
      protocol    = "6"
      source      = "10.0.0.0/16"
      description = "Intra-VCN all TCP"
    },
    {
      protocol    = "6"
      source      = var.allowed_mgmt_cidrs[0]
      tcp_options = { min = 22, max = 22 }
      description = "SSH"
    },
    {
      protocol    = "6"
      source      = var.allowed_mgmt_cidrs[0]
      tcp_options = { min = 6443, max = 6443 }
      description = "K3s API server"
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      tcp_options = { min = 80, max = 80 }
      description = "HTTP ingress"
    },
    {
      protocol    = "6"
      source      = "0.0.0.0/0"
      tcp_options = { min = 443, max = 443 }
      description = "HTTPS ingress"
    },
    {
      protocol     = "1"
      source       = "0.0.0.0/0"
      icmp_options = { type = 3, code = 4 }
      description  = "Path MTU discovery"
    },
  ]

  egress_security_rules = [
    {
      protocol    = "all"
      destination = "0.0.0.0/0"
      description = "All outbound traffic"
    },
  ]
}

# WARNING: The private key generated here is stored in Terraform state in plaintext.
# Ensure your state backend (e.g. OCI Object Storage) has appropriate access controls.
# For production use, generate the key pair externally and supply the public key directly.
resource "tls_private_key" "k3s" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.k3s.private_key_openssh
  filename        = "${path.module}/.ssh/k3s-key"
  file_permission = "0600"
}

# ARM image for K3s nodes
data "oci_core_images" "oracle_linux_arm" {
  compartment_id           = module.k3s_compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

# K3s server node (1x A1.Flex)
module "k3s_server" {
  source                = "../../oci/compute"
  compartment_id        = module.k3s_compartment.compartment_id
  subnet_id             = module.k3s_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux_arm.images[0].id
  instance_display_name = "k3s-server"
  shape                 = "VM.Standard.A1.Flex"
  shape_ocpus           = 1
  shape_memory_in_gbs   = 6
  ssh_authorized_keys   = tls_private_key.k3s.public_key_openssh
  user_data             = base64encode(file("${path.module}/cloud-init.yaml"))
  assign_public_ip      = true
}

# K3s agent nodes (3x A1.Flex — total 4 nodes × 50 GB = 200 GB storage limit)
module "k3s_agent" {
  count = 3

  source                = "../../oci/compute"
  compartment_id        = module.k3s_compartment.compartment_id
  subnet_id             = module.k3s_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux_arm.images[0].id
  instance_display_name = "k3s-agent-${count.index + 1}"
  shape                 = "VM.Standard.A1.Flex"
  shape_ocpus           = 1
  shape_memory_in_gbs   = 6
  ssh_authorized_keys   = tls_private_key.k3s.public_key_openssh
  user_data             = base64encode(file("${path.module}/cloud-init.yaml"))
  assign_public_ip      = true
}

# Deploy K3s via Ansible
module "k3s_cluster" {
  source = "../../oci/k3s_cluster"

  server_ips           = [module.k3s_server.instance_public_ip]
  agent_ips            = [for agent in module.k3s_agent : agent.instance_public_ip]
  ssh_private_key_path = local_sensitive_file.ssh_private_key.filename
  ssh_user             = "opc"
  k3s_version          = var.k3s_version
}
