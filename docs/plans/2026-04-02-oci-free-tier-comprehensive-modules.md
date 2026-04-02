# OCI Always Free Tier — Comprehensive Terraform Modules Plan

**Date:** 2026-04-02
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
| Compute (Arm Ampere A1) | 4 OCPUs + 24GB RAM total (flexible) |
| Block Volume | 200GB total, 5 backups |
| Object Storage | 20GB, 50K API requests/month |
| Vault/KMS | Unlimited software keys, 20 HSM key versions, 150 secrets |
| Resource Manager | 100 stacks, 2 concurrent jobs |

### Database

| Service | Free Allocation |
|---------|----------------|
| Autonomous Database | 2 instances, 1 OCPU, 20GB each |
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
| Email Delivery | 3K emails/month |
| APM | 1K tracing events, 10 synthetic runs/hour |
| Connector Hub | 2 connectors |
| Logging | 10GB/month |
| Bastion | Free for all accounts |
| Console Dashboards | 100 dashboards |
| Fleet Application Management | 25 operations/month |

### Other

| Service | Free Allocation |
|---------|----------------|
| Outbound Data Transfer | 10TB/month |

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

## Improvements to Existing Modules

### `oci/identity` — Add input validation

- **File:** `oci/identity/variables.tf`
- Add OCID regex validation to `oci_root_compartment` (line 31-34) matching the pattern from `oci/budget/variables.tf`
- Add character validation to `compartment_name` (alphanumeric, dots, underscores, dashes)
- Commit: `fix(identity): add OCID and name validation to variables`

---

## New Modules (17 total)

### Terraform Skill Usage

**Invoke `/terraform` at the start of every module creation or update task.** The skill is installed at `.claude/skills/terraform/` (submodule: `antonbabenko/terraform-skill`) and provides authoritative guidance on:

- Resource block ordering: `count`/`for_each` first, then arguments, `tags` last, then `depends_on`, then `lifecycle`
- Variable block ordering: `description` → `type` → `default` → `validation` → `nullable`
- `count = condition ? 1 : 0` for boolean conditionals; `for_each` for stable addressing of multiple resources
- Use `try()` locals for dependency management (e.g., VCN secondary CIDR ordering)
- `sensitive = true` on password/secret variables and outputs
- `description` required on all variables and outputs
- Detailed guides in `.claude/skills/terraform/references/` (module-patterns.md, code-patterns.md, security-compliance.md)

### Conventions (from existing modules + terraform skill)

- File structure: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `README.md`
- Provider block: `terraform >= 1.6.4`, `oci >= 6.0`
- Resource naming: `"this"` for singleton resources only; descriptive names for multiples
- Tag variables: `<prefix>_defined_tags` + `<prefix>_freeform_tags` (both `map(string)`, default `{}`)
- OCID validation regex: `^ocid1\.[a-z]+\.[a-z][a-z0-9-]*\.[a-z0-9-]*\.[a-z0-9]+$`
- Variable descriptions: `(Required)`, `(Optional)`, `(Updatable)` annotations
- README: manual usage example + terraform-docs markers

---

### P0 — Core Infrastructure

#### 1. `oci/vcn`

VCN with internet gateway, NAT gateway, route table, and security list.

| Resource | Conditional |
|----------|------------|
| `oci_core_vcn.this` | no |
| `oci_core_internet_gateway.this` | `create_internet_gateway` |
| `oci_core_nat_gateway.this` | `create_nat_gateway` |
| `oci_core_route_table.public` | `create_internet_gateway` |
| `oci_core_security_list.this` | no |

**Key variables:** `compartment_id`, `vcn_display_name`, `vcn_cidr_blocks` (default `["10.0.0.0/16"]`), `vcn_dns_label` (validated `^[a-z][a-z0-9]{0,14}$`), `create_internet_gateway` (default true), `create_nat_gateway` (default false)

**Outputs:** `vcn_id`, `vcn_cidr_blocks`, `internet_gateway_id`, `nat_gateway_id`, `default_security_list_id`, `default_route_table_id`

#### 2. `oci/subnet`

Individual subnet within a VCN.

| Resource | Conditional |
|----------|------------|
| `oci_core_subnet.this` | no |

**Key variables:** `compartment_id`, `vcn_id`, `subnet_cidr_block` (required), `subnet_display_name`, `subnet_dns_label`, `prohibit_public_ip_on_vnic` (bool), `route_table_id`, `security_list_ids`, `availability_domain`

**Outputs:** `subnet_id`, `subnet_cidr_block`

#### 3. `oci/compute`

Compute instance supporting AMD Micro and Arm A1 Flex shapes.

| Resource | Conditional |
|----------|------------|
| `oci_core_instance.this` | no |

**Key variables:** `compartment_id`, `availability_domain`, `shape` (default `"VM.Standard.E2.1.Micro"`, validated), `shape_ocpus` (for Flex), `shape_memory_in_gbs` (for Flex), `subnet_id`, `image_id`, `ssh_authorized_keys`, `assign_public_ip`, `boot_volume_size_in_gbs` (47-200)

**Design:** `dynamic "shape_config"` block renders only for Flex shapes

**Outputs:** `instance_id`, `instance_public_ip`, `instance_private_ip`, `instance_state`

#### 4. `oci/block_volume`

Block volume with optional instance attachment.

| Resource | Conditional |
|----------|------------|
| `oci_core_volume.this` | no |
| `oci_core_volume_attachment.this` | `attach_to_instance_id != null` |

**Key variables:** `compartment_id`, `availability_domain`, `volume_size_in_gbs` (50-200), `vpus_per_gb`, `attach_to_instance_id`, `attachment_type`

**Outputs:** `volume_id`, `volume_attachment_id`

#### 5. `oci/object_storage`

Object Storage bucket.

| Resource | Conditional |
|----------|------------|
| `oci_objectstorage_bucket.this` | no |
| `data.oci_objectstorage_namespace.this` | no |

**Key variables:** `compartment_id`, `bucket_name` (validated), `bucket_access_type`, `storage_tier`, `versioning`, `auto_tiering`

**Outputs:** `bucket_name`, `bucket_namespace`, `bucket_id`

---

### P1 — Databases

#### 6. `oci/autonomous_database`

Always Free Autonomous Database (ATP/ADW/AJD/APEX).

| Resource | Conditional |
|----------|------------|
| `oci_database_autonomous_database.this` | no |

**Key variables:** `compartment_id`, `db_name` (max 14 chars, validated), `db_workload` ("OLTP"/"DW"/"AJD"/"APEX"), `is_free_tier` (default true), `cpu_core_count` (validated == 1), `data_storage_size_in_tbs` (validated <= 0.02), `admin_password` (sensitive), `db_version`, `whitelisted_ips`, `subnet_id`, `nsg_ids`

**Outputs:** `autonomous_database_id`, `connection_strings`, `connection_urls`, `db_name`

#### 7. `oci/nosql`

NoSQL table with indexes.

| Resource | Conditional |
|----------|------------|
| `oci_nosql_table.this` | no |
| `oci_nosql_index.this` | `for_each` on index map |

**Key variables:** `compartment_id`, `table_name`, `ddl_statement`, `table_limits_max_read_units` (default 50), `table_limits_max_write_units` (default 50), `table_limits_max_storage_in_gbs` (1-25), `indexes` (map)

**Outputs:** `table_id`, `table_name`

#### 8. `oci/mysql`

MySQL HeatWave standalone system.

| Resource | Conditional |
|----------|------------|
| `oci_mysql_mysql_db_system.this` | no |

**Key variables:** `compartment_id`, `subnet_id` (required — MySQL needs private subnet), `availability_domain`, `shape_name` (validated "MySQL.Free"), `admin_username`, `admin_password` (sensitive), `data_storage_size_in_gb` (validated <= 50), `backup_is_enabled`, `is_highly_available` (false for free)

**Outputs:** `mysql_db_system_id`, `mysql_ip_address`, `mysql_port`

---

### P2 — Networking Extras & Security

#### 9. `oci/load_balancer`

Flexible Load Balancer with backend set and listener.

| Resource | Conditional |
|----------|------------|
| `oci_load_balancer_load_balancer.this` | no |
| `oci_load_balancer_backend_set.this` | no |
| `oci_load_balancer_listener.this` | no |

**Key variables:** `compartment_id`, `lb_display_name`, `lb_min_bandwidth_in_mbps` (validated == 10), `lb_max_bandwidth_in_mbps` (validated == 10), `subnet_ids`, `is_private`, `backend_set_name`, `backend_set_policy`, `health_check_*`, `listener_name`, `listener_port`, `listener_protocol`

**Outputs:** `load_balancer_id`, `load_balancer_ip_addresses`

#### 10. `oci/network_load_balancer`

Network Load Balancer with backend set and listener.

| Resource | Conditional |
|----------|------------|
| `oci_network_load_balancer_network_load_balancer.this` | no |
| `oci_network_load_balancer_backend_set.this` | no |
| `oci_network_load_balancer_listener.this` | no |

**Key variables:** `compartment_id`, `nlb_display_name`, `subnet_id`, `is_private`, `backend_set_name`, `backend_set_policy`, `health_check_*`, `listener_name`, `listener_port`, `listener_protocol`

**Outputs:** `network_load_balancer_id`, `nlb_ip_addresses`

#### 11. `oci/vault`

KMS Vault with optional software key.

| Resource | Conditional |
|----------|------------|
| `oci_kms_vault.this` | no |
| `oci_kms_key.this` | `create_key` |

**Key variables:** `compartment_id`, `vault_display_name`, `vault_type` ("DEFAULT"), `create_key` (default true), `key_display_name`, `key_algorithm`, `key_length`, `key_protection_mode` ("SOFTWARE"/"HSM")

**Outputs:** `vault_id`, `vault_crypto_endpoint`, `vault_management_endpoint`, `key_id`

#### 12. `oci/certificates`

Certificate Authority and certificates.

| Resource | Conditional |
|----------|------------|
| `oci_certificates_management_certificate_authority.this` | no |
| `oci_certificates_management_certificate.this` | `create_certificate` |

**Key variables:** `compartment_id`, `ca_name`, `ca_type`, `key_algorithm`, `signing_algorithm`, `subject_common_name`, `validity_in_days`, `create_certificate` (bool), `cert_name`

**Outputs:** `certificate_authority_id`, `certificate_id`

#### 13. `oci/bastion`

Bastion service for secure access.

| Resource | Conditional |
|----------|------------|
| `oci_bastion_bastion.this` | no |

**Key variables:** `compartment_id`, `bastion_name`, `bastion_type` (validated "STANDARD"), `target_subnet_id`, `client_cidr_block_allow_list`, `max_session_ttl_in_seconds`

**Outputs:** `bastion_id`, `bastion_name`

#### 14. `oci/vpn`

Site-to-Site VPN with CPE.

| Resource | Conditional |
|----------|------------|
| `oci_core_cpe.this` | no |
| `oci_core_ipsec.this` | no |

**Key variables:** `compartment_id`, `cpe_ip_address` (IP regex), `cpe_display_name`, `drg_id` (required), `ipsec_display_name`, `static_routes` (list of CIDRs)

**Note:** Requires a DRG — consider adding optional `create_drg` to `oci/vcn`

**Outputs:** `cpe_id`, `ipsec_connection_id`

---

### P3 — Observability & Management

#### 15. `oci/notifications`

Notification topics and subscriptions.

| Resource | Conditional |
|----------|------------|
| `oci_ons_notification_topic.this` | no |
| `oci_ons_subscription.this` | `for_each` on subscriptions |

**Key variables:** `compartment_id`, `topic_name`, `topic_description`, `subscriptions` (map of `{ protocol, endpoint }`)

**Outputs:** `topic_id`, `subscription_ids`

#### 16. `oci/monitoring`

Monitoring alarms.

| Resource | Conditional |
|----------|------------|
| `oci_monitoring_alarm.this` | no |

**Key variables:** `compartment_id`, `alarm_display_name`, `alarm_namespace`, `alarm_query`, `alarm_severity`, `alarm_is_enabled`, `destinations` (list of topic OCIDs)

**Outputs:** `alarm_id`, `alarm_state`

#### 17. `oci/email_delivery`

Email sender.

| Resource | Conditional |
|----------|------------|
| `oci_email_sender.this` | no |

**Key variables:** `compartment_id`, `sender_email_address` (email regex)

**Outputs:** `sender_id`, `sender_email_address`

#### 18. `oci/logging`

Log groups and logs.

| Resource | Conditional |
|----------|------------|
| `oci_logging_log_group.this` | no |
| `oci_logging_log.this` | `for_each` on logs |

**Key variables:** `compartment_id`, `log_group_display_name`, `logs` (map of log configs), `is_enabled`, `retention_duration`

**Outputs:** `log_group_id`, `log_ids`

#### 19. `oci/apm`

APM Domain.

| Resource | Conditional |
|----------|------------|
| `oci_apm_apm_domain.this` | no |

**Key variables:** `compartment_id`, `apm_display_name`, `apm_description`, `is_free_tier` (default true)

**Outputs:** `apm_domain_id`, `data_upload_endpoint`

#### 20. `oci/connector_hub`

Service Connector (moves data between OCI services).

| Resource | Conditional |
|----------|------------|
| `oci_sch_service_connector.this` | no |

**Key variables:** `compartment_id`, `connector_display_name`, `source_kind`, `source_log_group_id`, `target_kind`, `target_bucket_name`/`target_topic_id`

**Note:** Complex due to variable source/target configs; uses extensive `dynamic` blocks

**Outputs:** `service_connector_id`, `connector_state`

---

## Module Dependency Graph

```
oci_profile_reader --> identity (compartment)
                          |
         +-------+-------+--------+--------+--------+
         |       |       |        |        |        |
       budget   vcn   obj_stor  vault  certs    apm
                 |               nosql  email  notifs
                 |                              |
              subnet                        monitoring
                 |
    +-----+------+------+------+------+
    |     |      |      |      |      |
 compute  LB    NLB   mysql  bastion  vpn
    |
 block_vol
```

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

> **Before starting any module:** invoke `/terraform` skill to load authoritative conventions. Apply resource block ordering, variable ordering, count/for_each guidance, and security patterns from that skill throughout.

### Phase 1 — Core Infrastructure (P0)

1. Fix `oci/identity` validation → `fix(identity): add OCID and name validation`
2. `oci/vcn` → `feat(vcn): add VCN module with internet and NAT gateways`
3. `oci/subnet` → `feat(subnet): add subnet module`
4. `oci/compute` → `feat(compute): add compute instance module for AMD Micro and Ampere A1`
5. `oci/block_volume` → `feat(block_volume): add block volume module with optional attachment`
6. `oci/object_storage` → `feat(object_storage): add object storage bucket module`
7. `examples/free-tier-compute-stack` → `feat(examples): add free-tier-compute-stack example`

### Phase 2 — Databases (P1)

1. `oci/autonomous_database` → `feat(autonomous_database): add Always Free autonomous database module`
2. `oci/nosql` → `feat(nosql): add NoSQL table module with index support`
3. `oci/mysql` → `feat(mysql): add MySQL HeatWave standalone module`
4. `examples/free-tier-databases` → `feat(examples): add free-tier-databases example`

### Phase 3 — Networking Extras & Security (P2)

1. `oci/load_balancer` → `feat(load_balancer): add flexible load balancer module`
2. `oci/network_load_balancer` → `feat(network_load_balancer): add network load balancer module`
3. `oci/vault` → `feat(vault): add KMS vault and key module`
4. `oci/certificates` → `feat(certificates): add certificate authority and certificate module`
5. `oci/bastion` → `feat(bastion): add bastion service module`
6. `oci/vpn` → `feat(vpn): add site-to-site VPN module`
7. `examples/free-tier-web-app` + `examples/free-tier-security` → examples

### Phase 4 — Observability (P3)

1. `oci/notifications` → `feat(notifications): add notification topic and subscription module`
2. `oci/monitoring` → `feat(monitoring): add monitoring alarm module`
3. `oci/email_delivery` → `feat(email_delivery): add email sender module`
4. `oci/logging` → `feat(logging): add log group and log module`
5. `oci/apm` → `feat(apm): add APM domain module`
6. `oci/connector_hub` → `feat(connector_hub): add service connector module`
7. `examples/free-tier-observability` + `examples/free-tier-arm-server` → examples

---

## Verification

For each module:

1. `cd oci/<module> && terraform init && terraform validate`
2. `terraform fmt -check`
3. `pre-commit run --all-files` from repo root
4. Verify README auto-generates correctly between terraform-docs markers

---

## Summary

| Metric | Count |
|--------|-------|
| Existing modules to improve | 1 (identity) |
| New modules to create | 17 |
| Services excluded | 6 |
| New examples to create | 6 |
| Total Terraform resources across new modules | ~27 |
| Estimated total variables across new modules | ~150 |

---

## Key Reference Files

- `oci/budget/variables.tf` — Gold standard for validation patterns
- `oci/budget/main.tf` — Gold standard for resource structure
- `oci/budget/providers.tf` — Provider boilerplate to copy
- `oci/identity/variables.tf` — Needs validation fix
