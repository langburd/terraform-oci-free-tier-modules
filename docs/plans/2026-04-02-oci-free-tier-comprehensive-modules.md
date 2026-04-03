# OCI Always Free Tier — Comprehensive Terraform Modules Plan

**Date:** 2026-04-02 (revised 2026-04-03)
**Research source:** [OCI Always Free Resources docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)

## Context

The `terraform-oci-free-tier-modules` repo currently has only 3 modules (budget, identity, oci_profile_reader) but Oracle Cloud Free Tier offers 26+ services. This plan covers creating Terraform modules for all provisionable Always Free services, improving existing modules, and adding comprehensive examples.

---

## Oracle Cloud Always Free Services Inventory

### Infrastructure

| Service | Free Allocation |
|---------|----------------|
| Certificates | 5 CAs, 150 certificates |
| Compute (AMD Micro) | 2x VM.Standard.E2.1.Micro (1/8 OCPU, 1GB RAM) |
| Compute (Arm Ampere A1) | 3,000 OCPU-hours + 18,000 GB-hours/month (equivalent to 4 OCPUs + 24GB RAM running continuously) |
| Block Volume | 200GB total (boot + block combined), 5 backups |
| Object Storage | 20GB, 50K API requests/month |
| Vault/KMS | Unlimited software keys, 20 HSM key versions, 150 secrets |
| Resource Manager | 100 stacks, 2 concurrent jobs |

### Database

| Service | Free Allocation |
|---------|----------------|
| Autonomous Database | 2 instances, 1 ECPU, 20GB each |
| NoSQL Database | 133M reads/writes per month, 3 tables, 25GB each |
| MySQL HeatWave | 1 standalone system, 50GB storage + 50GB backup |

### Networking

| Service | Free Allocation |
|---------|----------------|
| VCN | 2 VCNs with IPv4/IPv6 |
| Flexible Load Balancer | 1 LB, 10Mbps, 16 listeners |
| Network Load Balancer | 1 NLB, 50 listeners |
| Site-to-Site VPN | 50 IPSec connections |
| VCN Flow Logs | 10GB/month (shared with Logging) |
| Cluster Placement Groups | 10-50 per region |

### Observability & Management

| Service | Free Allocation |
|---------|----------------|
| Monitoring | 500M ingestion, 1B retrieval data points |
| Notifications | 1M HTTPS + 1K email/month |
| Email Delivery | 200/day (~6K/month), 10/min rate limit |
| APM | 1K tracing events/hr, 10 synthetic runs/hr |
| Connector Hub | 2 connectors |
| Logging | 10GB/month |
| Bastion | Free for all accounts |
| Console Dashboards | 100 dashboards |
| Fleet Application Management | 25 operations/month |

### Other

| Service | Free Allocation |
|---------|----------------|
| Outbound Data Transfer | 10TB/month |

### Free Tier Toggle Summary

Resources that require explicit attributes to stay within the free tier:

| Resource | How to Enable Free Tier |
|----------|------------------------|
| Autonomous DB | `is_free_tier = true` (defaults to `false`) |
| APM Domain | `is_free_tier = true` (defaults to `false`) |
| Flexible Load Balancer | `shape = "flexible"` + `shape_details` min/max = 10 Mbps |
| Compute | Shape: `VM.Standard.E2.1.Micro` or `VM.Standard.A1.Flex` |
| MySQL HeatWave | Shape TBD (verify per region via `data.oci_mysql_shapes`), `is_highly_available = false` |
| Block Volume | `size_in_gbs` must be explicitly set (provider default is 1024GB, free tier total is 200GB) |

---

## Services Excluded from Module Scope

| Service | Reason |
|---------|--------|
| Resource Manager | Terraform-as-a-service; circular to manage via Terraform |
| Console Dashboards | Not manageable via Terraform |
| Fleet Application Management | Operational lifecycle service, not infrastructure |
| Outbound Data Transfer | Billing concept, not a provisionable resource |
| Cluster Placement Groups | For bare metal/HPC; irrelevant to free tier VM shapes |
| VCN Flow Logs | Covered by the logging module (flow log = `oci_logging_log` with VCN source) |

---

## Deprecated Arguments to Avoid

When implementing modules, avoid these deprecated provider arguments:

| Resource | Deprecated Argument | Use Instead |
|----------|-------------------|-------------|
| `oci_core_vcn` | `cidr_block` | `cidr_blocks` (list) |
| `oci_core_route_table` | `route_rules.cidr_block` | `route_rules.destination` + `destination_type` |
| `oci_core_volume` | `size_in_mbs` | `size_in_gbs` |
| `oci_core_volume` | `backup_policy_id` | Use backup policies separately |
| `oci_load_balancer_listener` | `path_route_set_name` | `routing_policy_name` |
| `oci_core_subnet` | `ipv6cidr_block` | `ipv6cidr_blocks` (list) |

---

## Data Sources Needed Across Modules

| Module(s) | Data Source | Purpose |
|-----------|-----------|---------|
| Compute, Block Volume, MySQL | `data.oci_identity_availability_domains` | Dynamic AD lookup |
| MySQL | `data.oci_mysql_shapes` | Discover available free tier shape name |
| VCN | `data.oci_core_services` | Service CIDR for service gateway routing |
| Object Storage | `data.oci_objectstorage_namespace` | Required for bucket creation |

---

## Improvements to Existing Modules

### `oci/identity` — Add input validation ✅ (PR #28)

- **File:** `oci/identity/variables.tf`
- ~~Add OCID regex validation to `oci_root_compartment`~~ Done
- ~~Add character validation to `compartment_name`~~ Done (length validation)
- Removed `root_compartment_id` output that just echoed the input variable
- Fixed `compartment_name` annotation from `(Required)` to `(Optional)`
- Standardized variable block ordering (`description` → `type` → `default` → `validation`)
- Added native Terraform tests (5 test cases)

### `oci/budget` — Validation & flexibility improvements ✅ (PR #28)

- Made alert rule conditional via new `create_alert_rule` variable (default `true`)
- Added integer validation to `budget_amount`
- Fixed `budget_targets` annotation from `(Optional)` to `(Required)`
- Added 1–28 range note to `budget_alert_rule_threshold_reset_period_start_offset` description
- Documented null return on outputs when `create_alert_rule = false`
- Fixed README usage example to match actual variable names
- Added native Terraform tests (17+ test cases covering all validation blocks)

### `oci/oci_profile_reader` — Robustness & security ✅ (PR #28)

- Added `profile_name` non-empty and whitespace validation
- Added `precondition` on output for missing profiles with helpful error listing available profiles
- Filtered sensitive fields (`key_file`, `fingerprint`, `passphrase`) from output
- Hardened INI parser: `trimspace` for `\r\n`, spaces around `=`, whitespace-only line filter, `can()` guard
- Used `lookup()` to prevent index panic before precondition fires
- Added native Terraform tests (3 test cases)

### All modules — Version & style standardization ✅ (PR #28)

- Standardized Terraform version constraint to `>= 1.6.4` across all modules
- Standardized OCI provider version constraint to `>= 6.0` across all modules
- Aligned example provider versions to `~> 6.0`
- Standardized variable block ordering (`description` → `type` → `default` → `validation`) across all modules

### CI & Pre-commit ✅ (PR #28)

- Fixed tflint install in CI (`unzip` instead of `gunzip` hack)
- Pinned Python to stable `3.13` instead of pre-release `3.14`
- Removed commented-out code from CI workflow and pre-commit config
- Pinned tool versions in pre-commit hooks, added `set -euo pipefail` and `curl --fail`
- Added `terraform-tests.yml` workflow with dynamic module discovery
- Added comment explaining disabled `terraform_module_pinned_source` rule

---

## New Modules (20 total)

### Terraform Skill Usage

**Invoke `/terraform-skill` at the start of every module creation or update task.** The skill is installed at `.claude/skills/terraform-skill/` (submodule: `antonbabenko/terraform-skill`) and provides authoritative guidance on:

- Resource block ordering: `count`/`for_each` first, then arguments, `tags` last, then `depends_on`, then `lifecycle`
- Variable block ordering: `description` → `type` → `default` → `validation` → `nullable`
- `count = condition ? 1 : 0` for boolean conditionals; `for_each` for stable addressing of multiple resources
- Use `try()` locals for dependency management (e.g., VCN secondary CIDR ordering)
- `sensitive = true` on password/secret variables and outputs
- `description` required on all variables and outputs
- Detailed guides in `.claude/skills/terraform-skill/references/` (module-patterns.md, code-patterns.md, security-compliance.md)

### Conventions (from existing modules + terraform skill)

- File structure: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `README.md`, `tests/<module>.tftest.hcl`
- Provider block: `terraform >= 1.6.4`, `oci >= 6.0`
- Resource naming: `"this"` for singleton resources only; descriptive names for multiples
- Tag variables: `<prefix>_defined_tags` + `<prefix>_freeform_tags` (both `map(string)`, default `{}`)
- OCID validation regex: `^ocid1\.[a-z]+\.[a-z][a-z0-9-]*\.[a-z0-9-]*\.[a-z0-9]+$`
- Variable block ordering: `description` → `type` → `default` → `validation` → `nullable` (enforced in PR #28)
- Variable descriptions: `(Required)`, `(Optional)`, `(Updatable)` annotations
- README: manual usage example + terraform-docs markers
- Tests: native Terraform test files in `tests/` directory, covering defaults, custom inputs, and validation rejection

---

### Phase 1 — Foundation

#### 1. `oci/vcn`

VCN with internet gateway, NAT gateway, optional service gateway, route tables, and security list.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_vcn` | no | `this` |
| `oci_core_internet_gateway` | `create_internet_gateway` | `this` |
| `oci_core_nat_gateway` | `create_nat_gateway` | `this` |
| `oci_core_service_gateway` | `create_service_gateway` | `this` |
| `oci_core_route_table` | `create_internet_gateway` | `public` |
| `oci_core_route_table` | `create_nat_gateway` | `private` |
| `oci_core_security_list` | no | `this` |

**Data sources:** `data.oci_core_services` — needed for service gateway `services` block (filter: "All .* Services In Oracle Services Network")

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

#### 2. `oci/subnet`

Individual subnet within a VCN.

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
| `availability_domain` | `string` | No | `null` | Null = regional subnet (recommended) |
| `subnet_defined_tags` | `map(string)` | No | `{}` | — |
| `subnet_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `subnet_id`, `subnet_cidr_block`

**Test scenarios:**
1. Default — public regional subnet
2. Private subnet — `prohibit_internet_ingress = true`
3. With route table and security list IDs
4. OCID validation rejection
5. DNS label validation rejection

#### 3. `oci/compute`

Compute instance supporting AMD Micro and Arm A1 Flex shapes.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_instance` | no | `this` |

**Data sources:** `data.oci_identity_availability_domains` — dynamic AD lookup

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
| `user_data` | `string` | No | `null` | Base64-encoded cloud-init |
| `boot_volume_size_in_gbs` | `number` | No | `50` | 50-200 |
| `instance_display_name` | `string` | No | `"instance"` | — |
| `nsg_ids` | `list(string)` | No | `[]` | — |
| `compute_defined_tags` | `map(string)` | No | `{}` | — |
| `compute_freeform_tags` | `map(string)` | No | `{}` | — |

**Design:**
- `dynamic "shape_config"` block renders only when `shape` contains "Flex"
- Uses `source_details` block (not deprecated `image` argument): `source_type = "image"`, `source_id = var.image_id`, `boot_volume_size_in_gbs`
- Uses `create_vnic_details` block: `subnet_id`, `assign_public_ip`, `nsg_ids`
- `metadata` block includes `ssh_authorized_keys` and `user_data`
- AD looked up via `data.oci_identity_availability_domains` using `availability_domain_number`

**Outputs:** `instance_id`, `instance_public_ip`, `instance_private_ip`, `instance_state`, `availability_domain`

**Free tier warning (README):** Instances with <20% average CPU and network utilization over 7 days may be reclaimed by Oracle. For A1 Flex, memory utilization is also checked.

**Aggregate storage warning:** Boot volumes count toward the 200GB free tier block storage limit. There is no cross-module enforcement — users must manually track total boot + block volume consumption.

**Test scenarios:**
1. AMD Micro default — no shape_config block rendered
2. A1 Flex — shape_config with ocpus + memory
3. Shape validation — reject invalid shape names
4. Boot volume range — reject < 50 or > 200
5. OCID validation rejection

#### 4. `oci/block_volume`

Block volume with optional instance attachment.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_volume` | no | `this` |
| `oci_core_volume_attachment` | `instance_id != null` | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | — | OCID regex |
| `availability_domain` | `string` | Yes | — | Must match instance AD |
| `volume_display_name` | `string` | No | `"block-volume"` | — |
| `volume_size_in_gbs` | `number` | No | `50` | 50-200 |
| `vpus_per_gb` | `number` | No | `10` | `>= 0 && <= 120 && value % 10 == 0` (values above 20 are Ultra High Performance and may incur charges) |
| `instance_id` | `string` | No | `null` | OCID regex or null |
| `attachment_type` | `string` | No | `"paravirtualized"` | `contains(["iscsi", "paravirtualized"], ...)` |
| `is_read_only` | `bool` | No | `false` | — |
| `volume_defined_tags` | `map(string)` | No | `{}` | — |
| `volume_freeform_tags` | `map(string)` | No | `{}` | — |

**Outputs:** `volume_id`, `volume_attachment_id`

**Critical:** Default `volume_size_in_gbs = 50` — NOT the provider default of 1 TB. Free tier total block storage is 200GB including boot volumes.

**Aggregate storage warning:** There is no cross-module enforcement of the 200GB aggregate free tier limit. Users must manually track total boot volume + block volume consumption across all instances.

**Test scenarios:**
1. Default — 50GB volume, no attachment
2. With attachment — paravirtualized
3. Size validation — reject > 200, reject < 50
4. VPUs validation — reject invalid values
5. OCID validation rejection

#### 5. `oci/object_storage`

Object Storage bucket.

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

**Important:** `storage_tier` is **immutable after creation** — changing it requires destroying and recreating the bucket.

**Test scenarios:**
1. Default — Standard tier, no public access, no versioning
2. Public read access
3. Archive tier
4. Versioning enabled
5. Bucket name validation — reject invalid characters
6. OCID validation rejection

---

### Phase 2 — Databases + Notifications

#### 6. `oci/autonomous_database`

Always Free Autonomous Database (ATP/ADW/AJD/APEX).

| Resource | Conditional |
|----------|------------|
| `oci_database_autonomous_database.this` | no |

**Key variables:** `compartment_id`, `db_name` (max 14 chars, validated), `db_workload` ("OLTP"/"DW"/"AJD"/"APEX"), `is_free_tier` (default true), `compute_model` ("ECPU"), `compute_count` (verify minimum at implementation — provider docs suggest min 2 for non-elastic-pool; free tier may accept 1), `data_storage_size_in_gb` (validated <= 20), `admin_password` (sensitive), `db_version`, `whitelisted_ips`, `is_mtls_connection_required` (set explicitly to `false` to allow TLS connections; verify provider default at implementation time)

**Free tier constraints:**

| Feature | Limitation |
|---------|-----------|
| ECPU | Fixed at 1, cannot scale |
| Storage | Fixed at 20GB, cannot scale |
| Auto-scaling | Not available |
| Private endpoints | Not available (`subnet_id`, `nsg_ids` cannot be used) |
| Data Guard | Not available |
| Manual/long-term backups | Not available |
| Inactivity | Auto-stops after 7 days idle |
| Reclamation | Permanently deleted after 90 days stopped |
| Max sessions | 30 concurrent |

**Outputs:** `autonomous_database_id`, `connection_strings`, `connection_urls`, `db_name`

#### 7. `oci/nosql`

NoSQL table with indexes.

| Resource | Conditional |
|----------|------------|
| `oci_nosql_table.this` | no |
| `oci_nosql_index.this` | `for_each` on index map |

**Key variables:** `compartment_id`, `table_name`, `ddl_statement`, `table_limits_max_read_units` (default 50), `table_limits_max_write_units` (default 50), `table_limits_max_storage_in_gbs` (1-25), `indexes` (map)

**Note:** `table_limits` block is marked optional in the provider schema but is **required for top-level tables**. `ddl_statement` updates must preserve column order.

**Outputs:** `table_id`, `table_name`

#### 8. `oci/mysql`

MySQL HeatWave standalone system.

| Resource | Conditional |
|----------|------------|
| `oci_mysql_mysql_db_system.this` | no |

**Data sources:** `data.oci_identity_availability_domains`, `data.oci_mysql_shapes` (discover free tier shape)

**Key variables:** `compartment_id`, `subnet_id` (required — MySQL needs private subnet), `availability_domain`, `shape_name` (validated against `data.oci_mysql_shapes`), `admin_username`, `admin_password` (sensitive), `data_storage_size_in_gb` (validated <= 50), `backup_is_enabled`, `is_highly_available` (false for free), `deletion_policy` (default `is_delete_protected = true`), `backup_policy` nested block

**Notes:**
- Home region only for Always Free
- Shape name varies by region — use `data.oci_mysql_shapes` to discover
- Includes `deletion_policy { is_delete_protected = true }` by default

**Outputs:** `mysql_db_system_id`, `mysql_ip_address`, `mysql_port`

#### 9. `oci/notifications`

Notification topics and subscriptions.

| Resource | Conditional |
|----------|------------|
| `oci_ons_notification_topic.this` | no |
| `oci_ons_subscription.this` | `for_each` on subscriptions |

**Key variables:** `compartment_id`, `topic_name`, `topic_description`, `subscriptions` (map of `{ protocol, endpoint }`)

**Important:** Topic `name` must be unique across the **entire tenancy**, not just the compartment.

**Outputs:** `topic_id`, `subscription_ids`

---

### Phase 3 — Networking Extras + Security + Bastion

#### 10. `oci/load_balancer`

Flexible Load Balancer with backend set, listener, and optional backends.

| Resource | Conditional |
|----------|------------|
| `oci_load_balancer_load_balancer.this` | no |
| `oci_load_balancer_backend_set.this` | no |
| `oci_load_balancer_listener.this` | no |
| `oci_load_balancer_backend.this` | `for_each` on backends map |

**Key variables:** `compartment_id`, `lb_display_name`, `subnet_ids`, `is_private`, `backend_set_name`, `backend_set_policy`, `health_check_*`, `listener_name`, `listener_port`, `listener_protocol`, `backends` (map of `{ ip_address, port }`)

**Design:** Shape is hardcoded to `"flexible"` with `shape_details` block (`minimum_bandwidth_in_mbps = 10`, `maximum_bandwidth_in_mbps = 10`) to enforce free tier.

**Outputs:** `load_balancer_id`, `load_balancer_ip_addresses`

#### 11. `oci/network_load_balancer`

Network Load Balancer with backend set, listener, and optional backends.

| Resource | Conditional |
|----------|------------|
| `oci_network_load_balancer_network_load_balancer.this` | no |
| `oci_network_load_balancer_backend_set.this` | no |
| `oci_network_load_balancer_listener.this` | no |
| `oci_network_load_balancer_backend.this` | `for_each` on backends map |

**Key variables:** `compartment_id`, `nlb_display_name`, `subnet_id` (singular — NLB uses one subnet, not a list), `is_private`, `backend_set_name`, `backend_set_policy`, `health_check_*`, `listener_name`, `listener_port`, `listener_protocol`, `backends` (map)

**Outputs:** `network_load_balancer_id`, `nlb_ip_addresses`

#### 12. `oci/vault`

KMS Vault with optional software key.

| Resource | Conditional |
|----------|------------|
| `oci_kms_vault.this` | no |
| `oci_kms_key.this` | `create_key` |

**Key variables:** `compartment_id`, `vault_display_name`, `vault_type` ("DEFAULT"), `create_key` (default true), `key_display_name`, `key_algorithm`, `key_length`, `key_protection_mode` ("SOFTWARE"/"HSM")

**Design notes:**
- `management_endpoint` on `oci_kms_key` must reference `oci_kms_vault.this.management_endpoint`
- `vault_type` is **immutable** after creation — use `DEFAULT` for free tier
- Auto-rotation is only available for `VIRTUAL_PRIVATE` vaults (not free tier)
- Use `protection_mode = "SOFTWARE"` for unlimited free key versions

**Outputs:** `vault_id`, `vault_crypto_endpoint`, `vault_management_endpoint`, `key_id`

#### 13. `oci/certificates`

Certificate Authority and certificates.

| Resource | Conditional |
|----------|------------|
| `oci_certificates_management_certificate_authority.this` | no |
| `oci_certificates_management_certificate.this` | `create_certificate` |

**Key variables:** `compartment_id`, `ca_name`, `certificate_authority_config` (nested: `config_type`, `subject.common_name`, `signing_algorithm`, `validity`), `create_certificate` (bool), `certificate_config` (nested: `config_type`, `issuer_certificate_authority_id`, `certificate_profile_type`, `subject.common_name`, `key_algorithm`, `validity`)

**Note:** Both `certificate_authority_config` and `certificate_config` are deeply nested blocks — implementation must use `dynamic` blocks or require structured objects.

**Outputs:** `certificate_authority_id`, `certificate_id`

#### 14. `oci/bastion`

Bastion service for secure access.

| Resource | Conditional |
|----------|------------|
| `oci_bastion_bastion.this` | no |

**Key variables:** `compartment_id`, `bastion_name`, `bastion_type` (validated "STANDARD" — verify enum casing against provider docs at implementation time), `target_subnet_id`, `client_cidr_block_allow_list`, `max_session_ttl_in_seconds`

**Note:** Bastion must be in a **public subnet** with gateway and route rules configured.

**Outputs:** `bastion_id`, `bastion_name`

---

### Phase 4 — Observability + VPN

#### 15. `oci/monitoring`

Monitoring alarms.

| Resource | Conditional |
|----------|------------|
| `oci_monitoring_alarm.this` | no |

**Key variables (all 8 required):** `compartment_id`, `alarm_display_name`, `metric_compartment_id`, `alarm_namespace`, `alarm_query` (MQL expression), `alarm_severity`, `alarm_is_enabled`, `destinations` (list of topic OCIDs)

**Note:** This resource has 8 required arguments — more complex than most OCI resources. `query` must be valid MQL with metric, statistic, interval, and trigger rule.

**Outputs:** `alarm_id`, `alarm_state`

#### 16. `oci/email_delivery`

Email domain, sender, and DKIM authentication.

| Resource | Conditional |
|----------|------------|
| `oci_email_email_domain.this` | no |
| `oci_email_sender.this` | no |
| `oci_email_dkim.this` | `create_dkim` |

**Key variables:** `compartment_id`, `email_domain_name`, `sender_email_address` (email regex), `create_dkim` (default true), `dkim_name`

**Outputs:** `email_domain_id`, `sender_id`, `dkim_id`, `dkim_cname_record_value`

#### 17. `oci/logging`

Log groups and logs.

| Resource | Conditional |
|----------|------------|
| `oci_logging_log_group.this` | no |
| `oci_logging_log.this` | `for_each` on logs |

**Key variables:** `compartment_id`, `log_group_display_name`, `logs` (map of log configs with `log_type`, `source_service`, `source_resource`, `source_category`), `is_enabled`, `retention_duration` (30-180, 30-day increments)

**Note:** `configuration` block is marked optional in the provider but is **required for SERVICE logs** (the most common type). Three log types: Audit (read-only), Service, Custom.

**Outputs:** `log_group_id`, `log_ids`

#### 18. `oci/apm`

APM Domain.

| Resource | Conditional |
|----------|------------|
| `oci_apm_apm_domain.this` | no |

**Key variables:** `compartment_id`, `apm_display_name`, `apm_description`, `is_free_tier` (default true)

**Outputs:** `apm_domain_id`, `data_upload_endpoint`

#### 19. `oci/connector_hub`

Service Connector (moves data between OCI services).

| Resource | Conditional |
|----------|------------|
| `oci_sch_service_connector.this` | no |

**Key variables:** `compartment_id`, `connector_display_name`, `source_kind` (`logging`/`monitoring`/`streaming`), `target_kind` (`objectStorage`/`notifications`/`streaming`/`monitoring`/`functions`/`loggingAnalytics`), plus kind-specific source/target config variables

**Design notes:**
- Complex due to conditional source/target configs — uses extensive `dynamic` blocks
- Source and target arguments are conditional on `kind`
- IAM policies must be created for the connector to access source and target resources
- Connectors auto-deactivate after 7+ days of continuous failures

**Outputs:** `service_connector_id`, `connector_state`

#### 20. `oci/vpn`

Site-to-Site VPN with DRG, CPE, and IPSec connection.

| Resource | Conditional |
|----------|------------|
| `oci_core_drg.this` | no |
| `oci_core_drg_attachment.this` | `vcn_id != null` |
| `oci_core_cpe.this` | no |
| `oci_core_ipsec.this` | no |

**Key variables:** `compartment_id`, `drg_display_name`, `vcn_id` (optional — for DRG attachment), `cpe_ip_address` (IP regex), `cpe_display_name`, `ipsec_display_name`, `static_routes` (list of CIDRs)

**Note:** The original plan referenced a `drg_id` input but `oci_core_ipsec` requires a DRG — this module now **creates its own DRG** and optionally attaches it to a VCN.

**Outputs:** `drg_id`, `cpe_id`, `ipsec_connection_id`

---

## Module Dependency Graph

```
oci_profile_reader --> identity (compartment)
                          |
         +-------+-------+--------+--------+--------+
         |       |       |        |        |        |
       budget   vcn   obj_stor  vault  certs    apm
                 |               nosql  email  notifs ──┬──────────┐
                 |                                      │          │
              subnet                              monitoring   logging
                 |                                      │          │
    +-----+------+------+------+------+                 └──┬───────┘
    |     |      |      |      |      |                    │
 compute  LB    NLB   mysql  bastion  vpn            connector_hub
    |                  (DRG)
 block_vol
```

> **Note:** All modules depend on `identity` for `compartment_id`. The graph shows only structural/data dependencies beyond this universal input.

---

## New Examples

| Example | Modules Used |
|---------|-------------|
| `examples/free-tier-compute-stack` | oci_profile_reader, identity, vcn, subnet (x2), compute (AMD Micro), bastion |
| `examples/free-tier-arm-server` | oci_profile_reader, identity, vcn, subnet, compute (A1 Flex), block_volume |
| `examples/free-tier-web-app` | oci_profile_reader, identity, vcn, subnet, compute (x2), load_balancer, autonomous_database, object_storage |
| `examples/free-tier-databases` | oci_profile_reader, identity, vcn, subnet, autonomous_database, mysql, nosql |
| `examples/free-tier-observability` | oci_profile_reader, identity, notifications, monitoring, logging, apm, connector_hub |
| `examples/free-tier-security` | oci_profile_reader, identity, vault, certificates |

---

## Implementation Sequence

> **Before starting any module:** invoke `/terraform-skill` skill to load authoritative conventions. Apply resource block ordering, variable ordering, count/for_each guidance, and security patterns from that skill throughout.

> **Use sub-agents for parallel implementation.** Modules within the same phase that have no dependencies on each other should be implemented concurrently using sub-agents (e.g., `oci/vcn` and `oci/object_storage` in Phase 1 can be built in parallel). Each sub-agent should receive the full module spec from this plan, the conventions section, and a pointer to a gold-standard module (`oci/budget`) as reference. Use the `/superpowers:dispatching-parallel-agents` or `/superpowers:subagent-driven-development` skill to coordinate.

### Phase 1 — Foundation

1. ~~Fix `oci/identity` validation~~ ✅ Done in PR #28 (also fixed budget, oci_profile_reader, CI, and added tests for all 3 existing modules)
2. `oci/vcn` → `feat(vcn): add VCN module with internet, NAT, and service gateways`
3. `oci/subnet` → `feat(subnet): add subnet module`
4. `oci/compute` → `feat(compute): add compute module for AMD Micro and Ampere A1 Flex`
5. `oci/block_volume` → `feat(block_volume): add block volume module with optional attachment`
6. `oci/object_storage` → `feat(object_storage): add object storage bucket module`
7. `examples/free-tier-compute-stack` → `feat(examples): add free-tier-compute-stack example`

### Phase 2 — Databases + Notifications

1. `oci/autonomous_database` → `feat(autonomous_database): add Always Free autonomous database module`
2. `oci/nosql` → `feat(nosql): add NoSQL table module with index support`
3. `oci/mysql` → `feat(mysql): add MySQL HeatWave standalone module`
4. `oci/notifications` → `feat(notifications): add notification topic and subscription module`
5. `examples/free-tier-databases` → `feat(examples): add free-tier-databases example`

### Phase 3 — Networking Extras + Security + Bastion

1. `oci/load_balancer` → `feat(load_balancer): add flexible load balancer module`
2. `oci/network_load_balancer` → `feat(network_load_balancer): add network load balancer module`
3. `oci/vault` → `feat(vault): add KMS vault and key module`
4. `oci/certificates` → `feat(certificates): add certificate authority and certificate module`
5. `oci/bastion` → `feat(bastion): add bastion service module`
6. `examples/free-tier-web-app` + `examples/free-tier-security` → examples

### Phase 4 — Observability + VPN

1. `oci/monitoring` → `feat(monitoring): add monitoring alarm module`
2. `oci/email_delivery` → `feat(email_delivery): add email domain, sender, and DKIM module`
3. `oci/logging` → `feat(logging): add log group and log module`
4. `oci/apm` → `feat(apm): add APM domain module`
5. `oci/connector_hub` → `feat(connector_hub): add service connector module`
6. `oci/vpn` → `feat(vpn): add site-to-site VPN module with DRG`
7. `examples/free-tier-observability` + `examples/free-tier-arm-server` → examples

---

## Verification

For each module:

1. `cd oci/<module> && terraform init && terraform validate`
2. `cd oci/<module> && terraform test` (native Terraform tests in `tests/` directory)
3. `terraform fmt -check`
4. `pre-commit run --all-files` from repo root
5. Verify README auto-generates correctly between terraform-docs markers
6. CI runs automatically via `terraform-tests.yml` workflow (dynamic module discovery, added in PR #28)

---

## Summary

| Metric | Count |
|--------|-------|
| Existing modules improved | 3 of 3 ✅ (identity, budget, oci_profile_reader — PR #28) |
| CI/testing infrastructure | ✅ Added terraform-tests workflow + tests for all existing modules (PR #28) |
| New modules to create | 20 |
| Services excluded | 6 |
| New examples to create | 6 |
| Total Terraform resources across new modules | ~35 |
| Estimated total variables across new modules | ~180 |

---

## Key Reference Files

- `oci/budget/variables.tf` — Gold standard for validation patterns (improved in PR #28)
- `oci/budget/main.tf` — Gold standard for resource structure (conditional alert rule added in PR #28)
- `oci/budget/providers.tf` — Provider boilerplate to copy
- `oci/budget/tests/budget.tftest.hcl` — Gold standard for test patterns (17+ test cases)
- `oci/identity/variables.tf` — ~~Needs validation fix~~ ✅ Fixed in PR #28
- `oci/oci_profile_reader/main.tf` — Reference for robust INI parsing and sensitive field filtering
- `.github/workflows/terraform-tests.yml` — CI test workflow with dynamic module discovery
