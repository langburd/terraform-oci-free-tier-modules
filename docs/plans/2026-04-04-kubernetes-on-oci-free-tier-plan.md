# Kubernetes on OCI Free Tier Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deploy a fully functional Kubernetes cluster on Oracle Cloud Infrastructure using only Always Free Tier resources ($0 cost), with two approaches: managed OKE and self-managed K3s.

**Architecture:** OKE uses Oracle's managed control plane (free) with Arm-based worker nodes in a VCN with public/private subnets. K3s uses the Terraform Ansible provider's `action` block (TF 1.14+) to run k3s-ansible playbooks against OCI compute instances provisioned by existing modules.

**Tech Stack:** Terraform >= 1.14, OCI Provider ~> 8.0, Ansible Provider ~> 1.4, k3s-ansible, Oracle Linux / Ubuntu on Arm (A1.Flex) and AMD (E2.1.Micro)

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Free Tier Resource Mapping](#2-free-tier-resource-mapping)
3. [Approach 1: OKE Deep Dive](#3-approach-1-oke-deep-dive)
4. [Approach 2: Self-Managed K3s Deep Dive](#4-approach-2-self-managed-k3s-deep-dive)
5. [Comparison Matrix](#5-comparison-matrix)
6. [Module Development Plan](#6-module-development-plan)
7. [Example Implementation Plan](#7-example-implementation-plan)
8. [Testing Strategy](#8-testing-strategy)
9. [Risks and Mitigations](#9-risks-and-mitigations)
10. [References](#10-references)

---

## 1. Executive Summary

### Recommendation: Implement Both Approaches (OKE first, K3s second)

**Primary recommendation: OKE (Approach 1)** for users who want a production-like managed Kubernetes experience. OKE's control plane is free, requires fewer new modules (2 vs 3), and is proven by multiple community implementations with 300+ combined GitHub stars.

**Secondary recommendation: K3s (Approach 2)** for users who want full control, multi-architecture clusters (Arm + AMD), or Terraform 1.14's `action` feature. K3s can include the 2 AMD Micro instances that OKE cannot use, but the 200 GB storage limit caps all approaches at **4 nodes** (each node requires a minimum 50 GB boot volume via the `oci/compute` module).

| Factor | OKE | K3s |
|--------|-----|-----|
| Implementation complexity | Medium | High |
| New modules required | 2 (`oke_cluster`, `oke_node_pool`) | 3 (`security_list`, `network_security_group`, `k3s_cluster`) |
| Maintenance burden | Low (Oracle manages control plane) | Medium (self-managed upgrades via Ansible) |
| Node count (free tier) | 2-4 Arm nodes | 4 nodes max (storage-limited): 2 Arm + 2 AMD, or 4 Arm |
| External dependencies | None | Ansible, k3s-ansible playbooks |
| Terraform version | >= 1.0 | >= 1.14 (for `action` block) |
| Community precedent | 3 proven repos | 2 repos (kubeadm, not K3s) |

---

## 2. Free Tier Resource Mapping

### OCI Always Free Resources (Home Region Only)

| Resource | Free Tier Limit | Source |
|----------|----------------|--------|
| AMD Micro Compute | 2x `VM.Standard.E2.1.Micro` (1/8 OCPU, 1 GB RAM each) | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Arm Ampere A1 Compute | 3,000 OCPU-hours + 18,000 GB-hours/month = **4 OCPUs + 24 GB RAM** always-on | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Block Storage | **200 GB** total (boot + block volumes combined), 5 backups | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| VCNs | 2 VCNs with IPv4/IPv6 | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Flexible Load Balancer | 1 LB, 10 Mbps, 16 listeners, 16 backend sets | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Network Load Balancer | 1 NLB, 50 listeners, 50 backend sets | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Object Storage | 20 GB, 50K API requests/month | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |
| Outbound Data Transfer | 10 TB/month | [OCI docs](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm) |

### Resource Consumption by Approach

| Resource | Free Limit | OKE (2-node) | OKE Remaining | K3s (4-node: 2 Arm + 2 AMD) | K3s Remaining |
|----------|-----------|--------------|---------------|------------------------------|---------------|
| Arm OCPUs | 4 | 2 (1/node) | 2 | 2 (1/node, or 2+0 split) | 2 |
| Arm Memory | 24 GB | 12 GB (6/node) | 12 GB | 12 GB (6/node) | 12 GB |
| AMD Micro | 2 | 0 (OKE can't use) | 2 | 2 (lightweight workers) | 0 |
| Boot Volumes | 200 GB | 100 GB (50/node) | 100 GB | 4×50 GB = 200 GB | 0 GB |
| Flexible LB | 1 | 1 (ingress) | 0 | 1 (ingress) | 0 |
| Network LB | 1 | 0-1 | 0-1 | 0-1 | 0-1 |
| VCNs | 2 | 1 | 1 | 1 | 1 |

**Storage constraint:** Each node requires a minimum 50 GB boot volume. With the 200 GB total limit, the maximum node count is **4** across both approaches. Five nodes would require 250 GB (5×50 GB), exceeding the limit.

> **Note on AMD Micro boot volume minimum:** The OCI Console allows AMD Micro (`VM.Standard.E2.1.Micro`) Always Free instances to use as little as 47 GB for a boot volume. However, the OCI Terraform provider (`oracle/oci` v8.x) enforces a **50 GB minimum** for all shapes — both `VM.Standard.E2.1.Micro` and `VM.Standard.A1.Flex`. Setting `boot_volume_size_in_gbs = 47` in Terraform will be rejected at plan time. Use 50 GB for all nodes when provisioning with Terraform.

**Note:** OKE can also run 4 nodes (1 OCPU + 6 GB each) consuming all Arm resources, with 50 GB boot volumes (200 GB total). This leaves 2 AMD Micros unused (OKE worker nodes must be managed via node pools, which don't support AMD Micro shapes for K8s workloads).

---

## 3. Approach 1: OKE Deep Dive

### Architecture

```
                         Internet
                            |
                     [Internet Gateway]
                            |
        +-------------------+-------------------+
        |                   |                   |
   [Public Subnet]    [Private Subnet]    [LB Subnet]
   10.0.1.0/24        10.0.2.0/24        10.0.3.0/24
        |                   |                   |
   K8s API Endpoint    Worker Nodes     Load Balancer
   (OKE managed)       (A1.Flex)        (10 Mbps)
                            |
                     [NAT Gateway]
                            |
                         Internet
```

### OKE Control Plane: Confirmed Free

- **"There is no additional charge for cluster management."** ([arnoldgalovics.com](https://arnoldgalovics.com/free-kubernetes-oracle-cloud/))
- Control plane runs on Oracle-managed infrastructure in the OKE service tenancy
- 3 control plane nodes (HA) managed by Oracle at no cost
- OKE is **not** listed as an Always Free resource, but control plane cost is $0 regardless of account type
- Basic cluster type (default via CLI/API) provides core K8s without SLA

### Cluster Configuration

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Cluster type | `BASIC_CLUSTER` | Free; Enhanced adds SLA + features at extra cost |
| K8s version | Latest stable (e.g., v1.33.x) | Query via `oci ce cluster-options get --cluster-option-id all --compartment-id <compartment-id>` |
| Pod CIDR | `10.244.0.0/16` | Standard, non-overlapping with VCN |
| Service CIDR | `10.96.0.0/16` | Standard Kubernetes default |
| CNI | Flannel (default) | VCN-native requires pod subnet (more complex) |
| API endpoint | Public (configurable) | Simplest for free tier; can restrict via NSG |
| Dashboard | Disabled | Security best practice |

### Node Pool Configuration

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Node shape | `VM.Standard.A1.Flex` | Only Arm free tier shape; AMD Micro not suitable for OKE workers |
| Nodes | 2 | 2x (1 OCPU + 6 GB) = moderate; or 2x (2 OCPU + 12 GB) = maximum |
| Boot volume | 50 GB (conservative) or 100 GB (aggressive) | 2x 50 GB = 100 GB used, 100 GB remaining; 2x 100 GB = 200 GB, 0 remaining |
| Image | Oracle Linux (aarch64) or Ubuntu (aarch64) | Use `data.oci_containerengine_node_pool_option` to discover |
| SSH key | Provided for debugging access | Via `ssh_public_key` on node pool |

### Networking Requirements

OKE requires **3 subnets** (minimum 2):

| Subnet | CIDR | Type | Purpose |
|--------|------|------|---------|
| API Endpoint | `10.0.1.0/24` | Public | K8s API server endpoint |
| Worker Nodes | `10.0.2.0/24` | Private | Node pool instances (behind NAT) |
| Load Balancer | `10.0.3.0/24` | Public | OCI LB for `LoadBalancer` services |

**Gateways required:** Internet Gateway (public subnets), NAT Gateway (private subnet outbound), Service Gateway (OCI services access)

### Security Rules (NSG-based, recommended over security lists)

**API Endpoint NSG:**

| Direction | Source/Dest | Protocol | Ports | Purpose |
|-----------|-------------|----------|-------|---------|
| Ingress | Worker subnet | TCP | 6443, 12250 | Worker-to-API |
| Ingress | 0.0.0.0/0 (optional) | TCP | 6443 | External kubectl access |
| Ingress | Worker subnet | ICMP | Type 3, Code 4 | Path MTU discovery |
| Egress | Worker subnet | TCP | All | API-to-worker |
| Egress | Oracle Services | TCP | 443 | OKE service communication |

**Worker Node NSG:**

| Direction | Source/Dest | Protocol | Ports | Purpose |
|-----------|-------------|----------|-------|---------|
| Ingress | Worker subnet | All | All | Inter-node communication |
| Ingress | API endpoint subnet | TCP | All | API-to-worker control |
| Ingress | 0.0.0.0/0 | ICMP | Type 3, Code 4 | Path MTU discovery |
| Egress | Worker subnet | All | All | Inter-node communication |
| Egress | 0.0.0.0/0 | TCP | All | Internet access (via NAT) |
| Egress | Oracle Services | TCP | All | OKE communication |
| Egress | API endpoint subnet | TCP | 6443, 12250 | Worker-to-API |

**Load Balancer NSG:**

| Direction | Source/Dest | Protocol | Ports | Purpose |
|-----------|-------------|----------|-------|---------|
| Ingress | 0.0.0.0/0 | TCP | 80, 443 | HTTP/HTTPS traffic |
| Egress | Worker subnet | TCP | 30000-32767 | NodePort range |
| Egress | Worker subnet | TCP | 10256 | kube-proxy health check |

### Pros and Cons

| Pros | Cons |
|------|------|
| Control plane managed by Oracle (free, HA) | Cannot use AMD Micro instances as workers |
| Kubernetes upgrades handled by Oracle | Requires 3 subnets + NSGs (more networking complexity) |
| Native OCI integration (LB, block volumes, etc.) | Basic cluster has no SLA |
| kubectl + OCI CLI access out of the box | Arm-only images required for workloads |
| Proven by 3 community implementations | Uses only Arm free tier; AMD Micros left unused |
| No external dependencies (pure Terraform + OCI) | Node pool changes can be slow (instance provisioning) |

### Required Terraform Resources

```hcl
# Existing modules (no changes needed):
module "vcn"    { source = "...oci/vcn" }    # VCN + IGW + NAT + SGW
module "subnet" { source = "...oci/subnet" } # x3: api_endpoint, workers, load_balancer

# New modules needed:
module "oke_cluster"   { source = "...oci/oke_cluster" }   # oci_containerengine_cluster
module "oke_node_pool" { source = "...oci/oke_node_pool" } # oci_containerengine_node_pool

# New supporting module:
module "network_security_group" { source = "...oci/network_security_group" } # oci_core_network_security_group + rules
```

---

## 4. Approach 2: Self-Managed K3s Deep Dive

### Architecture

```
                         Internet
                            |
                     [Internet Gateway]
                            |
              +-------------+-------------+
              |                           |
         [Public Subnet]           [LB Subnet]
         10.0.0.0/24              10.0.1.0/24
              |                        |
   +----------+-----+       [Flex LB 10Mbps]
   |     |     |    |       (ingress controller)
 srv-1 agt-1 amd1 amd2
 A1.Flex A1.Flex Micro Micro
 1 OCPU 1 OCPU  1/8   1/8
 6 GB   6 GB    1 GB  1 GB
 (server)(agent) (agent) (agent)
              |
        [NAT Gateway]
              |
           Internet
```

### Node Distribution

The 200 GB block storage limit (boot + block volumes combined) caps the cluster at **4 nodes**: each node requires a minimum 50 GB boot volume via the `oci/compute` module (5×50 GB = 250 GB for 5 nodes — exceeds the limit). The K3s advantage over OKE is not node count but **architecture diversity**: it can include the 2 AMD Micro instances that OKE node pools cannot use.

**Option A: 2 Arm + 2 AMD (maximize architecture diversity)**

| Node | Shape | OCPU | RAM | Role | Boot Vol | Rationale |
|------|-------|------|-----|------|----------|-----------|
| `k3s-server-1` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s server (control plane + etcd) | 50 GB | Arm; control plane |
| `k3s-agent-1` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s agent (worker) | 50 GB | Arm workload node |
| `k3s-agent-2` | `VM.Standard.E2.1.Micro` | 1/8 | 1 GB | K3s agent (lightweight) | 50 GB | AMD; ingress/monitoring |
| `k3s-agent-3` | `VM.Standard.E2.1.Micro` | 1/8 | 1 GB | K3s agent (lightweight) | 50 GB | AMD; ingress/monitoring |
| **Total** | | **2.25 OCPU** | **14 GB** | 1 server + 3 agents | **200 GB** | Uses Arm + AMD compute |

**Option B: 4 Arm (maximize Arm compute)**

| Node | Shape | OCPU | RAM | Role | Boot Vol | Rationale |
|------|-------|------|-----|------|----------|-----------|
| `k3s-server-1` | `VM.Standard.A1.Flex` | 2 | 8 GB | K3s server (control plane + etcd) | 50 GB | More RAM for etcd + API |
| `k3s-agent-1` | `VM.Standard.A1.Flex` | 1 | 8 GB | K3s agent (worker) | 50 GB | Arm workload node |
| `k3s-agent-2` | `VM.Standard.A1.Flex` | 1 | 8 GB | K3s agent (worker) | 50 GB | Arm workload node |
| `k3s-agent-3` | `VM.Standard.A1.Flex` | 0 OCPU* | 0 GB* | — | 50 GB | *Only 4 OCPU total: 2+1+1 exhausts it |
| **Total** | | **4 OCPU** | **24 GB** | 1 server + 2 agents | **200 GB** | Uses all Arm OCPU + RAM + storage |

> **Note for Option B:** With `2+1+1 = 4 OCPU` and `8+8+8 = 24 GB` the budget is exactly exhausted across 3 nodes. A 4th Arm node would require more OCPU/RAM and exceed the budget. So Option B is effectively 3 Arm nodes unless you use smaller allocations (e.g., `1+1+1+1 OCPU` and `6+6+6+6 GB = 24 GB`, `4×50 GB = 200 GB` exactly).

**Recommended default (plan implements Option B with 4×1 OCPU / 6 GB / 50 GB):**

| Node | Shape | OCPU | RAM | Role | Boot Vol |
|------|-------|------|-----|------|----------|
| `k3s-server-1` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s server | 50 GB |
| `k3s-agent-1` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s agent | 50 GB |
| `k3s-agent-2` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s agent | 50 GB |
| `k3s-agent-3` | `VM.Standard.A1.Flex` | 1 | 6 GB | K3s agent | 50 GB |
| **Total** | | **4 OCPU** | **24 GB** | 1 server + 3 agents | **200 GB** |

This mirrors the proven ampernetacle pattern (4×A1.Flex, 1 OCPU + 6 GB each). Switch to Option A if mixed-arch support is required.

**Note:** K3s supports mixed-architecture clusters (amd64 + arm64) natively. Workloads must use multi-arch images or be scheduled with node affinity.

### K3s Deployment via Terraform Ansible Provider

The deployment uses Terraform 1.14's `action` block with the `ansible/ansible` provider to run [k3s-ansible](https://github.com/k3s-io/k3s-ansible) playbooks:

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.4"
    }
  }
}

# Step 1: Build dynamic inventory from Terraform-provisioned instances
data "ansible_inventory" "k3s_cluster" {
  group {
    name = "k3s_cluster"
    children = ["server", "agent"]
    variables = {
      ansible_user             = "ubuntu"
      ansible_ssh_private_key_file = var.ssh_private_key_path
      ansible_ssh_extra_args   = "-o StrictHostKeyChecking=no"
      k3s_version              = var.k3s_version
      token                    = random_password.k3s_token.result
      api_endpoint             = module.k3s_server.instance_public_ip
    }
  }
  group {
    name = "server"
    host {
      name = module.k3s_server.instance_public_ip
    }
  }
  group {
    name = "agent"
    dynamic "host" {
      for_each = concat(
        [for inst in module.k3s_arm_agents : inst.instance_public_ip],
        [for inst in module.k3s_amd_agents : inst.instance_public_ip]
      )
      content {
        name = host.value
      }
    }
  }
}

# Step 2: Run k3s-ansible site.yml playbook
action "ansible_playbook_run" "k3s_deploy" {
  config {
    playbooks        = ["${path.module}/vendor/k3s-ansible/playbooks/site.yml"]
    inventories      = [data.ansible_inventory.k3s_cluster.json]
    private_key_file = var.ssh_private_key_path
    become           = true
  }
}
```

### k3s-ansible Playbook Integration

The [k3s-io/k3s-ansible](https://github.com/k3s-io/k3s-ansible) repository provides:

| Playbook | Purpose | When to Use |
|----------|---------|-------------|
| `playbooks/site.yml` | Full cluster deployment (prereq + server + agent roles) | Initial deployment |
| `playbooks/upgrade.yml` | In-place K3s version upgrade | Version bumps |
| `playbooks/reset.yml` | Tear down K3s from all nodes | Cluster destruction |

**Inventory structure expected by k3s-ansible:**

```yaml
k3s_cluster:
  children:
    server:
      hosts:
        <server-ip>:
    agent:
      hosts:
        <agent-1-ip>:
        <agent-2-ip>:
  vars:
    k3s_version: "v1.31.12+k3s1"
    token: "<random-token>"
    api_endpoint: "<server-ip>"
```

The `data.ansible_inventory` data source in the Ansible Terraform provider produces exactly this structure from HCL, bridging Terraform outputs to Ansible inventory.

### Networking Setup

Simpler than OKE — a single public subnet is sufficient since there's no OKE API endpoint subnet requirement:

| Component | Configuration |
|-----------|---------------|
| VCN | `10.0.0.0/16` |
| Public Subnet | `10.0.0.0/24` (all nodes) |
| LB Subnet | `10.0.1.0/24` (Flexible LB for ingress) |
| Internet Gateway | For all outbound + inbound traffic |
| NAT Gateway | Optional (nodes are in public subnet) |

### Security List Rules

| Direction | Source/Dest | Protocol | Ports | Purpose |
|-----------|-------------|----------|-------|---------|
| Ingress | VCN CIDR | All | All | Intra-cluster communication |
| Ingress | 0.0.0.0/0 | TCP | 22 | SSH access |
| Ingress | 0.0.0.0/0 | TCP | 6443 | K3s API server |
| Ingress | 0.0.0.0/0 | TCP | 80, 443 | HTTP/HTTPS ingress |
| Ingress | 0.0.0.0/0 | TCP | 30000-32767 | NodePort services |
| Ingress | 0.0.0.0/0 | ICMP | Type 3, Code 4 | Path MTU discovery |
| Egress | 0.0.0.0/0 | All | All | All outbound traffic |

### SSH Key Management

```hcl
# Generate SSH keypair for node access
resource "tls_private_key" "k3s" {
  algorithm = "ED25519"
}

# Write private key to local file for Ansible
resource "local_sensitive_file" "ssh_private_key" {
  content         = tls_private_key.k3s.private_key_openssh
  filename        = "${path.module}/.ssh/k3s-key"
  file_permission = "0600"
}

# Pass public key to compute instances
module "k3s_server" {
  source              = "...oci/compute"
  ssh_authorized_keys = tls_private_key.k3s.public_key_openssh
  # ...
}
```

### Persistent Storage Options

| Option | Mechanism | Pros | Cons |
|--------|-----------|------|------|
| Local path provisioner (default) | K3s built-in `local-path-provisioner` | Zero setup, works immediately | Data lost if node is reclaimed |
| OCI Block Volume CSI | Manual CSI driver installation | Persistent across node replacement | Complex setup, 200 GB total limit shared with boot vols |
| Longhorn | Distributed storage across nodes | Replicated, HA | Heavy resource usage on Micro instances |
| Object Storage (S3-compatible) | OCI Object Storage with S3 compatibility API | 20 GB free, off-node | Not suitable for block storage workloads |

**Recommendation:** Start with local-path-provisioner (K3s default). Add OCI Block Volume CSI only if persistent storage is required.

### Upgrade/Maintenance Strategy

1. **K3s version upgrade:** Change `k3s_version` variable, re-run `terraform apply` (triggers `upgrade.yml` playbook)
2. **OS patching:** Cloud-init `package_upgrade: true` on instance recreation, or Ansible ad-hoc patching
3. **Node replacement:** Terraform `taint` on the instance, `apply` recreates it, Ansible re-joins to cluster
4. **Cluster reset:** Run `reset.yml` playbook via `terraform apply -invoke=ansible_playbook_run.k3s_reset`

### Pros and Cons

| Pros | Cons |
|------|------|
| Can use AMD Micro instances as workers (OKE cannot) | Self-managed control plane (no Oracle HA) |
| Multi-architecture cluster (amd64 + arm64) | Requires Terraform >= 1.14 (for `action` block) |
| Full control over K8s configuration | Requires Ansible installed on Terraform runner |
| Lighter than full K8s (K3s ~100 MB binary) | Mixed-arch workloads need multi-arch images |
| Declarative upgrades via Ansible playbooks | More moving parts (Terraform + Ansible + k3s-ansible) |
| AMD Micro instances provide extra capacity | AMD Micro instances are very constrained (1/8 OCPU, 1 GB) |
| No vendor lock-in to OKE | No native OCI integrations (manual CSI, no auto-LB provisioning) |

---

## 5. Comparison Matrix

| Dimension | OKE (Managed) | K3s (Self-Managed) |
|-----------|---------------|---------------------|
| **Cost** | $0 | $0 |
| **Control plane** | Oracle-managed, HA (3 nodes) | Self-managed, single server |
| **Worker nodes** | 2-4 Arm A1.Flex | 4 nodes max (2 Arm + 2 AMD, or 4 Arm) |
| **Total cluster RAM** | 12-24 GB (workers only) | 24 GB (4 Arm) or 14 GB (2 Arm + 2 AMD) |
| **Total cluster OCPUs** | 2-4 (Arm only) | 4 Arm, or 2 Arm + 0.25 AMD |
| **K8s version control** | Oracle-provided versions | Any K3s release |
| **Upgrade mechanism** | OKE node cycling / manual | Ansible `upgrade.yml` playbook |
| **OCI LB integration** | Native (`LoadBalancer` service auto-creates OCI LB) | Manual (point LB at NodePort) |
| **Storage integration** | Native OCI CSI driver | Manual CSI or local-path |
| **Networking complexity** | High (3 subnets + 3 NSGs) | Low (1-2 subnets + 1 security list) |
| **New modules required** | 2 (`oke_cluster`, `oke_node_pool`) + 1 supporting (`network_security_group`) | 2 (`security_list`, `network_security_group`) + 1 composite (`k3s_cluster`) |
| **Terraform version** | >= 1.0 | >= 1.14 |
| **External dependencies** | None | Ansible >= 2.15, k3s-ansible (vendored) |
| **Setup time (estimated)** | ~10 min (Terraform apply) | ~15 min (Terraform + Ansible) |
| **Time to implement modules** | Phase 1: 2 modules | Phase 2: 3 modules |
| **Community precedent** | 3 repos (galovics, nce, ystory) | 2 repos (ampernetacle, robinlieb) — kubeadm, not K3s |
| **Idle instance reclamation risk** | Low (K8s keeps nodes busy) | Low (K3s keeps nodes busy) |
| **Multi-arch support** | No (Arm only) | Yes (Arm + AMD) |
| **Best for** | Production-like experience, minimal ops | Full control, learning, maximizing free resources |

---

## 6. Module Development Plan

### New Modules Required

All modules follow conventions from [terraform-oci-free-tier-modules/docs/plans/2026-04-02-oci-free-tier-modules-plan.md](../../terraform-oci-free-tier-modules/docs/plans/2026-04-02-oci-free-tier-modules-plan.md):

- File structure: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`, `README.md`, `tests/<module>.tftest.hcl`
- Provider: `terraform >= 1.0`, `oci >= 8.0` (except `k3s_cluster` which needs `>= 1.14`)
- Variable ordering: `description` -> `type` -> `default` -> `validation`
- OCID validation regex on all OCID inputs
- terraform-docs markers in README
- Native Terraform tests

#### Priority 1: Shared Infrastructure Modules (needed by both approaches)

##### Module 1: `oci/network_security_group`

NSG with configurable ingress/egress rules. Required by OKE (recommended over security lists) and useful for K3s.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_network_security_group` | no | `this` |
| `oci_core_network_security_group_security_rule` | `for_each` on rules | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | -- | OCID regex |
| `vcn_id` | `string` | Yes | -- | OCID regex |
| `nsg_display_name` | `string` | No | `"nsg"` | -- |
| `ingress_rules` | `map(object({...}))` | No | `{}` | See below |
| `egress_rules` | `map(object({...}))` | No | `{}` | See below |
| `nsg_defined_tags` | `map(string)` | No | `{}` | -- |
| `nsg_freeform_tags` | `map(string)` | No | `{}` | -- |

Rule object shape:

```hcl
object({
  protocol    = string           # "6" (TCP), "17" (UDP), "1" (ICMP), "all"
  source      = optional(string) # CIDR for ingress
  destination = optional(string) # CIDR for egress
  source_type      = optional(string, "CIDR_BLOCK")
  destination_type = optional(string, "CIDR_BLOCK")
  tcp_options = optional(object({
    destination_port_range = object({
      min = number
      max = number
    })
  }))
  udp_options = optional(object({
    destination_port_range = object({
      min = number
      max = number
    })
  }))
  icmp_options = optional(object({
    type = number
    code = optional(number)
  }))
  description = optional(string, "")
})
```

**Outputs:** `nsg_id`

**Test scenarios:**

1. Default -- empty NSG, no rules
2. With TCP ingress rules (SSH + HTTPS)
3. With ICMP rules
4. With egress rules
5. OCID validation rejection

##### Module 2: `oci/security_list`

Standalone security list with configurable rules. The VCN module creates an empty security list; this module creates additional ones with rules.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_core_security_list` | no | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | -- | OCID regex |
| `vcn_id` | `string` | Yes | -- | OCID regex |
| `security_list_display_name` | `string` | No | `"security-list"` | -- |
| `ingress_security_rules` | `list(object({...}))` | No | `[]` | -- |
| `egress_security_rules` | `list(object({...}))` | No | `[]` | -- |
| `security_list_defined_tags` | `map(string)` | No | `{}` | -- |
| `security_list_freeform_tags` | `map(string)` | No | `{}` | -- |

Ingress rule object:

```hcl
object({
  protocol    = string  # "6" (TCP), "17" (UDP), "1" (ICMP), "all"
  source      = string  # CIDR block
  source_type = optional(string, "CIDR_BLOCK")
  description = optional(string, "")
  tcp_options = optional(object({
    min = number
    max = number
  }))
  udp_options = optional(object({
    min = number
    max = number
  }))
  icmp_options = optional(object({
    type = number
    code = optional(number)
  }))
  stateless = optional(bool, false)
})
```

Egress rule object: same shape but with `destination` and `destination_type` instead of `source`/`source_type`.

**Outputs:** `security_list_id`

**Test scenarios:**

1. Default -- empty security list
2. With TCP ingress (SSH, HTTPS)
3. With ICMP rules
4. With egress rules
5. With stateless rules
6. OCID validation rejection

#### Priority 2: OKE Modules

##### Module 3: `oci/oke_cluster`

OKE cluster with basic configuration.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_containerengine_cluster` | no | `this` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | -- | OCID regex |
| `vcn_id` | `string` | Yes | -- | OCID regex |
| `cluster_name` | `string` | Yes | -- | -- |
| `kubernetes_version` | `string` | Yes | -- | Starts with `v` |
| `cluster_type` | `string` | No | `"BASIC_CLUSTER"` | `contains(["BASIC_CLUSTER", "ENHANCED_CLUSTER"], ...)` |
| `cni_type` | `string` | No | `"FLANNEL_OVERLAY"` | `contains(["FLANNEL_OVERLAY", "OCI_VCN_IP_NATIVE"], ...)` |
| `endpoint_subnet_id` | `string` | Yes | -- | OCID regex |
| `endpoint_is_public_ip_enabled` | `bool` | No | `true` | -- |
| `endpoint_nsg_ids` | `list(string)` | No | `[]` | -- |
| `service_lb_subnet_ids` | `list(string)` | No | `[]` | -- |
| `pods_cidr` | `string` | No | `"10.244.0.0/16"` | Valid CIDR |
| `services_cidr` | `string` | No | `"10.96.0.0/16"` | Valid CIDR |
| `is_kubernetes_dashboard_enabled` | `bool` | No | `false` | -- |
| `cluster_defined_tags` | `map(string)` | No | `{}` | -- |
| `cluster_freeform_tags` | `map(string)` | No | `{}` | -- |

**Outputs:** `cluster_id`, `cluster_kubernetes_version`, `cluster_endpoints` (sensitive), `cluster_state`

**Design notes:**

- `type` defaults to `BASIC_CLUSTER` for free tier
- `endpoint_config` block always rendered (requires `subnet_id`)
- `options.add_ons.is_tiller_enabled` hardcoded to `false` (deprecated)

**Test scenarios:**

1. Basic cluster with required parameters
2. Enhanced cluster type
3. VCN-native CNI
4. Custom pod/service CIDRs
5. Private endpoint (`is_public_ip_enabled = false`)
6. Kubernetes version validation
7. OCID validation rejection

##### Module 4: `oci/oke_node_pool`

OKE node pool for worker nodes.

| Resource | Conditional | Name |
|----------|-------------|------|
| `oci_containerengine_node_pool` | no | `this` |

**Data sources:** `data.oci_identity_availability_domains` -- for placement configs

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `compartment_id` | `string` | Yes | -- | OCID regex |
| `cluster_id` | `string` | Yes | -- | OCID regex |
| `node_pool_name` | `string` | Yes | -- | -- |
| `node_shape` | `string` | No | `"VM.Standard.A1.Flex"` | `contains(["VM.Standard.A1.Flex", "VM.Standard.E2.1.Micro"], ...)` |
| `node_shape_ocpus` | `number` | No | `1` | 1-4 |
| `node_shape_memory_in_gbs` | `number` | No | `6` | 1-24 |
| `node_count` | `number` | No | `2` | >= 1 |
| `kubernetes_version` | `string` | Yes | -- | Starts with `v` |
| `image_id` | `string` | Yes | -- | OCID regex |
| `boot_volume_size_in_gbs` | `number` | No | `50` | 50-200 |
| `subnet_id` | `string` | Yes | -- | OCID regex (worker subnet) |
| `nsg_ids` | `list(string)` | No | `[]` | -- |
| `ssh_public_key` | `string` | No | `null` | SSH key prefix validation |
| `node_pool_defined_tags` | `map(string)` | No | `{}` | -- |
| `node_pool_freeform_tags` | `map(string)` | No | `{}` | -- |

**Design notes:**

- Uses `node_config_details` (not deprecated `subnet_ids` / `quantity_per_subnet`)
- Generates `placement_configs` dynamically across ADs
- `node_shape_config` block rendered only for Flex shapes (like `oci/compute`)
- `node_source_details` with `source_type = "IMAGE"`

**Outputs:** `node_pool_id`, `node_pool_nodes` (list of node IPs and states)

**Test scenarios:**

1. Default A1.Flex node pool
2. Custom OCPU + memory
3. Custom node count
4. Boot volume size validation
5. Shape validation
6. OCID validation rejection

#### Priority 3: K3s Composite Module

##### Module 5: `oci/k3s_cluster` (in `terraform-oci-free-tier-modules`)

This is a **composite module** that wraps the Ansible provider to deploy K3s. It does NOT provision infrastructure (compute, networking) -- that's done by existing modules in the calling configuration. It takes instance IPs as inputs and runs k3s-ansible.

| Resource/Action | Type | Name |
|-----------------|------|------|
| `random_password` | resource | `k3s_token` |
| `data.ansible_inventory` | data source | `k3s_cluster` |
| `action.ansible_playbook_run` | action | `k3s_deploy` |

**Variables:**

| Variable | Type | Required | Default | Validation |
|----------|------|----------|---------|------------|
| `server_ips` | `list(string)` | Yes | -- | Length >= 1 |
| `agent_ips` | `list(string)` | No | `[]` | -- |
| `ssh_user` | `string` | No | `"ubuntu"` | -- |
| `ssh_private_key_path` | `string` | Yes | -- | -- |
| `k3s_version` | `string` | No | `"v1.31.12+k3s1"` | Starts with `v` |
| `k3s_ansible_path` | `string` | No | `"${path.module}/vendor/k3s-ansible"` | -- |
| `extra_server_args` | `string` | No | `""` | -- |
| `extra_agent_args` | `string` | No | `""` | -- |
| `api_endpoint` | `string` | No | `null` (defaults to first server IP) | -- |

**Providers required:**

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    ansible = {
      source  = "ansible/ansible"
      version = "~> 1.4"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
```

**Outputs:** `k3s_token` (sensitive), `api_endpoint`, `kubeconfig_command` (string: `ssh -i <key> <user>@<server> sudo cat /etc/rancher/k3s/k3s.yaml`)

**Design notes:**

- k3s-ansible is vendored as a Git submodule at `vendor/k3s-ansible/` within the module
- The `action` block runs k3s-ansible's `site.yml` against the dynamic inventory
- Token is generated via `random_password` and passed as an `extra_var`
- The module assumes instances are already provisioned and SSH-accessible
- Cloud-init should be used on compute instances to install Python 3 (required by Ansible)

**Test scenarios:**

1. Plan-only test with mock IPs (action blocks cannot be tested in `terraform test`)
2. Variable validation tests (empty server_ips, invalid k3s_version)

---

## 7. Example Implementation Plan

### Example 1: `examples/free-tier-kubernetes-oke` (in modules repo)

```
examples/free-tier-kubernetes-oke/
  main.tf          # VCN, subnets (x3), NSGs (x3), OKE cluster, node pool
  variables.tf     # compartment_id, region, ssh_public_key, k8s_version, node_count
  outputs.tf       # cluster_id, kubeconfig_command, node_ips, lb_subnet_id
  providers.tf     # OCI provider config
  README.md        # Usage, prerequisites, free tier warnings
```

**`main.tf` structure:**

```hcl
# 1. Read OCI profile
module "oci_profile_reader" { ... }

# 2. Create compartment (optional, can use existing)
module "k8s_compartment" { source = "../../oci/identity" }

# 3. VCN with all gateways
module "k8s_vcn" {
  source                 = "../../oci/vcn"
  create_internet_gateway = true
  create_nat_gateway      = true
  create_service_gateway  = true
  vcn_dns_label          = "k8svcn"
}

# 4. Three subnets
module "api_endpoint_subnet" {
  source           = "../../oci/subnet"
  subnet_cidr_block = "10.0.1.0/24"
  route_table_id   = module.k8s_vcn.public_route_table_id
  subnet_dns_label = "apiep"
}
module "worker_subnet" {
  source                    = "../../oci/subnet"
  subnet_cidr_block         = "10.0.2.0/24"
  prohibit_internet_ingress = true
  route_table_id            = module.k8s_vcn.private_route_table_id
  subnet_dns_label          = "workers"
}
module "lb_subnet" {
  source           = "../../oci/subnet"
  subnet_cidr_block = "10.0.3.0/24"
  route_table_id   = module.k8s_vcn.public_route_table_id
  subnet_dns_label = "lbsub"
}

# 5. NSGs (api_endpoint, workers, load_balancer)
module "api_endpoint_nsg" { source = "../../oci/network_security_group" }
module "worker_nsg"       { source = "../../oci/network_security_group" }
module "lb_nsg"           { source = "../../oci/network_security_group" }

# 6. OKE cluster
module "oke_cluster" {
  source              = "../../oci/oke_cluster"
  cluster_name        = "free-tier-oke"
  kubernetes_version  = var.kubernetes_version
  endpoint_subnet_id  = module.api_endpoint_subnet.subnet_id
  endpoint_nsg_ids    = [module.api_endpoint_nsg.nsg_id]
  service_lb_subnet_ids = [module.lb_subnet.subnet_id]
}

# 7. Node pool
module "oke_node_pool" {
  source                    = "../../oci/oke_node_pool"
  cluster_id                = module.oke_cluster.cluster_id
  node_pool_name            = "free-tier-arm-pool"
  node_shape                = "VM.Standard.A1.Flex"
  node_shape_ocpus          = 1
  node_shape_memory_in_gbs  = 6
  node_count                = 2
  kubernetes_version        = var.kubernetes_version
  subnet_id                 = module.worker_subnet.subnet_id
  nsg_ids                   = [module.worker_nsg.nsg_id]
  boot_volume_size_in_gbs   = 50
}
```

### Example 2: `examples/free-tier-k3s-cluster` (in modules repo)

```
examples/free-tier-k3s-cluster/
  main.tf          # VCN, subnet, security_list, compute (x5), k3s_cluster
  variables.tf     # compartment_id, region, k3s_version, ssh_private_key_path
  outputs.tf       # server_ip, agent_ips, kubeconfig_command
  providers.tf     # OCI + Ansible provider config
  cloud-init.yaml  # Install Python 3 for Ansible
  README.md        # Usage, prerequisites, Ansible requirement
```

**`main.tf` structure:**

```hcl
# 1. Read OCI profile
module "oci_profile_reader" { ... }

# 2. VCN with internet gateway
module "k3s_vcn" {
  source                 = "../../oci/vcn"
  create_internet_gateway = true
  vcn_dns_label          = "k3svcn"
}

# 3. Public subnet
module "k3s_subnet" {
  source           = "../../oci/subnet"
  subnet_cidr_block = "10.0.0.0/24"
  route_table_id   = module.k3s_vcn.public_route_table_id
  subnet_dns_label = "k3ssub"
}

# 4. Security list with K3s rules
module "k3s_security_list" {
  source = "../../oci/security_list"
  ingress_security_rules = [
    { protocol = "6", source = "10.0.0.0/16", description = "Intra-VCN" },
    { protocol = "6", source = "0.0.0.0/0", tcp_options = { min = 22, max = 22 }, description = "SSH" },
    { protocol = "6", source = "0.0.0.0/0", tcp_options = { min = 6443, max = 6443 }, description = "K3s API" },
    { protocol = "6", source = "0.0.0.0/0", tcp_options = { min = 80, max = 80 }, description = "HTTP" },
    { protocol = "6", source = "0.0.0.0/0", tcp_options = { min = 443, max = 443 }, description = "HTTPS" },
  ]
  egress_security_rules = [
    { protocol = "all", destination = "0.0.0.0/0", description = "All outbound" },
  ]
}

# 5. SSH keypair
resource "tls_private_key" "k3s" { algorithm = "ED25519" }
resource "local_sensitive_file" "ssh_key" {
  content         = tls_private_key.k3s.private_key_openssh
  filename        = "${path.module}/.ssh/k3s-key"
  file_permission = "0600"
}

# 6. K3s server (Arm A1.Flex - 1 OCPU, 6 GB)
# Note: 4 nodes × 50 GB boot = 200 GB exactly (storage limit).
# For mixed-arch (2 Arm + 2 AMD), swap modules 7 and 8 below and adjust
# agent_ips accordingly; AMD Micro boot volumes are 50 GB each (200 GB total).
module "k3s_server" {
  source                = "../../oci/compute"
  shape                 = "VM.Standard.A1.Flex"
  shape_ocpus           = 1
  shape_memory_in_gbs   = 6
  instance_display_name = "k3s-server"
  ssh_authorized_keys   = tls_private_key.k3s.public_key_openssh
  user_data             = base64encode(file("${path.module}/cloud-init.yaml"))
  assign_public_ip      = true
}

# 7. K3s Arm agents (3x A1.Flex - 1 OCPU, 6 GB each)
# Together with the server: 4 × 1 OCPU + 4 × 6 GB = 4 OCPU + 24 GB (exactly the free limit).
# 4 × 50 GB boot = 200 GB (exactly the storage limit).
module "k3s_arm_agent" {
  count                 = 3
  source                = "../../oci/compute"
  shape                 = "VM.Standard.A1.Flex"
  shape_ocpus           = 1
  shape_memory_in_gbs   = 6
  instance_display_name = "k3s-arm-agent-${count.index + 1}"
  ssh_authorized_keys   = tls_private_key.k3s.public_key_openssh
  user_data             = base64encode(file("${path.module}/cloud-init.yaml"))
  assign_public_ip      = true
}

# 8. Deploy K3s via Ansible
module "k3s_cluster" {
  source               = "../../oci/k3s_cluster"
  server_ips           = [module.k3s_server.instance_public_ip]
  agent_ips            = [for agent in module.k3s_arm_agent : agent.instance_public_ip]
  ssh_private_key_path = local_sensitive_file.ssh_key.filename
  ssh_user             = "ubuntu"
}
```

**`cloud-init.yaml`:**

```yaml
#cloud-config
package_update: true
packages:
  - python3
  - python3-pip
runcmd:
  - echo "Cloud-init complete" > /tmp/cloud-init-done
```

---

## 8. Testing Strategy

### Module-Level Testing (Native Terraform Tests)

Each new module gets a `tests/<module>.tftest.hcl` file with:

| Test Type | Description | Example |
|-----------|-------------|---------|
| Validation tests | Verify variable constraints reject invalid inputs | Invalid OCID, out-of-range ports |
| Plan tests | Verify resource creation with default and custom values | `run { command = plan }` |
| Default tests | Verify sensible defaults are applied | Cluster type = BASIC_CLUSTER |

**Note:** `action` blocks (used in `oci/k3s_cluster`) cannot be tested via `terraform test` -- only plan-level and validation tests are possible.

### Integration Testing (Manual/CI)

| Phase | Test | How to Verify |
|-------|------|---------------|
| 1. Infrastructure | VCN, subnets, NSGs/security lists created | `terraform apply` succeeds, `terraform output` shows IDs |
| 2. OKE Cluster | Cluster reaches `ACTIVE` state | `oci ce cluster get --cluster-id <id> \| jq '.data."lifecycle-state"'` |
| 3. OKE Node Pool | Nodes reach `ACTIVE` state | `oci ce node-pool get --node-pool-id <id>` |
| 4. kubectl | Can connect and list nodes | `kubectl get nodes` shows Ready nodes |
| 5. Workload | Deploy nginx, expose via LB | `kubectl create deployment nginx --image=nginx && kubectl expose deployment nginx --type=LoadBalancer --port=80` |
| 6. K3s Cluster | Ansible playbook completes successfully | Terraform apply succeeds, no Ansible errors |
| 7. K3s kubectl | Can connect and list nodes | `ssh <server> sudo kubectl get nodes` |
| 8. K3s Workload | Deploy nginx on K3s | Same as step 5, via K3s kubeconfig |

### Free Tier Compliance Checks

| Check | How |
|-------|-----|
| Block storage <= 200 GB | `oci bv volume list --compartment-id <id> \| jq '[.data[]."size-in-gbs"] \| add // 0'` |
| Compute instances within limits | `oci compute instance list --compartment-id <id> \| jq '.data[] \| {shape: .shape, state: ."lifecycle-state"}'` |
| LB count <= 1 | `oci lb load-balancer list --compartment-id <id> \| jq '.data \| length'` |
| NLB count <= 1 | `oci nlb network-load-balancer list --compartment-id <id> \| jq '.data \| length'` |

---

## 9. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Idle instance reclamation** | Oracle reclaims instances with <20% CPU/network/memory utilization over 7 days | Medium | K8s/K3s processes keep nodes active; add dummy workloads if needed; monitor via OCI Monitoring |
| **Arm image availability** | Some container images lack arm64 support | Medium | Use multi-arch images; build arm64 images; AMD Micro agents run amd64 images (K3s) |
| **A1.Flex capacity** | New Always Free accounts may face A1.Flex capacity limits (429 "Out of host capacity") | High for new accounts | Retry with exponential backoff; try different ADs; OCI capacity improves over time |
| **Boot volume storage exhaustion** | 200 GB limit shared across all volumes | Low | Conservative defaults (50 GB boot); document aggregate tracking |
| **K3s mixed-arch scheduling** | Workloads scheduled on wrong architecture | Low | Node labels (`kubernetes.io/arch`) auto-applied; use `nodeSelector` or affinity rules |
| **Terraform 1.14 `action` maturity** | `action` blocks are new (Nov 2025); potential breaking changes | Medium | Pin provider versions; vendor k3s-ansible; test upgrades in isolation |
| **Ansible provider dependency** | Requires `ansible-playbook` binary on Terraform runner | Low | Document prerequisite; cloud-init installs Python 3 on nodes; CI uses ansible Docker image |
| **OKE version lag** | Oracle may not offer latest K8s versions immediately | Low | Use `data.oci_containerengine_cluster_option` to discover available versions |
| **Network egress limits** | 10 TB/month free; K8s pull traffic from container registries | Very low | 10 TB is generous; use regional OCI Container Registry to reduce egress |
| **Single server K3s** | No HA for control plane in K3s approach | Medium | Acceptable for free tier (lab/learning); document limitation; etcd data on local disk |

---

## 10. References

### OCI Documentation

| Topic | URL |
|-------|-----|
| Always Free Resources | <https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm> |
| OKE Cluster Types | <https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengclustersnodes.htm> |
| OKE Network Config | <https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengnetworkconfig.htm> |

### Terraform Provider Documentation

| Provider | Resource | URL |
|----------|----------|-----|
| oracle/oci | `oci_containerengine_cluster` | <https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_cluster> |
| oracle/oci | `oci_containerengine_node_pool` | <https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/containerengine_node_pool> |
| oracle/oci | `oci_core_network_security_group` | <https://registry.terraform.io/providers/oracle/oci/latest/docs/resources/core_network_security_group> |
| ansible/ansible | `ansible_playbook` / `ansible_playbook_run` | <https://registry.terraform.io/providers/ansible/ansible/latest/docs> |

### Reference Implementations (OKE)

| Repo | Stars | Key Pattern |
|------|-------|-------------|
| [galovics/free-kubernetes-oracle-cloud-terraform](https://github.com/galovics/free-kubernetes-oracle-cloud-terraform) | 62 | OKE + 2 A1.Flex nodes (1 OCPU, 6 GB each) |
| [nce/oci-free-cloud-k8s](https://github.com/nce/oci-free-cloud-k8s) | 233 | OKE + 2 A1.Flex nodes (2 OCPU, 12 GB each) + Flux GitOps |
| [ystory/terraform-oci-always-free-oke](https://github.com/ystory/terraform-oci-always-free-oke) | 12 | OKE via oracle-terraform-modules/oke module + bastion |

### Reference Implementations (Self-Managed K8s on OCI)

| Repo | Stars | Key Pattern |
|------|-------|-------------|
| [jpetazzo/ampernetacle](https://github.com/jpetazzo/ampernetacle) | 2,692 | kubeadm + 4 A1.Flex + cloud-init provisioning |
| [robinlieb/terraform-oci-free-tier-kubernetes](https://github.com/robinlieb/terraform-oci-free-tier-kubernetes) | 38 | kubeadm + 4 A1.Flex + Flannel + OCI Cloud Controller |

### Blog Posts

| Title | URL |
|-------|-----|
| Free Kubernetes Cluster on Oracle Cloud | <https://arnoldgalovics.com/free-kubernetes-oracle-cloud/> |
| Oracle Cloud Kubernetes with Terraform | <https://arnoldgalovics.com/oracle-cloud-kubernetes-terraform/> |

### K3s / Ansible

| Resource | URL |
|----------|-----|
| k3s-ansible playbooks | <https://github.com/k3s-io/k3s-ansible> |
| Terraform Ansible Provider | <https://registry.terraform.io/providers/ansible/ansible/latest/docs> |
| Terraform 1.14 Action Blocks | <https://developer.hashicorp.com/terraform/language/resources/ephemeral/action> |

### Existing Module Conventions

| Resource | Path |
|----------|------|
| Module development plan | `terraform-oci-free-tier-modules/docs/plans/2026-04-02-oci-free-tier-modules-plan.md` |
| Gold standard module (budget) | `terraform-oci-free-tier-modules/oci/budget/` |
| Compute module (reference for node shapes) | `terraform-oci-free-tier-modules/oci/compute/` |
| VCN module (reference for networking) | `terraform-oci-free-tier-modules/oci/vcn/` |

---

## Implementation Sequence

### Phase 1: Shared Infrastructure Modules (Priority 1)

> Implement in `terraform-oci-free-tier-modules` repo. These modules are needed by both OKE and K3s approaches.

- [ ] **Task 1:** Create `oci/network_security_group` module
- [ ] **Task 2:** Create `oci/security_list` module
- [ ] **Task 3:** Run `pre-commit run --all-files` and verify CI passes

### Phase 2: OKE Modules (Priority 2)

> Implement in `terraform-oci-free-tier-modules` repo. Depends on Phase 1.

- [ ] **Task 4:** Create `oci/oke_cluster` module
- [ ] **Task 5:** Create `oci/oke_node_pool` module
- [ ] **Task 6:** Create `examples/free-tier-kubernetes-oke` example
- [ ] **Task 7:** Run `pre-commit run --all-files` and verify CI passes

### Phase 3: K3s Module (Priority 3)

> Implement in `terraform-oci-free-tier-modules` repo. Depends on Phase 1.

- [ ] **Task 8:** Vendor k3s-ansible as Git submodule in `oci/k3s_cluster/vendor/`
- [ ] **Task 9:** Create `oci/k3s_cluster` module (Ansible provider action)
- [ ] **Task 10:** Create `examples/free-tier-k3s-cluster` example
- [ ] **Task 11:** Run `pre-commit run --all-files` and verify CI passes

### Phase 4: Infra Repo Integration (Post-merge)

> Implement in `terraform-oci-free-tier-infra` repo after module tags are created.

- [ ] **Task 12:** Create `ddyyconsulting/kubernetes/` directory with OKE or K3s deployment referencing tagged modules
- [ ] **Task 13:** Update module source refs to tagged versions
- [ ] **Task 14:** Test end-to-end deployment
