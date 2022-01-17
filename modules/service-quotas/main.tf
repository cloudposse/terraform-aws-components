module "service_quotas" {
  source  = "cloudposse/service-quotas/aws"
  version = "0.1.0"
  context = module.this.context

  service_quotas = var.service_quotas
}
