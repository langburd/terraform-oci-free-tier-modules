data "oci_objectstorage_namespace" "this" {
  compartment_id = var.compartment_id
}

resource "oci_objectstorage_bucket" "this" {
  compartment_id        = var.compartment_id
  name                  = var.bucket_name
  namespace             = data.oci_objectstorage_namespace.this.namespace
  access_type           = var.bucket_access_type
  storage_tier          = var.storage_tier
  versioning            = var.versioning
  auto_tiering          = var.auto_tiering
  object_events_enabled = var.object_events_enabled
  defined_tags          = var.bucket_defined_tags
  freeform_tags         = var.bucket_freeform_tags
}
