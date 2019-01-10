# <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html>

variable "github_oauth_token" {
  type        = "string"
  description = "GitHub Oauth token"
}

variable "atlantis_branch" {
  type        = "string"
  description = "Atlantis GitHub branch"
}

variable "atlantis_repo_name" {
  type        = "string"
  description = "GitHub repository name of the atlantis to be built and deployed to ECS."
}

variable "atlantis_healthcheck_path" {
  type        = "string"
  description = "Atlantis healthcheck path"
  default     = "/healthz"
}

variable "atlantis_chamber_service" {
  default = "atlantis"
}

variable "atlantis_repo_owner" {
  description = "GitHub organization containing the Atlantis repository"
}

variable "atlantis_desired" {
  type        = "string"
  description = "Atlantis desired tasks"
  default     = "1"
}

variable "atlantis_min" {
  type        = "string"
  description = "Atlantis minimum tasks to run"
  default     = "1"
}

variable "atlantis_max" {
  type        = "string"
  description = "Atlantis maximum tasks to run"
  default     = "1"
}

variable "atlantis_cpu" {
  type        = "string"
  description = "Atlantis CPUs per task"
  default     = "256"
}

variable "atlantis_memory" {
  type        = "string"
  description = "Atlantis memory per task"
  default     = "512"
}

variable "atlantis_policy_arn" {
  type        = "string"
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
  description = "Permission to grant to atlantis server"
}

# web app
module "atlantis_web_app" {
  source     = "git::https://github.com/cloudposse/terraform-aws-ecs-web-app.git?ref=tags/0.9.0"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  attributes = "${concat(var.attributes, list("atlantis"))}"

  vpc_id = "${module.vpc.vpc_id}"

  container_image  = "${var.default_backend_image}"
  container_cpu    = "${var.atlantis_cpu}"
  container_memory = "${var.atlantis_memory}"

  #container_memory_reservation = ""
  container_port = "80"
  desired_count  = "${var.atlantis_desired}"

  autoscaling_enabled               = "true"
  autoscaling_dimension             = "cpu"
  autoscaling_min_capacity          = "${var.atlantis_min}"
  autoscaling_max_capacity          = "${var.atlantis_max}"
  autoscaling_scale_up_adjustment   = "1"
  autoscaling_scale_up_cooldown     = "60"
  autoscaling_scale_down_adjustment = "-1"
  autoscaling_scale_down_cooldown   = "300"

  #launch_type           = "FARGATE"
  listener_arns          = "${module.alb.listener_arns}"
  listener_arns_count    = "2"
  aws_logs_region        = "${var.region}"
  ecs_cluster_arn        = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name       = "${aws_ecs_cluster.default.name}"
  ecs_security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  ecs_private_subnet_ids = ["${module.subnets.private_subnet_ids}"]

  alb_ingress_healthcheck_path  = "${var.atlantis_healthcheck_path}"
  alb_ingress_paths             = ["/*"]
  alb_ingress_listener_priority = "100"

  codepipeline_enabled = "true"
  github_oauth_token   = "${var.github_oauth_token}"
  repo_owner           = "${var.atlantis_repo_owner}"
  repo_name            = "${var.atlantis_repo_name}"
  branch               = "${var.atlantis_branch}"
  ecs_alarms_enabled   = "true"

  # ecs_alarms_cpu_utilization_low_threshold              = "20"
  # ecs_alarms_cpu_utilization_low_evaluation_periods     = "1"
  # ecs_alarms_cpu_utilization_low_period                 = "300"
  # ecs_alarms_cpu_utilization_low_alarm_actions          = []
  # ecs_alarms_cpu_utilization_low_ok_actions             = []
  ecs_alarms_cpu_utilization_high_threshold = "60"

  # ecs_alarms_cpu_utilization_high_evaluation_periods    = "1"
  # ecs_alarms_cpu_utilization_high_period                = "300"
  # ecs_alarms_cpu_utilization_high_alarm_actions         = []
  # ecs_alarms_cpu_utilization_high_ok_actions            = []
  # ecs_alarms_memory_utilization_low_threshold           = "20"
  # ecs_alarms_memory_utilization_low_evaluation_periods  = "1"
  # ecs_alarms_memory_utilization_low_period              = "300"
  # ecs_alarms_memory_utilization_low_alarm_actions       = []
  # ecs_alarms_memory_utilization_low_ok_actions          = []
  # ecs_alarms_memory_utilization_high_threshold          = "80"
  # ecs_alarms_memory_utilization_high_evaluation_periods = "1"
  # ecs_alarms_memory_utilization_high_period             = "300"
  # ecs_alarms_memory_utilization_high_alarm_actions      = []
  # ecs_alarms_memory_utilization_high_ok_actions         = []

  alb_target_group_alarms_enabled                 = "true"
  alb_target_group_alarms_3xx_threshold           = "25"
  alb_target_group_alarms_4xx_threshold           = "25"
  alb_target_group_alarms_5xx_threshold           = "25"
  alb_target_group_alarms_response_time_threshold = "0.5"
  alb_target_group_alarms_period                  = "300"
  alb_target_group_alarms_evaluation_periods      = "1"
  alb_name                                        = "${module.alb.alb_name}"
  alb_arn_suffix                                  = "${module.alb.alb_arn_suffix}"

  #alb_target_group_alarms_alarm_actions              = []
  #alb_target_group_alarms_ok_actions                 = []
  #alb_target_group_alarms_insufficient_data_actions  = []
}

data "aws_caller_identity" "default" {}

locals {
  account_id = "${data.aws_caller_identity.default.account_id}"
}

##
# SSM
##

variable "atlantis_hostname" {
  type        = "string"
  description = "Atlantis URL"
  default     = ""
}

variable "atlantis_allow_repo_config" {
  type        = "string"
  description = "Allow Atlantis to use atlantis.yaml"
  default     = "true"
}

variable "atlantis_gh_user" {
  type        = "string"
  description = "Atlantis Github user"
}

variable "atlantis_gh_webhook_secret" {
  type        = "string"
  description = "Atlantis Github webhook secret"
  default     = ""
}

variable "atlantis_log_level" {
  type        = "string"
  description = "Atlantis log level"
  default     = "info"
}

variable "atlantis_repo_config" {
  type        = "string"
  description = "Path to atlantis config file"
  default     = "atlantis.yaml"
}

variable "atlantis_repo_whitelist" {
  type        = "list"
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  default     = []
}

variable "atlantis_wake_word" {
  type        = "string"
  description = "Wake world for Atlantis"
  default     = "atlantis"
}

locals {
  default_atlantis_hostname  = "atlantis.${var.region}.${var.domain_name}"
  atlantis_hostname          = "${length(var.atlantis_hostname) > 0 ? var.atlantis_hostname : local.default_atlantis_hostname}"
  atlantis_url               = "${format("https://%s/events", local.atlantis_hostname)}"
  atlantis_gh_webhook_secret = "${length(var.atlantis_gh_webhook_secret) > 0 ? var.atlantis_gh_webhook_secret : join("", random_string.atlantis_gh_webhook_secret.*.result)}"
}

resource "random_string" "atlantis_gh_webhook_secret" {
  count   = "${length(var.atlantis_gh_webhook_secret) > 0 ? 0 : 1}"
  length  = 32
  special = true
}

resource "aws_ssm_parameter" "atlantis_atlantis_url" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_atlantis_url")}"
  description = "URL to reach Atlantis e.g. For webhooks"
  type        = "String"
  value       = "${local.atlantis_url}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_allow_repo_config" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_allow_repo_config")}"
  description = "allow Atlantis to use atlantis.yaml"
  type        = "String"
  value       = "${var.atlantis_allow_repo_config}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_gh_user" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_gh_user")}"
  description = "Atlantis Github user"
  type        = "String"
  value       = "${var.atlantis_gh_user}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_gh_webhook_secret" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_gh_webhook_secret")}"
  description = "Atlantis Github webhook secret"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  value       = "${local.atlantis_gh_webhook_secret}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_iam_role" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_iam_role")}"
  description = "Atlantis IAM role"
  type        = "String"
  value       = "${aws_iam_role.atlantis.arn}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_log_level" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_log_level")}"
  description = "Atlantis log level"
  type        = "String"
  value       = "${var.atlantis_log_level}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_repo_config" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_repo_config")}"
  description = "Path to atlantis config file"
  type        = "String"
  value       = "${var.atlantis_repo_config}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_repo_whitelist" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_repo_whitelist")}"
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  type        = "String"
  value       = "${join(",", var.atlantis_repo_whitelist)}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_wake_word" {
  name        = "${format("/%s/%s", var.atlantis_chamber_service, "atlantis_wake_word")}"
  description = "Wake world for Atlantis"
  type        = "String"
  value       = "${var.atlantis_wake_word}"
  overwrite   = true
}

# Additional Security Group Rules

data "aws_security_group" "atlantis" {
  depends_on = ["module.atlantis_web_app"]
  name       = "${module.atlantis_web_app.service_name}"
  vpc_id     = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "egress_http" {
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${data.aws_security_group.atlantis.id}"
}

resource "aws_security_group_rule" "egress_https" {
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${data.aws_security_group.atlantis.id}"
}

resource "aws_security_group_rule" "egress_udp_dns" {
  type        = "egress"
  from_port   = 53
  to_port     = 53
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${data.aws_security_group.atlantis.id}"
}

resource "aws_security_group_rule" "egress_tdp_dns" {
  type        = "egress"
  from_port   = 53
  to_port     = 53
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${data.aws_security_group.atlantis.id}"
}

# IAM Role ARN usage Example (S3)
# This is just an example on how to set the permissions to allow an ECS task into AWS resources. You will need
# to update your current bucket policy to include the Principal section below.

data "aws_kms_key" "chamber_kms_key" {
  key_id = "${format("alias/%s-%s-chamber", var.namespace, var.stage)}"
}

##
# Chamber Base
#
# Used by the lancher to fetch our credentials.
#
data "aws_iam_policy_document" "chamber_policy" {
  statement {
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }

  statement {
    actions = ["ssm:GetParametersByPath", "ssm:GetParameters"]

    resources = [
      "${format("arn:aws:ssm:%s:%s:parameter/atlantis/*", var.region, local.account_id)}",
    ]
  }

  statement {
    actions   = ["kms:Decrypt"]
    resources = ["${data.aws_kms_key.chamber_kms_key.arn}"]
  }
}

## Chamber
resource "aws_iam_policy" "chamber_policy" {
  name        = "${format("XXXXXX-%s-atlantis-chamber", var.stage)}"
  description = "Insurance3 application Chamber policy."
  policy      = "${data.aws_iam_policy_document.chamber_policy.json}"
}

## Chamber
resource "aws_iam_role_policy_attachment" "app_chamber_attach" {
  role       = "${basename(module.atlantis_web_app.task_role_arn)}"
  policy_arn = "${aws_iam_policy.chamber_policy.arn}"
}

data "aws_iam_role" "code_build" {
  depends_on = ["module.atlantis_web_app"]
  name       = "${format("XXXXXX-%s-atlantis-build", var.stage)}"
}

resource "aws_iam_role_policy_attachment" "codebuild_chamber_attach" {
  role       = "${basename(data.aws_iam_role.code_build.arn)}"
  policy_arn = "${aws_iam_policy.chamber_policy.arn}"
}

resource "aws_iam_role" "atlantis" {
  name        = "${format("XXXXXX-%s-atlantis", var.stage)}"
  description = "Role that can be assumed by atlantis"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = "${data.aws_iam_policy_document.atlantis_assume_role.json}"
}

data "aws_iam_policy_document" "atlantis_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "atlantis" {
  role       = "${aws_iam_role.atlantis.name}"
  policy_arn = "${var.atlantis_policy_arn}"

  lifecycle {
    create_before_destroy = true
  }
}

# dns
resource "aws_route53_record" "atlantis" {
  zone_id = "zone-id-for-staging"
  name    = "atlantis.${var.domain_name}"
  type    = "A"


  alias {
    name                   = "${module.alb.alb_dns_name}"
    zone_id                = "${module.alb.alb_zone_id}"
    evaluate_target_health = true
  }
}
