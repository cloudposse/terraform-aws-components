module "glue_schema" {
  source  = "cloudposse/glue/aws//modules/glue-schema"
  version = "0.4.0"

  schema_name        = var.schema_name
  schema_description = var.schema_description
  registry_arn       = module.glue_registry.outputs.registry_arn
  data_format        = var.data_format
  compatibility      = var.compatibility
  schema_definition  = var.schema_definition

  context = module.this.context
}
