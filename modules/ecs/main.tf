locals {
  enabled = module.this.enabled
}

module "cluster" {
  source  = "cloudposse/ecs-cluster/aws"
  version = "0.3.0"

  context = module.this.context

  container_insights_enabled      = var.container_insights_enabled
  capacity_providers_fargate      = var.capacity_providers_fargate
  capacity_providers_fargate_spot = var.capacity_providers_fargate_spot

  # TODO: refine these when necessary
  # capacity_providers_ec2 = {
  #   for name, provider in var.capacity_providers_ec2 :
  #   name => merge(
  #     provider,
  #     {
  #       security_group_ids          = concat(aws_security_group.default.*.id, provider.security_group_ids)
  #       subnet_ids                  = var.internal_enabled ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
  #       associate_public_ip_address = !var.internal_enabled
  #     }
  #   )
  # }

  #  external_ec2_capacity_providers = {
  #    external_default = {
  #      autoscaling_group_arn          = module.autoscale_group.autoscaling_group_arn
  #      managed_termination_protection = false
  #      managed_scaling_status         = false
  #      instance_warmup_period         = 300
  #      maximum_scaling_step_size      = 1
  #      minimum_scaling_step_size      = 1
  #      target_capacity_utilization    = 100
  #    }
  #  }
}
