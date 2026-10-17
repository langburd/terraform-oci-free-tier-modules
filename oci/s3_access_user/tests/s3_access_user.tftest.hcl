mock_provider "oci" {
  mock_resource "oci_identity_group" {
    defaults = {
      id = "ocid1.group.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    }
  }
}

variables {
  tenancy_id     = "ocid1.tenancy.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  name           = "app-s3"
  bucket_names   = ["app-data", "app-backup"]
}

run "creates_user_group_and_key" {
  command = plan

  assert {
    condition     = oci_identity_user.this.name == "app-s3" && oci_identity_user.this.compartment_id == var.tenancy_id
    error_message = "user should be created in the tenancy with the given name"
  }

  assert {
    condition     = oci_identity_group.this.name == "app-s3" && oci_identity_group.this.compartment_id == var.tenancy_id
    error_message = "group should be created in the tenancy with the given name"
  }

  assert {
    condition     = oci_identity_customer_secret_key.this.display_name == "app-s3"
    error_message = "customer secret key should be named after the user"
  }

  assert {
    condition     = oci_identity_policy.this.compartment_id == var.compartment_id
    error_message = "policy should live in the bucket compartment"
  }
}

run "policy_is_scoped_to_buckets" {
  command = apply

  assert {
    condition = oci_identity_policy.this.statements == tolist([
      "Allow group id ocid1.group.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa to read buckets in compartment id ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa where any {target.bucket.name = 'app-data', target.bucket.name = 'app-backup'}",
      "Allow group id ocid1.group.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa to manage objects in compartment id ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa where any {target.bucket.name = 'app-data', target.bucket.name = 'app-backup'}",
    ])
    error_message = "policy should grant read buckets + manage objects on the listed buckets only"
  }
}

run "rejects_empty_bucket_names" {
  command = plan

  variables {
    bucket_names = []
  }

  expect_failures = [
    var.bucket_names,
  ]
}

run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_names = ["bad name'"]
  }

  expect_failures = [
    var.bucket_names,
  ]
}

run "rejects_invalid_name" {
  command = plan

  variables {
    name = "bad name"
  }

  expect_failures = [
    var.name,
  ]
}

run "rejects_invalid_tenancy_ocid" {
  command = plan

  variables {
    tenancy_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.tenancy_id,
  ]
}

run "rejects_invalid_compartment_ocid" {
  command = plan

  variables {
    compartment_id = "not-a-valid-ocid"
  }

  expect_failures = [
    var.compartment_id,
  ]
}
