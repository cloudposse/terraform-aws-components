module "aurora_postgres" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = var.aurora_postgres_component_name

  context = module.this.context
}
