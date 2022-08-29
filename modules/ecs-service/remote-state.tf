locals {
  # Grab only namespace, tenant, environment, stage since those will be the common tags across resources of interest in this account
  match_tags = {
    for key, value in module.this.tags :
    key => value
    if contains(["namespace", "tenant", "environment", "stage"], lower(key))
  }

  subnet_match_tags = merge({
    Attributes = local.assign_public_ip ? "public" : "private"
  }, var.subnet_match_tags)

  lb_match_tags = merge({
    # e.g. platform-public
    Attributes = format("%s-%s", local.cluster_type, local.domain_type)
  }, var.lb_match_tags)

  vpc_id          = try(one(data.aws_vpc.selected[*].id), null)
  vpc_sg_id       = try(one(data.aws_security_group.vpc_default[*].id), null)
  rds_sg_id       = try(one(data.aws_security_group.rds[*].id), null)
  subnet_ids      = try(one(data.aws_subnets.selected[*].ids), null)
  ecs_cluster_arn = try(one(data.aws_ecs_cluster.selected[*].arn), null)

  lb_arn                = try(one(data.aws_lb.selected[*].arn), null)
  lb_name               = try(one(data.aws_lb.selected[*].name), null)
  lb_listener_https_arn = try(one(data.aws_lb_listener.selected_https[*].arn), null)
  lb_sg_id              = try(one(data.aws_security_group.lb[*].id), null)
  lb_zone_id            = try(one(data.aws_lb.selected[*].zone_id), null)
}

## Company specific locals for domain convention
locals {
  domain_name = {
    tenantexample = "example.net",
  }
  zone_domain = format("%s.%s.%s", var.stage, var.tenant, coalesce(var.domain_name, local.domain_name[var.tenant]))

  domain_type  = var.public_lb_enabled ? "public" : "private"
  cluster_type = var.cluster_attributes[0]

  # e.g. example.public-platform.{environment}.{zone_domain}
  full_domain = format("%s.%s-%s.%s.%s", var.name, local.domain_type, local.cluster_type, var.environment, local.zone_domain)

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

variable "vpc_match_tags" {
  type        = map(any)
  description = "The additional matching tags for the VPC data source. Used with current namespace, tenant, env, and stage tags."
  default     = {}
}

variable "subnet_match_tags" {
  type        = map(string)
  description = "The additional matching tags for the VPC subnet data source. Used with current namespace, tenant, env, and stage tags."
  default     = {}
}

variable "lb_match_tags" {
  type        = map(string)
  description = "The additional matching tags for the LB data source. Used with current namespace, tenant, env, and stage tags."
  default     = {}
}

data "aws_vpc" "selected" {
  count = local.enabled ? 1 : 0

  default = false

  tags = merge(local.match_tags, var.vpc_match_tags)
}

data "aws_security_group" "vpc_default" {
  count = local.enabled ? 1 : 0

  name = "default"

  vpc_id = local.vpc_id

  tags = local.match_tags
}

data "aws_subnets" "selected" {
  count = local.enabled ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = merge(local.match_tags, local.subnet_match_tags)
}

module "ecs_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name       = var.cluster_name
  attributes = var.cluster_attributes

  context = module.this.context
}

module "rds_sg_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  name       = var.kms_key_alias
  attributes = ["client"]

  context = module.this.context
}

data "aws_security_group" "rds" {
  count = local.enabled && var.use_rds_client_sg ? 1 : 0

  vpc_id = local.vpc_id

  tags = {
    "Name" = module.rds_sg_label.id
  }
}

data "aws_ecs_cluster" "selected" {
  count = local.enabled ? 1 : 0

  cluster_name = coalesce(var.cluster_full_name, module.ecs_label.id)
}

data "aws_security_group" "lb" {
  count = local.enabled ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(local.match_tags, local.lb_match_tags)
}

data "aws_lb" "selected" {
  count = local.enabled ? 1 : 0

  tags = merge(local.match_tags, local.lb_match_tags)
}

data "aws_lb_listener" "selected_https" {
  count = local.enabled ? 1 : 0

  load_balancer_arn = local.lb_arn
  port              = 443
}

# This is purely a check to ensure this zone exists
data "aws_route53_zone" "selected" {
  count = local.enabled ? 1 : 0

  name         = local.zone_domain
  private_zone = false
}

data "aws_route53_zone" "selected_vanity" {
  count = local.enabled ? 1 : 0

  name         = local.vanity_domain
  private_zone = false
}

data "aws_kms_alias" "selected" {
  count = local.enabled && var.kinesis_enabled ? 1 : 0
  name  = format("alias/%s", coalesce(var.kms_key_alias, var.name))
}
