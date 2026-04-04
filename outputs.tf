output "node_pool_id" {
  description = "OCID of the OKE node pool."
  value       = oci_containerengine_node_pool.this.id
}

output "node_pool_nodes" {
  description = "List of nodes in the node pool with their IPs and lifecycle states."
  value       = oci_containerengine_node_pool.this.nodes
}
