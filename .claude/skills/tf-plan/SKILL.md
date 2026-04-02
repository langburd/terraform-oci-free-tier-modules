---
name: tf-plan
description: Run terraform init and plan on an example directory to validate module changes end-to-end. Use when testing module changes.
disable-model-invocation: true
---

Run a Terraform plan in an example directory to validate module changes. Use $ARGUMENTS to determine which example (dynamic-profile, two-profiles, two-tenancies). If not specified, ask the user.

1. `cd examples/<example_dir>`
2. `terraform init` — initialize
3. `terraform plan` — preview changes

Show the plan output and summarize any errors or warnings.
