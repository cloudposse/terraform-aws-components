locals {
  enabled = module.this.enabled

  url    = try(module.store_read.map[format("%s/%s", var.ssm_path_prefix, "url")], "")
  ca     = try(module.store_read.map[format("%s/%s", var.ssm_path_prefix, "ca")], "")
  issuer = try(module.store_read.map[format("%s/%s", var.ssm_path_prefix, "issuer")], "")
}

module "store_read" {
  source  = "cloudposse/ssm-parameter-store/aws"
  version = "0.10.0"

  context = module.this.context

  parameter_read = formatlist("%s/%s", var.ssm_path_prefix, ["url", "ca", "issuer"])
}
