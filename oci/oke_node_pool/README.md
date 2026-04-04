# OCI OKE Node Pool Module

Terraform module creating an Oracle Kubernetes Engine (OKE) node pool.

## Usage Example

```hcl
module "oke_node_pool" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/oke_node_pool/v1.0.0"

  compartment_id            = "<compartment_ocid>"
  cluster_id                = "<oke_cluster_ocid>"
  node_pool_name            = "free-tier-arm-pool"
  kubernetes_version        = "v1.32.1"
  image_id                  = "<arm_image_ocid>"
  subnet_id                 = "<worker_subnet_ocid>"

  node_shape               = "VM.Standard.A1.Flex"
  node_shape_ocpus         = 1
  node_shape_memory_in_gbs = 6
  node_count               = 2
  boot_volume_size_in_gbs  = 50
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | >= 8.0, < 9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | >= 8.0, < 9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_containerengine_node_pool.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool) | resource |
| [oci_identity_availability_domains.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/identity_availability_domains) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_volume_size_in_gbs"></a> [boot\_volume\_size\_in\_gbs](#input\_boot\_volume\_size\_in\_gbs) | Boot volume size in GBs for each node. | `number` | `50` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | OCID of the OKE cluster to which this node pool belongs. | `string` | n/a | yes |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | OCID of the compartment in which to create the node pool. | `string` | n/a | yes |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | OCID of the node image to use. | `string` | n/a | yes |
| <a name="input_is_pv_encryption_in_transit_enabled"></a> [is\_pv\_encryption\_in\_transit\_enabled](#input\_is\_pv\_encryption\_in\_transit\_enabled) | (Optional) Whether in-transit encryption is enabled for the boot volume. | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the node pool (e.g. v1.32.1). | `string` | n/a | yes |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Total number of nodes to provision across all Availability Domains. Nodes are distributed round-robin across ADs; for even distribution use a multiple of the AD count in your region. | `number` | `2` | no |
| <a name="input_node_pool_defined_tags"></a> [node\_pool\_defined\_tags](#input\_node\_pool\_defined\_tags) | Defined tags to apply to the node pool. | `map(string)` | `{}` | no |
| <a name="input_node_pool_freeform_tags"></a> [node\_pool\_freeform\_tags](#input\_node\_pool\_freeform\_tags) | Freeform tags to apply to the node pool. | `map(string)` | `{}` | no |
| <a name="input_node_pool_name"></a> [node\_pool\_name](#input\_node\_pool\_name) | Display name for the node pool. | `string` | n/a | yes |
| <a name="input_node_shape"></a> [node\_shape](#input\_node\_shape) | Shape of each node. Only VM.Standard.A1.Flex is supported for OKE; VM.Standard.E2.1.Micro is not compatible with OKE node pools. | `string` | `"VM.Standard.A1.Flex"` | no |
| <a name="input_node_shape_memory_in_gbs"></a> [node\_shape\_memory\_in\_gbs](#input\_node\_shape\_memory\_in\_gbs) | Memory in GBs per node (only applies to Flex shapes). | `number` | `6` | no |
| <a name="input_node_shape_ocpus"></a> [node\_shape\_ocpus](#input\_node\_shape\_ocpus) | Number of OCPUs per node (only applies to Flex shapes). | `number` | `1` | no |
| <a name="input_nsg_ids"></a> [nsg\_ids](#input\_nsg\_ids) | List of NSG OCIDs to associate with node pool VNICs. | `list(string)` | `[]` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key to inject into nodes. Must start with 'ssh-' or 'ecdsa-', or be null. | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | OCID of the subnet in which nodes will be placed. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_node_pool_id"></a> [node\_pool\_id](#output\_node\_pool\_id) | OCID of the OKE node pool. |
| <a name="output_node_pool_nodes"></a> [node\_pool\_nodes](#output\_node\_pool\_nodes) | List of nodes in the node pool with their IPs and lifecycle states. |
<!-- END_TF_DOCS -->
