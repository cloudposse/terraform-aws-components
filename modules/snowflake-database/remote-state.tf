module "snowflake_account" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.1"

  component = "snowflake-account"

  context = module.introspection.context
}
