module "waf" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  bypass      = !local.aws_waf_enabled
  component   = var.cloudfront_aws_waf_component_name
  privileged  = false
  environment = var.cloudfront_aws_waf_environment

  defaults = {
    acl = {
      arn = ""
    }
  }

  context = module.this.context
}

module "dns_delegated" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component   = "dns-delegated"
  environment = var.dns_delegated_environment_name

  context = module.this.context
}

module "github_runners" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  bypass      = !local.github_runners_enabled
  component   = var.github_runners_component_name
  stage       = var.github_runners_stage_name
  environment = var.github_runners_environment_name
  tenant      = try(var.github_runners_tenant_name, module.this.tenant)

  context = module.this.context
}
