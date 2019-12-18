variable "atlantis_enabled" {
  type    = bool
  default = true
}

variable "atlantis_gh_team_whitelist" {
  type        = string
  description = "Atlantis GitHub team whitelist"
  default     = ""
}

variable "atlantis_gh_user" {
  type        = string
  description = "Atlantis GitHub user"
  default     = "undefined"
}

variable "atlantis_repo_config" {
  type        = string
  description = "Path to atlantis server-side repo config file (https://www.runatlantis.io/docs/server-side-repo-config.html)"
  default     = "atlantis-repo-config.yaml"
}

variable "atlantis_repo_whitelist" {
  type        = list(string)
  description = "Whitelist of repositories Atlantis will accept webhooks from"
  default     = []
}

variable "atlantis_branch" {
  type        = string
  default     = "master"
  description = "Atlantis branch Branch of the GitHub repository, _e.g._ `master`"
}

variable "atlantis_repo_name" {
  type        = string
  description = "GitHub repository name of the atlantis to be built and deployed to ECS."
}

variable "atlantis_repo_owner" {
  type        = string
  description = "GitHub organization containing the Atlantis repository"
  default     = "undefined"
}

variable "atlantis_container_cpu" {
  type        = number
  description = "The vCPU setting to control cpu limits of container. (If FARGATE launch type is used below, this must be a supported vCPU size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 256
}

variable "atlantis_container_memory" {
  type        = number
  description = "The amount of RAM to allow container to use in MB. (If FARGATE launch type is used below, this must be a supported Memory size from the table here: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html)"
  default     = 512
}

variable "atlantis_authentication_type" {
  type        = string
  default     = ""
  description = "Authentication action type. Supported values are `COGNITO` and `OIDC`"
}

variable "atlantis_cognito_user_pool_arn" {
  type        = string
  description = "Cognito User Pool ARN"
  default     = ""
}

variable "atlantis_cognito_user_pool_arn_ssm_name" {
  type        = string
  description = "SSM param name to lookup `atlantis_cognito_user_pool_arn` if not provided"
  default     = ""
}

variable "atlantis_cognito_user_pool_client_id" {
  type        = string
  description = "Cognito User Pool Client ID"
  default     = ""
}

variable "atlantis_cognito_user_pool_client_id_ssm_name" {
  type        = string
  description = "SSM param name to lookup `atlantis_cognito_user_pool_client_id` if not provided"
  default     = ""
}

variable "atlantis_cognito_user_pool_domain" {
  type        = string
  description = "Cognito User Pool Domain. The User Pool Domain should be set to the domain prefix (`xxx`) instead of full domain (https://xxx.auth.us-west-2.amazoncognito.com)"
  default     = ""
}

variable "atlantis_cognito_user_pool_domain_ssm_name" {
  type        = string
  description = "SSM param name to lookup `atlantis_cognito_user_pool_domain` if not provided"
  default     = ""
}

variable "atlantis_oidc_client_id" {
  type        = string
  description = "OIDC Client ID"
  default     = ""
}

variable "atlantis_oidc_client_id_ssm_name" {
  type        = string
  description = "SSM param name to lookup `atlantis_oidc_client_id` if not provided"
  default     = ""
}

variable "atlantis_oidc_client_secret" {
  type        = string
  description = "OIDC Client Secret"
  default     = ""
}

variable "atlantis_oidc_client_secret_ssm_name" {
  type        = string
  description = "SSM param name to lookup `atlantis_oidc_client_secret` if not provided"
  default     = ""
}

variable "atlantis_oidc_issuer" {
  type        = string
  description = "OIDC Issuer"
  default     = ""
}

variable "atlantis_oidc_authorization_endpoint" {
  type        = string
  description = "OIDC Authorization Endpoint"
  default     = ""
}

variable "atlantis_oidc_token_endpoint" {
  type        = string
  description = "OIDC Token Endpoint"
  default     = ""
}

variable "atlantis_oidc_user_info_endpoint" {
  type        = string
  description = "OIDC User Info Endpoint"
  default     = ""
}

variable "atlantis_alb_ingress_listener_unauthenticated_priority" {
  type        = number
  default     = 50
  description = "The priority for the rules without authentication, between 1 and 50000 (1 being highest priority). Must be different from `alb_ingress_listener_authenticated_priority` since a listener can't have multiple rules with the same priority"
}

variable "atlantis_alb_ingress_listener_authenticated_priority" {
  type        = number
  default     = 100
  description = "The priority for the rules with authentication, between 1 and 50000 (1 being highest priority). Must be different from `alb_ingress_listener_unauthenticated_priority` since a listener can't have multiple rules with the same priority"
}

variable "atlantis_alb_ingress_unauthenticated_paths" {
  type        = list(string)
  default     = []
  description = "Unauthenticated path pattern to match (a maximum of 1 can be defined)"
}

variable "atlantis_alb_ingress_authenticated_paths" {
  type        = list(string)
  default     = []
  description = "Authenticated path pattern to match (a maximum of 1 can be defined)"
}

variable "atlantis_build_timeout" {
  type        = number
  description = "Time (in minutes) to allow for Atlantis build to complete before declaring it a failure"
  default     = 20
}

module "atlantis" {
  source    = "git::https://github.com/cloudposse/terraform-aws-ecs-atlantis.git?ref=tags/0.14.0"
  enabled   = var.atlantis_enabled
  name      = var.name
  namespace = var.namespace
  region    = var.region
  stage     = var.stage

  atlantis_gh_team_whitelist = var.atlantis_gh_team_whitelist
  atlantis_gh_user           = var.atlantis_gh_user
  atlantis_repo_whitelist    = var.atlantis_repo_whitelist
  atlantis_repo_config       = var.atlantis_repo_config

  alb_arn_suffix     = module.alb.alb_arn_suffix
  alb_dns_name       = module.alb.alb_dns_name
  alb_name           = module.alb.alb_name
  alb_zone_id        = module.alb.alb_zone_id
  alb_security_group = module.alb.security_group_id

  container_cpu    = var.atlantis_container_cpu
  container_memory = var.atlantis_container_memory

  branch             = var.atlantis_branch
  parent_zone_id     = module.dns.zone_id
  ecs_cluster_arn    = aws_ecs_cluster.default.arn
  ecs_cluster_name   = aws_ecs_cluster.default.name
  repo_name          = var.atlantis_repo_name
  repo_owner         = var.atlantis_repo_owner
  private_subnet_ids = module.subnets.private_subnet_ids
  vpc_id             = module.vpc.vpc_id

  alb_ingress_authenticated_listener_arns       = [module.alb.https_listener_arn]
  alb_ingress_authenticated_listener_arns_count = 1

  alb_ingress_unauthenticated_listener_arns       = module.alb.listener_arns
  alb_ingress_unauthenticated_listener_arns_count = 2

  alb_ingress_unauthenticated_paths             = var.atlantis_alb_ingress_unauthenticated_paths
  alb_ingress_listener_unauthenticated_priority = var.atlantis_alb_ingress_listener_unauthenticated_priority
  alb_ingress_authenticated_paths               = var.atlantis_alb_ingress_authenticated_paths
  alb_ingress_listener_authenticated_priority   = var.atlantis_alb_ingress_listener_authenticated_priority

  authentication_type                        = var.atlantis_authentication_type
  authentication_cognito_user_pool_arn       = var.atlantis_cognito_user_pool_arn
  authentication_cognito_user_pool_client_id = var.atlantis_cognito_user_pool_client_id
  authentication_cognito_user_pool_domain    = var.atlantis_cognito_user_pool_domain
  authentication_oidc_client_id              = var.atlantis_oidc_client_id
  authentication_oidc_client_secret          = var.atlantis_oidc_client_secret
  authentication_oidc_issuer                 = var.atlantis_oidc_issuer
  authentication_oidc_authorization_endpoint = var.atlantis_oidc_authorization_endpoint
  authentication_oidc_token_endpoint         = var.atlantis_oidc_token_endpoint
  authentication_oidc_user_info_endpoint     = var.atlantis_oidc_user_info_endpoint

  authentication_cognito_user_pool_arn_ssm_name       = var.atlantis_cognito_user_pool_arn_ssm_name
  authentication_cognito_user_pool_client_id_ssm_name = var.atlantis_cognito_user_pool_client_id_ssm_name
  authentication_cognito_user_pool_domain_ssm_name    = var.atlantis_cognito_user_pool_domain_ssm_name
  authentication_oidc_client_id_ssm_name              = var.atlantis_oidc_client_id_ssm_name
  authentication_oidc_client_secret_ssm_name          = var.atlantis_oidc_client_secret_ssm_name

  codepipeline_s3_bucket_force_destroy = true

  build_timeout = var.atlantis_build_timeout
}

output "atlantis_url" {
  value = module.atlantis.atlantis_url
}
