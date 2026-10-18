# Secret names are not sensitive; only their content is. nonsensitive() on the keys lets
# for_each address each secret while the contents stay redacted.
resource "oci_vault_secret" "this" {
  for_each = toset(nonsensitive(keys(var.secrets)))

  compartment_id = var.compartment_id
  vault_id       = var.vault_id
  key_id         = var.key_id
  secret_name    = each.key
  description    = var.secrets[each.key].description
  defined_tags   = var.defined_tags
  freeform_tags  = var.freeform_tags

  secret_content {
    content_type = "BASE64"
    content      = base64encode(var.secrets[each.key].content)
  }

  lifecycle {
    ignore_changes = [defined_tags]
  }
}
