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
| Autonomous DB | Use `data_storage_size_in_gbs = 20` instead of `data_storage_size_in_tbs = 0.02` |
| Autonomous DB | Remove `subnet_id`, `nsg_ids` — private endpoints NOT available for free tier |
| Autonomous DB | `cpu_core_count` is now ECPUs, not OCPUs |
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
- `is_mtls_connection_required` defaults to `false` since July 2023 — be explicit
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

## 5. Deeper P0 Module Specs (Phase 1)

### 5.1 `oci/vcn`

**Resources:**

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_vcn` | no | `this` |
| `oci_core_internet_gateway` | `create_internet_gateway` | `this` |
| `oci_core_nat_gateway` | `create_nat_gateway` | `this` |
| `oci_core_service_gateway` | `create_service_gateway` | `this` |
| `oci_core_route_table` | `create_internet_gateway` | `public` |
| `oci_core_route_table` | `create_nat_gateway` | `private` |
| `oci_core_security_list` | no | `this` |

**Data sources:**
- `data.oci_core_services` — needed for service gateway `services` block (filter: "All .* Services In Oracle Services Network")

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `vcn_display_name` | `string` | No | `"vcn"` | — |
| `vcn_cidr_blocks` | `list(string)` | No | `["10.0.0.0/16"]` | Each element is valid CIDR |
| `vcn_dns_label` | `string` | No | `null` | `^[a-z][a-z0-9]{0,14}$` |
| `create_internet_gateway` | `bool` | No | `true` | — |
| `create_nat_gateway` | `bool` | No | `false` | — |
| `create_service_gateway` | `bool` | No | `false` | — |
| `vcn_defined_tags` | `map(string)` | No | `{}` | — |
| `vcn_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `vcn_id`, `vcn_cidr_blocks`, `internet_gateway_id`, `nat_gateway_id`, `service_gateway_id`, `public_route_table_id`, `private_route_table_id`, `default_security_list_id`

**Route table design:**
- Public route table: `0.0.0.0/0` → IGW (+ service CIDR → SGW if service gateway created)
- Private route table: `0.0.0.0/0` → NAT (+ service CIDR → SGW if service gateway created)
- Uses `destination` + `destination_type`, NOT deprecated `cidr_block`

**Test scenarios:**
1. Default — VCN + IGW + public route table created, no NAT/SGW
2. All gateways — `create_nat_gateway = true`, `create_service_gateway = true`
3. No gateways — both false, only VCN + security list
4. Custom CIDR — `vcn_cidr_blocks = ["192.168.0.0/20"]`
5. DNS label validation — reject invalid labels
6. OCID validation — reject invalid compartment_id

### 5.2 `oci/subnet`

**Resources:**

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_subnet` | no | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `vcn_id` | `string` | Yes | — | OCID regex |
| `subnet_cidr_block` | `string` | Yes | — | Valid CIDR |
| `subnet_display_name` | `string` | No | `"subnet"` | — |
| `subnet_dns_label` | `string` | No | `null` | `^[a-z][a-z0-9]{0,14}$` |
| `prohibit_internet_ingress` | `bool` | No | `false` | — |
| `route_table_id` | `string` | No | `null` | OCID regex or null |
| `security_list_ids` | `list(string)` | No | `null` | — |
| `availability_domain` | `string` | No | `null` | — |
| `subnet_defined_tags` | `map(string)` | No | `{}` | — |
| `subnet_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `subnet_id`, `subnet_cidr_block`

**Test scenarios:**
1. Default — public regional subnet
2. Private subnet — `prohibit_internet_ingress = true`
3. With route table and security list IDs
4. OCID validation rejection
5. DNS label validation rejection

### 5.3 `oci/compute`

**Resources:**

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_instance` | no | `this` |

**Data sources:**
- `data.oci_identity_availability_domains` — dynamic AD lookup

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `availability_domain_number` | `number` | No | `1` | >= 1 |
| `shape` | `string` | No | `"VM.Standard.E2.1.Micro"` | `contains(["VM.Standard.E2.1.Micro", "VM.Standard.A1.Flex"], ...)` |
| `shape_ocpus` | `number` | No | `1` | 1-4 (for A1 Flex free tier) |
| `shape_memory_in_gbs` | `number` | No | `6` | 1-24 (for A1 Flex free tier) |
| `image_id` | `string` | Yes | — | OCID regex |
| `subnet_id` | `string` | Yes | — | OCID regex |
| `assign_public_ip` | `bool` | No | `true` | — |
| `ssh_authorized_keys` | `string` | No | `null` | — |
| `user_data` | `string` | No | `null` | — |
| `boot_volume_size_in_gbs` | `number` | No | `50` | 50-200 |
| `instance_display_name` | `string` | No | `"instance"` | — |
| `nsg_ids` | `list(string)` | No | `[]` | — |
| `compute_defined_tags` | `map(string)` | No | `{}` | — |
| `compute_freeform_tags` | `map(string)` | No | `{}` | — |

**Design notes:**
- `dynamic "shape_config"` block renders only when `shape` contains "Flex"
- Uses `source_details` block (not deprecated `image` argument)
- Uses `create_vnic_details` block
- `metadata` block includes `ssh_authorized_keys` and `user_data`
- AD looked up via `data.oci_identity_availability_domains` using `availability_domain_number`

**Outputs:** `instance_id`, `instance_public_ip`, `instance_private_ip`, `instance_state`, `availability_domain`

**Test scenarios:**
1. AMD Micro default — no shape_config block rendered
2. A1 Flex — shape_config with ocpus + memory
3. Shape validation — reject invalid shape names
4. Boot volume range — reject < 50 or > 200
5. OCID validation rejection

**README warning:** Document idle instance reclamation (<20% CPU/network utilization over 7 days).

### 5.4 `oci/block_volume`

**Resources:**

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_volume` | no | `this` |
| `oci_core_volume_attachment` | `instance_id != null` | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `availability_domain` | `string` | Yes | — | — |
| `volume_display_name` | `string` | No | `"block-volume"` | — |
| `volume_size_in_gbs` | `number` | No | `50` | 50-200 (free tier safe default, NOT provider default of 1024) |
| `vpus_per_gb` | `number` | No | `10` | `contains([0, 10, 20], ...)` |
| `instance_id` | `string` | No | `null` | OCID regex or null |
| `attachment_type` | `string` | No | `"paravirtualized"` | `contains(["iscsi", "paravirtualized"], ...)` |
| `is_read_only` | `bool` | No | `false` | — |
| `volume_defined_tags` | `map(string)` | No | `{}` | — |
| `volume_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `volume_id`, `volume_attachment_id`

**Critical design note:** Default `volume_size_in_gbs = 50` (NOT provider default of 1024GB). Free tier total is 200GB including boot volumes.

**Test scenarios:**
1. Default — 50GB volume, no attachment
2. With attachment — paravirtualized
3. Size validation — reject > 200, reject < 50
4. VPUs validation — reject invalid values
5. OCID validation rejection

### 5.5 `oci/object_storage`

**Resources:**

| Resource | Conditional | Name |
|----------|-------------|------|
| `data.oci_objectstorage_namespace` | no | `this` |
| `oci_objectstorage_bucket` | no | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `bucket_name` | `string` | Yes | — | `^[a-zA-Z0-9._-]+$` |
| `bucket_access_type` | `string` | No | `"NoPublicAccess"` | `contains(["NoPublicAccess", "ObjectRead", "ObjectReadWithoutList"], ...)` |
| `storage_tier` | `string` | No | `"Standard"` | `contains(["Standard", "Archive"], ...)` |
| `versioning` | `string` | No | `"Disabled"` | `contains(["Enabled", "Suspended", "Disabled"], ...)` |
| `auto_tiering` | `string` | No | `"Disabled"` | `contains(["Disabled", "InfrequentAccess"], ...)` |
| `object_events_enabled` | `bool` | No | `false` | — |
| `bucket_defined_tags` | `map(string)` | No | `{}` | — |
| `bucket_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `bucket_name`, `bucket_namespace`, `bucket_id`

**Design note:** `storage_tier` is **immutable after creation** — document prominently.

**Test scenarios:**
1. Default — Standard tier, no public access, no versioning
2. Public read access
3. Archive tier
4. Versioning enabled
5. Bucket name validation — reject invalid characters
6. OCID validation rejection

---

## 6. Module Dependency Graph (Updated)

```
oci_profile_reader --> identity (compartment)
                          |
         +-------+-------+--------+--------+--------+
         |       |       |        |        |        |
       budget   vcn   obj_stor  vault  certs    apm
                 |               nosql  email  notifs ──┐
                 |                                      │
              subnet                                monitoring
                 |                                      │
    +-----+------+------+------+------+           logging
    |     |      |      |      |      |              │
 compute  LB    NLB   mysql  bastion  vpn      connector_hub
    |                  (DRG)
 block_vol
```

---

## 7. Updated Implementation Sequence

### Phase 1 — Foundation (5 modules + 1 example)

1. `oci/vcn` → `feat(vcn): add VCN module with internet, NAT, and service gateways`
2. `oci/subnet` → `feat(subnet): add subnet module`
3. `oci/compute` → `feat(compute): add compute module for AMD Micro and Ampere A1 Flex`
4. `oci/block_volume` → `feat(block_volume): add block volume module with optional attachment`
5. `oci/object_storage` → `feat(object_storage): add object storage bucket module`
6. `examples/free-tier-compute-stack` → `feat(examples): add free-tier-compute-stack example`

### Phase 2 — Databases + Notifications (4 modules + 1 example)

1. `oci/autonomous_database` → `feat(autonomous_database): add Always Free autonomous database module`
2. `oci/nosql` → `feat(nosql): add NoSQL table module with index support`
3. `oci/mysql` → `feat(mysql): add MySQL HeatWave standalone module`
4. `oci/notifications` → `feat(notifications): add notification topic and subscription module`
5. `examples/free-tier-databases` → `feat(examples): add free-tier-databases example`

### Phase 3 — Networking Extras + Security (5 modules + 2 examples)

1. `oci/load_balancer` → `feat(load_balancer): add flexible load balancer module`
2. `oci/network_load_balancer` → `feat(network_load_balancer): add network load balancer module`
3. `oci/vault` → `feat(vault): add KMS vault and key module`
4. `oci/certificates` → `feat(certificates): add certificate authority and certificate module`
5. `oci/bastion` → `feat(bastion): add bastion service module`
6. `examples/free-tier-web-app` + `examples/free-tier-security` → examples

### Phase 4 — Observability + VPN (6 modules + 2 examples)

1. `oci/monitoring` → `feat(monitoring): add monitoring alarm module`
2. `oci/email_delivery` → `feat(email_delivery): add email domain, sender, and DKIM module`
3. `oci/logging` → `feat(logging): add log group and log module`
4. `oci/apm` → `feat(apm): add APM domain module`
5. `oci/connector_hub` → `feat(connector_hub): add service connector module`
6. `oci/vpn` → `feat(vpn): add site-to-site VPN module with DRG`
7. `examples/free-tier-observability` + `examples/free-tier-arm-server` → examples
