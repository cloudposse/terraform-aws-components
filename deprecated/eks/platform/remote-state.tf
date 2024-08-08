module "eks" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.eks_component_name

  context = module.this.context
}


module "remote" {
  for_each = merge(var.references, local.metadata)
  source   = "cloudposse/stack-config/yaml//modules/remote-state"
  version  = "1.5.0"

  component   = each.value["component"]
  privileged  = coalesce(try(each.value["privileged"], null), false)
  tenant      = coalesce(try(each.value["tenant"], null), module.this.context["tenant"], null)
  environment = coalesce(try(each.value["environment"], null), module.this.context["environment"], null)
  stage       = coalesce(try(each.value["stage"], null), module.this.context["stage"], null)

  context = module.this.context
}
