module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  for_each = var.eks_tags_enabled ? var.eks_component_names : []

  component = each.value

  context = module.this.context
}

module "vpc_flow_logs_bucket" {
  count = var.vpc_flow_logs_enabled ? 1 : 0

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component   = "vpc-flow-logs-bucket"
  environment = var.vpc_flow_logs_bucket_environment_name
  stage       = var.vpc_flow_logs_bucket_stage_name
  tenant      = coalesce(var.vpc_flow_logs_bucket_tenant_name, module.this.tenant)

  context = module.this.context
}
