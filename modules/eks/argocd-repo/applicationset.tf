locals {
  applicationset_template = "${path.module}/templates/${var.applicationset_template}"
}

resource "github_repository_file" "application_set" {
  for_each = local.environments

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = "${each.value.tenant != null ? format("%s/", each.value.tenant) : ""}${each.value.environment}-${each.value.stage}/${local.manifest_kubernetes_namespace}/applicationset.yaml"
  content = templatefile(local.applicationset_template, {
    environment            = each.key
    environment_normalized = replace(each.key, "/", "-")
    auto-sync              = each.value.auto-sync
    auto-sync-namespaces   = each.value.auto-sync-namespaces
    name                   = module.this.namespace
    namespace              = local.manifest_kubernetes_namespace
    ssh_url                = join("", github_repository.default.*.ssh_clone_url)
    slack_channel          = each.value.slack_channel
  })
  commit_message      = "Initialize environment: `${each.key}`."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}
