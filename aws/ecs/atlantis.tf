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

variable "atlantis_authentication_type" {
  type        = "string"
  default     = ""
  description = "Authentication action type. Supported values are `COGNITO` and `OIDC`"
}

variable "atlantis_cognito_user_pool_arn" {
  type        = "string"
  description = "Cognito User Pool ARN"
  default     = ""
}

variable "atlantis_cognito_user_pool_arn_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup `atlantis_cognito_user_pool_arn` if not provided"
  default     = ""
}

variable "atlantis_cognito_user_pool_client_id" {
  type        = "string"
  description = "Cognito User Pool Client ID"
  default     = ""
}

variable "atlantis_cognito_user_pool_client_id_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup `atlantis_cognito_user_pool_client_id` if not provided"
  default     = ""
}

variable "atlantis_cognito_user_pool_domain" {
  type        = "string"
  description = "Cognito User Pool Domain. The User Pool Domain should be set to the domain prefix (`xxx`) instead of full domain (https://xxx.auth.us-west-2.amazoncognito.com)"
  default     = ""
}

variable "atlantis_cognito_user_pool_domain_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup `atlantis_cognito_user_pool_domain` if not provided"
  default     = ""
}

variable "atlantis_oidc_client_id" {
  type        = "string"
  description = "OIDC Client ID"
  default     = ""
}

variable "atlantis_oidc_client_id_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup `atlantis_oidc_client_id` if not provided"
  default     = ""
}

variable "atlantis_oidc_client_secret" {
  type        = "string"
  description = "OIDC Client Secret"
  default     = ""
}

variable "atlantis_oidc_client_secret_ssm_name" {
  type        = "string"
  description = "SSM param name to lookup `atlantis_oidc_client_secret` if not provided"
  default     = ""
}

variable "atlantis_oidc_issuer" {
  type        = "string"
  description = "OIDC Issuer"
  default     = ""
}

variable "atlantis_oidc_authorization_endpoint" {
  type        = "string"
  description = "OIDC Authorization Endpoint"
  default     = ""
}

variable "atlantis_oidc_token_endpoint" {
  type        = "string"
  description = "OIDC Token Endpoint"
  default     = ""
}

variable "atlantis_oidc_user_info_endpoint" {
  type        = "string"
  description = "OIDC User Info Endpoint"
  default     = ""
}

variable "atlantis_alb_ingress_listener_unauthenticated_priority" {
  type        = "string"
  default     = "50"
  description = "The priority for the rules without authentication, between 1 and 50000 (1 being highest priority). Must be different from `alb_ingress_listener_authenticated_priority` since a listener can't have multiple rules with the same priority"
}

variable "atlantis_alb_ingress_listener_authenticated_priority" {
  type        = "string"
  default     = "100"
  description = "The priority for the rules with authentication, between 1 and 50000 (1 being highest priority). Must be different from `alb_ingress_listener_unauthenticated_priority` since a listener can't have multiple rules with the same priority"
}

variable "atlantis_alb_ingress_unauthenticated_paths" {
  type        = "list"
  default     = []
  description = "Unauthenticated path pattern to match (a maximum of 1 can be defined)"
}

variable "atlantis_alb_ingress_authenticated_paths" {
  type        = "list"
  default     = []
  description = "Authenticated path pattern to match (a maximum of 1 can be defined)"
}

variable "kms_key_id" {
  type        = "string"
  description = "KMS key ID used to encrypt SSM SecureString parameters"
  default     = ""
}

variable "chamber_format" {
  type        = "string"
  description = "Format to store parameters in SSM, for consumption with chamber"
  default     = "/%s/%s"
}

variable "chamber_service" {
  type        = "string"
  description = "SSM parameter service name for use with chamber. This is used in chamber_format where /$chamber_service/$parameter would be the default."
  default     = "atlantis"
}

variable "overwrite_ssm_parameter" {
  type        = "string"
  default     = "true"
  description = "Whether to overwrite an existing SSM parameter"
}

data "aws_ssm_parameter" "atlantis_cognito_user_pool_arn" {
  count = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" && length(var.atlantis_cognito_user_pool_arn) == 0 ? 1 : 0}"
  name  = "${local.atlantis_cognito_user_pool_arn_ssm_name}"
}

data "aws_ssm_parameter" "atlantis_cognito_user_pool_client_id" {
  count = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" && length(var.atlantis_cognito_user_pool_client_id) == 0 ? 1 : 0}"
  name  = "${local.atlantis_cognito_user_pool_client_id_ssm_name}"
}

data "aws_ssm_parameter" "atlantis_cognito_user_pool_domain" {
  count = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" && length(var.atlantis_cognito_user_pool_domain) == 0 ? 1 : 0}"
  name  = "${local.atlantis_cognito_user_pool_domain_ssm_name}"
}

data "aws_ssm_parameter" "atlantis_oidc_client_id" {
  count = "${local.atlantis_enabled && var.atlantis_authentication_type == "OIDC" && length(var.atlantis_oidc_client_id) == 0 ? 1 : 0}"
  name  = "${local.atlantis_oidc_client_id_ssm_name}"
}

data "aws_ssm_parameter" "atlantis_oidc_client_secret" {
  count = "${local.atlantis_enabled && var.atlantis_authentication_type == "OIDC" && length(var.atlantis_oidc_client_secret) == 0 ? 1 : 0}"
  name  = "${local.atlantis_oidc_client_secret_ssm_name}"
}

locals {
  atlantis_enabled = "${var.atlantis_enabled == "true" ? true : false}"

  kms_key_id = "${length(var.kms_key_id) > 0 ? var.kms_key_id : format("alias/%s-%s-chamber", var.namespace, var.stage)}"

  atlantis_cognito_user_pool_arn          = "${length(join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_arn.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_arn.*.value) : var.atlantis_cognito_user_pool_arn}"
  atlantis_cognito_user_pool_arn_ssm_name = "${length(var.atlantis_cognito_user_pool_arn_ssm_name) > 0 ? var.atlantis_cognito_user_pool_arn_ssm_name : format(var.chamber_format, var.chamber_service, "atlantis_cognito_user_pool_arn")}"

  atlantis_cognito_user_pool_client_id          = "${length(join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_client_id.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_client_id.*.value) : var.atlantis_cognito_user_pool_client_id}"
  atlantis_cognito_user_pool_client_id_ssm_name = "${length(var.atlantis_cognito_user_pool_client_id_ssm_name) > 0 ? var.atlantis_cognito_user_pool_client_id_ssm_name : format(var.chamber_format, var.chamber_service, "atlantis_cognito_user_pool_client_id")}"

  atlantis_cognito_user_pool_domain          = "${length(join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_domain.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_cognito_user_pool_domain.*.value) : var.atlantis_cognito_user_pool_domain}"
  atlantis_cognito_user_pool_domain_ssm_name = "${length(var.atlantis_cognito_user_pool_domain_ssm_name) > 0 ? var.atlantis_cognito_user_pool_domain_ssm_name : format(var.chamber_format, var.chamber_service, "atlantis_cognito_user_pool_domain")}"

  atlantis_oidc_client_id          = "${length(join("", data.aws_ssm_parameter.atlantis_oidc_client_id.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_oidc_client_id.*.value) : var.atlantis_oidc_client_id}"
  atlantis_oidc_client_id_ssm_name = "${length(var.atlantis_oidc_client_id_ssm_name) > 0 ? var.atlantis_oidc_client_id_ssm_name : format(var.chamber_format, var.chamber_service, "atlantis_oidc_client_id")}"

  atlantis_oidc_client_secret          = "${length(join("", data.aws_ssm_parameter.atlantis_oidc_client_secret.*.value)) > 0 ? join("", data.aws_ssm_parameter.atlantis_oidc_client_secret.*.value) : var.atlantis_oidc_client_secret}"
  atlantis_oidc_client_secret_ssm_name = "${length(var.atlantis_oidc_client_secret_ssm_name) > 0 ? var.atlantis_oidc_client_secret_ssm_name : format(var.chamber_format, var.chamber_service, "atlantis_oidc_client_secret")}"
}

module "atlantis" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecs-atlantis.git?ref=tags/0.6.0"
  enabled   = "${var.atlantis_enabled}"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  region    = "${var.region}"
  stage     = "${var.stage}"

  atlantis_gh_team_whitelist = "${var.atlantis_gh_team_whitelist}"
  atlantis_gh_user           = "${var.atlantis_gh_user}"
  atlantis_repo_whitelist    = ["${var.atlantis_repo_whitelist}"]

  alb_arn_suffix = "${module.alb.alb_arn_suffix}"
  alb_dns_name   = "${module.alb.alb_dns_name}"
  alb_name       = "${module.alb.alb_name}"
  alb_zone_id    = "${module.alb.alb_zone_id}"

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

  alb_ingress_authenticated_listener_arns       = ["${module.alb.https_listener_arn}"]
  alb_ingress_authenticated_listener_arns_count = 1

  alb_ingress_unauthenticated_listener_arns       = ["${module.alb.listener_arns}"]
  alb_ingress_unauthenticated_listener_arns_count = 2

  alb_ingress_unauthenticated_paths             = ["${var.atlantis_alb_ingress_unauthenticated_paths}"]
  alb_ingress_listener_unauthenticated_priority = "${var.atlantis_alb_ingress_listener_unauthenticated_priority}"
  alb_ingress_authenticated_paths               = ["${var.atlantis_alb_ingress_authenticated_paths}"]
  alb_ingress_listener_authenticated_priority   = "${var.atlantis_alb_ingress_listener_authenticated_priority}"

  authentication_type                        = "${var.atlantis_authentication_type}"
  authentication_cognito_user_pool_arn       = "${var.atlantis_cognito_user_pool_arn}"
  authentication_cognito_user_pool_client_id = "${var.atlantis_cognito_user_pool_client_id}"
  authentication_cognito_user_pool_domain    = "${var.atlantis_cognito_user_pool_domain}"
  authentication_oidc_client_id              = "${var.atlantis_oidc_client_id}"
  authentication_oidc_client_secret          = "${var.atlantis_oidc_client_secret}"
  authentication_oidc_issuer                 = "${var.atlantis_oidc_issuer}"
  authentication_oidc_authorization_endpoint = "${var.atlantis_oidc_authorization_endpoint}"
  authentication_oidc_token_endpoint         = "${var.atlantis_oidc_token_endpoint}"
  authentication_oidc_user_info_endpoint     = "${var.atlantis_oidc_user_info_endpoint}"
}

resource "aws_ssm_parameter" "atlantis_cognito_user_pool_arn" {
  count       = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" ? 1 : 0}"
  overwrite   = "${var.overwrite_ssm_parameter}"
  type        = "SecureString"
  description = "Atlantis Cognito User Pool ARN"
  key_id      = "${local.kms_key_id}"
  name        = "${local.atlantis_cognito_user_pool_arn_ssm_name}"
  value       = "${local.atlantis_cognito_user_pool_arn}"
}

resource "aws_ssm_parameter" "atlantis_cognito_user_pool_client_id" {
  count       = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" ? 1 : 0}"
  overwrite   = "${var.overwrite_ssm_parameter}"
  type        = "SecureString"
  description = "Atlantis Cognito User Pool Client ID"
  key_id      = "${local.kms_key_id}"
  name        = "${local.atlantis_cognito_user_pool_client_id_ssm_name}"
  value       = "${local.atlantis_cognito_user_pool_client_id}"
}

resource "aws_ssm_parameter" "atlantis_cognito_user_pool_domain" {
  count       = "${local.atlantis_enabled && var.atlantis_authentication_type == "COGNITO" ? 1 : 0}"
  overwrite   = "${var.overwrite_ssm_parameter}"
  type        = "SecureString"
  description = "Atlantis Cognito User Pool Domain"
  key_id      = "${local.kms_key_id}"
  name        = "${local.atlantis_cognito_user_pool_domain_ssm_name}"
  value       = "${local.atlantis_cognito_user_pool_domain}"
}

resource "aws_ssm_parameter" "atlantis_oidc_client_id" {
  count       = "${local.atlantis_enabled && var.atlantis_authentication_type == "OIDC" ? 1 : 0}"
  overwrite   = "${var.overwrite_ssm_parameter}"
  type        = "SecureString"
  description = "Atlantis OIDC Client ID"
  key_id      = "${local.kms_key_id}"
  name        = "${local.atlantis_oidc_client_id_ssm_name}"
  value       = "${local.atlantis_oidc_client_id}"
}

resource "aws_ssm_parameter" "atlantis_oidc_client_secret" {
  count       = "${local.atlantis_enabled && var.atlantis_authentication_type == "OIDC" ? 1 : 0}"
  overwrite   = "${var.overwrite_ssm_parameter}"
  type        = "SecureString"
  description = "Atlantis OIDC Client Secret"
  key_id      = "${local.kms_key_id}"
  name        = "${local.atlantis_oidc_client_secret_ssm_name}"
  value       = "${local.atlantis_oidc_client_secret}"
}

output "atlantis_url" {
  value = "${module.atlantis.atlantis_url}"
}
