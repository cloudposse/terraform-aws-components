variable "default_backend_image" {
  default = "cloudposse/default-backend:0.1.2"
}

variable "default_backend_name" {
  default = "404"
}

# default backend app
module "default_backend_web_app" {
  source     = "git::https://github.com/cloudposse/terraform-aws-ecs-web-app.git?ref=tags/0.24.0"
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage
  attributes = concat(var.attributes, [var.default_backend_name])

  vpc_id = module.vpc.vpc_id
  region = var.region

  container_image  = var.default_backend_image
  container_cpu    = 256
  container_memory = 512
  container_port   = 80

  #launch_type                 = "FARGATE"
  aws_logs_region              = var.region
  ecs_cluster_arn              = aws_ecs_cluster.default.arn
  ecs_cluster_name             = aws_ecs_cluster.default.name
  ecs_private_subnet_ids       = module.subnets.private_subnet_ids
  alb_ingress_healthcheck_path = "/healthz"

  codepipeline_enabled = false
  ecs_alarms_enabled   = true
  autoscaling_enabled  = false

  alb_name                                        = module.alb.alb_name
  alb_arn_suffix                                  = module.alb.alb_arn_suffix
  alb_security_group                              = module.alb.security_group_id
  alb_target_group_alarms_enabled                 = true
  alb_target_group_alarms_3xx_threshold           = 25
  alb_target_group_alarms_4xx_threshold           = 25
  alb_target_group_alarms_5xx_threshold           = 25
  alb_target_group_alarms_response_time_threshold = 0.5
  alb_target_group_alarms_period                  = 300
  alb_target_group_alarms_evaluation_periods      = 1

  alb_ingress_unauthenticated_listener_arns       = module.alb.listener_arns
  alb_ingress_unauthenticated_listener_arns_count = 1

  alb_ingress_unauthenticated_paths = ["/*"]
  alb_ingress_authenticated_paths   = []

  repo_owner = var.atlantis_repo_owner

  webhook_enabled       = false
  github_oauth_token    = "NO_TOKEN"
  github_webhooks_token = "NO_TOKEN"
}
