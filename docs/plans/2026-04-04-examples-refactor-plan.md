# Examples Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `block_volume` to `free-tier-compute-stack`, replace `two-profiles` and `two-tenancies` with a new `dual-tenancy` example using `oci_profile_reader` + `identity` + `budget`.

**Architecture:** Three independent changes — one module addition to an existing example, one new example directory, one deletion. Each change is validated and committed independently.

**Tech Stack:** Terraform >= 1.6.4, OCI provider ~> 8.0, pre-commit (terraform-fmt, terraform-tflint, terraform-docs)

---

## File Map

### Task 1 — Extend `free-tier-compute-stack`
- Modify: `examples/free-tier-compute-stack/main.tf` — add `module "block_volume"` block
- Modify: `examples/free-tier-compute-stack/outputs.tf` — add `block_volume_id` output
- Auto-updated by pre-commit: `examples/free-tier-compute-stack/README.md` (terraform-docs section)

### Task 2 — Create `dual-tenancy` example
- Create: `examples/dual-tenancy/providers.tf`
- Create: `examples/dual-tenancy/variables.tf`
- Create: `examples/dual-tenancy/main.tf`
- Create: `examples/dual-tenancy/outputs.tf`
- Create: `examples/dual-tenancy/terraform.tfvars`
- Create: `examples/dual-tenancy/README.md`

### Task 3 — Delete old examples
- Delete: `examples/two-profiles/` (entire directory)
- Delete: `examples/two-tenancies/` (entire directory)

---

## Task 1: Add `block_volume` to `free-tier-compute-stack`

**Files:**
- Modify: `examples/free-tier-compute-stack/main.tf`
- Modify: `examples/free-tier-compute-stack/outputs.tf`

- [ ] **Step 1: Add `block_volume` module to `main.tf`**

Append after the `module "compute"` block (after line 72, before the commented-out bastion block):

```hcl
module "block_volume" {
  source              = "../../oci/block_volume"
  compartment_id      = module.compartment.compartment_id
  availability_domain = module.compute.availability_domain
  instance_id         = module.compute.instance_id
  volume_display_name = "free-tier-data-volume"
}
```

The full `main.tf` after the change:

```hcl
locals {
  oci_profile_data = module.oci_profile_reader.oci_profile_data
}

module "oci_profile_reader" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.oci_config_profile
}

module "compartment" {
  source               = "../../oci/identity"
  oci_root_compartment = local.oci_profile_data.tenancy
  compartment_name     = var.compartment_name
}

module "vcn" {
  source                  = "../../oci/vcn"
  compartment_id          = module.compartment.compartment_id
  vcn_display_name        = "free-tier-compute-vcn"
  vcn_cidr_blocks         = ["10.0.0.0/16"]
  create_internet_gateway = true
  create_nat_gateway      = false
}

module "public_subnet" {
  source              = "../../oci/subnet"
  compartment_id      = module.compartment.compartment_id
  vcn_id              = module.vcn.vcn_id
  subnet_cidr_block   = "10.0.1.0/24"
  subnet_display_name = "public-subnet"
  route_table_id      = module.vcn.public_route_table_id
}

module "private_subnet" {
  source                    = "../../oci/subnet"
  compartment_id            = module.compartment.compartment_id
  vcn_id                    = module.vcn.vcn_id
  subnet_cidr_block         = "10.0.2.0/24"
  subnet_display_name       = "private-subnet"
  prohibit_internet_ingress = true
  # No route_table_id: private subnet intentionally has no egress routes.
  # To enable egress, set create_nat_gateway = true on the vcn module
  # and pass route_table_id = module.vcn.private_route_table_id here.
}

# This data source fetches the latest Oracle Linux 8 image for VM.Standard.E2.1.Micro.
# If this fails with an index error, verify that images for this shape exist in your region:
# oci compute image list --compartment-id <tenancy-ocid> \
#   --operating-system "Oracle Linux" --operating-system-version 8
data "oci_core_images" "oracle_linux" {
  compartment_id           = module.compartment.compartment_id
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.E2.1.Micro"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

module "compute" {
  source                = "../../oci/compute"
  compartment_id        = module.compartment.compartment_id
  subnet_id             = module.public_subnet.subnet_id
  image_id              = data.oci_core_images.oracle_linux.images[0].id
  instance_display_name = "free-tier-amd-micro"
  shape                 = "VM.Standard.E2.1.Micro"
  ssh_authorized_keys   = var.ssh_authorized_keys
  assign_public_ip      = true

  compute_freeform_tags = {
    "example" = "free-tier-compute-stack"
  }
}

module "block_volume" {
  source              = "../../oci/block_volume"
  compartment_id      = module.compartment.compartment_id
  availability_domain = module.compute.availability_domain
  instance_id         = module.compute.instance_id
  volume_display_name = "free-tier-data-volume"
}

# Bastion module is part of Phase 3 and not yet available.
# Uncomment when oci/bastion module is released.
# module "bastion" {
#   source                       = "../../oci/bastion"
#   compartment_id               = module.compartment.compartment_id
#   # target_subnet_id points to the private subnet so the bastion bridges into the private tier.
#   target_subnet_id             = module.private_subnet.subnet_id
#   bastion_name                 = "free-tier-bastion"
#   bastion_type                 = "STANDARD"
#   client_cidr_block_allow_list = ["0.0.0.0/0"]
# }
```

- [ ] **Step 2: Add `block_volume_id` output to `outputs.tf`**

Full `outputs.tf` after the change:

```hcl
output "compartment_id" {
  description = "OCID of the created compartment."
  value       = module.compartment.compartment_id
}

output "vcn_id" {
  description = "OCID of the VCN."
  value       = module.vcn.vcn_id
}

output "compute_instance_id" {
  description = "OCID of the compute instance."
  value       = module.compute.instance_id
}

output "compute_public_ip" {
  description = "Public IP address of the compute instance."
  value       = module.compute.instance_public_ip
}

output "block_volume_id" {
  description = "OCID of the block volume attached to the compute instance."
  value       = module.block_volume.volume_id
}
```

- [ ] **Step 3: Validate the configuration**

```bash
cd examples/free-tier-compute-stack
terraform init -upgrade
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 4: Run pre-commit to format and regenerate docs**

```bash
cd /Users/avi.langburd/git/ddyy/terraform-oci-free-tier-modules
pre-commit run --all-files
```

Expected: all checks pass (terraform-docs will update the `<!-- BEGIN_TF_DOCS -->` section in `README.md`). If terraform-fmt reformats any file, that is expected — the reformatted file is correct.

- [ ] **Step 5: Commit**

```bash
git add examples/free-tier-compute-stack/main.tf \
        examples/free-tier-compute-stack/outputs.tf \
        examples/free-tier-compute-stack/README.md
git commit -m "feat(examples): add block_volume to free-tier-compute-stack"
```

---

## Task 2: Create `dual-tenancy` example

**Files:**
- Create: `examples/dual-tenancy/providers.tf`
- Create: `examples/dual-tenancy/variables.tf`
- Create: `examples/dual-tenancy/main.tf`
- Create: `examples/dual-tenancy/outputs.tf`
- Create: `examples/dual-tenancy/terraform.tfvars`
- Create: `examples/dual-tenancy/README.md`

- [ ] **Step 1: Create `providers.tf`**

```hcl
terraform {
  required_version = ">= 1.6.4"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 8.0"
    }
  }
}

provider "oci" {
  alias               = "tenancy1"
  config_file_profile = var.profile1
}

provider "oci" {
  alias               = "tenancy2"
  config_file_profile = var.profile2
}
```

- [ ] **Step 2: Create `variables.tf`**

```hcl
variable "profile1" {
  description = "OCI config profile name for the first tenancy. Must exist in ~/.oci/config."
  type        = string
}

variable "profile2" {
  description = "OCI config profile name for the second tenancy. Must exist in ~/.oci/config."
  type        = string
}

variable "budget_amount" {
  description = "Monthly budget cap in the currency of your OCI rate card. Applied to both tenancies."
  type        = number
  default     = 1
}

variable "alert_recipients" {
  description = "Comma-separated email address(es) to notify when forecasted spend is on track to exceed the budget."
  type        = string
}
```

- [ ] **Step 3: Create `main.tf`**

```hcl
# --- Tenancy 1 ---

module "oci_profile_reader1" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.profile1
}

module "compartment1" {
  source               = "../../oci/identity"
  oci_root_compartment = module.oci_profile_reader1.oci_profile_data.tenancy
  compartment_name     = "tenancy1-compartment"

  providers = {
    oci = oci.tenancy1
  }
}

module "budget1" {
  source                = "../../oci/budget"
  budget_compartment_id = module.oci_profile_reader1.oci_profile_data.tenancy
  budget_targets        = [module.oci_profile_reader1.oci_profile_data.tenancy]
  budget_amount         = var.budget_amount
  alert_recipients      = var.alert_recipients

  providers = {
    oci = oci.tenancy1
  }
}

# --- Tenancy 2 ---

module "oci_profile_reader2" {
  source       = "../../oci/oci_profile_reader"
  profile_name = var.profile2
}

module "compartment2" {
  source               = "../../oci/identity"
  oci_root_compartment = module.oci_profile_reader2.oci_profile_data.tenancy
  compartment_name     = "tenancy2-compartment"

  providers = {
    oci = oci.tenancy2
  }
}

module "budget2" {
  source                = "../../oci/budget"
  budget_compartment_id = module.oci_profile_reader2.oci_profile_data.tenancy
  budget_targets        = [module.oci_profile_reader2.oci_profile_data.tenancy]
  budget_amount         = var.budget_amount
  alert_recipients      = var.alert_recipients

  providers = {
    oci = oci.tenancy2
  }
}
```

- [ ] **Step 4: Create `outputs.tf`**

```hcl
output "compartment1_id" {
  description = "OCID of the compartment created in the first tenancy."
  value       = module.compartment1.compartment_id
}

output "compartment2_id" {
  description = "OCID of the compartment created in the second tenancy."
  value       = module.compartment2.compartment_id
}

output "budget1_id" {
  description = "OCID of the budget for the first tenancy."
  value       = module.budget1.budget_id
}

output "budget2_id" {
  description = "OCID of the budget for the second tenancy."
  value       = module.budget2.budget_id
}
```

- [ ] **Step 5: Create `terraform.tfvars`**

```hcl
profile1         = "TENANCY1"
profile2         = "TENANCY2"
budget_amount    = 1
alert_recipients = "you@example.com"
```

- [ ] **Step 6: Create `README.md`**

```markdown
# dual-tenancy

Demonstrates managing resources across two separate OCI tenancies simultaneously: creating a compartment and a monthly spend budget in each.

## Modules used

- [`oci_profile_reader`](../../oci/oci_profile_reader): reads a named profile from `~/.oci/config` to extract the tenancy OCID
- [`identity`](../../oci/identity): creates a compartment under the tenancy root
- [`budget`](../../oci/budget): sets a monthly spend cap with a forecast email alert

## Prerequisites

Both profiles must exist in `~/.oci/config`. Run `oci setup config` to create or add profiles.

## Usage

Edit `terraform.tfvars` with your profile names and alert email, then:

```sh
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

- [ ] **Step 7: Validate the configuration**

```bash
cd examples/dual-tenancy
terraform init
terraform validate
```

Expected: `Success! The configuration is valid.`

- [ ] **Step 8: Run pre-commit to format and regenerate docs**

```bash
cd /Users/avi.langburd/git/ddyy/terraform-oci-free-tier-modules
pre-commit run --all-files
```

Expected: all checks pass; terraform-docs fills in the `<!-- BEGIN_TF_DOCS -->` section of `README.md`.

- [ ] **Step 9: Commit**

```bash
git add examples/dual-tenancy/
git commit -m "feat(examples): add dual-tenancy example with identity and budget modules"
```

---

## Task 3: Delete `two-profiles`, `two-tenancies`, and `dynamic-profile`

**Files:**
- Delete: `examples/two-profiles/` (entire directory)
- Delete: `examples/two-tenancies/` (entire directory)
- Delete: `examples/dynamic-profile/` (entire directory)

- [ ] **Step 1: Remove all three directories**

```bash
rm -rf examples/two-profiles examples/two-tenancies examples/dynamic-profile
```

- [ ] **Step 2: Confirm they are gone**

```bash
ls examples/
```

Expected output (order may vary):
```
dual-tenancy
free-tier-compute-stack
```

- [ ] **Step 3: Commit**

```bash
git add -A examples/two-profiles examples/two-tenancies examples/dynamic-profile
git commit -m "chore(examples): remove two-profiles, two-tenancies, and dynamic-profile (replaced by dual-tenancy)"
```
