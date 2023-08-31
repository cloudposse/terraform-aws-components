resource "github_repository_file" "application_set" {
  for_each = local.environments

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = "${each.value.tenant != null ? format("%s/", each.value.tenant) : ""}${each.value.environment}-${each.value.stage}/${local.manifest_kubernetes_namespace}/applicationset.yaml"
  content = templatefile("${path.module}/templates/applicationset.yaml.tpl", {
    environment   = each.key
    auto-sync     = each.value.auto-sync
    name          = module.this.namespace
    namespace     = local.manifest_kubernetes_namespace
    ssh_url       = join("", github_repository.default.*.ssh_clone_url)
    notifications = var.github_default_notifications_enabled
  })
  commit_message      = "Initialize environment: `${each.key}`."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}
