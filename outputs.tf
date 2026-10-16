output "bucket_name" {
  description = "Name of the object storage bucket."
  value       = oci_objectstorage_bucket.this.name
}

output "bucket_namespace" {
  description = "Object storage namespace for the bucket."
  value       = data.oci_objectstorage_namespace.this.namespace
}

output "bucket_id" {
  description = "Bucket ID of the object storage bucket."
  value       = oci_objectstorage_bucket.this.bucket_id
}
