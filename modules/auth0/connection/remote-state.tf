module "auth0_apps" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  for_each = local.enabled ? { for app in var.auth0_app_connections : "${app.tenant}-${app.environment}-${app.stage}-${app.component}" => app } : {}

  component   = each.value.component
  tenant      = length(each.value.tenant) > 0 ? each.value.tenant : module.this.tenant
  environment = length(each.value.environment) > 0 ? each.value.environment : module.this.environment
  stage       = length(each.value.stage) > 0 ? each.value.stage : module.this.stage
}
