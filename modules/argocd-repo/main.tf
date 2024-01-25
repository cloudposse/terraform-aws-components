locals {
  enabled = module.this.enabled

  environments = local.enabled ? {
    for env in var.environments :
    (format(
      "${env.tenant != null ? "%[1]s/" : ""}%[2]s-%[3]s${length(env.attributes) > 0 ? "-%[4]s" : "%[4]s"}",
      env.tenant,
      env.environment,
      env.stage,
      join("-", env.attributes)
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

  empty_repo = {
    name           = ""
    default_branch = ""
  }

  github_repository = try((var.create_repo ? github_repository.default : data.github_repository.default)[0], local.empty_repo)
}

data "github_repository" "default" {
  count = local.enabled && !var.create_repo ? 1 : 0
  name  = var.name
}

resource "github_repository" "default" {
  count = local.enabled && var.create_repo ? 1 : 0

  name        = module.this.name
  description = var.description
  auto_init   = true # will create a 'main' branch

  visibility = "private"
}

resource "github_branch_default" "default" {
  count = local.enabled ? 1 : 0

  repository = local.github_repository.name
  branch     = local.github_repository.default_branch
}

data "github_user" "automation_user" {
  count = local.enabled ? 1 : 0

  username = var.github_user
}

resource "github_branch_protection" "default" {
  # This resource enforces PRs needing to be opened in order for changes to be made, except for automated commits to
  # the main branch. Those commits made by the automation user, which is an admin.
  count = local.enabled ? 1 : 0

  repository_id = local.github_repository.name

  pattern          = join("", github_branch_default.default[*].branch)
  enforce_admins   = false # needs to be false in order to allow automation user to push
  allows_deletions = true

  dynamic "required_pull_request_reviews" {
    for_each = var.required_pull_request_reviews ? [0] : []
    content {
      dismiss_stale_reviews      = true
      restrict_dismissals        = true
      require_code_owner_reviews = true
    }
  }

  push_restrictions = var.push_restrictions_enabled ? [
    join("", data.github_user.automation_user[*].node_id),
  ] : []
}

data "github_team" "default" {
  for_each = local.team_slugs

  slug = each.value
}

resource "github_team_repository" "default" {
  for_each = local.team_permissions

  repository = local.github_repository.name
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

  title      = "Deploy key for ArgoCD environment: ${each.key} (${local.github_repository.default_branch} branch)"
  repository = local.github_repository.name
  key        = tls_private_key.default[each.key].public_key_openssh
  read_only  = true
}
