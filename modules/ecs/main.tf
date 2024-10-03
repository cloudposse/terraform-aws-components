locals {
  enabled = module.this.enabled

  dns_enabled = local.enabled && var.route53_enabled

  # If var.acm_certificate_domain is defined, use it.
  # Else if var.acm_certificate_domain_suffix is defined, use {{ var.acm_certificate_domain_suffix }}.{{ environment }}.{{ domain }}
  # Else, use {{ environment }}.{{ domain }}
  acm_certificate_domain = try(length(var.acm_certificate_domain) > 0, false) ? var.acm_certificate_domain : try(length(var.acm_certificate_domain_suffix) > 0, false) ? format("%s.%s.%s", var.acm_certificate_domain_suffix, var.environment, module.dns_delegated.outputs.default_domain_name) : format("%s.%s", var.environment, module.dns_delegated.outputs.default_domain_name)

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

resource "aws_security_group" "default" {
  count       = local.enabled ? 1 : 0
  name        = module.this.id
  description = "ECS cluster EC2 autoscale capacity providers"
  vpc_id      = module.vpc.outputs.vpc_id
}

resource "aws_security_group_rule" "ingress_cidr" {
  for_each          = local.enabled ? toset(var.allowed_cidr_blocks) : []
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "ingress_security_groups" {
  for_each                 = local.enabled ? toset(var.allowed_security_groups) : []
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = join("", aws_security_group.default[*].id)
}

resource "aws_security_group_rule" "egress" {
  count             = local.enabled ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default[*].id)
}

module "cluster" {
  source  = "cloudposse/ecs-cluster/aws"
  version = "0.4.1"

  context = module.this.context

  container_insights_enabled      = var.container_insights_enabled
  capacity_providers_fargate      = var.capacity_providers_fargate
  capacity_providers_fargate_spot = var.capacity_providers_fargate_spot
  capacity_providers_ec2 = {
    for name, provider in var.capacity_providers_ec2 :
    name => merge(
      provider,
      {
        security_group_ids          = concat(aws_security_group.default[*].id, provider.security_group_ids)
        subnet_ids                  = var.internal_enabled ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
        associate_public_ip_address = !var.internal_enabled
      }
    )
  }

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

#locals {
#  user_data = <<EOT
##!/bin/bash
#echo ECS_CLUSTER="${module.cluster.name}" >> /etc/ecs/ecs.config
#echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config
#echo ECS_POLL_METRICS=true >> /etc/ecs/ecs.config
#EOT
#
#}
#
#data "aws_ssm_parameter" "ami" {
#  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
#}
#
#module "autoscale_group" {
#  source  = "cloudposse/ec2-autoscale-group/aws"
#  version = "0.31.1"
#
#  context = module.this.context
#
#  image_id                    = data.aws_ssm_parameter.ami.value
#  instance_type               = "t3.medium"
#  security_group_ids          = aws_security_group.default[*].id
#  subnet_ids                  = var.internal_enabled ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
#  health_check_type           = "EC2"
#  desired_capacity            = 1
#  min_size                    = 1
#  max_size                    = 2
#  wait_for_capacity_timeout   = "5m"
#  associate_public_ip_address = true
#  user_data_base64            = base64encode(local.user_data)
#
#  # Auto-scaling policies and CloudWatch metric alarms
#  autoscaling_policies_enabled           = true
#  cpu_utilization_high_threshold_percent = "70"
#  cpu_utilization_low_threshold_percent  = "20"
#
#  iam_instance_profile_name = module.cluster.role_name
#}


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
  version = "1.11.1"

  for_each = local.enabled ? var.alb_configuration : {}

  vpc_id          = module.vpc.outputs.vpc_id
  subnet_ids      = lookup(each.value, "internal_enabled", var.internal_enabled) ? module.vpc.outputs.private_subnet_ids : module.vpc.outputs.public_subnet_ids
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

  access_logs_enabled                     = lookup(each.value, "access_logs_enabled", true)
  alb_access_logs_s3_bucket_force_destroy = lookup(each.value, "alb_access_logs_s3_bucket_force_destroy", true)

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

locals {
  # formats the load-balancer configuration data to be:
  # { "${alb_configuration key}_${additional_cert_entry}" => "additional_cert_entry" }
  certificate_domains = merge([
    for config_key, config in var.alb_configuration :
    { for domain in config.additional_certs :
    "${config_key}_${domain}" => domain } if length(lookup(config, "additional_certs", [])) > 0
  ]...)
}

resource "aws_lb_listener_certificate" "additional_certs" {
  for_each = local.certificate_domains

  listener_arn    = module.alb[split("_", each.key)[0]].https_listener_arn
  certificate_arn = data.aws_acm_certificate.additional_certs[each.key].arn
}
data "aws_acm_certificate" "additional_certs" {
  for_each = local.certificate_domains

  domain = each.value
}
