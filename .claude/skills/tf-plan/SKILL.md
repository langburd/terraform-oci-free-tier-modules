---
name: tf-plan
description: Run terraform init + plan on an example directory to validate module changes end-to-end. Use when the user says "run a plan", "test this against an example", "does the plan work", or wants to check that module changes don't break a real deployment scenario.
disable-model-invocation: true
---

Run a Terraform plan in an example directory to validate module changes end-to-end. Use $ARGUMENTS to determine which example. If not specified, ask the user.

Available examples:
- `dual-tenancy` — multi-tenancy auth with oci_profile_reader
- `free-tier-arm-server` — A1 Flex + VCN + block volume
- `free-tier-compute-stack` — VCN + subnets + AMD Micro + bastion
- `free-tier-databases` — Autonomous DB + MySQL + NoSQL
- `free-tier-k3s-cluster` — K3s cluster
- `free-tier-kubernetes-oke` — OKE cluster with node pool
- `free-tier-web-app` — 2x AMD Micro + flexible load balancer + VCN
- `free-tier-observability` — monitoring + logging + APM + connector hub + notifications
- `free-tier-security` — Vault + software key + root CA + TLS certificate

Steps:
1. `cd examples/<example_dir>`
2. `terraform init` — initialize
3. `terraform plan` — preview changes

Show the plan output and summarize any errors or warnings.
