resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_id
  vcn_id             = var.vcn_id
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  type               = var.cluster_type
  defined_tags       = var.cluster_defined_tags
  freeform_tags      = var.cluster_freeform_tags

  endpoint_config {
    subnet_id            = var.endpoint_subnet_id
    is_public_ip_enabled = var.endpoint_is_public_ip_enabled
    nsg_ids              = var.endpoint_nsg_ids
  }

  cluster_pod_network_options {
    cni_type = var.cni_type
  }

  options {
    service_lb_subnet_ids = var.service_lb_subnet_ids

    add_ons {
      is_kubernetes_dashboard_enabled = var.is_kubernetes_dashboard_enabled
      is_tiller_enabled               = false
    }

    admission_controller_options {
      is_pod_security_policy_enabled = var.is_pod_security_policy_enabled
    }

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }
}
