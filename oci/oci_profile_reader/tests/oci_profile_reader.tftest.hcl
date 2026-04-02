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

run "accepts_default_profile_name" {
  command = plan

  variables {
    profile_name = "DEFAULT"
  }
}
