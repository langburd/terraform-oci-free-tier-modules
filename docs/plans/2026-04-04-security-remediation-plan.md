# Security Remediation Plan

**Date:** 2026-04-04
**Scope:** All 23 modules under `oci/`, CI workflows, scanner configs
**Delivery:** Single PR, single branch
**Sources:**
- `docs/reports/security-review-2026-04-04.md` (30 findings)
- Checkov CI — 9 open alerts in GitHub Security tab
- Trivy CI — 0 findings (clean)

---

## Guiding Principles

1. **Free-tier-safe defaults.** Where the secure option costs money (CMK encryption, HSM keys, block volume backups), add the variable but default to `null` and document why.
2. **Suppress, don't ignore.** Free-tier exceptions get centralized skip annotations in `.checkov.yml` / `.trivyignore` with comments explaining the rationale.
3. **Breaking changes are acceptable** when the old default was insecure. Document all breaking changes in the PR description.

---

## Summary

| Category | Count |
|----------|-------|
| Breaking default changes | 7 |
| Module code fixes | 30 findings addressed |
| Checkov alerts resolved | 9 (4 fixed in code, 5 skipped: 3 free-tier + 2 by-design) |
| New files | `.checkov.yml`, `.trivyignore`, `.tflint.hcl` |
| Modules touched | 14 of 23 |

---

## Module Changes

### Critical Fixes

| ID | Module | Change | Breaking? |
|----|--------|--------|-----------|
| C-1 | `bastion` | Default `client_cidr_block_allow_list` -> `[]` (empty). Callers must now provide CIDRs | Yes |
| C-2 | `load_balancer` | Default `listener_protocol` -> `"HTTPS"`. Add validation warning for HTTP | Yes |
| C-3 | `network_load_balancer` | Add description warning about unencrypted TCP default. NLB is L4; HTTPS not applicable -- document only | No |
| C-4 | `compute` | Default `assign_public_ip` -> `false` | Yes |
| C-5 | `autonomous_database` | Default `is_mtls_connection_required` -> `true` | Yes |
| C-6 | `mysql` | Investigate `oci_mysql_db_system` for SSL enforcement attribute. If not available in provider, add description documenting that OCI MySQL HeatWave enforces TLS by default at the service level | No |

### High Fixes

| ID | Module | Change | Breaking? |
|----|--------|--------|-----------|
| H-1 | `object_storage` | Add new `allow_public_access` variable (default `false`). Add cross-variable validation: `bucket_access_type != "NoPublicAccess"` requires `allow_public_access = true` | No |
| H-2 | `compute` | Add SSH key format validation: `can(regex("^(ssh-rsa\|ssh-ed25519\|ecdsa-sha2-nistp256) ", var.ssh_authorized_keys))` | No |
| H-3 | `autonomous_database` | Add `admin_password` validation: min 12 chars, upper, lower, digit, special char | No |
| H-4 | `mysql` | Add `admin_password` validation: 8-32 chars, upper, lower, digit, special char | No |
| H-5 | `vcn` | Document implicit allow-all egress on empty security list in description/README. Don't add rules -- this is intentionally a building block | No |
| H-6 | `load_balancer`, `network_load_balancer` | Skip health check port validation. Document in README instead | No |
| H-7 | `logging` | Improve description noting AUDIT log type should be configured separately | No |
| H-8 | `vault` | Keep `SOFTWARE` default (HSM costs money). Improve description warning that HSM is recommended for production | No |

### Medium Fixes

| ID | Module | Change | Breaking? |
|----|--------|--------|-----------|
| M-1 | `autonomous_database` | Improve `whitelisted_ips` description recommending IP ACLs for private deployments | No |
| M-2 | `certificates` | Change CA validity from 2035 to 3 years from issuance, cert validity from 2034 to 1 year. Add description about rotation best practices | No |
| M-3 | `bastion` | Default `max_session_ttl_in_seconds` -> `1800` (30 min). Already within validation range | Yes |
| M-4 | `vcn` | Default `create_internet_gateway` -> `false` | Yes |
| M-5 | `mysql` | Investigate encryption-at-rest attributes. If not in provider, document OCI manages encryption by default | No |
| M-6 | `object_storage` | Default `versioning` -> `"Enabled"` | Yes |
| M-7 | `compute` | Improve `user_data` description: warn about trusting cloud-init scripts and OCI console visibility | No |
| M-8 | `object_storage`, `vault`, `mysql`, `autonomous_database` | Add encryption-related test runs asserting secure defaults | No |
| M-9 | `load_balancer`, `network_load_balancer`, `bastion` | Add network security rejection tests for insecure CIDR/protocol configs | No |
| M-10 | `compute`, `mysql`, `network_load_balancer` | Mark IP/port outputs `sensitive = true` | No |

### Low Fixes

| ID | Module | Change | Breaking? |
|----|--------|--------|-----------|
| L-1 | `budget` | Add email format validation for `alert_recipients` | No |
| L-2 | `subnet` | Improve `dns_label` description with examples | No |
| L-3 | All modules | Constrain provider version `>= 6.0, < 7.0` | No |

### Info Fixes

| ID | Module | Change | Breaking? |
|----|--------|--------|-----------|
| I-1 | `oci_profile_reader` | Add README warning about state file exposure | No |
| I-2 | `object_storage` | Add description warning about retention rule irreversibility | No |
| I-3 | `notifications` | Add `contains()` validation for subscription protocol | No |

---

## Checkov Alert Resolution

| Check | Module | Resolution | Skip? |
|-------|--------|------------|-------|
| CKV_OCI_4 | `compute` | Add `launch_options { is_pv_encryption_in_transit_enabled = true }` | No -- fix |
| CKV_OCI_5 | `compute` | Add `instance_options { are_legacy_imds_endpoints_disabled = true }` | No -- fix |
| CKV_OCI_7 | `object_storage` | Default `object_events_enabled` -> `true` | No -- fix |
| CKV_OCI_8 | `object_storage` | Covered by M-6 (versioning default -> `"Enabled"`) | No -- fix |
| CKV_OCI_9 | `object_storage` | Add `kms_key_id` variable (default `null`). CMK requires paid Vault | Yes -- free-tier |
| CKV_OCI_2 | `block_volume` | Add `backup_policy_id` variable (default `null`). Backups require paid storage | Yes -- free-tier |
| CKV_OCI_3 | `block_volume` | Add `kms_key_id` variable (default `null`). CMK requires paid Vault | Yes -- free-tier |
| CKV_OCI_16 | `vcn` | Empty security list is by design (building block pattern) | Yes -- by design |
| CKV_OCI_19 | `vcn` | Same empty security list -- no ingress rules by design | Yes -- by design |

---

## New Files

### `.checkov.yml`

Centralized Checkov skip config at repo root:

```yaml
skip-check:
  - CKV_OCI_9   # CMK encryption requires paid OCI Vault -- variable exposed, default null (free tier)
  - CKV_OCI_2   # Block volume backup requires paid storage -- variable exposed, default null (free tier)
  - CKV_OCI_3   # Block volume CMK requires paid OCI Vault -- variable exposed, default null (free tier)
  - CKV_OCI_16  # VCN security list intentionally empty -- consumers define rules via subnet module
  - CKV_OCI_19  # Same empty security list -- no ingress rules by design
```

### `.trivyignore`

Empty initially (Trivy has 0 findings). Header comment explaining purpose:

```
# Trivy ignore file for OCI Free Tier Modules
# Add Trivy check IDs here to suppress known false positives or free-tier exceptions
# Format: one check ID per line, with optional comment after #
```

### `.tflint.hcl`

tflint config with OCI ruleset:

```hcl
plugin "oci" {
  enabled = true
  version = "0.1.2"
  source  = "github.com/joelp172/tflint-ruleset-oci"
}

plugin "terraform" {
  enabled = true
}
```

> **Note:** The OCI tflint ruleset is a community project (v0.1.2). It may have limited rule coverage compared to AWS/Azure rulesets. If it proves too immature during implementation, fall back to the built-in `terraform` plugin only and rely on Checkov/Trivy for OCI-specific checks.

Pre-commit already runs `terraform_tflint` -- this file is picked up automatically.

---

## CI Workflow Updates

### `checkov.yml`

Add `config_file` reference:

```yaml
- name: Run Checkov IaC scan
  uses: bridgecrewio/checkov-action@v12
  with:
    directory: oci/
    framework: terraform
    config_file: .checkov.yml          # <-- add
    output_format: sarif
    output_file_path: checkov-results.sarif
    soft_fail: true
```

### `trivy.yml`

Add `trivyignores` reference:

```yaml
- name: Run Trivy IaC scan
  uses: aquasecurity/trivy-action@v0.35.0
  with:
    scan-type: config
    scan-ref: oci/
    trivyignores: .trivyignore         # <-- add
    format: sarif
    output: trivy-results.sarif
    exit-code: "0"
    severity: CRITICAL,HIGH,MEDIUM
```

---

## Test Strategy

### New Test Runs

| Module | New Test Runs |
|--------|---------------|
| `bastion` | Rejection: empty `client_cidr_block_allow_list` with no override. Custom-inputs with explicit CIDRs |
| `compute` | Assert `assign_public_ip = false` in defaults. Rejection for invalid SSH key. Assert `launch_options` and `instance_options` in plan |
| `load_balancer` | Assert `listener_protocol = "HTTPS"` in defaults |
| `autonomous_database` | Assert `is_mtls_connection_required = true` in defaults. Rejection for weak `admin_password` |
| `mysql` | Rejection for weak `admin_password` |
| `object_storage` | Assert `versioning = "Enabled"` and `object_events_enabled = true` in defaults. Rejection for public access without `allow_public_access = true` |
| `vcn` | Assert `create_internet_gateway = false` in defaults |
| `block_volume` | Custom-inputs exercising `kms_key_id` and `backup_policy_id` |
| `certificates` | Assert shorter validity defaults |
| `budget` | Rejection for malformed email in `alert_recipients` |
| `notifications` | Rejection for invalid subscription protocol |

### Existing Tests

Tests relying on old defaults (e.g., `assign_public_ip = true`, `create_internet_gateway = true`) must be updated to either explicitly pass the old value or accept the new secure default.

### Verification

All tests use `command = plan` with `mock_provider "oci" {}`. Run `terraform init && terraform test` in each changed module directory before committing.

---

## Breaking Changes Summary

These 7 default changes will break existing consumers who relied on the old (insecure) defaults:

| Change | Old Default | New Default | Migration |
|--------|-------------|-------------|-----------|
| `bastion.client_cidr_block_allow_list` | `["0.0.0.0/0"]` | `[]` | Add explicit CIDR blocks |
| `load_balancer.listener_protocol` | `"HTTP"` | `"HTTPS"` | Add SSL cert config or set `listener_protocol = "HTTP"` |
| `compute.assign_public_ip` | `true` | `false` | Set `assign_public_ip = true` explicitly |
| `autonomous_database.is_mtls_connection_required` | `false` | `true` | Update client connection config for mTLS or set `is_mtls_connection_required = false` |
| `bastion.max_session_ttl_in_seconds` | `10800` | `1800` | Set `max_session_ttl_in_seconds = 10800` explicitly |
| `vcn.create_internet_gateway` | `true` | `false` | Set `create_internet_gateway = true` explicitly |
| `object_storage.versioning` | `"Disabled"` | `"Enabled"` | Set `versioning = "Disabled"` explicitly or accept new default |

All breaking changes should be documented in the PR description with migration instructions.

---

## Implementation Order

Since this is a single PR, work module by module in this order (dependencies first):

1. **New config files** -- `.checkov.yml`, `.trivyignore`, `.tflint.hcl`
2. **CI workflows** -- update `checkov.yml` and `trivy.yml`
3. **Provider version constraint** -- L-3 across all modules
4. **Core modules** -- `vcn`, `subnet` (networking foundation)
5. **Compute modules** -- `compute`, `block_volume`
6. **Database modules** -- `autonomous_database`, `mysql`
7. **Storage modules** -- `object_storage`
8. **Security modules** -- `vault`, `certificates`, `bastion`
9. **Connectivity modules** -- `load_balancer`, `network_load_balancer`
10. **Observability modules** -- `logging`, `monitoring`, `notifications`, `budget`
11. **Utility modules** -- `oci_profile_reader`
12. **Run all tests** -- `terraform init && terraform test` in each changed module
13. **Run pre-commit** -- `pre-commit run --all-files`
