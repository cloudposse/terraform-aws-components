resource "github_repository_file" "application_set" {
  for_each = local.environments

  repository = local.github_repository.name
  branch     = local.github_repository.default_branch
  file       = "${each.value.tenant != null ? format("%s/", each.value.tenant) : ""}${each.value.environment}-${each.value.stage}${length(each.value.attributes) > 0 ? format("-%s", join("-", each.value.attributes)) : ""}/${local.manifest_kubernetes_namespace}/applicationset.yaml"
  content = templatefile("${path.module}/templates/applicationset.yaml.tpl", {
    environment        = each.key
    auto-sync          = each.value.auto-sync
    ignore-differences = each.value.ignore-differences
    name               = module.this.namespace
    namespace          = local.manifest_kubernetes_namespace
    ssh_url            = local.github_repository.ssh_clone_url
    notifications      = var.github_default_notifications_enabled
  })
  commit_message      = "Initialize environment: `${each.key}`."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}
