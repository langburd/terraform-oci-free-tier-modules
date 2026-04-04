# OCI OKE Cluster Module

Terraform module creating an Oracle Kubernetes Engine (OKE) cluster.

## Usage Example

```hcl
module "oke_cluster" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/oke_cluster/v1.0.0"

  compartment_id     = "<compartment_ocid>"
  vcn_id             = "<vcn_ocid>"
  cluster_name       = "free-tier-oke"
  kubernetes_version = "v1.32.1"
  endpoint_subnet_id = "<api_endpoint_subnet_ocid>"

  endpoint_nsg_ids      = ["<api_endpoint_nsg_ocid>"]
  service_lb_subnet_ids = ["<lb_subnet_ocid>"]
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
| <a name="provider_oci"></a> [oci](#provider\_oci) | 8.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [oci_containerengine_cluster.this](https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_defined_tags"></a> [cluster\_defined\_tags](#input\_cluster\_defined\_tags) | (Optional) (Updatable) Defined tags for the OKE cluster. | `map(string)` | `{}` | no |
| <a name="input_cluster_freeform_tags"></a> [cluster\_freeform\_tags](#input\_cluster\_freeform\_tags) | (Optional) (Updatable) Free-form tags for the OKE cluster. | `map(string)` | `{}` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | (Required) A user-friendly name for the OKE cluster. | `string` | n/a | yes |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | (Optional) The type of OKE cluster. Either BASIC\_CLUSTER or ENHANCED\_CLUSTER. | `string` | `"BASIC_CLUSTER"` | no |
| <a name="input_cni_type"></a> [cni\_type](#input\_cni\_type) | (Optional) The CNI type for the OKE cluster. Either FLANNEL\_OVERLAY or OCI\_VCN\_IP\_NATIVE. | `string` | `"FLANNEL_OVERLAY"` | no |
| <a name="input_compartment_id"></a> [compartment\_id](#input\_compartment\_id) | (Required) The OCID of the compartment in which to create the OKE cluster. | `string` | n/a | yes |
| <a name="input_endpoint_is_public_ip_enabled"></a> [endpoint\_is\_public\_ip\_enabled](#input\_endpoint\_is\_public\_ip\_enabled) | (Optional) Whether the Kubernetes API endpoint is assigned a public IP address. | `bool` | `true` | no |
| <a name="input_endpoint_nsg_ids"></a> [endpoint\_nsg\_ids](#input\_endpoint\_nsg\_ids) | (Optional) List of NSG OCIDs to associate with the Kubernetes API endpoint. | `list(string)` | `[]` | no |
| <a name="input_endpoint_subnet_id"></a> [endpoint\_subnet\_id](#input\_endpoint\_subnet\_id) | (Required) The OCID of the subnet for the Kubernetes API endpoint. | `string` | n/a | yes |
| <a name="input_is_kubernetes_dashboard_enabled"></a> [is\_kubernetes\_dashboard\_enabled](#input\_is\_kubernetes\_dashboard\_enabled) | (Optional) Whether the Kubernetes Dashboard add-on is enabled. | `bool` | `false` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | (Required) The Kubernetes version to use for the OKE cluster (e.g. v1.32.1). | `string` | n/a | yes |
| <a name="input_pods_cidr"></a> [pods\_cidr](#input\_pods\_cidr) | (Optional) CIDR block for pods in the Kubernetes cluster. | `string` | `"10.244.0.0/16"` | no |
| <a name="input_service_lb_subnet_ids"></a> [service\_lb\_subnet\_ids](#input\_service\_lb\_subnet\_ids) | (Optional) List of subnet OCIDs for Kubernetes service load balancers. | `list(string)` | `[]` | no |
| <a name="input_services_cidr"></a> [services\_cidr](#input\_services\_cidr) | (Optional) CIDR block for Kubernetes services. | `string` | `"10.96.0.0/16"` | no |
| <a name="input_vcn_id"></a> [vcn\_id](#input\_vcn\_id) | (Required) The OCID of the VCN in which to create the OKE cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_endpoints"></a> [cluster\_endpoints](#output\_cluster\_endpoints) | OKE cluster API endpoints. |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | OCID of the OKE cluster. |
| <a name="output_cluster_kubernetes_version"></a> [cluster\_kubernetes\_version](#output\_cluster\_kubernetes\_version) | Kubernetes version of the OKE cluster. |
| <a name="output_cluster_state"></a> [cluster\_state](#output\_cluster\_state) | Lifecycle state of the OKE cluster. |
<!-- END_TF_DOCS -->
