data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

# WARNING: Retention rules applied to this bucket via the OCI console or separate
# Terraform resources are irreversible until their duration expires. Do not apply
# retention rules to buckets you may need to empty or delete before the retention
# period ends.
resource "oci_objectstorage_bucket" "this" {
  compartment_id        = var.compartment_id
  name                  = var.bucket_name
  namespace             = data.oci_objectstorage_namespace.this.namespace
  access_type           = var.bucket_access_type
  storage_tier          = var.storage_tier
  versioning            = var.versioning
  auto_tiering          = var.auto_tiering
  object_events_enabled = var.object_events_enabled
  kms_key_id            = var.kms_key_id
  defined_tags          = var.bucket_defined_tags
  freeform_tags         = var.bucket_freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# Deletes non-current object versions after previous_version_retention_days. OCI runs
# lifecycle rules as the regional Object Storage service, which needs an IAM grant on
# the bucket; without it the policy is accepted but never acts.
resource "oci_objectstorage_object_lifecycle_policy" "this" {
  count = var.previous_version_retention_days == null ? 0 : 1

  bucket    = oci_objectstorage_bucket.this.name
  namespace = data.oci_objectstorage_namespace.this.namespace

  rules {
    name        = "delete-previous-versions"
    action      = "DELETE"
    target      = "previous-object-versions"
    time_amount = var.previous_version_retention_days
    time_unit   = "DAYS"
    is_enabled  = true
  }

  depends_on = [oci_identity_policy.lifecycle]
}

resource "oci_identity_policy" "lifecycle" {
  count = var.previous_version_retention_days == null ? 0 : 1

  compartment_id = var.compartment_id
  name           = "${var.bucket_name}-lifecycle"
  description    = "Allow Object Storage lifecycle management on bucket ${var.bucket_name}."
  defined_tags   = var.bucket_defined_tags
  freeform_tags  = var.bucket_freeform_tags

  statements = [
    "Allow service objectstorage-${coalesce(var.region, "unset")} to manage object-family in compartment id ${var.compartment_id} where target.bucket.name = '${var.bucket_name}'",
  ]

  lifecycle {
    ignore_changes = [defined_tags]
  }
}
