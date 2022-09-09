# Additional resources for argocd-cluster-config repo(s)
locals {
  cluster_config_enabled        = module.this.enabled && var.applicationset_template == "config.applicationset.yaml.tpl"
  environment_tenants           = toset([for env in var.environments : env.tenant])
  environment_config_set        = setproduct([for k, v in local.environments : k], var.cluster_config_types)
  environment_tenant_config_set = setproduct(local.environment_tenants, var.cluster_config_types)

  global_bases_map = local.cluster_config_enabled ? { for config_type in var.cluster_config_types : config_type => config_type } : {}

  tenant_overlays_map = local.cluster_config_enabled ? {
    for env_tenant_config in local.environment_tenant_config_set : "${env_tenant_config[0]} ${env_tenant_config[1]} overlays" => {
      tenant      = env_tenant_config[0]
      config_type = env_tenant_config[1]
    }
  } : {}
  environment_overlays_map = local.cluster_config_enabled ? {
    for env_config in local.environment_config_set : "${env_config[0]} ${env_config[1]} overlays" => {
      environment = env_config[0]
      config_type = env_config[1]
    }
  } : {}
}

resource "github_repository_file" "config_global_bases" {
  for_each = { for config_type in var.cluster_config_types : config_type => config_type }

  repository          = join("", github_repository.default.*.name)
  branch              = join("", github_repository.default.*.default_branch)
  file                = "global/${each.key}/kustomization.yaml"
  content             = templatefile("${path.module}/templates/config.bases.kustomization.yaml.tpl", {})
  commit_message      = "Initialize global ${each.key} bases."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "github_repository_file" "config_tenant_overlays" {
  for_each = local.tenant_overlays_map

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = "${each.value.tenant}/${each.value.config_type}/kustomization.yaml"
  content = templatefile("${path.module}/templates/config.overlays.kustomization.yaml.tpl", {
    resources = "../../global/${each.value.config_type}"
  })
  commit_message      = "Initialize ${each.key}."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}

resource "github_repository_file" "config_environment_overlays" {
  for_each = local.environment_overlays_map

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = "${each.value.environment}/config/${each.value.config_type}/kustomization.yaml"
  content = templatefile("${path.module}/templates/config.overlays.kustomization.yaml.tpl", {
    resources = "../../../${each.value.config_type}"
  })
  commit_message      = "Initialize ${each.key}."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      content
    ]
  }
}
