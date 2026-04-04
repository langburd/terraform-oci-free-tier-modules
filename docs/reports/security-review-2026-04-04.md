# Security Review: OCI Terraform Free Tier Modules

**Date:** 2026-04-04
**Scope:** All 23 modules under `oci/`
**Files Analyzed:** ~115 (main.tf, variables.tf, outputs.tf, providers.tf, tests/*.tftest.hcl per module)

---

## Summary

| Severity | Count |
|----------|-------|
| CRITICAL | 6 |
| HIGH | 8 |
| MEDIUM | 10 |
| LOW | 3 |
| INFO | 3 |
| **Total** | **30** |

---

## Critical Findings

### C-1: Bastion — Open Network Access by Default

- **Module:** `bastion`
- **File:** `variables.tf`
- **Issue:** `client_cidr_block_allow_list` defaults to `["0.0.0.0/0"]`, allowing worldwide access to the bastion
- **Risk:** Bastions are privileged access points; a world-open default negates their value as a controlled entry point
- **Recommendation:** Change default to `[]` (empty list). Require explicit CIDR blocks

### C-2: Load Balancer — HTTP Listener Default

- **Module:** `load_balancer`
- **File:** `variables.tf`, `main.tf`
- **Issue:** Listener defaults to HTTP (port 80, unencrypted). No validation enforces HTTPS
- **Risk:** Traffic between clients and the load balancer is unencrypted in default configuration
- **Recommendation:** Change default protocol to HTTPS or add validation requiring HTTPS for production workloads

### C-3: Network Load Balancer — Unencrypted Default Listener

- **Module:** `network_load_balancer`
- **File:** `variables.tf`, `main.tf`
- **Issue:** Listener defaults to TCP on port 80 with no encryption enforcement
- **Risk:** Same as C-2; unencrypted traffic is the path of least resistance
- **Recommendation:** Document and enforce encryption expectations at the listener level

### C-4: Compute — Public IP Assigned by Default

- **Module:** `compute`
- **File:** `variables.tf`
- **Issue:** `assign_public_ip` defaults to `true`, exposing instances directly to the internet
- **Risk:** Any instance created with default settings is internet-reachable, increasing attack surface
- **Recommendation:** Change default to `false`. Require explicit opt-in for public IP assignment

### C-5: Autonomous Database — mTLS Disabled by Default

- **Module:** `autonomous_database`
- **File:** `variables.tf`
- **Issue:** `is_mtls_connection_required` defaults to `false`
- **Risk:** Database allows single-TLS or even plaintext client connections; susceptible to MITM
- **Recommendation:** Change default to `true`. Add validation preventing non-mTLS configurations for production

### C-6: MySQL — No SSL/TLS Connection Enforcement

- **Module:** `mysql`
- **File:** `main.tf`, `variables.tf`
- **Issue:** Module does not expose or enforce SSL/TLS connection requirements
- **Risk:** Database clients can connect unencrypted; no module-level defense for in-transit encryption
- **Recommendation:** Add variable for mandatory SSL enforcement if supported by the OCI MySQL service API

---

## High Findings

### H-1: Object Storage — Public Bucket Access Allowed Without Warning

- **Module:** `object_storage`
- **File:** `variables.tf`
- **Issue:** `bucket_access_type` accepts `ObjectRead` and `ObjectReadWithoutList` without any guard or strong warning
- **Risk:** Operators can accidentally create publicly readable buckets
- **Recommendation:** Add a cross-variable guard that requires an explicit `allow_public_access = true` flag, or add a `validation` block with a prominent warning in the error message

### H-2: Compute — SSH Key Format Not Validated

- **Module:** `compute`
- **File:** `variables.tf`
- **Issue:** `ssh_authorized_keys` accepts arbitrary strings; no SSH public key format validation
- **Risk:** Invalid or malformed keys could lock out operators, or a non-key value could be silently accepted
- **Recommendation:** Add `validation` block with regex: `can(regex("^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256) ", var.ssh_authorized_keys))`

### H-3: Autonomous Database — Admin Password Strength Not Validated

- **Module:** `autonomous_database`
- **File:** `variables.tf`
- **Issue:** `admin_password` is marked `sensitive` but has no complexity validation
- **Risk:** Weak passwords accepted silently; OCI itself enforces requirements at apply time causing late-cycle failures
- **Recommendation:** Add validation: min 12 chars, at least one uppercase, one lowercase, one digit, one special character

### H-4: MySQL — Admin Password Strength Not Validated

- **Module:** `mysql`
- **File:** `variables.tf`
- **Issue:** `admin_password` description mentions requirements (8–32 chars, mixed types) but no `validation` block enforces them
- **Risk:** Same as H-3; policy described in prose is not machine-enforced
- **Recommendation:** Add regex validation matching the stated requirements

### H-5: VCN — Default Security List Is Empty (Implicit Allow-All Egress)

- **Module:** `vcn`
- **File:** `main.tf`
- **Issue:** Module creates an intentionally empty security list. OCI's default behavior for empty lists is to allow all egress and deny all ingress
- **Risk:** Unrestricted outbound traffic; data exfiltration or C2 connectivity is unimpeded
- **Recommendation:** Create an explicit deny-all egress security list as the baseline, or document the implicit behavior prominently

### H-6: Load Balancer / NLB — Health Check Port Not Restricted

- **Module:** `load_balancer`, `network_load_balancer`
- **File:** `variables.tf` (both)
- **Issue:** Health check port has no validation against privileged or management ports (22, 3389, 3306, 5432, etc.)
- **Risk:** Misconfigured health checks could probe sensitive internal ports, leaking availability info or causing unintended load
- **Recommendation:** Add `validation` block rejecting known management ports for health check targets

### H-7: Logging — Audit Log Type Not Enforced or Recommended

- **Module:** `logging`
- **File:** `variables.tf`
- **Issue:** `AUDIT` log type is available but no guidance, default, or enforcement exists
- **Risk:** Deployments without audit logging lose the ability to reconstruct security events
- **Recommendation:** Document that AUDIT logging must be configured separately. Consider creating a separate `audit_log` sub-resource or companion example

### H-8: Vault — Key Protection Mode Defaults to SOFTWARE

- **Module:** `vault`
- **File:** `variables.tf`
- **Issue:** `key_protection_mode` defaults to `SOFTWARE`
- **Risk:** Software-protected keys are extractable in theory; `HSM`-protected keys are hardware-isolated
- **Recommendation:** Change default to `HSM` or require explicit justification (`SOFTWARE` should be opt-in)

---

## Medium Findings

### M-1: Autonomous Database — No IP-Level Access Restriction by Default

- **Module:** `autonomous_database`
- **File:** `variables.tf`
- **Issue:** `whitelisted_ips` defaults to `[]` (unrestricted)
- **Recommendation:** Document that IP ACLs should be configured. Add note recommending at least one CIDR for private deployments

### M-2: Certificates — Long Default Validity Periods

- **Module:** `certificates`
- **File:** `variables.tf`
- **Issue:** CA validity hardcoded to 2035, certificate to 2034 (~8–9 years)
- **Risk:** Compromised keys remain valid for years; long-lived certs conflict with modern rotation best practices
- **Recommendation:** Default to 1-year validity. Document certificate rotation procedures

### M-3: Bastion — Session TTL Default Too High

- **Module:** `bastion`
- **File:** `variables.tf`
- **Issue:** `max_session_ttl_in_seconds` defaults to 10,800 seconds (3 hours)
- **Risk:** Hijacked sessions remain valid for an extended window
- **Recommendation:** Change default to 1,800 seconds (30 minutes). Document the security trade-off

### M-4: VCN — Internet Gateway Created by Default

- **Module:** `vcn`
- **File:** `variables.tf`
- **Issue:** `create_internet_gateway` defaults to `true`
- **Risk:** New VCNs are internet-connected by default; operators must consciously opt out
- **Recommendation:** Change default to `false`. Require explicit opt-in

### M-5: MySQL — No Encryption-at-Rest Configuration

- **Module:** `mysql`
- **File:** `main.tf`
- **Issue:** No variable or resource block for encryption at rest
- **Risk:** Data-at-rest protection depends entirely on OCI defaults, with no module-level control
- **Recommendation:** Expose encryption-at-rest options if the OCI MySQL service API supports them

### M-6: Object Storage — Versioning Disabled by Default

- **Module:** `object_storage`
- **File:** `variables.tf`
- **Issue:** Versioning defaults to `Disabled`
- **Risk:** Accidental or malicious deletions/overwrites are unrecoverable
- **Recommendation:** Change default to `Enabled`. Document the cost implications of versioning

### M-7: Compute — User Data Accepts Arbitrary Input

- **Module:** `compute`
- **File:** `variables.tf`
- **Issue:** `user_data` accepts arbitrary base64-encoded data with no validation or warning
- **Risk:** Operator error (or supply-chain attack on scripts) could silently introduce insecure configurations
- **Recommendation:** Add `description` warning about trusting cloud-init scripts. Document that user_data is visible in OCI console

### M-8: Missing Encryption Tests

- **Modules:** `object_storage`, `vault`, `mysql`, `autonomous_database`
- **Issue:** Test suites do not verify encryption configurations or defaults
- **Recommendation:** Add test runs that assert encryption variables are set to secure values when defaults are used

### M-9: Missing Network Security Tests

- **Modules:** `load_balancer`, `network_load_balancer`, `bastion`
- **Issue:** Tests don't validate CIDR restrictions, protocol defaults, or port restrictions
- **Recommendation:** Add rejection tests for insecure protocol/CIDR configurations

### M-10: Outputs — IP Addresses and Ports Not Marked Sensitive

- **Modules:** `compute`, `mysql`, `network_load_balancer`
- **Issue:** Outputs like `instance_private_ip`, `mysql_ip_address`, `mysql_port`, `nlb_ip_addresses` are not marked `sensitive = true`
- **Risk:** IP addresses and ports appear in CI/CD logs and `terraform show` output; useful for reconnaissance
- **Recommendation:** Mark these outputs `sensitive = true` per the project's `outputs.tf` convention

---

## Low Findings

### L-1: Budget — Alert Recipients Not Format-Validated

- **Module:** `budget`
- **File:** `variables.tf`
- **Issue:** `alert_recipients` is a delimited string with no email format validation
- **Recommendation:** Add regex validation for email format, or split into a `list(string)` with per-element validation

### L-2: Subnet — DNS Label Validation Docs Are Sparse

- **Module:** `subnet`
- **File:** `variables.tf`
- **Issue:** `dns_label` regex validation present but description lacks examples of valid/invalid labels
- **Recommendation:** Improve description with a concrete example (e.g., `subnet01`)

### L-3: OCI Provider Version Range Too Broad

- **All modules**
- **File:** `providers.tf`
- **Issue:** All modules declare `>= 6.0` with no upper bound, allowing potentially breaking provider upgrades
- **Recommendation:** Constrain to `>= 6.0, < 7.0` to avoid surprise upgrades

---

## Info / Notes

### I-1: oci_profile_reader — State File Exposes Local Config Path

- **Module:** `oci_profile_reader`
- **File:** `main.tf`
- **Issue:** Module reads `~/.oci/config`; the resolved path and profile name appear in Terraform state
- **Recommendation:** Add a prominent README warning that state files should be encrypted and access-controlled

### I-2: Object Storage — Retention Rules Irreversibility Not Documented

- **Module:** `object_storage`
- **File:** `variables.tf`
- **Issue:** Retention rules (once active) are legally locked and cannot be reduced. The module does not warn about this
- **Recommendation:** Add a comment or `description` field warning that enabling retention rules is irreversible

### I-3: Notifications — No Subscription Protocol Validation

- **Module:** `notifications`
- **File:** `variables.tf`
- **Issue:** Subscription `protocol` accepts `CUSTOM_HTTPS`, `EMAIL`, `SLACK`, etc. but no validation exists
- **Recommendation:** Add `contains([...], var.protocol)` validation

---

## Remediation Priority

### Immediate (Critical — change defaults, add guards)

| # | Action | Module |
|---|--------|--------|
| 1 | Set `assign_public_ip` default to `false` | `compute` |
| 2 | Set `is_mtls_connection_required` default to `true` | `autonomous_database` |
| 3 | Set `client_cidr_block_allow_list` default to `[]` | `bastion` |
| 4 | Change default listener protocol to HTTPS | `load_balancer` |
| 5 | Add SSL enforcement variable | `mysql` |
| 6 | Add encryption enforcement tests | `autonomous_database`, `mysql` |

### High Priority (next sprint)

| # | Action | Module |
|---|--------|--------|
| 7 | Add password strength validation | `autonomous_database`, `mysql` |
| 8 | Add SSH key format validation | `compute` |
| 9 | Add public-access guard | `object_storage` |
| 10 | Set `key_protection_mode` default to `HSM` | `vault` |
| 11 | Enable versioning by default | `object_storage` |
| 12 | Mark sensitive outputs | `compute`, `mysql`, `network_load_balancer` |

### Medium Priority (next quarter)

| # | Action | Module |
|---|--------|--------|
| 13 | Reduce certificate default validity | `certificates` |
| 14 | Reduce bastion session TTL default | `bastion` |
| 15 | Change `create_internet_gateway` default to `false` | `vcn` |
| 16 | Add explicit egress deny to default security list | `vcn` |
| 17 | Add audit logging guidance | `logging` |
| 18 | Add network security tests | `load_balancer`, `network_load_balancer`, `bastion` |

---

*Generated by Claude Code security review — 2026-04-04*
