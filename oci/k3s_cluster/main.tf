locals {
  k3s_ansible_path = var.k3s_ansible_path != "" ? var.k3s_ansible_path : "${path.module}/vendor/k3s-ansible"
  api_endpoint     = var.api_endpoint != null ? var.api_endpoint : var.server_ips[0]
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

# Run the k3s-ansible site.yml playbook for each server node first.
# Servers must be provisioned before agents so that the API endpoint is
# available when agent nodes join the cluster.
resource "ansible_playbook" "k3s_server" {
  for_each = toset(var.server_ips)

  playbook   = "${local.k3s_ansible_path}/playbooks/site.yml"
  name       = each.key
  replayable = false

  groups = ["server", "k3s_cluster"]

  extra_vars = {
    ansible_user                 = var.ssh_user
    ansible_ssh_private_key_file = var.ssh_private_key_path
    ansible_ssh_extra_args       = var.ssh_extra_args
    k3s_version                  = var.k3s_version
    token                        = random_password.k3s_token.result
    api_endpoint                 = local.api_endpoint
    extra_server_args            = var.extra_server_args
    extra_agent_args             = var.extra_agent_args
  }

  depends_on = [random_password.k3s_token]
}

# Run the k3s-ansible site.yml playbook for each agent node after all servers
# are provisioned. Agent nodes use api_endpoint from extra_vars to join the
# cluster, so they must run after the server resource completes.
resource "ansible_playbook" "k3s_agent" {
  for_each = toset(var.agent_ips)

  playbook   = "${local.k3s_ansible_path}/playbooks/site.yml"
  name       = each.key
  replayable = false

  groups = ["agent", "k3s_cluster"]

  extra_vars = {
    ansible_user                 = var.ssh_user
    ansible_ssh_private_key_file = var.ssh_private_key_path
    ansible_ssh_extra_args       = var.ssh_extra_args
    k3s_version                  = var.k3s_version
    token                        = random_password.k3s_token.result
    api_endpoint                 = local.api_endpoint
    extra_server_args            = var.extra_server_args
    extra_agent_args             = var.extra_agent_args
  }

  depends_on = [ansible_playbook.k3s_server]
}
