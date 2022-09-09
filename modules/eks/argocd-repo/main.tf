locals {
  enabled = module.this.enabled
  environments = local.enabled ? {
    for env in var.environments :
    (format(
      "${env.tenant != null ? "%[1]s/" : ""}%[2]s-%[3]s",
      env.tenant,
      env.environment,
      env.stage,
    )) => env
  } : {}

  deploy_key_generation_environments = var.deploy_key_generation_enabled ? local.environments : {}
  ssm_deploy_key_environments        = var.deploy_key_generation_enabled ? {} : local.environments

  manifest_kubernetes_namespace = "argocd"
}

resource "github_repository" "default" {
  count = local.enabled ? 1 : 0

  name        = module.this.name
  description = var.description
  auto_init   = true # will create a 'main' branch

  visibility = "private"
}

resource "github_branch_default" "default" {
  count = local.enabled ? 1 : 0

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
}

data "github_user" "automation_user" {
  count = local.enabled ? 1 : 0

  username = var.github_user
}

resource "github_branch_protection" "default" {
  # This resource enforces PRs needing to be opened in order for changes to be made, except for automated commits to
  # the main branch. Those commits made by the automation user, which is an admin.
  count = local.enabled ? 1 : 0

  repository_id = join("", github_repository.default.*.name)

  pattern          = join("", github_branch_default.default.*.branch)
  enforce_admins   = false # needs to be false in order to allow automation user to push
  allows_deletions = true

  required_pull_request_reviews {
    dismiss_stale_reviews      = true
    restrict_dismissals        = true
    require_code_owner_reviews = true
  }

  push_restrictions = [
    join("", data.github_user.automation_user.*.node_id),
  ]
}


resource "tls_private_key" "default" {
  for_each = local.deploy_key_generation_environments

  algorithm = "ED25519"
}

resource "github_repository_deploy_key" "generated_deploy_keys" {
  for_each = local.deploy_key_generation_environments

  title      = "Deploy key for ArgoCD environment: ${each.key} (${join("", github_repository.default.*.default_branch)} branch)"
  repository = join("", github_repository.default.*.name)
  key        = tls_private_key.default[each.key].public_key_openssh
  read_only  = true
}

resource "github_repository_deploy_key" "deploy_key" {
  for_each = local.ssm_deploy_key_environments

  title      = "Deploy key for ArgoCD environment: ${each.key} (${join("", github_repository.default.*.default_branch)} branch)"
  repository = join("", github_repository.default.*.name)
  key        = data.aws_ssm_parameter.public_deploy_keys[each.key].value
  read_only  = true
}