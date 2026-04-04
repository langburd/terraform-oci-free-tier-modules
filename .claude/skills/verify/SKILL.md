---
name: verify
description: Run Terraform formatting check, validation, and docs generation to verify module changes are correct. Use before committing or when asked to check work.
---

Run the following verification steps. Detect which module or example directory was changed and run validation there:

1. `terraform fmt -check -recursive` — check formatting from repo root (fix with `terraform fmt -recursive` if needed)
2. For each changed module/example directory:
   - `terraform init -backend=false` — initialize without backend (if .terraform doesn't exist)
   - `terraform validate` — validate configuration
3. For each changed module directory under `oci/` (skip `examples/` — they have no tests):
   - `terraform test` — run the module's test suite (already initialized above)
4. Before regenerating docs, delete all `.terraform/` dirs and `.terraform.lock.hcl` files from `oci/` — otherwise terraform-docs embeds the resolved provider version instead of the constraint string, causing CI to fail:
   ```
   find oci -name ".terraform.lock.hcl" -delete && find oci -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null; true
   ```
5. `pre-commit run terraform_docs --all-files` — regenerate docs (run twice; first run modifies files, second confirms clean)

Report results as a table: directory, step, status (pass/fail), and any error details.
