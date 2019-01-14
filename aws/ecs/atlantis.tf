# <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html>

variable "github_oauth_token" {
  type        = "string"
  description = "GitHub Oauth token. If not provided the token is looked up from SSM."
  default     = ""
}

variable "github_oauth_token_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup GitHub OAuth token if not provided"
  default     = ""
}

variable "atlantis_enabled" {
  type    = "string"
  default = "false"
}

variable "atlantis_branch" {
  type        = "string"
  description = "Atlantis GitHub branch"
}

variable "atlantis_repo_name" {
  type        = "string"
  description = "GitHub repository name of the atlantis to be built and deployed to ECS."
}

variable "atlantis_repo_owner" {
  description = "GitHub organization containing the Atlantis repository"
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

variable "atlantis_healthcheck_path" {
  type        = "string"
  description = "Atlantis healthcheck path"
  default     = "/healthz"
}

variable "atlantis_chamber_format" {
  default = "/%s/%s"
}

variable "atlantis_chamber_service" {
  default = "atlantis"
}

variable "atlantis_desired_count" {
  type        = "string"
  description = "Atlantis desired number of tasks"
  default     = "1"
}

variable "atlantis_short_name" {
  description = "Alantis Short DNS name (E.g. `atlantis`)"
  default     = "atlantis"
}

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
  description = "Atlantis GitHub user"
}

variable "atlantis_gh_team_whitelist" {
  type        = "string"
  description = "Atlantis GitHub team whitelist"
  default     = ""
}

variable "atlantis_gh_webhook_secret" {
  type        = "string"
  description = "Atlantis GitHub webhook secret"
  default     = ""
}

variable "atlantis_log_level" {
  type        = "string"
  description = "Atlantis log level"
  default     = "info"
}

variable "atlantis_port" {
  type        = "string"
  description = "Atlantis container port"
  default     = "4141"
}

variable "atlantis_wake_word" {
  type        = "string"
  description = "Wake world for Atlantis"
  default     = "atlantis"
}

variable "atlantis_webhook_format" {
  type    = "string"
  default = "https://%s/events"
}

variable "atlantis_autoscaling_min_capacity" {
  type        = "string"
  description = "Atlantis minimum tasks to run"
  default     = "1"
}

variable "atlantis_autoscaling_max_capacity" {
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

locals {
  atlantis_attributes         = "${concat(list(var.atlantis_short_name), var.attributes)}"
  github_oauth_token          = "${length(join("", data.aws_ssm_parameter.atlantis_gh_token.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_gh_token.*.value) : var.github_oauth_token}"
  github_oauth_token_ssm_name = "${length(var.github_oauth_token_ssm_name) > 0 ? var.github_oauth_token_ssm_name : format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_gh_token")}"
}

data "aws_ssm_parameter" "atlantis_gh_token" {
  count = "${length(var.github_oauth_token) > 0 ? 0 : 1}"
  name  = "${local.github_oauth_token_ssm_name}"
}

resource "aws_ssm_parameter" "atlantis_gh_token" {
  count       = "${length(var.github_oauth_token) > 0 ? 1 : 0}"
  name        = "${local.github_oauth_token_ssm_name}"
  description = "Atlantis GitHub OAuth token"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  value       = "${local.github_oauth_token}"
  overwrite   = true
}

# web app
module "atlantis_web_app" {
  source     = "git::https://github.com/cloudposse/terraform-aws-ecs-web-app.git?ref=tags/0.11.0"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  attributes = "${local.atlantis_attributes}"

  vpc_id = "${module.vpc.vpc_id}"

  environment = [
    {
      name  = "ATLANTIS_ENABLED"
      value = "${var.atlantis_enabled}"
    }
  ]

  github_webhook_events = ["release"]
  webhook_filter_json_path = "$.action"
  webhook_filter_match_equals = "published"

  container_image  = "${var.default_backend_image}"
  container_cpu    = "${var.atlantis_cpu}"
  container_memory = "${var.atlantis_memory}"

  codepipeline_enabled = "${var.atlantis_enabled}"

  #container_memory_reservation = ""
  container_port = "${var.atlantis_port}"

  port_mappings = [{
    "containerPort" = "${var.atlantis_port}"
    "hostPort"      = "${var.atlantis_port}"
    "protocol"      = "tcp"
  }]

  desired_count = "${var.atlantis_desired_count}"

  autoscaling_enabled               = "${var.atlantis_enabled}"
  autoscaling_dimension             = "cpu"
  autoscaling_min_capacity          = "${var.atlantis_autoscaling_min_capacity}"
  autoscaling_max_capacity          = "${var.atlantis_autoscaling_max_capacity}"
  autoscaling_scale_up_adjustment   = "1"
  autoscaling_scale_up_cooldown     = "60"
  autoscaling_scale_down_adjustment = "-1"
  autoscaling_scale_down_cooldown   = "300"

  #launch_type           = "FARGATE"
  listener_arns          = "${module.alb.listener_arns}"
  listener_arns_count    = "2"
  aws_logs_region        = "${var.region}"
  ecs_alarms_enabled     = "${var.atlantis_enabled}"
  ecs_cluster_arn        = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name       = "${aws_ecs_cluster.default.name}"
  ecs_security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  ecs_private_subnet_ids = ["${module.subnets.private_subnet_ids}"]

  alb_ingress_healthcheck_path  = "${var.atlantis_healthcheck_path}"
  alb_ingress_paths             = ["/*"]
  alb_ingress_listener_priority = "100"

  github_oauth_token = "${local.github_oauth_token}"
  repo_owner         = "${var.atlantis_repo_owner}"
  repo_name          = "${var.atlantis_repo_name}"
  branch             = "${var.atlantis_branch}"
  build_timeout      = 5
  badge_enabled      = "false"

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

  alb_target_group_alarms_enabled                 = "${var.atlantis_enabled}"
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

module "atlantis_ssh_key_pair" {
  source               = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-ssh-key-pair.git?ref=tags/0.2.0"
  enabled              = "${var.atlantis_enabled}"
  namespace            = "${var.namespace}"
  stage                = "${var.stage}"
  name                 = "${var.name}"
  attributes           = "${local.atlantis_attributes}"
  ssh_private_key_name = "atlantis_ssh_private_key"
  ssh_public_key_name  = "atlantis_ssh_public_key"
  ssm_path_prefix      = "${var.atlantis_chamber_service}"
  ssh_key_algorithm    = "ECDSA"
  ecdsa_curve          = "P521"
}

output "atlantis_ssh_public_key" {
  description = "Atlantis SSH Public Key"
  value       = "${module.atlantis_ssh_key_pair.public_key}"
}

output "badge_url" {
  description = "the url of the build badge when badge_enabled is enabled"
  value       = "${module.atlantis_web_app.badge_url}"
}

resource "random_string" "atlantis_gh_webhook_secret" {
  count   = "${length(var.atlantis_gh_webhook_secret) > 0 ? 0 : 1}"
  length  = 32
  special = true
}

locals {
  default_atlantis_hostname  = "${var.atlantis_short_name}.${var.domain_name}"
  atlantis_enabled           = "${var.atlantis_enabled == "true"}"
  atlantis_hostname          = "${length(var.atlantis_hostname) > 0 ? var.atlantis_hostname : local.default_atlantis_hostname}"
  atlantis_url               = "${format(var.atlantis_webhook_format, local.atlantis_hostname)}"
  atlantis_gh_webhook_secret = "${length(var.atlantis_gh_webhook_secret) > 0 ? var.atlantis_gh_webhook_secret : join("", random_string.atlantis_gh_webhook_secret.*.result)}"
}

resource "aws_ssm_parameter" "atlantis_port" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_port")}"
  description = "Atlantis server port"
  type        = "String"
  value       = "${var.atlantis_port}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_atlantis_url" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_atlantis_url")}"
  description = "URL to reach Atlantis e.g. For webhooks"
  type        = "String"
  value       = "${local.atlantis_url}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_allow_repo_config" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_allow_repo_config")}"
  description = "allow Atlantis to use atlantis.yaml"
  type        = "String"
  value       = "${var.atlantis_allow_repo_config}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_gh_user" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_gh_user")}"
  description = "Atlantis GitHub user"
  type        = "String"
  value       = "${var.atlantis_gh_user}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_gh_team_whitelist" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_gh_team_whitelist")}"
  description = "Atlantis GitHub team whitelist"
  type        = "String"
  value       = "${var.atlantis_gh_team_whitelist}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_gh_webhook_secret" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_gh_webhook_secret")}"
  description = "Atlantis GitHub webhook secret"
  type        = "SecureString"
  key_id      = "${data.aws_kms_key.chamber_kms_key.id}"
  value       = "${local.atlantis_gh_webhook_secret}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_iam_role_arn" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_iam_role_arn")}"
  description = "Atlantis IAM role ARN"
  type        = "String"
  value       = "${module.atlantis_web_app.task_role_arn}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_log_level" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_log_level")}"
  description = "Atlantis log level"
  type        = "String"
  value       = "${var.atlantis_log_level}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_repo_config" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_repo_config")}"
  description = "Path to atlantis config file"
  type        = "String"
  value       = "${var.atlantis_repo_config}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_repo_whitelist" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_repo_whitelist")}"
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  type        = "String"
  value       = "${join(",", var.atlantis_repo_whitelist)}"
  overwrite   = true
}

resource "aws_ssm_parameter" "atlantis_wake_word" {
  name        = "${format(var.atlantis_chamber_format, var.atlantis_chamber_service, "atlantis_wake_word")}"
  description = "Wake world for Atlantis"
  type        = "String"
  value       = "${var.atlantis_wake_word}"
  overwrite   = true
}

# Additional Security Group Rules

locals {
  atlantis_security_group_id = "${module.atlantis_web_app.service_security_group_id}"
}

resource "aws_security_group_rule" "atlantis_egress_http" {
  count       = "${local.atlantis_enabled ? 1 : 0}"
  type        = "egress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${local.atlantis_security_group_id}"
}

resource "aws_security_group_rule" "atlantis_egress_https" {
  count       = "${local.atlantis_enabled ? 1 : 0}"
  type        = "egress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${local.atlantis_security_group_id}"
}

resource "aws_security_group_rule" "atlantis_egress_udp_dns" {
  count       = "${local.atlantis_enabled ? 1 : 0}"
  type        = "egress"
  from_port   = 53
  to_port     = 53
  protocol    = "udp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${local.atlantis_security_group_id}"
}

resource "aws_security_group_rule" "atlantis_egress_tdp_dns" {
  count       = "${local.atlantis_enabled ? 1 : 0}"
  type        = "egress"
  from_port   = 53
  to_port     = 53
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${local.atlantis_security_group_id}"
}

# IAM Role ARN usage
# This is just an example on how to set the permissions to allow an ECS task into AWS resources. i

data "aws_kms_key" "chamber_kms_key" {
  key_id = "${format("alias/%s-%s-chamber", var.namespace, var.stage)}"
}

resource "aws_iam_role_policy_attachment" "atlantis" {
  role       = "${module.atlantis_web_app.task_role_name}"
  policy_arn = "${var.atlantis_policy_arn}"

  lifecycle {
    create_before_destroy = true
  }
}

module "atlantis_hostname" {
  source           = "git::https://github.com/cloudposse/terraform-aws-route53-alias.git?ref=tags/0.2.7"
  enabled          = "${var.atlantis_enabled}"
  aliases          = ["${local.atlantis_hostname}"]
  parent_zone_name = "${var.domain_name}"
  target_dns_name  = "${module.alb.alb_dns_name}"
  target_zone_id   = "${module.alb.alb_zone_id}"
}

module "atlantis_webhooks" {
  source         = "git::https://github.com/cloudposse/terraform-github-repository-webhooks.git?ref=tags/0.1.1"
  github_token   = "${local.github_oauth_token}"
  webhook_secret = "${local.atlantis_gh_webhook_secret}"
  webhook_url    = "${local.atlantis_url}"

  active              = "${local.atlantis_enabled}"
  github_organization = "${var.atlantis_repo_owner}"
  github_repositories = ["${var.atlantis_repo_name}"]
  events              = ["pull_request_review_comment", "pull_request", "pull_request_review", "issue_comment", "push"]

  # This value must be "web"; it is a GitHub webhook type
  name = "web"
}
