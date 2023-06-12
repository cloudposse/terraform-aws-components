output "enabled_subscriptions" {
  description = "A list of subscriptions that have been enabled"
  value       = local.enabled && local.is_global_collector_account ? module.security_hub[0].enabled_subscriptions : []
}

output "sns_topic_name" {
  description = "The SNS topic name that was created"
  value       = local.enabled && local.is_global_collector_account && var.create_sns_topic ? module.security_hub[0].sns_topic.name : null
}

output "sns_topic_subscriptions" {
  description = "The SNS topic subscriptions"
  value       = local.enabled && local.is_global_collector_account && var.create_sns_topic ? module.security_hub[0].sns_topic_subscriptions : null
}
