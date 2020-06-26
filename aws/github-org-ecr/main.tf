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
  repos_to_create = concat(cache_repo_list, lower_org_names)
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
