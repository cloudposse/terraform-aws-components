variable "spacelift_api_endpoint" {
  type        = string
  description = "The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io)"
}

# The Spacelift always validates its credentials, so we always pass api_key_id and api_key_secret
data "aws_ssm_parameter" "spacelift_key_id" {
  count = local.enabled ? 1 : 0
  name  = "/spacelift/key_id"
}

data "aws_ssm_parameter" "spacelift_key_secret" {
  count = local.enabled ? 1 : 0
  name  = "/spacelift/key_secret"
}

locals {
  enabled = module.this.enabled
}

# This provider always validates its credentials, so we always pass api_key_id and api_key_secret
provider "spacelift" {
  api_key_endpoint = var.spacelift_api_endpoint
  api_key_id       = local.enabled ? data.aws_ssm_parameter.spacelift_key_id[0].value : null
  api_key_secret   = local.enabled ? data.aws_ssm_parameter.spacelift_key_secret[0].value : null
}
