locals {
  vpc_id          = module.vpc.outputs.vpc_id
  vpc_sg_id       = module.vpc.outputs.vpc_default_security_group_id
  rds_port        = try(one(module.rds[*].outputs.config_map.port), null)
  rds_sg_id       = try(one(module.rds[*].outputs.security_group_id), null)
  subnet_ids      = lookup(module.vpc.outputs.subnets, local.assign_public_ip ? "public" : "private", { ids = [] }).ids
  ecs_cluster_arn = module.ecs_cluster.outputs.cluster.arn

  is_alb = try(length(var.alb_name) > 0, false)
  alb    = try(module.alb[0].outputs, null)

  is_nlb = try(length(var.nlb_name) > 0, false)
  nlb    = try(module.nlb[0].outputs, null)

  use_lb = local.enabled && var.use_lb && (local.is_nlb || local.is_alb)

  lb_arn                       = try(coalesce(local.nlb.nlb_arn, ""), coalesce(local.alb.alb_arn, ""), null)
  lb_name                      = try(coalesce(local.nlb.nlb_name, ""), coalesce(local.alb.alb_name, ""), null)
  lb_listener_http_arn         = try(coalesce(local.nlb.default_listener_arn, ""), coalesce(local.alb.http_listener_arn, ""), null)
  lb_listener_http_is_redirect = try(length(local.is_nlb ? "" : local.alb.http_redirect_listener_arn) > 0, false)
  lb_listener_https_arn        = try(coalesce(local.nlb.default_listener_arn, ""), coalesce(local.alb.https_listener_arn, ""), null)
  lb_listener_arn              = local.lb_listener_http_is_redirect ? local.lb_listener_https_arn : local.lb_listener_http_arn
  lb_sg_id                     = try(local.is_nlb ? null : local.alb.security_group_id, null)
  lb_zone_id                   = try(coalesce(local.nlb.nlb_zone_id, ""), coalesce(local.alb.alb_zone_id, ""), null)
  lb_fqdn                      = try(coalesce(local.nlb.route53_record.fqdn, ""), coalesce(local.alb.route53_record.fqdn, ""), null)

  unauthenticated_paths = local.is_nlb ? ["/"] : var.unauthenticated_paths
  http_protocol         = local.lb_listener_http_is_redirect || try(local.is_nlb && local.nlb.is_443_enabled, false) ? "https" : "http"
  # NOTE: this is the rare _not_ in the ternary purely for readability
  full_urls = !local.use_lb ? [] : [for path in local.unauthenticated_paths : format("%s://%s%s", local.http_protocol, local.lb_fqdn, trimsuffix(trimsuffix(path, "*"), "/"))]

  ## Company specific locals for domain convention
  zone_domain = local.use_lb ? local.lb_fqdn : null

  full_domain = local.use_lb ? local.lb_fqdn : null
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}

module "rds" {
  count   = local.enabled && var.use_rds_client_sg && try(length(var.rds_name), 0) > 0 ? 1 : 0
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.rds_name

  context = module.this.context
}

module "ecs_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = coalesce(var.ecs_cluster_name, "ecs-cluster")

  context = module.this.context
}

module "alb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  count = local.is_alb ? 1 : 0

  component = var.alb_name

  context = module.this.context
}

module "nlb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  count = local.is_nlb ? 1 : 0

  component = var.nlb_name

  context = module.this.context
}

data "aws_kms_alias" "selected" {
  count = local.enabled && var.kinesis_enabled ? 1 : 0
  name  = format("alias/%s", coalesce(var.kms_key_alias, var.name))
}
