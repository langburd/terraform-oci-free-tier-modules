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
| [`oci/vault`](oci/vault) | KMS vault + optional software key |
| [`oci/certificates`](oci/certificates) | Certificate Authority + optional issued certificate |
| [`oci/bastion`](oci/bastion) | Bastion service (STANDARD type) |
| [`oci/vpn`](oci/vpn) | Site-to-Site VPN: DRG + optional VCN attachment + CPE + IPSec |

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
| [`examples/free-tier-web-app`](examples/free-tier-web-app) | 2x AMD Micro + flexible load balancer + VCN |
| [`examples/free-tier-observability`](examples/free-tier-observability) | Monitoring + logging + APM + connector hub + notifications |
| [`examples/free-tier-security`](examples/free-tier-security) | Vault + software key + root CA + TLS certificate |

## Requirements

- Terraform >= 1.6.4
- OCI provider >= 6.0

## Versioning and Releases

Modules are automatically versioned and released via [techpivot/terraform-module-releaser](https://github.com/techpivot/terraform-module-releaser) on every PR merge to `master`.

Each module under `oci/` gets its own semver tag (e.g., `oci/budget/v1.2.0`) and GitHub Release. Version bumps follow [Conventional Commits](https://www.conventionalcommits.org/):

| Commit type | Version bump |
|---|---|
| `feat!:` or `BREAKING CHANGE:` footer | major |
| `feat:` | minor |
| `fix:`, `chore:`, etc. | patch |

Module documentation is published to the [repository wiki](../../wiki) automatically.
