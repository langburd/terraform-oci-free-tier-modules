# OCI K3s Cluster Module

Terraform module deploying K3s on already-provisioned OCI instances using the Ansible provider.

This is a composite module: it does NOT provision compute or networking infrastructure. Call `oci/compute` and `oci/subnet` modules first, then pass the instance public IPs to this module.

## Prerequisites

- Terraform >= 1.14
- `ansible-playbook` binary installed on the Terraform runner
- Target instances must be SSH-accessible with the provided key
- Python 3 must be installed on target instances (use cloud-init)

## Approach

This module uses `resource "ansible_playbook"` from the `ansible/ansible` provider (v1.4). One resource is created per host (servers and agents) using `for_each`, with each host assigned to its respective group (`server` or `agent`) via the `groups` argument.

**Note on `action` block**: The Terraform 1.14 `action "ansible_playbook_run"` block was evaluated but cannot be used here because the Ansible provider's `ValidateConfig` checks playbook file existence at validate time. Since the playbook path depends on `path.module` (which resolves to `"."` during validation), the provider receives an empty string and fails. The `resource "ansible_playbook"` approach does not have this limitation.

## Usage Example

```hcl
module "k3s_cluster" {
  source = "git@github.com:langburd/terraform-oci-free-tier-modules.git?ref=oci/k3s_cluster/v1.0.0"

  server_ips           = [module.k3s_server.instance_public_ip]
  agent_ips            = [for agent in module.k3s_agents : agent.instance_public_ip]
  ssh_private_key_path = local_sensitive_file.ssh_key.filename
  ssh_user             = "ubuntu"
  k3s_version          = "v1.31.12+k3s1"
}

output "kubeconfig_command" {
  value = module.k3s_cluster.kubeconfig_command
}
```

## k3s-ansible

This module vendors [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible) as a Git submodule at `vendor/k3s-ansible/`. The Ansible playbooks are run automatically during `terraform apply`.

To update k3s-ansible: `git submodule update --remote oci/k3s_cluster/vendor/k3s-ansible`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14 |
| <a name="requirement_ansible"></a> [ansible](#requirement\_ansible) | ~> 1.4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ansible"></a> [ansible](#provider\_ansible) | 1.4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.8.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [ansible_playbook.k3s_agent](https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/playbook) | resource |
| [ansible_playbook.k3s_server](https://registry.terraform.io/providers/ansible/ansible/latest/docs/resources/playbook) | resource |
| [random_password.k3s_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_ips"></a> [agent\_ips](#input\_agent\_ips) | List of public IP addresses for K3s agent (worker) nodes. | `list(string)` | `[]` | no |
| <a name="input_api_endpoint"></a> [api\_endpoint](#input\_api\_endpoint) | API endpoint for the K3s cluster. Defaults to the first server IP. | `string` | `null` | no |
| <a name="input_extra_agent_args"></a> [extra\_agent\_args](#input\_extra\_agent\_args) | Additional arguments to pass to k3s agent. | `string` | `""` | no |
| <a name="input_extra_server_args"></a> [extra\_server\_args](#input\_extra\_server\_args) | Additional arguments to pass to k3s server. | `string` | `""` | no |
| <a name="input_k3s_ansible_path"></a> [k3s\_ansible\_path](#input\_k3s\_ansible\_path) | Path to the k3s-ansible directory containing playbooks. | `string` | `""` | no |
| <a name="input_k3s_version"></a> [k3s\_version](#input\_k3s\_version) | K3s version to install. Must start with 'v' (e.g. 'v1.31.12+k3s1'). | `string` | `"v1.31.12+k3s1"` | no |
| <a name="input_server_ips"></a> [server\_ips](#input\_server\_ips) | List of public IP addresses for K3s server (control plane) nodes. At least one required. | `list(string)` | n/a | yes |
| <a name="input_ssh_extra_args"></a> [ssh\_extra\_args](#input\_ssh\_extra\_args) | Additional SSH arguments passed to Ansible. Defaults to disabling host key checking for initial provisioning. Set to '' or override for stricter security in trusted environments. | `string` | `"-o StrictHostKeyChecking=no"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to the SSH private key file for connecting to K3s nodes. | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH username to connect to K3s nodes. Oracle Linux images use 'opc'; Ubuntu images use 'ubuntu'. | `string` | `"opc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | Public IP of the K3s server node (API endpoint). |
| <a name="output_k3s_token"></a> [k3s\_token](#output\_k3s\_token) | K3s cluster token (sensitive). Used to join additional nodes. |
| <a name="output_kubeconfig_command"></a> [kubeconfig\_command](#output\_kubeconfig\_command) | SSH command to retrieve the kubeconfig from the K3s server. |
<!-- END_TF_DOCS -->
