output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = module.oke_cluster.cluster_id
}

output "cluster_state" {
  description = "Current lifecycle state of the OKE cluster."
  value       = module.oke_cluster.cluster_state
}

output "cluster_endpoints" {
  description = "OKE cluster API endpoints."
  sensitive   = true
  value       = module.oke_cluster.cluster_endpoints
}

output "node_pool_id" {
  description = "OCID of the OKE node pool."
  value       = module.oke_node_pool.node_pool_id
}

output "kubeconfig_command" {
  description = "OCI CLI command to generate kubeconfig for this cluster."
  value       = "oci ce cluster create-kubeconfig --cluster-id ${module.oke_cluster.cluster_id} --file $HOME/.kube/config --region <your-region> --token-version 2.0.0"
}
