output "k3s_token" {
  description = "K3s cluster token (sensitive). Used to join additional nodes."
  sensitive   = true
  value       = random_password.k3s_token.result
}

output "api_endpoint" {
  description = "Public IP of the K3s server node (API endpoint)."
  sensitive   = true
  value       = local.api_endpoint
}

output "kubeconfig_command" {
  description = "SSH command to retrieve the kubeconfig from the K3s server."
  sensitive   = true
  value       = "ssh -i ${var.ssh_private_key_path} ${var.ssh_user}@${local.api_endpoint} sudo cat /etc/rancher/k3s/k3s.yaml"
}
