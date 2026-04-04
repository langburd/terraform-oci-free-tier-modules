locals {
  k3s_ansible_path = var.k3s_ansible_path != "" ? var.k3s_ansible_path : "${abspath(path.module)}/vendor/k3s-ansible"
  api_endpoint     = var.api_endpoint != null ? var.api_endpoint : var.server_ips[0]

  # Build per-host map: ip -> group (server or agent)
  server_hosts = { for ip in var.server_ips : ip => "server" }
  agent_hosts  = { for ip in var.agent_ips : ip => "agent" }
  all_hosts    = merge(local.server_hosts, local.agent_hosts)
}

resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

resource "ansible_playbook" "k3s_deploy" {
  for_each = local.all_hosts

  playbook   = "${local.k3s_ansible_path}/playbooks/site.yml"
  name       = each.key
  replayable = true

  groups = [each.value, "k3s_cluster"]

  extra_vars = {
    ansible_user                 = var.ssh_user
    ansible_ssh_private_key_file = var.ssh_private_key_path
    ansible_ssh_extra_args       = "-o StrictHostKeyChecking=no"
    k3s_version                  = var.k3s_version
    token                        = random_password.k3s_token.result
    api_endpoint                 = local.api_endpoint
    extra_server_args            = var.extra_server_args
    extra_agent_args             = var.extra_agent_args
  }

  depends_on = [random_password.k3s_token]
}
