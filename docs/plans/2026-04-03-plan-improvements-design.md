# Design: Improvements to OCI Free Tier Comprehensive Modules Plan

**Date:** 2026-04-03
**Scope:** Incremental fix-up of the existing plan with accuracy corrections, deeper P0 specs, and revised phasing

---

## 1. Accuracy Corrections

### 1.1 Deprecated Arguments

| Module | Fix |
|--------|-----|
| VCN | Use `cidr_blocks` (list), not deprecated `cidr_block` |
| VCN route table | Use `destination` + `destination_type`, not deprecated `route_rules.cidr_block` |
| Block Volume | Explicitly set `size_in_gbs` — provider default is 1TB, free tier budget is 200GB total |
| Compute | Boot volume min is 50GB (not 47) |
| Autonomous DB | Use `data_storage_size_in_gb = 20` instead of `data_storage_size_in_tbs = 0.02` (note: no trailing "s" in provider argument name) |
| Autonomous DB | Remove `subnet_id`, `nsg_ids` — private endpoints NOT available for free tier |
| Autonomous DB | Replace `cpu_core_count` with `compute_model = "ECPU"` + `compute_count`; `cpu_core_count` is a legacy field that reports 0 under the ECPU model |
| Load Balancer | Shape must be `"flexible"` with `shape_details` block, not flat bandwidth vars |
| LB Listener | `path_route_set_name` deprecated — use `routing_policy_name` |

### 1.2 Free Tier Inventory Corrections

| Current Plan | Correction |
|-------------|-----------|
| Email: "3K emails/month" | 200/day (~6K/mo), 10/min rate limit for trial accounts |
| Compute A1: "4 OCPUs + 24GB RAM total" | 3,000 OCPU-hours + 18,000 GB-hours/month (equivalent to 4 OCPUs + 24GB running continuously) |

### 1.3 Free Tier Toggle Summary (new section to add)

| Resource | How to Enable Free Tier |
|----------|------------------------|
| Autonomous DB | `is_free_tier = true` |
| APM Domain | `is_free_tier = true` |
| Load Balancer | `shape = "flexible"`, `shape_details` min/max = 10 Mbps |
| Compute | Shape: `VM.Standard.E2.1.Micro` or `VM.Standard.A1.Flex` |
| MySQL | Shape TBD (verify per region via `data.oci_mysql_shapes`), `is_highly_available = false` |

---

## 2. Missing Resources

### 2.1 Resources to Add to Module Specs

| Module | Resource | Required/Optional | Why |
|--------|----------|-------------------|-----|
| VCN | `oci_core_service_gateway` | Conditional (`create_service_gateway`) | Private OCI service access (Object Storage, etc.) |
| VPN | `oci_core_drg` | Required | `oci_core_ipsec` mandates `drg_id` |
| VPN | `oci_core_drg_attachment` | Required | Attaches DRG to VCN |
| Email | `oci_email_email_domain` | Required | Domain configuration for sending |
| Email | `oci_email_dkim` | Conditional | DKIM authentication |
| LB | `oci_load_balancer_backend` | Optional (`for_each` on backends map) | Backend server registration |
| NLB | `oci_network_load_balancer_backend` | Optional (`for_each` on backends map) | Backend server registration |

### 2.2 Data Sources to Add

| Module(s) | Data Source | Purpose |
|-----------|-----------|---------|
| Compute, Block Vol, MySQL | `data.oci_identity_availability_domains` | Dynamic AD lookup |
| MySQL | `data.oci_mysql_shapes` | Discover available free tier shape name |
| VCN | `data.oci_core_services` | Service CIDR for service gateway |

---

## 3. Per-Module Spec Corrections

### Subnet
- Primary toggle: `prohibit_internet_ingress` (not `prohibit_public_ip_on_vnic`)
- Default `availability_domain = null` → regional subnet (Oracle recommended)

### Compute
- Use nested blocks: `source_details { source_type, source_id, boot_volume_size_in_gbs }` and `create_vnic_details { subnet_id, assign_public_ip, nsg_ids }`
- `metadata` map for `ssh_authorized_keys` and optional `user_data`
- Document idle instance reclamation: <20% CPU/network over 7 days → reclaimed
- `shape_config` block required for Flex shapes only

### Autonomous DB — Free Tier Constraints
- No auto-scaling, no manual backups, no Data Guard, no private endpoints
- Auto-stops after 7 days idle; reclaimed after 90 days stopped
- Max 30 concurrent sessions
- `is_mtls_connection_required` — set explicitly to `false` to allow TLS connections; verify provider default at implementation time
- Supported workloads: OLTP, DW, AJD (JSON), APEX

### MySQL
- Shape name needs runtime discovery via `data.oci_mysql_shapes`
- Add `deletion_policy { is_delete_protected = true }` default
- Add `backup_policy` nested block
- Home region only for Always Free

### Vault
- `management_endpoint` on `oci_kms_key` must reference `oci_kms_vault.this.management_endpoint`
- Auto-rotation only for VIRTUAL_PRIVATE vaults (not free tier DEFAULT)
- `vault_type` is immutable after creation

### Certificates
- `certificate_authority_config` and `certificate_config` are deeply nested — plan must show actual block structure

### Notifications
- Topic `name` must be unique across **entire tenancy** (not just compartment)

### Monitoring
- 8 required arguments: `compartment_id`, `destinations`, `display_name`, `is_enabled`, `metric_compartment_id`, `namespace`, `query`, `severity`
- Add `metric_compartment_id` as required variable

### Connector Hub
- Source/target args are conditional on `kind` — needs extensive `dynamic` blocks
- Note IAM policy requirements for cross-service access

---

## 4. Revised Phasing

### Rationale

The original phasing groups by category (infra, DBs, networking, observability). A better approach follows the **dependency graph** — build foundational modules first, then modules that consume them.

Key changes:
- **Notifications moves to Phase 2** (it's a dependency of Monitoring in Phase 4, which needs `destinations`)
- **Object Storage stays in Phase 1** (simple, no dependencies, useful early for state/backups)
- **Bastion moves to Phase 3** (depends on VCN/subnet from Phase 1)
- **VPN moves to Phase 4** (niche use case, complex DRG dependency)
- **Connector Hub stays Phase 4** (depends on Logging + Notifications from earlier phases)

### Revised Phase Structure

#### Phase 1 — Foundation (VCN + Subnet + Compute + Block Volume + Object Storage)

These are the building blocks everything else depends on:

1. `oci/vcn` — VCN + IGW + NAT + service gateway + route tables + security list
2. `oci/subnet` — Subnet within a VCN
3. `oci/compute` — Instance (AMD Micro + A1 Flex)
4. `oci/block_volume` — Block volume + optional attachment
5. `oci/object_storage` — Bucket
6. `examples/free-tier-compute-stack` — Ties them together

#### Phase 2 — Databases + Notifications (depends on Phase 1 networking)

Databases need subnets; notifications are a leaf dependency for monitoring later:

1. `oci/autonomous_database` — Always Free ADB
2. `oci/nosql` — NoSQL tables + indexes
3. `oci/mysql` — MySQL HeatWave (needs private subnet)
4. `oci/notifications` — Topics + subscriptions (moved up — needed by monitoring)
5. `examples/free-tier-databases`

#### Phase 3 — Networking Extras + Security + Bastion

These consume VCN/subnet and enhance the infrastructure:

1. `oci/load_balancer` — Flexible LB + backend set + listener + backends
2. `oci/network_load_balancer` — NLB + backend set + listener + backends
3. `oci/vault` — KMS vault + software key
4. `oci/certificates` — CA + certificates
5. `oci/bastion` — Bastion service
6. `examples/free-tier-web-app` + `examples/free-tier-security`

#### Phase 4 — Observability + VPN

Monitoring/logging depend on notifications (Phase 2). VPN is niche:

1. `oci/monitoring` — Alarms (needs notification topics as destinations)
2. `oci/email_delivery` — Email domain + sender + DKIM
3. `oci/logging` — Log groups + logs
4. `oci/apm` — APM domain
5. `oci/connector_hub` — Service connector (needs logging + notifications)
6. `oci/vpn` — Site-to-Site VPN with DRG + CPE + IPSec
7. `examples/free-tier-observability` + `examples/free-tier-arm-server`

---

## 5. Detailed Module Specs

The detailed Phase 1 module specs (variables, resources, outputs, test scenarios) and the dependency graph / implementation sequence are maintained in the main plan ([2026-04-02-oci-free-tier-comprehensive-modules.md](2026-04-02-oci-free-tier-comprehensive-modules.md)), which is the single source of truth. This design doc captures only the rationale for changes — refer to the main plan for authoritative specs.
