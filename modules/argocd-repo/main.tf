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
  manifest_kubernetes_namespace = "argocd"

  team_slugs = toset(compact([
    for permission in var.permissions : lookup(permission, "team_slug", null)
  ]))

  team_ids = [
    for team in data.github_team.default : team.id
  ]

  team_permissions = {
    for index, id in local.team_ids : (var.permissions[index].team_slug) => {
      id         = id
      permission = var.permissions[index].permission
    }
  }
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

data "github_team" "default" {
  for_each = local.team_slugs

  slug = each.value
}

resource "github_team_repository" "default" {
  for_each = local.team_permissions

  repository = join("", github_repository.default[*].name)
  team_id    = each.value.id
  permission = each.value.permission
}

resource "tls_private_key" "default" {
  for_each = local.environments

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "github_repository_deploy_key" "default" {
  for_each = local.environments

  title      = "Deploy key for ArgoCD environment: ${each.key} (${join("", github_repository.default.*.default_branch)} branch)"
  repository = join("", github_repository.default.*.name)
  key        = tls_private_key.default[each.key].public_key_openssh
  read_only  = true
}
