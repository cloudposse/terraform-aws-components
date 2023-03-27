module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = "vpc"

  context = module.this.context
}

module "vpc_ingress" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  for_each = toset(var.allow_ingress_from_vpc_stages)

  component = "vpc"
  stage     = each.key

  context = module.this.context
}
