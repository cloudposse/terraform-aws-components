module "aurora_postgres" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.4.1"

  component = var.aurora_postgres_component_name

  context = module.this.context
}
