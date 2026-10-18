locals {
  bucket_condition = "any {${join(", ", [for b in var.bucket_names : "target.bucket.name = '${b}'"])}}"
}

# IAM users and groups live in the tenancy (root compartment).
resource "oci_identity_user" "this" {
  compartment_id = var.tenancy_id
  name           = var.name
  description    = var.description
  email          = var.email
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# The user only holds a Customer Secret Key: no console password, API keys, auth tokens or SMTP credentials.
resource "oci_identity_user_capabilities_management" "this" {
  user_id                      = oci_identity_user.this.id
  can_use_api_keys             = false
  can_use_auth_tokens          = false
  can_use_console_password     = false
  can_use_customer_secret_keys = true
  can_use_smtp_credentials     = false
}

resource "oci_identity_group" "this" {
  compartment_id = var.tenancy_id
  name           = var.name
  description    = var.description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

resource "oci_identity_user_group_membership" "this" {
  group_id = oci_identity_group.this.id
  user_id  = oci_identity_user.this.id
}

# Read on the bucket (HEAD/GET bucket metadata) and full object access, nothing else:
# the key cannot list or touch any other bucket.
resource "oci_identity_policy" "this" {
  compartment_id = var.compartment_id
  name           = var.name
  description    = var.description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  statements = [
    "Allow group id ${oci_identity_group.this.id} to read buckets in compartment id ${var.compartment_id} where ${local.bucket_condition}",
    "Allow group id ${oci_identity_group.this.id} to manage objects in compartment id ${var.compartment_id} where ${local.bucket_condition}",
  ]

  lifecycle {
    ignore_changes = [defined_tags]
  }
}

# S3-compatible access key pair (access key id = this resource's id, secret = key).
resource "oci_identity_customer_secret_key" "this" {
  display_name = var.name
  user_id      = oci_identity_user.this.id
}
