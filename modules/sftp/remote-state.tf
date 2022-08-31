module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "0.22.4"

  component = "vpc"
  stage     = "${var.tenant}-${var.stage}"

  context = module.this.context
}
