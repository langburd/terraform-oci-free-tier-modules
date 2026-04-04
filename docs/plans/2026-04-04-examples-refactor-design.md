# Examples Refactor Design

**Date:** 2026-04-04  
**Status:** Approved

## Goal

Improve the `examples/` directory so it collectively showcases all modules in the repository, eliminating redundancy between `two-profiles` and `two-tenancies`.

## Changes

### 1. Add `block_volume` to `free-tier-compute-stack`

`free-tier-compute-stack` currently demonstrates: `oci_profile_reader`, `identity`, `vcn`, `subnet`, `compute`.

Add one `block_volume` module call after the `compute` module:

```hcl
module "block_volume" {
  source              = "../../oci/block_volume"
  compartment_id      = module.compartment.compartment_id
  availability_domain = module.compute.availability_domain
  instance_id         = module.compute.instance_id
  volume_display_name = "free-tier-data-volume"
}
```

- Uses all defaults (50 GB, `paravirtualized` attachment) — Free Tier safe.
- Add output `block_volume_id`.
- No new variables needed.

### 2. New `dual-tenancy` example

Replaces both `two-profiles` and `two-tenancies`. Demonstrates: `oci_profile_reader`, `identity`, `budget` across two tenancies.

**Profile sourcing:** Input variables (`var.profile1` / `var.profile2`) set via `terraform.tfvars`. No extra providers needed.

#### `providers.tf`

- OCI provider `~> 8.0`
- Two aliased providers: `oci.tenancy1` and `oci.tenancy2`, each using `config_file_profile = var.profileN`

#### `variables.tf`

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `profile1` | `string` | — | OCI config profile for first tenancy |
| `profile2` | `string` | — | OCI config profile for second tenancy |
| `budget_amount` | `number` | `1` | Monthly budget cap applied to both tenancies |
| `alert_recipients` | `string` | — | Email(s) for budget alert notifications |

#### `main.tf`

Symmetric per tenancy:

1. `module "oci_profile_reader1/2"` — reads tenancy OCID from `~/.oci/config`
2. `module "compartment1/2"` — creates a compartment using the tenancy OCID as root; passed `providers = { oci = oci.tenancy1/2 }`
3. `module "budget1/2"` — monthly budget targeting root tenancy OCID; `budget_compartment_id` and `budget_targets[0]` both set to the tenancy OCID from the profile reader; `alert_recipients` wired from variable

#### `outputs.tf`

`compartment1_id`, `compartment2_id`, `budget1_id`, `budget2_id`

#### `terraform.tfvars`

Placeholder values:
```hcl
profile1          = "TENANCY1"
profile2          = "TENANCY2"
budget_amount     = 1
alert_recipients  = "you@example.com"
```

### 3. Delete `two-profiles` and `two-tenancies`

Both `examples/two-profiles/` and `examples/two-tenancies/` are removed entirely.

## Module Coverage After Refactor

| Module | Covered by |
|--------|-----------|
| `oci_profile_reader` | `free-tier-compute-stack`, `dual-tenancy` |
| `identity` | `free-tier-compute-stack`, `dual-tenancy`, `dynamic-profile` |
| `vcn` | `free-tier-compute-stack` |
| `subnet` | `free-tier-compute-stack` |
| `compute` | `free-tier-compute-stack` |
| `block_volume` | `free-tier-compute-stack` |
| `budget` | `dual-tenancy` |
| `object_storage` | *(not yet covered — future example)* |
