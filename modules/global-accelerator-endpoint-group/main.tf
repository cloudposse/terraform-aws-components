module "endpoint_group" {
  source  = "cloudposse/global-accelerator/aws//modules/endpoint-group"
  version = "0.5.0"

  context = module.this.context

  listener_arn = module.global_accelerator.outputs.listener_ids[0]
  config       = var.config
}
