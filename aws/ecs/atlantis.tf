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

variable "atlantis_authentication_action_type" {
  type        = "string"
  default     = "NONE"
  description = "Authentication action type. Supported values are `COGNITO`, `GOOGLE_OIDC`, `NONE`"
}

variable "atlantis_cognito_user_pool_arn" {
  type        = "string"
  description = "Cognito User Pool ARN"
  default     = ""
}

variable "atlantis_cognito_user_pool_client_id" {
  type        = "string"
  description = "Cognito User Pool Client ID"
  default     = ""
}

variable "atlantis_cognito_user_pool_domain" {
  type        = "string"
  description = "Cognito User Pool Domain. The User Pool Domain should be set to the domain prefix (`xxx`) instead of full domain (https://xxx.auth.us-west-2.amazoncognito.com)"
  default     = ""
}

variable "atlantis_google_oidc_client_id" {
  type        = "string"
  description = "Google OIDC Client ID. Use this URL to create a Google OAuth 2.0 Client and obtain the Client ID and Client Secret: https://console.developers.google.com/apis/credentials"
  default     = ""
}

variable "atlantis_google_oidc_client_secret" {
  type        = "string"
  description = "Google OIDC Client Secret. Use this URL to create a Google OAuth 2.0 Client and obtain the Client ID and Client Secret: https://console.developers.google.com/apis/credentials"
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
  default     = ["/events"]
  description = "Unauthenticated path pattern to match (a maximum of 1 can be defined)"
}

variable "atlantis_alb_ingress_authenticated_paths" {
  type        = "list"
  default     = ["/*"]
  description = "Authenticated path pattern to match (a maximum of 1 can be defined)"
}

locals {
  authentication_enabled = "${var.atlantis_authentication_action_type == "COGNITO" || var.atlantis_authentication_action_type == "GOOGLE_OIDC" ? "true" : "false"}"

  supported_authentication_actions = {
    "COGNITO" = {
      type = "authenticate-cognito"

      authenticate_cognito = [{
        user_pool_arn       = "${var.atlantis_cognito_user_pool_arn}"
        user_pool_client_id = "${var.atlantis_cognito_user_pool_client_id}"
        user_pool_domain    = "${var.atlantis_cognito_user_pool_domain}"
      }]
    }

    "GOOGLE_OIDC" = {
      type = "authenticate-oidc"

      authenticate_oidc = [{
        client_id     = "${var.atlantis_google_oidc_client_id}"
        client_secret = "${var.atlantis_google_oidc_client_secret}"

        # Use this URL to get Google Auth endpoints: https://accounts.google.com/.well-known/openid-configuration
        issuer                 = "https://accounts.google.com"
        authorization_endpoint = "https://accounts.google.com/o/oauth2/v2/auth"
        token_endpoint         = "https://oauth2.googleapis.com/token"
        user_info_endpoint     = "https://openidconnect.googleapis.com/v1/userinfo"
      }]
    }

    "NONE" = {
      type = "none"
    }
  }

  authentication_action = "${lookup(supported_authentication_actions, var.atlantis_authentication_action_type)}"

  # NOTE: Cognito and OIDC authentication only supported on HTTPS endpoints
  # If authentication enabled, we provide only HTTPS listener ARNs from ALB
  supported_alb_listener_arns = {
    "true"  = ["${module.alb.https_listener_arn}"]
    "false" = ["${module.alb.listener_arn}"]
  }

  alb_listener_arns = "${lookup(supported_alb_listener_arns, local.authentication_enabled)}"

  supported_alb_ingress_unauthenticated_paths = {
    "true"  = ["${var.atlantis_alb_ingress_unauthenticated_paths}"]
    "false" = ["${var.atlantis_alb_ingress_authenticated_paths}"]
  }

  alb_ingress_unauthenticated_paths = "${lookup(supported_alb_ingress_unauthenticated_paths, local.authentication_enabled)}"

  supported_alb_ingress_authenticated_paths = {
    "true"  = ["${var.atlantis_alb_ingress_authenticated_paths}"]
    "false" = []
  }

  alb_ingress_authenticated_paths = "${lookup(supported_alb_ingress_authenticated_paths, local.authentication_enabled)}"
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

  # NOTE: Cognito and OIDC authentication only supported on HTTPS endpoints; here we provide `https_listener_arn` from ALB
  alb_listener_arns       = ["${local.alb_listener_arns}"]
  alb_listener_arns_count = "${local.authentication_enabled == "true" ? 1 : 2}"

  alb_ingress_unauthenticated_paths             = ["${local.alb_ingress_unauthenticated_paths}"]
  alb_ingress_listener_unauthenticated_priority = "${var.atlantis_alb_ingress_listener_unauthenticated_priority}"
  alb_ingress_authenticated_paths               = ["${local.alb_ingress_authenticated_paths}"]
  alb_ingress_listener_authenticated_priority   = "${var.atlantis_alb_ingress_listener_authenticated_priority}"

  authentication_action = "${local.authentication_action}"
}

output "atlantis_url" {
  value = "${module.atlantis.atlantis_url}"
}
