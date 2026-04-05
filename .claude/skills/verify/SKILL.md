---
name: verify
description: Run Terraform verification (format, validate, test, docs) before committing or when completing module work. Invoke whenever the user says "check my changes", "verify this", "before I commit", "does this look right", or finishes implementing a module change — even if they don't say "verify".
---

Detect which module or example directories were changed (use `git diff --name-only` if unsure), then run these steps:

1. **Format** — from repo root:
   ```
   terraform fmt -check -recursive
   ```
   If it fails, fix with `terraform fmt -recursive`, then re-check.

2. **Validate** — for each changed module or example directory:
   ```
   terraform init -backend=false
   terraform validate
   ```
   Skip `terraform init` if `.terraform/` already exists in that directory.

3. **Test** — for each changed directory under `oci/` (skip `examples/` — they have no tests):
   ```
   terraform test
   ```

4. **Clean lock files** — before regenerating docs, remove `.terraform/` and `.terraform.lock.hcl` from all `oci/` directories. If these exist when terraform-docs runs, it embeds the resolved provider version (e.g. `8.8.0`) instead of the constraint (`>= 8.0`), which causes CI to fail:
   ```
   find oci -name ".terraform.lock.hcl" -delete && find oci -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null; true
   ```

5. **Docs** — run terraform-docs twice. The first pass modifies README files; the second pass must exit clean to confirm no stale content remains:
   ```
   pre-commit run terraform_docs --all-files
   pre-commit run terraform_docs --all-files
   ```
   Both runs must succeed. If only the first fails but the second passes, that's expected — it just means docs were stale and have been regenerated.

Report results as a table: directory | step | status | notes.
