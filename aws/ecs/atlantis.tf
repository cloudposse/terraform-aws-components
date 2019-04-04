variable "atlantis_enabled" {
  type    = "string"
  default = "true"
}

variable "atlantis_gh_team_whitelist" {
  type        = "string"
  description = "Atlantis GitHub team whitelist"
  default     = ""
}

variable "atlantis_gh_user" {
  type        = "string"
  description = "Atlantis GitHub user"
  default     = "undefined"
}

variable "atlantis_repo_whitelist" {
  type        = "list"
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  default     = []
}

variable "atlantis_branch" {
  type        = "string"
  default     = "master"
  description = "Atlantis branch Branch of the GitHub repository, _e.g._ `master`"
}

variable "atlantis_repo_name" {
  type        = "string"
  description = "GitHub repository name of the atlantis to be built and deployed to ECS."
}

variable "atlantis_repo_owner" {
  type        = "string"
  description = "GitHub organization containing the Atlantis repository"
  default     = "undefined"
}

variable "atlantis_container_cpu" {
  type        = "string"
  description = "The vCPU setting to control cpu limits of container. (If FARGATE launch type is used below, this must be a supported vCPU size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = "256"
}

variable "atlantis_container_memory" {
  type        = "string"
  description = "The amount of RAM to allow container to use in MB. (If FARGATE launch type is used below, this must be a supported Memory size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = "512"
}

variable "atlantis_authentication_action" {
  type        = "map"
  default     = {}
  description = "Authentication action to be placed in front of all other ALB listener actions to authenticate users with Cognito or OIDC"
}

module "atlantis" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecs-atlantis.git?ref=tags/0.4.0"
  enabled   = "${var.atlantis_enabled}"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  region    = "${var.region}"
  stage     = "${var.stage}"

  atlantis_gh_team_whitelist = "${var.atlantis_gh_team_whitelist}"
  atlantis_gh_user           = "${var.atlantis_gh_user}"
  atlantis_repo_whitelist    = ["${var.atlantis_repo_whitelist}"]

  alb_arn_suffix    = "${module.alb.alb_arn_suffix}"
  alb_dns_name      = "${module.alb.alb_dns_name}"
  alb_listener_arns = ["${module.alb.listener_arns}"]
  alb_name          = "${module.alb.alb_name}"
  alb_zone_id       = "${module.alb.alb_zone_id}"

  container_cpu    = "${var.atlantis_container_cpu}"
  container_memory = "${var.atlantis_container_memory}"

  branch             = "${var.atlantis_branch}"
  parent_zone_id     = "${module.dns.zone_id}"
  ecs_cluster_arn    = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name   = "${aws_ecs_cluster.default.name}"
  repo_name          = "${var.atlantis_repo_name}"
  repo_owner         = "${var.atlantis_repo_owner}"
  private_subnet_ids = ["${module.subnets.private_subnet_ids}"]
  security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  vpc_id             = "${module.vpc.vpc_id}"

  authentication_action = "${var.atlantis_authentication_action}"
}

output "atlantis_url" {
  value = "${module.atlantis.atlantis_url}"
}
