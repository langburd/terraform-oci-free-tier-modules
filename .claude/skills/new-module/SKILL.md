---
name: new-module
description: Scaffold a new OCI Terraform module with all required files matching project conventions. Use when the user asks to create, add, or build a new module — even if they don't say "scaffold". Any request to create a new resource type under oci/ should trigger this skill.
disable-model-invocation: false
---

# New Module Scaffold

Create a new module under `oci/<module_name>/` with this exact structure:

```
oci/<module_name>/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── README.md
└── tests/<module_name>.tftest.hcl
```

If `$ARGUMENTS` is provided, use it as the module name. Otherwise ask the user.

## File Templates

### providers.tf
```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 8.0, < 9.0"
    }
  }
}
```

### variables.tf
Order: `compartment_id` first, then required inputs (no default), then optional inputs (with default).

```hcl
variable "compartment_id" {
  description = "The OCID of the compartment to create the resource in."
  type        = string

  validation {
    condition     = can(regex("^ocid1\\.compartment\\.[a-z][a-z0-9-]*\\.[a-z0-9-]*\\.[a-z0-9]+$", var.compartment_id))
    error_message = "compartment_id must be a valid compartment OCID."
  }
}
```

### main.tf
Use `"this"` as the resource name for singleton resources. Use `count` for on/off conditionals, `for_each` for collections.

### outputs.tf
Mark outputs `sensitive = true` when they contain connection strings, URLs, private keys, passwords, or session tokens.

### README.md
```markdown
# oci/<module_name>

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
```

**The two marker lines are the complete README body — nothing goes between them.** terraform-docs fills that section automatically when pre-commit runs. Writing inputs/outputs tables or any other content between the markers causes CI to fail on the next pre-commit run because it gets overwritten.

### tests/<module_name>.tftest.hcl
```hcl
mock_provider "oci" {}

# 1. Defaults run — required inputs only
run "defaults" {
  command = plan

  variables {
    compartment_id = "ocid1.compartment.oc1..aaaaaaaa"
  }

  assert {
    condition     = <resource>.<name>.<attr> == <expected>
    error_message = "Expected <attr> to be <expected>."
  }
}

# 2. Custom-inputs run — exercise optional inputs
run "custom_inputs" {
  command = plan

  variables {
    compartment_id = "ocid1.compartment.oc1..aaaaaaaa"
    # set optional vars here
  }
}

# 3. One rejection run per validation block
run "rejects_invalid_compartment_id" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [var.compartment_id]
}
```

Every module test MUST include all three run types. Add one rejection run per `validation` block in variables.tf.

## After Scaffolding

1. Run `terraform init && terraform test` from `oci/<module_name>/` to verify tests pass.
2. Run `pre-commit run --all-files` from the repo root (with no `.terraform.lock.hcl` present) to generate the README docs section and verify formatting.
3. Add an entry for the new module in the root `README.md` inventory table.
