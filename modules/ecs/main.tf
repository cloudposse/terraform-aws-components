locals {
  enabled = module.this.enabled

  dns_enabled = local.enabled && var.route53_enabled

  acm_certificate_domain = length(var.acm_certificate_domain_suffix) > 0 ? format("%s.%s.%s", var.acm_certificate_domain_suffix, var.environment, module.dns_delegated.outputs.default_domain_name) : coalesce(var.acm_certificate_domain, module.dns_delegated.outputs.default_domain_name)

  maintenance_page_fixed_response = {
    content_type = "text/html"
    status_code  = "503"
    message_body = file("${path.module}/${var.maintenance_page_path}")
  }
}

# This is used due to the short limit on target group names i.e. 32 characters
module "target_group_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name = "default"

  tenant      = ""
  namespace   = ""
  stage       = ""
  environment = ""

  context = module.this.context
}

resource "aws_ecs_cluster" "default" {
  count = local.enabled ? 1 : 0

  name = module.this.id

  # TODO: configuration.execute_command_configuration
  # execute_command_configuration {
  #   kms_key_id =
  #   logging = "OVERRIDE" # "DEFAULT"
  #   # log_configuration is required when logging is set to "OVERRIDE"
  #   log_configuration {
  #     cloud_watch_encryption_enabled = var.cloud_watch_encryption_enabled
  #     cloud_watch_log_group_name     = module.cloudwatch_log_group.name
  #     s3_bucket_name                 = module.logging_bucket.name
  #     s3_bucket_encryption_enabled   = true
  #     s3_key_prefix                  = "/"
  #   }
  # }

  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }

  tags = module.this.tags
}

# TODO: setup capacity providers
# resource "aws_ecs_cluster_capacity_providers" "default" {
#   count = local.enabled ? 1 : 0
#
#   cluster_name = join("", aws_ecs_cluster.default[*].name)
#
#   capacity_providers = ["FARGATE"]
#
#   default_capacity_provider_strategy {
#     base              = 1
#     weight            = 100
#     capacity_provider = "FARGATE"
#   }
# }

resource "aws_route53_record" "default" {
  for_each = local.dns_enabled ? var.alb_configuration : {}
  zone_id  = module.dns_delegated.outputs.default_dns_zone_id
  name     = format("%s.%s", lookup(each.value, "route53_record_name", var.route53_record_name), var.environment)
  type     = "A"

  alias {
    name                   = module.alb[each.key].alb_dns_name
    zone_id                = module.alb[each.key].alb_zone_id
    evaluate_target_health = true
  }
}

data "aws_acm_certificate" "default" {
  count       = local.enabled ? 1 : 0
  domain      = local.acm_certificate_domain
  statuses    = ["ISSUED"]
  most_recent = true
}

module "alb" {
  source  = "cloudposse/alb/aws"
  version = "1.4.0"

  for_each = local.enabled ? var.alb_configuration : {}

  vpc_id          = module.vpc.outputs.vpc_id
  subnet_ids      = var.internal_enabled ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
  ip_address_type = lookup(each.value, "ip_address_type", "ipv4")

  internal = lookup(each.value, "internal_enabled", var.internal_enabled)

  security_group_enabled = lookup(each.value, "security_group_enabled", true)
  security_group_ids     = [module.vpc.outputs.vpc_default_security_group_id]

  http_enabled             = lookup(each.value, "http_enabled", true)
  http_port                = lookup(each.value, "http_port", 80)
  http_redirect            = lookup(each.value, "http_redirect", true)
  http_ingress_cidr_blocks = lookup(each.value, "http_ingress_cidr_blocks", var.alb_ingress_cidr_blocks_http)

  https_enabled             = lookup(each.value, "https_enabled", true)
  https_port                = lookup(each.value, "https_port", 443)
  https_ingress_cidr_blocks = lookup(each.value, "https_ingress_cidr_blocks", var.alb_ingress_cidr_blocks_https)
  certificate_arn           = lookup(each.value, "certificate_arn", one(data.aws_acm_certificate.default[*].arn))

  access_logs_enabled                             = lookup(each.value, "access_logs_enabled", true)
  alb_access_logs_s3_bucket_force_destroy         = lookup(each.value, "alb_access_logs_s3_bucket_force_destroy", true)
  alb_access_logs_s3_bucket_force_destroy_enabled = lookup(each.value, "alb_access_logs_s3_bucket_force_destroy_enabled", true)

  lifecycle_rule_enabled = lookup(each.value, "lifecycle_rule_enabled", true)

  expiration_days                    = lookup(each.value, "expiration_days", 90)
  noncurrent_version_expiration_days = lookup(each.value, "noncurrent_version_expiration_days", 90)
  standard_transition_days           = lookup(each.value, "standard_transition_days", 30)
  noncurrent_version_transition_days = lookup(each.value, "noncurrent_version_transition_days", 30)

  enable_glacier_transition = lookup(each.value, "enable_glacier_transition", true)
  glacier_transition_days   = lookup(each.value, "glacier_transition_days", 60)

  stickiness                        = lookup(each.value, "stickiness", null)
  cross_zone_load_balancing_enabled = lookup(each.value, "cross_zone_load_balancing_enabled", true)

  target_group_name        = join(module.target_group_label.delimiter, [module.target_group_label.id, each.key])
  target_group_port        = lookup(each.value, "target_group_port", 80)
  target_group_protocol    = lookup(each.value, "target_group_protocol", "HTTP")
  target_group_target_type = lookup(each.value, "target_group_target_type", "ip")

  health_check_interval            = lookup(each.value, "health_check_interval", 300)
  health_check_healthy_threshold   = lookup(each.value, "health_check_healthy_threshold", 2)
  health_check_matcher             = lookup(each.value, "health_check_matcher", "200-399")
  health_check_path                = lookup(each.value, "health_check_path", "/")
  health_check_port                = lookup(each.value, "health_check_port", "traffic-port")
  health_check_timeout             = lookup(each.value, "health_check_timeout", 100)
  health_check_unhealthy_threshold = lookup(each.value, "health_check_unhealthy_threshold", 10)

  deregistration_delay = lookup(each.value, "deregistration_delay", 15)

  # HTTP and HTTPS listeners return a fixed maintenance page for the default action
  listener_http_fixed_response  = local.maintenance_page_fixed_response
  listener_https_fixed_response = local.maintenance_page_fixed_response

  attributes = lookup(each.value, "attributes", [each.key])

  context = module.this.context
}
