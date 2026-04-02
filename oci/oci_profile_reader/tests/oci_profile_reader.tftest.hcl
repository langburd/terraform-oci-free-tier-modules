run "rejects_empty_profile_name" {
  command = plan

  variables {
    profile_name = ""
  }

  expect_failures = [
    var.profile_name,
  ]
}
