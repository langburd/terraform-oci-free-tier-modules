# terraform-oci-free-tier-modules

Reusable Terraform modules for Oracle Cloud Infrastructure (OCI) Always Free Tier resources. Consumed by the sibling [terraform-oci-free-tier-infra](https://github.com/langburd/terraform-oci-free-tier-infra) repo.

## Modules

### Foundation

| Module | Resource(s) |
|---|---|
| [`oci/identity`](oci/identity) | Compartment |
| [`oci/oci_profile_reader`](oci/oci_profile_reader) | Reads local OCI CLI profile for auth |
| [`oci/budget`](oci/budget) | Budget + optional alert rule |
| [`oci/vcn`](oci/vcn) | VCN, internet/NAT/service gateways, route tables |
| [`oci/subnet`](oci/subnet) | Subnet (public or private, regional or AD-scoped) |
| [`oci/compute`](oci/compute) | VM instance (AMD Micro or Arm A1 Flex) |
| [`oci/block_volume`](oci/block_volume) | Block volume + optional instance attachment |
| [`oci/object_storage`](oci/object_storage) | Object Storage bucket |

### Databases

| Module | Resource(s) |
|---|---|
| [`oci/autonomous_database`](oci/autonomous_database) | Always Free Autonomous Database (OLTP/DW/AJD/APEX) |
| [`oci/mysql`](oci/mysql) | MySQL HeatWave standalone system (`MySQL.Free` shape) |
| [`oci/nosql`](oci/nosql) | NoSQL table + optional indexes |

### Networking & Security

| Module | Resource(s) |
|---|---|
| [`oci/load_balancer`](oci/load_balancer) | Flexible LB (10 Mbps, free tier) + backend set + listener |
| [`oci/network_load_balancer`](oci/network_load_balancer) | Layer-4 NLB + backend set + listener |
| [`oci/network_security_group`](oci/network_security_group) | Network Security Group + ingress/egress rules |
| [`oci/security_list`](oci/security_list) | Security list + ingress/egress rules |
| [`oci/vault`](oci/vault) | KMS vault + optional software key |
| [`oci/certificates`](oci/certificates) | Certificate Authority + optional issued certificate |
| [`oci/bastion`](oci/bastion) | Bastion service (STANDARD type) |
| [`oci/vpn`](oci/vpn) | Site-to-Site VPN: DRG + optional VCN attachment + CPE + IPSec |

### Kubernetes & Containers

| Module | Resource(s) |
|---|---|
| [`oci/k3s_cluster`](oci/k3s_cluster) | K3s cluster provisioned via Ansible on existing compute nodes |
| [`oci/oke_cluster`](oci/oke_cluster) | OKE (Oracle Kubernetes Engine) cluster |
| [`oci/oke_node_pool`](oci/oke_node_pool) | OKE node pool |

### Observability & Notifications

| Module | Resource(s) |
|---|---|
| [`oci/monitoring`](oci/monitoring) | Monitoring alarm |
| [`oci/notifications`](oci/notifications) | ONS topic + optional subscriptions |
| [`oci/email_delivery`](oci/email_delivery) | Email domain + sender + optional DKIM |
| [`oci/logging`](oci/logging) | Log group + logs (via `for_each`) |
| [`oci/apm`](oci/apm) | APM domain (free tier) |
| [`oci/connector_hub`](oci/connector_hub) | Service Connector Hub |

## Examples

| Example | What it demonstrates |
|---|---|
| [`examples/dual-tenancy`](examples/dual-tenancy) | Multi-tenancy auth with `oci_profile_reader` |
| [`examples/free-tier-compute-stack`](examples/free-tier-compute-stack) | VCN + public/private subnets + AMD Micro + bastion |
| [`examples/free-tier-arm-server`](examples/free-tier-arm-server) | A1 Flex (4 OCPUs / 24 GB RAM) + VCN + block volume |
| [`examples/free-tier-databases`](examples/free-tier-databases) | Autonomous DB + MySQL + NoSQL wired together |
| [`examples/free-tier-k3s-cluster`](examples/free-tier-k3s-cluster) | K3s cluster on Always Free compute nodes |
| [`examples/free-tier-kubernetes-oke`](examples/free-tier-kubernetes-oke) | OKE cluster with node pool |
| [`examples/free-tier-web-app`](examples/free-tier-web-app) | 2x AMD Micro + flexible load balancer + VCN |
| [`examples/free-tier-observability`](examples/free-tier-observability) | Monitoring + logging + APM + connector hub + notifications |
| [`examples/free-tier-security`](examples/free-tier-security) | Vault + software key + root CA + TLS certificate |

## Requirements

- Terraform >= 1.0
- OCI provider >= 8.0

## Prerequisites for Local Development

In addition to Terraform, you need:

| Tool | Version | Install |
|---|---|---|
| [pre-commit](https://pre-commit.com) | any | `brew install pre-commit` |
| [terraform-docs](https://terraform-docs.io) | v0.19.0 | `brew install terraform-docs` |
| [tflint](https://github.com/terraform-linters/tflint) | v0.55.0 | `brew install tflint` |
| [yamlfmt](https://github.com/google/yamlfmt) | any | `brew install yamlfmt` |
| OCI credentials | — | `~/.oci/config` + `~/.oci/oci_api_key.pem` |

OCI credentials are required because `terraform_docs` and `tflint` call `terraform init` internally during pre-commit.

The pinned versions for `terraform-docs` and `tflint` match what CI uses (see `.github/workflows/pre-commit.yml`). Using different local versions may produce output that diverges from CI.

After installing tools, install the pre-commit hooks:

```bash
pre-commit install
```

## Local Development

### Running tests

Tests use a mock OCI provider and only run `terraform plan` — no real OCI resources are created.

```bash
cd oci/<module>
terraform init
terraform test
```

### Validating a module or example

```bash
cd oci/<module>      # or examples/<example>
terraform init
terraform validate
```

### Running all pre-commit checks

**Important:** Delete any `.terraform.lock.hcl` files before running pre-commit. If they exist, `terraform_docs` embeds the resolved provider version (e.g. `8.8.0`) instead of the constraint (`>= 8.0`), which causes CI to fail.

```bash
find oci -name ".terraform.lock.hcl" -delete
pre-commit run --all-files
```

## Contributing

1. **Branch** — branch off `master` and open a PR; never push directly to `master`.

2. **Commit messages** — follow [Conventional Commits](https://www.conventionalcommits.org/). The commit type determines the version bump for every module touched by the PR:

   | Commit type | Version bump |
   |---|---|
   | `feat!:` or `BREAKING CHANGE:` footer | major |
   | `feat:` | minor |
   | `fix:`, `chore:`, etc. | patch |

3. **Tests** — every change to a module must have a corresponding update to `tests/<module>.tftest.hcl`. Tests must pass (`terraform init && terraform test` from the module directory).

4. **Pre-commit** — run `pre-commit run --all-files` from the repo root (with no `.terraform.lock.hcl` present) before pushing. This formats code, regenerates README docs sections, and runs tflint.

5. **New modules** — follow the module layout (`main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `README.md`, `tests/<module>.tftest.hcl`) and add an entry to the modules table above.

## Versioning and Releases

Modules are automatically versioned and released via [techpivot/terraform-module-releaser](https://github.com/techpivot/terraform-module-releaser) on every PR merge to `master`.

Each module under `oci/` gets its own semver tag (e.g., `oci/budget/v1.2.0`) and GitHub Release. Version bumps follow [Conventional Commits](https://www.conventionalcommits.org/):

| Commit type | Version bump |
|---|---|
| `feat!:` or `BREAKING CHANGE:` footer | major |
| `feat:` | minor |
| `fix:`, `chore:`, etc. | patch |

Module documentation is published to the [repository wiki](../../wiki) automatically.
