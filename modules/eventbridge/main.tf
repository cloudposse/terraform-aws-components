locals {
  enabled     = module.this.enabled
  description = var.cloudwatch_event_rule_description != "" ? var.cloudwatch_event_rule_description : module.this.id
}

module "cloudwatch_logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.8"
  count   = local.enabled ? 1 : 0

  retention_in_days = var.event_log_retention_in_days

  context = module.this.context
}

module "cloudwatch_event" {
  source  = "cloudposse/cloudwatch-events/aws"
  version = "0.7.0"
  count   = local.enabled ? 1 : 0

  cloudwatch_event_rule_description = local.description
  cloudwatch_event_rule_pattern     = var.cloudwatch_event_rule_pattern
  cloudwatch_event_target_arn       = one(module.cloudwatch_logs[*].log_group_arn)

  context = module.this.context
}
