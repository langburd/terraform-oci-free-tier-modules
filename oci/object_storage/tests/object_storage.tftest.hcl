mock_provider "oci" {}

variables {
  compartment_id = "ocid1.compartment.oc1..aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  bucket_name    = "my-bucket"
}

run "default_bucket" {
  command = plan

  assert {
    condition     = oci_objectstorage_bucket.this.access_type == "NoPublicAccess"
    error_message = "access_type should default to NoPublicAccess"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.storage_tier == "Standard"
    error_message = "storage_tier should default to Standard"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.versioning == "Enabled"
    error_message = "versioning should default to Enabled"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.auto_tiering == "Disabled"
    error_message = "auto_tiering should default to Disabled"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.object_events_enabled == true
    error_message = "object_events_enabled should default to true"
  }
}

run "public_read_access" {
  command = plan

  variables {
    bucket_access_type  = "ObjectRead"
    allow_public_access = true
  }

  assert {
    condition     = oci_objectstorage_bucket.this.access_type == "ObjectRead"
    error_message = "access_type should be ObjectRead"
  }
}

run "rejects_public_access_without_guard" {
  command = plan

  variables {
    bucket_access_type = "ObjectRead"
  }

  expect_failures = [
    var.bucket_access_type,
  ]
}

run "archive_tier" {
  command = plan

  variables {
    storage_tier = "Archive"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.storage_tier == "Archive"
    error_message = "storage_tier should be Archive"
  }
}

run "versioning_enabled" {
  command = plan

  variables {
    versioning = "Enabled"
  }

  assert {
    condition     = oci_objectstorage_bucket.this.versioning == "Enabled"
    error_message = "versioning should be Enabled"
  }
}

run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "invalid name!"
  }

  expect_failures = [
    var.bucket_name,
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
