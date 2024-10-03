module "glue_iam_role" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_iam_component_name

  context = module.this.context
}

module "glue_catalog_database" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.glue_catalog_database_component_name

  context = module.this.context
}
