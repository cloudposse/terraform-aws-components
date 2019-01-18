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

module "atlantis" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecs-atlantis.git?ref=tags/0.1.0"
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

  branch             = "${var.atlantis_branch}"
  domain_name        = "${var.domain_name}"
  ecs_cluster_arn    = "${aws_ecs_cluster.default.arn}"
  ecs_cluster_name   = "${aws_ecs_cluster.default.name}"
  repo_name          = "${var.atlantis_repo_name}"
  repo_owner         = "${var.atlantis_repo_owner}"
  private_subnet_ids = ["${module.subnets.private_subnet_ids}"]
  security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  vpc_id             = "${module.vpc.vpc_id}"
}
