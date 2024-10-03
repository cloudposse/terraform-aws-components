module "api_gateway_account_settings" {
  source  = "cloudposse/api-gateway/aws//modules/account-settings"
  version = "0.3.1"

  context = module.this.context
}
