module "aurora_mysql" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.3.1"

  component = var.aurora_mysql_component_name

  context = module.this.context
}
