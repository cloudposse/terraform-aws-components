module "glue_registry" {
  source  = "cloudposse/glue/aws//modules/glue-registry"
  version = "0.4.0"

  registry_name        = var.registry_name
  registry_description = var.registry_description

  context = module.this.context
}
