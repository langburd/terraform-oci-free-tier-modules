# terraform-oci-free-tier-modules

Collection of terraform modules for full use of Oracle Cloud Free Tier

## Versioning and Releases

Modules are automatically versioned and released via [techpivot/terraform-module-releaser](https://github.com/techpivot/terraform-module-releaser) on every PR merge to `master`.

Each module under `oci/` gets its own semver tag (e.g., `oci/budget/v1.2.0`) and GitHub Release. Version bumps follow [Conventional Commits](https://www.conventionalcommits.org/):

| Commit type | Version bump |
|---|---|
| `feat!:` or `BREAKING CHANGE:` footer | major |
| `feat:` | minor |
| `fix:`, `chore:`, etc. | patch |

Module documentation is published to the [repository wiki](../../wiki) automatically.
