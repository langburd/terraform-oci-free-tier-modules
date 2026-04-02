---
name: verify
description: Run Terraform formatting check, validation, and docs generation to verify module changes are correct. Use before committing or when asked to check work.
---

Run the following verification steps. Detect which module or example directory was changed and run validation there:

1. `terraform fmt -check -recursive` — check formatting from repo root (fix with `terraform fmt -recursive` if needed)
2. For each changed module/example directory:
   - `terraform init -backend=false` — initialize without backend (if .terraform doesn't exist)
   - `terraform validate` — validate configuration
3. `pre-commit run terraform_docs --all-files` — regenerate docs

Report results as a table: directory, step, status (pass/fail), and any error details.
