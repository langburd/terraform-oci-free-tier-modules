output "cluster_id" {
  description = "OCID of the OKE cluster."
  value       = oci_containerengine_cluster.this.id
}

output "cluster_kubernetes_version" {
  description = "Kubernetes version of the OKE cluster."
  value       = oci_containerengine_cluster.this.kubernetes_version
}

output "cluster_endpoints" {
  description = "OKE cluster API endpoints."
  sensitive   = true
  value       = oci_containerengine_cluster.this.endpoints
}

output "cluster_state" {
  description = "Lifecycle state of the OKE cluster."
  value       = oci_containerengine_cluster.this.state
}
