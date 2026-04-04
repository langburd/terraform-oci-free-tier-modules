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
}
