run "rejects_empty_profile_name" {
  command = plan

  variables {
    profile_name = ""
  }

  expect_failures = [
    var.profile_name,
  ]
}

run "rejects_whitespace_only_profile_name" {
  command = plan

  variables {
    profile_name = "   "
  }

  expect_failures = [
    var.profile_name,
  ]
}

# Requires ~/.oci/config to exist with a [DEFAULT] profile.
# In CI this is satisfied by the OCI_CONFIG secret in .github/workflows/pre-commit.yml.
# Running locally requires a DEFAULT profile in ~/.oci/config.
run "accepts_default_profile_name" {
  command = plan

  variables {
    profile_name = "DEFAULT"
  }
}
