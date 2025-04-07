# /* Instances */

# resource "oci_core_instance" "free_instance0" {
#   availability_domain = data.oci_identity_availability_domain.ad.name
#   compartment_id      = var.compartment_ocid
#   display_name        = "freeInstance0"
#   shape               = var.instance_shape

#   shape_config {
#     ocpus         = var.instance_ocpus
#     memory_in_gbs = var.instance_shape_config_memory_in_gbs
#   }

#   create_vnic_details {
#     subnet_id        = oci_core_subnet.test_subnet.id
#     display_name     = "primaryvnic"
#     assign_public_ip = true
#     hostname_label   = "freeinstance0"
#   }

#   source_details {
#     source_type = "image"
#     source_id   = data.oci_core_images.test_images.id
#   }

#   metadata = {
#     ssh_authorized_keys = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.public_key_openssh
#   }
# }

# resource "oci_core_instance" "free_instance1" {
#   availability_domain = data.oci_identity_availability_domain.ad.name
#   compartment_id      = var.compartment_ocid
#   display_name        = "freeInstance1"
#   shape               = var.instance_shape

#   shape_config {
#     ocpus         = 1
#     memory_in_gbs = 6
#   }

#   create_vnic_details {
#     subnet_id        = oci_core_subnet.test_subnet.id
#     display_name     = "primaryvnic"
#     assign_public_ip = true
#     hostname_label   = "freeinstance1"
#   }

#   source_details {
#     source_type = "image"
#     source_id   = data.oci_core_images.test_images.id
#   }

#   metadata = {
#     ssh_authorized_keys = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.public_key_openssh
#   }
# }

# resource "tls_private_key" "compute_ssh_key" {
#   algorithm = "RSA"
#   rsa_bits  = 2048
# }

# output "generated_private_key_pem" {
#   value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.private_key_pem
#   sensitive = true
# }
