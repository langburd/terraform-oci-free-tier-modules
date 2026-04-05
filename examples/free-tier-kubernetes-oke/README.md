# Free Tier Kubernetes (OKE) Example

Deploys a fully functional OKE cluster on OCI Always Free Tier resources.

## Architecture

- 1 VCN with 3 subnets (API endpoint, worker nodes, load balancer)
- 3 Network Security Groups with OKE-required rules
- 1 OKE cluster (BASIC_CLUSTER, free control plane)
- 1 Node pool: 2x `VM.Standard.A1.Flex` (1 OCPU, 6 GB each)

## Free Tier Resource Usage

| Resource | Used | Free Limit |
|----------|------|-----------|
| Arm OCPUs | 2 (default) | 4 |
| Arm Memory | 12 GB (default) | 24 GB |
| Boot Volumes | 100 GB (default) | 200 GB |
| Flexible LB | 0 (manual) | 1 |
| VCNs | 1 | 2 |

## Usage

```hcl
# terraform.tfvars
oci_config_profile = "DEFAULT"
kubernetes_version = "v1.32.1"
ssh_public_key     = "ssh-ed25519 AAAA..."
```

```bash
terraform init
terraform plan
terraform apply
# After cluster is ACTIVE:
oci ce cluster create-kubeconfig --cluster-id <cluster_id> --file ~/.kube/config --region <region> --token-version 2.0.0
kubectl get nodes
```

## Prerequisites

- OCI CLI configured with a valid profile
- Terraform >= 1.0
- Target region must be your home region (free tier resources are home-region-only)

## Notes

- OKE control plane is free (no additional charge)
- A1.Flex instances may show "Out of host capacity" in new accounts; retry or try different ADs
- AMD Micro instances cannot be used as OKE worker nodes (use K3s for mixed-arch)
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_oci"></a> [oci](#requirement\_oci) | ~> 8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_oci"></a> [oci](#provider\_oci) | ~> 8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_endpoint_nsg"></a> [api\_endpoint\_nsg](#module\_api\_endpoint\_nsg) | ../../oci/network_security_group | n/a |
| <a name="module_api_endpoint_subnet"></a> [api\_endpoint\_subnet](#module\_api\_endpoint\_subnet) | ../../oci/subnet | n/a |
| <a name="module_k8s_compartment"></a> [k8s\_compartment](#module\_k8s\_compartment) | ../../oci/identity | n/a |
| <a name="module_k8s_vcn"></a> [k8s\_vcn](#module\_k8s\_vcn) | ../../oci/vcn | n/a |
| <a name="module_lb_nsg"></a> [lb\_nsg](#module\_lb\_nsg) | ../../oci/network_security_group | n/a |
| <a name="module_lb_subnet"></a> [lb\_subnet](#module\_lb\_subnet) | ../../oci/subnet | n/a |
| <a name="module_oci_profile_reader"></a> [oci\_profile\_reader](#module\_oci\_profile\_reader) | ../../oci/oci_profile_reader | n/a |
| <a name="module_oke_cluster"></a> [oke\_cluster](#module\_oke\_cluster) | ../../oci/oke_cluster | n/a |
| <a name="module_oke_node_pool"></a> [oke\_node\_pool](#module\_oke\_node\_pool) | ../../oci/oke_node_pool | n/a |
| <a name="module_worker_nsg"></a> [worker\_nsg](#module\_worker\_nsg) | ../../oci/network_security_group | n/a |
| <a name="module_worker_subnet"></a> [worker\_subnet](#module\_worker\_subnet) | ../../oci/subnet | n/a |

## Resources

| Name | Type |
|------|------|
| [oci_core_images.oracle_linux_arm](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_images) | data source |
| [oci_core_services.all](https://registry.terraform.io/providers/oracle/oci/latest/docs/data-sources/core_services) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_boot_volume_size_in_gbs"></a> [boot\_volume\_size\_in\_gbs](#input\_boot\_volume\_size\_in\_gbs) | Boot volume size in GB for each worker node. Total must not exceed 200 GB (free tier block storage limit). | `number` | `50` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the OKE cluster. | `string` | `"free-tier-oke"` | no |
| <a name="input_compartment_name"></a> [compartment\_name](#input\_compartment\_name) | Name of the OCI compartment to create. | `string` | `"free-tier-kubernetes-oke"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the OKE cluster and node pool. Must start with 'v' (e.g. 'v1.32.1'). | `string` | `"v1.32.1"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | Number of worker nodes in the node pool. Each node uses 50 GB boot volume; max 4 nodes (200 GB total free tier limit). | `number` | `2` | no |
| <a name="input_node_memory_in_gbs"></a> [node\_memory\_in\_gbs](#input\_node\_memory\_in\_gbs) | Memory in GB per worker node. Total across all nodes must not exceed 24 GB (free tier limit). | `number` | `6` | no |
| <a name="input_node_ocpus"></a> [node\_ocpus](#input\_node\_ocpus) | Number of OCPUs per worker node. Total across all nodes must not exceed 4 (free tier limit). | `number` | `1` | no |
| <a name="input_oci_config_profile"></a> [oci\_config\_profile](#input\_oci\_config\_profile) | (Required) OCI CLI config file profile name to use for authentication. | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key to authorize on worker nodes for debugging access. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoints"></a> [cluster\_endpoints](#output\_cluster\_endpoints) | OKE cluster API endpoints. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | OCID of the OKE cluster. |
| <a name="output_cluster_state"></a> [cluster\_state](#output\_cluster\_state) | Current lifecycle state of the OKE cluster. |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | OCI CLI command to generate kubeconfig for this cluster. |
| <a name="output_node_pool_id"></a> [node\_pool\_id](#output\_node\_pool\_id) | OCID of the OKE node pool. |
<!-- END_TF_DOCS -->
