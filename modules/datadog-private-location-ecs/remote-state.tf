locals {
  vpc_id          = module.vpc.outputs.vpc_id
  vpc_sg_id       = module.vpc.outputs.vpc_default_security_group_id
  subnet_ids      = lookup(module.vpc.outputs.subnets, "private", { ids = [] }).ids
  ecs_cluster_arn = module.ecs_cluster.outputs.cluster_arn

  lb_arn                = try(module.ecs_cluster.outputs.alb[var.alb_configuration].alb_arn, null)
  lb_listener_https_arn = try(module.ecs_cluster.outputs.alb[var.alb_configuration].https_listener_arn, null)
  lb_sg_id              = try(module.ecs_cluster.outputs.alb[var.alb_configuration].security_group_id, null)
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "vpc"

  context = module.this.context
}

module "ecs_cluster" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = "ecs/cluster"

  context = module.this.context
}
