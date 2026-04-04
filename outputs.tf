output "topic_id" {
  description = "OCID of the notification topic resource."
  value       = oci_ons_notification_topic.this.id
}

output "topic_arn" {
  description = "The API endpoint (topic ARN) of the notification topic."
  value       = oci_ons_notification_topic.this.api_endpoint
}

output "subscription_ids" {
  description = "A map of subscription keys to their OCIDs."
  value       = { for k, v in oci_ons_subscription.this : k => v.id }
}
