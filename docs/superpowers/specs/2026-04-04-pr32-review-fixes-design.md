# PR #32 Code Review Fixes

## Summary

Two targeted fixes from the code review of `feat/examples-refactor`:

1. Align example provider version constraints with modules (`~> 8.0` → `>= 6.0`)
2. Add missing `validation` blocks to string variables in `dual-tenancy`

## Fix 1: Provider Version Alignment

**Files:** `examples/free-tier-compute-stack/providers.tf`, `examples/dual-tenancy/providers.tf`

Change `version = "~> 8.0"` to `version = ">= 6.0"` in both files. This matches the constraint used by every module in `oci/`, avoids implying OCI 8.x is required, and keeps examples consistent with the modules they consume.

## Fix 2: Variable Validations in `dual-tenancy`

**File:** `examples/dual-tenancy/variables.tf`

Add non-empty `validation` blocks to `profile1`, `profile2`, and `alert_recipients`. `budget_amount` already has validation. Pattern to follow (already present in other modules):

```hcl
validation {
  condition     = length(trimspace(var.profile1)) > 0
  error_message = "profile1 must not be empty."
}
```

## Out of Scope

- Issue A (`BASE_REF` guard): already present in current workflow code
- Issue D (no default OCI provider): not a real issue — `oci_profile_reader` has no OCI requirement
