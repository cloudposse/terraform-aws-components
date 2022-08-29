module "aurora_postgres" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.3"

  component = var.aurora_postgres_component_name

  context = module.this.context
}
