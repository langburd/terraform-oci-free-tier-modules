resource "oci_ons_notification_topic" "this" {
  compartment_id = var.compartment_id
  name           = var.topic_name
  description    = var.topic_description
  defined_tags   = var.notifications_defined_tags
  freeform_tags  = var.notifications_freeform_tags
}

resource "oci_ons_subscription" "this" {
  for_each = var.subscriptions

  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.this.id
  protocol       = each.value.protocol
  endpoint       = each.value.endpoint
}
