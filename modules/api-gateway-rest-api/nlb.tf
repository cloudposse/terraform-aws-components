module "nlb" {
  source  = "cloudposse/nlb/aws"
  version = "0.12.0"
  count   = var.enable_private_link_nlb ? 1 : 0

  enabled = local.enabled

  vpc_id                                  = module.vpc.outputs.vpc.id
  subnet_ids                              = module.vpc.outputs.private_subnet_ids
  internal                                = true
  tcp_enabled                             = true
  cross_zone_load_balancing_enabled       = true
  ip_address_type                         = "ipv4"
  deletion_protection_enabled             = var.enable_private_link_nlb_deletion_protection
  tcp_port                                = 443
  target_group_port                       = 443
  target_group_target_type                = "alb"
  health_check_protocol                   = "HTTPS"
  nlb_access_logs_s3_bucket_force_destroy = true
  deregistration_delay                    = var.deregistration_delay

  context = module.this.context
}

## You can use a target attachment like below to point the nlb at an ecs alb.
#resource "aws_lb_target_group_attachment" "alb" {
#  target_group_arn = one(module.nlb[*].default_target_group_arn)
#  target_id        = module.ecs.outputs.alb_arn
#  port             = 443
#}
