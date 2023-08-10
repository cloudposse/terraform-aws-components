module "waf" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  count = local.aws_waf_enabled ? 1 : 0

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

  count = local.github_runners_enabled ? 1 : 0

  component   = "github-runners"
  stage       = var.github_runners_stage_name
  environment = var.github_runners_environment_name
  tenant      = try(var.github_runners_tenant_name, var.tenant)

  context = module.this.context
}
