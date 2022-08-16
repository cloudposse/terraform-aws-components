module "aurora_mysql" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = var.aurora_mysql_component_name

  context = module.this.context
}
