output "instance_id" {
  description = "OCID of the compute instance."
  value       = oci_core_instance.this.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance's primary VNIC. Returns null when assign_public_ip is false."
  value       = oci_core_instance.this.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the instance's primary VNIC."
  value       = oci_core_instance.this.private_ip
}

output "instance_state" {
  description = "Current state of the instance (e.g. RUNNING, STOPPED)."
  value       = oci_core_instance.this.state
}

output "availability_domain" {
  description = "Availability domain in which the instance was launched."
  value       = oci_core_instance.this.availability_domain
}
