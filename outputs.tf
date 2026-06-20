output "instance_id" {
  description = "OCID of the compute instance."
  value       = oci_core_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance. Returns null when no public IP is assigned (e.g., assign_public_ip is false or the subnet prohibits public IPs)."
  value       = oci_core_instance.this.public_ip != "" ? oci_core_instance.this.public_ip : null
  sensitive   = true
}

output "instance_private_ip" {
  description = "Private IP address of the instance's primary VNIC."
  value       = oci_core_instance.this.private_ip
  sensitive   = true
}

output "instance_state" {
  description = "Current state of the instance (e.g. RUNNING, STOPPED)."
  value       = oci_core_instance.this.state
}

output "availability_domain" {
  description = "Availability domain in which the instance was launched."
  value       = oci_core_instance.this.availability_domain
}
