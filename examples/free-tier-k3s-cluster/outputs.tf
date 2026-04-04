output "server_ip" {
  description = "Public IP of the K3s server node."
  value       = module.k3s_server.instance_public_ip
}

output "agent_ips" {
  description = "Public IPs of the K3s agent nodes."
  value       = [for agent in module.k3s_agent : agent.instance_public_ip]
}

output "kubeconfig_command" {
  description = "SSH command to retrieve the kubeconfig from the K3s server."
  value       = module.k3s_cluster.kubeconfig_command
}

output "k3s_token" {
  description = "K3s cluster token for joining additional nodes."
  sensitive   = true
  value       = module.k3s_cluster.k3s_token
}
