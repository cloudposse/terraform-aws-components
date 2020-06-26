terraform {
  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
}

data "github_repositories" "all_org_repos" {
  query = "org:${var.github_organization}"
}

locals {
  cache_repo_list = var.cache_registry_name == "" ? [] : [var.cache_registry_name]
  lower_org_names = [for s in data.github_repositories.all_org_repos.names : lower(s)]
  repos_to_create = concat(local.cache_repo_list, local.lower_org_names)
  ecr_user        = length(var.ecr_username) > 0 ? var.ecr_username : "${var.name}-user"
}

module "ecr" {
  source                     = "git::https://github.com/cloudposse/terraform-aws-ecr.git?ref=0.16.0"
  namespace                  = var.namespace
  stage                      = var.stage
  name                       = var.name
  delimiter                  = var.delimiter
  attributes                 = var.attributes
  tags                       = var.tags
  image_names                = local.repos_to_create
  max_image_count            = var.max_image_count
  principals_full_access     = var.principals_full_access
  principals_readonly_access = var.principals_readonly_access
  use_fullname               = false
  scan_images_on_push        = var.scan_images_on_push
  image_tag_mutability       = var.image_tag_mutability
}

output "repository_url_map" {
  value = module.ecr.repository_url_map
}

output "repository_arn_map" {
  value = module.ecr.repository_arn_map
}

module "ecr_user" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=0.9.0"

  enabled   = var.enable_user
  name      = local.ecr_user
  namespace = var.namespace
  stage     = var.stage
  tags      = var.tags
}

data "aws_iam_policy_document" "ecr_user_policy_doc" {
  count = var.enable_user ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:DescribeImages",
      "ecr:BatchGetImage",
      "ecr:GetLifecyclePolicy",
      "ecr:GetLifecyclePolicyPreview",
      "ecr:ListTagsForResource",
      "ecr:DescribeImageScanFindings",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "ecr_power_user_policy" {
  count  = var.enable_user ? 1 : 0
  name   = "${local.ecr_user}-policy"
  policy = join("", data.aws_iam_policy_document.ecr_user_policy_doc.*.json)
  user   = module.ecr_user.user_name
}

output "user_name" {
  value       = module.ecr_user.user_name
  description = "Normalized IAM user name"
}

output "user_arn" {
  value       = module.ecr_user.user_arn
  description = "The ARN assigned by AWS for this user"
}

output "user_unique_id" {
  value       = module.ecr_user.user_unique_id
  description = "The unique ID assigned by AWS"
}

output "access_key_id" {
  value       = module.ecr_user.access_key_id
  description = "The access key ID"
}

output "secret_access_key" {
  sensitive   = true
  value       = module.ecr_user.secret_access_key
  description = "The secret access key. This will be written to the state file in plain-text"
}
