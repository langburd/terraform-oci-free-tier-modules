variable "server_ips" {
  description = "List of public IP addresses for K3s server (control plane) nodes. At least one required."
  type        = list(string)
  validation {
    condition     = length(var.server_ips) >= 1
    error_message = "At least one server IP is required."
  }
}

variable "agent_ips" {
  description = "List of public IP addresses for K3s agent (worker) nodes."
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "SSH username to connect to K3s nodes. Oracle Linux images use 'opc'; Ubuntu images use 'ubuntu'."
  type        = string
  default     = "opc"
}

variable "ssh_extra_args" {
  description = "Additional SSH arguments passed to Ansible. Defaults to disabling host key checking for initial provisioning. Set to '' or override for stricter security in trusted environments."
  type        = string
  default     = "-o StrictHostKeyChecking=no"
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key file for connecting to K3s nodes."
  type        = string
}

variable "k3s_version" {
  description = "K3s version to install. Must start with 'v' (e.g. 'v1.31.12+k3s1')."
  type        = string
  default     = "v1.31.12+k3s1"
  validation {
    condition     = can(regex("^v", var.k3s_version))
    error_message = "k3s_version must start with 'v'."
  }
}

variable "k3s_ansible_path" {
  description = "Path to the k3s-ansible directory containing playbooks."
  type        = string
  default     = ""
}

variable "extra_server_args" {
  description = "Additional arguments to pass to k3s server."
  type        = string
  default     = ""
}

variable "extra_agent_args" {
  description = "Additional arguments to pass to k3s agent."
  type        = string
  default     = ""
}

variable "api_endpoint" {
  description = "API endpoint for the K3s cluster. Defaults to the first server IP."
  type        = string
  default     = null
}
