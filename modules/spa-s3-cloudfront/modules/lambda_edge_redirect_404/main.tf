# https://levelup.gitconnected.com/preview-environments-in-aws-with-cloudfront-and-lambda-edge-7acccb0b67d1

locals {
  lambda_runtime = var.runtime
  lambda_handler = "index.handler"
}

module "lambda_edge" {
  source  = "cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge"
  version = "0.82.4"

  functions = {
    origin_response = {
      source = [{
        content  = file("${path.module}/index.js")
        filename = "index.js"
      }]
      runtime      = local.lambda_runtime
      handler      = local.lambda_handler
      event_type   = "origin-response"
      include_body = false
    }
  }

  providers = {
    aws = aws.us-east-1
  }

  context = module.this.context
}
