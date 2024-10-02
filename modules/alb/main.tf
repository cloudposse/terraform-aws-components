locals {
  dns_delegated_outputs             = module.dns_delegated.outputs
  dns_delegated_default_domain_name = local.dns_delegated_outputs.default_domain_name
  dns_delegated_certificate         = local.dns_delegated_outputs.certificate
  dns_delegated_certificate_obj     = lookup(local.dns_delegated_certificate, local.dns_delegated_default_domain_name, {})
  dns_delegated_certificate_arn     = lookup(local.dns_delegated_certificate_obj, "arn", "")

  certificate_arn = var.dns_acm_enabled ? module.acm.outputs.arn : local.dns_delegated_certificate_arn
}

module "alb" {
  source  = "cloudposse/alb/aws"
  version = "1.11.1"

  vpc_id          = module.vpc.outputs.vpc_id
  subnet_ids      = module.vpc.outputs.public_subnet_ids
  certificate_arn = local.certificate_arn

  internal                                = var.internal
  http_port                               = var.http_port
  http_ingress_cidr_blocks                = var.http_ingress_cidr_blocks
  http_ingress_prefix_list_ids            = var.http_ingress_prefix_list_ids
  https_port                              = var.https_port
  https_ingress_cidr_blocks               = var.https_ingress_cidr_blocks
  https_ingress_prefix_list_ids           = var.https_ingress_prefix_list_ids
  http_enabled                            = var.http_enabled
  https_enabled                           = var.https_enabled
  http2_enabled                           = var.http2_enabled
  http_redirect                           = var.http_redirect
  https_ssl_policy                        = var.https_ssl_policy
  access_logs_enabled                     = var.access_logs_enabled
  access_logs_prefix                      = var.access_logs_prefix
  access_logs_s3_bucket_id                = var.access_logs_s3_bucket_id
  alb_access_logs_s3_bucket_force_destroy = var.alb_access_logs_s3_bucket_force_destroy
  cross_zone_load_balancing_enabled       = var.cross_zone_load_balancing_enabled
  idle_timeout                            = var.idle_timeout
  ip_address_type                         = var.ip_address_type
  deletion_protection_enabled             = var.deletion_protection_enabled
  deregistration_delay                    = var.deregistration_delay
  health_check_path                       = var.health_check_path
  health_check_port                       = var.health_check_port
  health_check_timeout                    = var.health_check_timeout
  health_check_healthy_threshold          = var.health_check_healthy_threshold
  health_check_unhealthy_threshold        = var.health_check_unhealthy_threshold
  health_check_interval                   = var.health_check_interval
  health_check_matcher                    = var.health_check_matcher
  target_group_port                       = var.target_group_port
  target_group_protocol                   = var.target_group_protocol
  target_group_name                       = var.target_group_name
  target_group_target_type                = var.target_group_target_type
  stickiness                              = var.stickiness
  lifecycle_rule_enabled                  = var.lifecycle_rule_enabled

  context = module.this.context
}
