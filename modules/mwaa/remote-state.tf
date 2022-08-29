module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  for_each = toset(var.allow_ingress_from_vpc_stages)

  component = "vpc"
  stage     = each.key

  context = module.this.context
}
