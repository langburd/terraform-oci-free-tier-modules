variable "compartment_id" {
  description = "(Required) The OCID of the compartment in which to create the OKE cluster."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid OCI OCID (e.g. ocid1.compartment.oc1..aaaaaa...)."
  }
}

variable "vcn_id" {
  description = "(Required) The OCID of the VCN in which to create the OKE cluster."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.vcn_id))
    error_message = "vcn_id must be a valid OCI OCID (e.g. ocid1.vcn.oc1..aaaaaa...)."
  }
}

variable "cluster_name" {
  description = "(Required) A user-friendly name for the OKE cluster."
  type        = string
}

variable "kubernetes_version" {
  description = "(Required) The Kubernetes version to use for the OKE cluster (e.g. v1.32.1)."
  type        = string
  validation {
    condition     = can(regex("^v", var.kubernetes_version))
    error_message = "kubernetes_version must start with 'v' (e.g. v1.32.1)."
  }
}

variable "cluster_type" {
  description = "(Optional) The type of OKE cluster. Either BASIC_CLUSTER or ENHANCED_CLUSTER."
  type        = string
  default     = "BASIC_CLUSTER"
  validation {
    condition     = contains(["BASIC_CLUSTER", "ENHANCED_CLUSTER"], var.cluster_type)
    error_message = "cluster_type must be either BASIC_CLUSTER or ENHANCED_CLUSTER."
  }
}

variable "cni_type" {
  description = "(Optional) The CNI type for the OKE cluster. Either FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE."
  type        = string
  default     = "FLANNEL_OVERLAY"
  validation {
    condition     = contains(["FLANNEL_OVERLAY", "OCI_VCN_IP_NATIVE"], var.cni_type)
    error_message = "cni_type must be either FLANNEL_OVERLAY or OCI_VCN_IP_NATIVE."
  }
}

variable "endpoint_subnet_id" {
  description = "(Required) The OCID of the subnet for the Kubernetes API endpoint."
  type        = string
  validation {
    condition     = can(regex("^ocid1\\.[a-z]+\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.endpoint_subnet_id))
    error_message = "endpoint_subnet_id must be a valid OCI OCID (e.g. ocid1.subnet.oc1..aaaaaa...)."
  }
}

variable "endpoint_is_public_ip_enabled" {
  description = "(Optional) Whether the Kubernetes API endpoint is assigned a public IP address."
  type        = bool
  default     = true
}

variable "endpoint_nsg_ids" {
  description = "(Optional) List of NSG OCIDs to associate with the Kubernetes API endpoint."
  type        = list(string)
  default     = []
}

variable "service_lb_subnet_ids" {
  description = "(Optional) List of subnet OCIDs for Kubernetes service load balancers."
  type        = list(string)
  default     = []
}

variable "pods_cidr" {
  description = "(Optional) CIDR block for pods in the Kubernetes cluster."
  type        = string
  default     = "10.244.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.pods_cidr))
    error_message = "pods_cidr must be a valid CIDR block (e.g. 10.244.0.0/16)."
  }
}

variable "services_cidr" {
  description = "(Optional) CIDR block for Kubernetes services."
  type        = string
  default     = "10.96.0.0/16"
  validation {
    condition     = can(cidrnetmask(var.services_cidr))
    error_message = "services_cidr must be a valid CIDR block (e.g. 10.96.0.0/16)."
  }
}

variable "is_kubernetes_dashboard_enabled" {
  description = "(Optional) Whether the Kubernetes Dashboard add-on is enabled."
  type        = bool
  default     = false
}

variable "is_pod_security_policy_enabled" {
  description = "(Optional) Whether pod security policy admission controller is enabled."
  type        = bool
  default     = true
}

variable "cluster_defined_tags" {
  description = "(Optional) (Updatable) Defined tags for the OKE cluster."
  type        = map(string)
  default     = {}
}

variable "cluster_freeform_tags" {
  description = "(Optional) (Updatable) Free-form tags for the OKE cluster."
  type        = map(string)
  default     = {}
}
