variable "default_backend_image" {
  default = "cloudposse/default-backend:0.1.2"
}

variable "default_backend_name" {
  default = "404"
}

# default backend app
module "default_backend_web_app" {
  source     = "git::https://github.com/cloudposse/terraform-aws-ecs-web-app.git?ref=pass-attributes"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  attributes = ["${concat(var.attributes, list(var.default_backend_name))}"]
  vpc_id     = "${module.vpc.vpc_id}"

  container_image  = "${var.default_backend_image}"
  container_cpu    = "256"
  container_memory = "512"
  container_port   = "80"

  #launch_type                 = "FARGATE"
  listener_arns                = "${module.alb.listener_arns}"
  listener_arns_count          = "1"
  aws_logs_region              = "${var.region}"
  ecs_cluster_arn              = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name             = "${aws_ecs_cluster.default.name}"
  ecs_security_group_ids       = ["${module.vpc.vpc_default_security_group_id}"]
  ecs_private_subnet_ids       = ["${module.subnets.private_subnet_ids}"]
  alb_ingress_healthcheck_path = "/healthz"
  alb_ingress_paths            = ["/*"]

  codepipeline_enabled = "false"
  ecs_alarms_enabled   = "true"
  autoscaling_enabled  = "false"

  alb_name                                        = "${module.alb.alb_name}"
  alb_arn_suffix                                  = "${module.alb.alb_arn_suffix}"
  alb_target_group_alarms_enabled                 = "true"
  alb_target_group_alarms_3xx_threshold           = "25"
  alb_target_group_alarms_4xx_threshold           = "25"
  alb_target_group_alarms_5xx_threshold           = "25"
  alb_target_group_alarms_response_time_threshold = "0.5"
  alb_target_group_alarms_period                  = "300"
  alb_target_group_alarms_evaluation_periods      = "1"
}
