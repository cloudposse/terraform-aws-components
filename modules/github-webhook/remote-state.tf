# This can be any component that has the required output, `github-webhook-value`
# This is typically eks/argocd
module "source" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.remote_state_github_webhook_enabled ? 1 : 0

  component = var.remote_state_component_name

  context = module.this.context
}
