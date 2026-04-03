# oci/compute

Terraform module creating an OCI compute instance for AMD Micro (`VM.Standard.E2.1.Micro`) and Ampere A1 Flex (`VM.Standard.A1.Flex`) shapes, both available in the OCI Free Tier.

## Usage

```hcl
module "compute" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/compute/v1.0.0"

  compartment_id = "ocid1.compartment.oc1..xxx"
  image_id       = "ocid1.image.oc1.iad.xxx"
  subnet_id      = "ocid1.subnet.oc1.iad.xxx"
}
```

### A1 Flex example

```hcl
module "compute_arm" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/compute/v1.0.0"

  compartment_id      = "ocid1.compartment.oc1..xxx"
  image_id            = "ocid1.image.oc1.iad.xxx"
  subnet_id           = "ocid1.subnet.oc1.iad.xxx"
  shape               = "VM.Standard.A1.Flex"
  shape_ocpus         = 2
  shape_memory_in_gbs = 12
}
```

## Notes

**Free Tier Warning:** Instances with less than 20% average CPU and network utilization over 7 consecutive days may be reclaimed by Oracle. For A1 Flex shapes, memory utilization is also checked. Keep instances active to avoid reclamation.

**Storage Note:** Boot volumes count toward the 200GB free tier block storage limit. There is no cross-module enforcement — manually track total boot + block volume consumption across all instances.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.4 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_core_instance.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_instance) | resource |
| [oci_identity_availability_domains.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | (Optional) Whether to assign a public IP to the instance's primary VNIC. | `bool` | `true` | no |
| <a name="input_availability_domain_number"></a> [availability\_domain\_number](#input\_availability\_domain\_number) | (Optional) 1-indexed availability domain number used to select the AD for the instance. | `number` | `1` | no |
| <a name="input_boot_volume_size_in_gbs"></a> [boot\_volume\_size\_in\_gbs](#input\_boot\_volume\_size\_in\_gbs) | (Optional) Size of the boot volume in GBs. | `number` | `50` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment in which to create the compute instance. | `string` | n/a | yes |
| <a name="input_compute_defined_tags"></a> [compute\_defined\_tags](#input\_compute\_defined\_tags) | (Optional) (Updatable) Defined tags for the compute instance. | `map(string)` | `{}` | no |
| <a name="input_compute_freeform_tags"></a> [compute\_freeform\_tags](#input\_compute\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the compute instance. | `map(string)` | `{}` | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | (Required) The OCID of the image to use for the instance boot volume. | `string` | n/a | yes |
| <a name="input_instance_display_name"></a> [instance\_display\_name](#input\_instance\_display\_name) | (Optional) A user-friendly name for the instance. | `string` | `"instance"` | no |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | (Optional) List of Network Security Group OCIDs to associate with the instance's primary VNIC. | `list(string)` | `[]` | no |
| <a name="input_shape"></a> [shape](#input\_shape) | (Optional) The shape of the instance. Must be one of the supported Free Tier shapes. | `string` | `"VM.Standard.E2.1.Micro"` | no |
| <a name="input_shape_memory_in_gbs"></a> [shape\_memory\_in\_gbs](#input\_shape\_memory\_in\_gbs) | (Optional) Amount of memory in GBs for Flex shapes. Ignored for fixed shapes. | `number` | `6` | no |
| <a name="input_shape_ocpus"></a> [shape\_ocpus](#input\_shape\_ocpus) | (Optional) Number of OCPUs for Flex shapes. Ignored for fixed shapes. | `number` | `1` | no |
| <a name="input_ssh_authorized_keys"></a> [ssh\_authorized\_keys](#input\_ssh\_authorized\_keys) | (Optional) One or more public SSH keys to place in the instance's authorized\_keys file. Null omits the key from instance metadata. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | (Required) The OCID of the subnet in which to place the instance's primary VNIC. | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | (Optional) Base64-encoded cloud-init user data to pass to the instance. Null omits user\_data from instance metadata. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_availability_domain"></a> [availability\_domain](#output\_availability\_domain) | Availability domain in which the instance was launched. |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | OCID of the compute instance. |
| <a name="output_instance_private_ip"></a> [instance\_private\_ip](#output\_instance\_private\_ip) | Private IP address of the instance's primary VNIC. |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | Public IP address of the instance. Returns null when assign\_public\_ip is false. |
| <a name="output_instance_state"></a> [instance\_state](#output\_instance\_state) | Current state of the instance (e.g. RUNNING, STOPPED). |
<!-- END_TF_DOCS -->
