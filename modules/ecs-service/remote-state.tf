locals {
  vpc_id          = module.vpc.outputs.vpc_id
  vpc_sg_id       = module.vpc.outputs.vpc_default_security_group_id
  rds_sg_id       = try(one(module.rds[*].outputs.exports.security_groups.client), null)
  subnet_ids      = lookup(module.vpc.outputs.subnets, local.assign_public_ip ? "public" : "private", { ids = [] }).ids
  ecs_cluster_arn = module.ecs_cluster.outputs.cluster_arn

  lb_arn                = try(module.ecs_cluster.outputs.alb[var.alb_configuration].alb_arn, null)
  lb_name               = try(module.ecs_cluster.outputs.alb[var.alb_configuration].alb_name, null)
  lb_listener_https_arn = try(module.ecs_cluster.outputs.alb[var.alb_configuration].https_listener_arn, null)
  lb_sg_id              = try(module.ecs_cluster.outputs.alb[var.alb_configuration].security_group_id, null)
  lb_zone_id            = try(module.ecs_cluster.outputs.alb[var.alb_configuration].alb_zone_id, null)
}

## Company specific locals for domain convention
locals {
  domain_name = {
    tenantexample = "example.net",
  }
  zone_domain = format("%s.%s.%s", var.stage, var.tenant, coalesce(var.domain_name, local.domain_name[var.tenant]))

  domain_type  = var.alb_configuration
  cluster_type = var.cluster_attributes[0]

  # e.g. example.public-platform.{environment}.{zone_domain}
  full_domain = format("%s.%s-%s.%s.%s", join("-", concat([
    var.name
  ], var.attributes)), local.domain_type, local.cluster_type, var.environment, local.zone_domain)
  domain_no_service_name         = format("%s-%s.%s.%s", local.domain_type, local.cluster_type, var.environment, local.zone_domain)
  public_domain_no_service_name  = format("%s-%s.%s.%s", "public", local.cluster_type, var.environment, local.zone_domain)
  private_domain_no_service_name = format("%s-%s.%s.%s", "private", local.cluster_type, var.environment, local.zone_domain)

  # tenant to domain mapping
  vanity_domain_names = {
    tenantexample = {
      "dev"     = "example-dev.com",
      "staging" = "example-staging.com",
      "prod"    = "example-prod.com",
    },
  }

  vanity_domain         = local.vanity_domain_names[var.tenant][var.stage]
  vanity_domain_zone_id = try(one(data.aws_route53_zone.selected_vanity[*].zone_id), null)
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"

  context = module.this.context
}

module "rds" {
  count   = local.enabled && var.use_rds_client_sg ? 1 : 0
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "rds"

  context = module.this.context
}

module "ecs_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "ecs"

  context = module.this.context
}

# This is purely a check to ensure this zone exists
data "aws_route53_zone" "selected" {
  count = local.enabled ? 1 : 0

  name         = local.zone_domain
  private_zone = false
}

data "aws_route53_zone" "selected_vanity" {
  count = local.enabled && var.vanity_domain_enabled ? 1 : 0

  name         = local.vanity_domain
  private_zone = false
}

data "aws_kms_alias" "selected" {
  count = local.enabled && var.kinesis_enabled ? 1 : 0
  name  = format("alias/%s", coalesce(var.kms_key_alias, var.name))
}
