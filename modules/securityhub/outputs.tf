output "enabled_subscriptions" {
  description = "A list of subscriptions that have been enabled"
  value       = local.enabled && local.is_global_collector_account ? module.security_hub[0].enabled_subscriptions : []
}
