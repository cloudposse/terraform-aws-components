module "vpc_flow_logs_bucket" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.17.0"

  stack_config_local_path = "../../../stacks"
  component               = "vpc-flow-logs-bucket"
  environment             = var.vpc_flow_logs_bucket_environment_name
  stage                   = var.vpc_flow_logs_bucket_stage_name

  context = module.this.context
}
