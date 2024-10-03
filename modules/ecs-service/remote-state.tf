locals {
  vpc_id          = module.vpc.outputs.vpc_id
  vpc_sg_id       = module.vpc.outputs.vpc_default_security_group_id
  rds_sg_id       = try(one(module.rds[*].outputs.exports.security_groups.client), null)
  subnet_ids      = lookup(module.vpc.outputs.subnets, local.assign_public_ip ? "public" : "private", { ids = [] }).ids
  ecs_cluster_arn = module.ecs_cluster.outputs.cluster_arn

  use_external_lb = local.use_lb && (try(length(var.alb_name) > 0, false) || try(length(var.nlb_name) > 0, false))

  is_alb = local.use_lb && !try(length(var.nlb_name) > 0, false)
  alb    = local.use_lb ? (local.use_external_lb ? try(module.alb[0].outputs, null) : module.ecs_cluster.outputs.alb[var.alb_configuration]) : null

  is_nlb = local.use_lb && try(length(var.nlb_name) > 0, false)
  nlb    = try(module.nlb[0].outputs, null)

  use_lb = local.enabled && var.use_lb

  requested_protocol = local.use_lb && !local.lb_listener_http_is_redirect ? var.http_protocol : null
  lb_protocol        = local.lb_listener_http_is_redirect || try(local.is_nlb && local.nlb.is_443_enabled, false) ? "https" : "http"
  http_protocol      = coalesce(local.requested_protocol, local.lb_protocol)

  lb_arn                       = try(coalesce(local.nlb.nlb_arn, ""), coalesce(local.alb.alb_arn, ""), null)
  lb_name                      = try(coalesce(local.nlb.nlb_name, ""), coalesce(local.alb.alb_dns_name, ""), null)
  lb_listener_http_is_redirect = try(length(local.is_nlb ? "" : local.alb.http_redirect_listener_arn) > 0, false)
  lb_listener_https_arn        = try(coalesce(local.nlb.default_listener_arn, ""), coalesce(local.alb.https_listener_arn, ""), null)
  lb_sg_id                     = try(local.is_nlb ? null : local.alb.security_group_id, null)
  lb_zone_id                   = try(coalesce(local.nlb.nlb_zone_id, ""), coalesce(local.alb.alb_zone_id, ""), null)
  lb_fqdn                      = try(coalesce(local.nlb.route53_record.fqdn, ""), coalesce(local.alb.route53_record.fqdn, ""), local.full_domain)

}

## Company specific locals for domain convention
locals {
  domain_type  = var.alb_configuration
  cluster_type = try(var.cluster_attributes[0], "platform")

  zone_domain = jsondecode(data.jq_query.service_domain_query.result)

  # e.g. example.public-platform.{environment}.{zone_domain}
  full_domain = format("%s.%s-%s.%s.%s", join("-", concat([
    var.name
  ], var.attributes)), local.domain_type, local.cluster_type, var.environment, local.zone_domain)
  domain_no_service_name         = format("%s-%s.%s.%s", local.domain_type, local.cluster_type, var.environment, local.zone_domain)
  public_domain_no_service_name  = format("%s-%s.%s.%s", "public", local.cluster_type, var.environment, local.zone_domain)
  private_domain_no_service_name = format("%s-%s.%s.%s", "private", local.cluster_type, var.environment, local.zone_domain)

  vanity_domain_zone_id = one(data.aws_route53_zone.selected_vanity[*].zone_id)

  unauthenticated_paths = local.is_nlb ? ["/"] : var.unauthenticated_paths

  # NOTE: this is the rare _not_ in the ternary purely for readability
  full_urls = !local.use_lb ? [] : [for path in local.unauthenticated_paths : format("%s://%s%s", local.http_protocol, local.lb_fqdn, trimsuffix(trimsuffix(path, "*"), "/"))]

}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}

module "security_group" {
  count   = local.enabled && var.task_security_group_component != null ? 1 : 0
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.task_security_group_component

  context = module.this.context
}

module "rds" {
  count   = local.enabled && var.use_rds_client_sg && try(length(var.rds_name), 0) > 0 ? 1 : 0
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.rds_name

  context = module.this.context
}

module "ecs_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = coalesce(var.ecs_cluster_name, "ecs-cluster")

  context = module.this.context
}

module "alb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.is_alb && local.use_external_lb ? 1 : 0

  component = var.alb_name

  context = module.this.context
}

module "nlb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.is_nlb ? 1 : 0

  component = var.nlb_name

  context = module.this.context
}

module "s3" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.s3_mirroring_enabled ? 1 : 0

  component = var.s3_mirror_name

  context = module.this.context
}


module "service_domain" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.zone_component

  context     = module.this.context
  environment = "gbl"
}

data "jq_query" "service_domain_query" {
  data  = jsonencode(one(module.service_domain[*].outputs))
  query = var.zone_component_output
}

module "datadog_configuration" {
  count   = var.datadog_agent_sidecar_enabled ? 1 : 0
  source  = "../datadog-configuration/modules/datadog_keys"
  enabled = true
  context = module.this.context
}

# This is purely a check to ensure this zone exists
# tflint-ignore: terraform_unused_declarations
data "aws_route53_zone" "selected" {
  count = local.enabled ? 1 : 0

  name         = local.zone_domain
  private_zone = false
}

data "aws_route53_zone" "selected_vanity" {
  count = local.enabled && var.vanity_domain != null ? 1 : 0

  name         = var.vanity_domain
  private_zone = false
}

data "aws_kms_alias" "selected" {
  count = local.enabled && var.kinesis_enabled ? 1 : 0
  name  = format("alias/%s", coalesce(var.kms_key_alias, var.name))
}

module "iam_role" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"
  count   = local.enabled && var.task_iam_role_component != null ? 1 : 0

  component = var.task_iam_role_component

  context = module.this.context
}

module "efs" {
  for_each = local.efs_component_map

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  # Here we can use [0] because aws only allows one efs volume configuration per volume
  component = each.value.efs_volume_configuration[0].component

  context = module.this.context

  tenant      = each.value.efs_volume_configuration[0].tenant
  stage       = each.value.efs_volume_configuration[0].stage
  environment = each.value.efs_volume_configuration[0].environment

}
