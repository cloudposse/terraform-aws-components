data "aws_ssm_parameter" "spacelift_key_id" {
  name = "/spacelift/key_id"
}

data "aws_ssm_parameter" "spacelift_key_secret" {
  name = "/spacelift/key_secret"
}

# This provider always validates its credentials, so we always pass api_key_id and api_key_secret
provider "spacelift" {
  api_key_endpoint = var.spacelift_api_endpoint
  api_key_id       = data.aws_ssm_parameter.spacelift_key_id.value
  api_key_secret   = data.aws_ssm_parameter.spacelift_key_secret.value
}
