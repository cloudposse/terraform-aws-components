module "s3_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.s3_bucket_component_name
  environment = try(var.s3_bucket_environment_name, module.this.environment)

  context = module.this.context
}

module "dynamodb" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = var.dynamodb_component_name
  environment = try(var.dynamodb_environment_name, module.this.environment)

  context = module.this.context
}
