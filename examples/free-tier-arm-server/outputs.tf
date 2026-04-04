output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "vcn_id" {
  description = "OCID of the VCN."
  value       = module.vcn.vcn_id
}

output "compute_instance_id" {
  description = "OCID of the A1 Flex compute instance."
  value       = module.compute.instance_id
}

output "compute_public_ip" {
  description = "Public IP address of the compute instance."
  value       = module.compute.instance_public_ip
}

output "block_volume_id" {
  description = "OCID of the 50 GB block volume attached to the instance."
  value       = module.block_volume.volume_id
}
