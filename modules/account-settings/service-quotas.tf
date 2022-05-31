module "service_quotas" {
  source  = "cloudposse/service-quotas/aws"
  version = "0.1.0"
  enabled = module.this.enabled && var.service_quotas_enabled

  service_quotas = var.service_quotas

  context = module.this.context
}
