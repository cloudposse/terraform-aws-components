# https://levelup.gitconnected.com/preview-environments-in-aws-with-cloudfront-and-lambda-edge-7acccb0b67d1

locals {
  lambda_runtime = "nodejs12.x"
  lambda_handler = "index.handler"
}

module "lambda_edge" {
  source  = "cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge"
  version = "0.82.4"

  functions = {
    origin_request = {
      source = [{
        content  = <<-EOT
        exports.handler = (event, context, callback) => {
            const site_fqdn = "${var.site_fqdn}";

            const { request } = event.Records[0].cf;
            const default_prefix = "";

            console.log(event);
            console.log(request);
            console.log(request.headers);
            const host = request.headers['x-forwarded-host'][0].value;
            if (host == site_fqdn) {
              request.origin.custom.path = default_prefix; // use default prefix if there is no subdomain
            } else {
              const subdomain = host.replace('.' + site_fqdn, '');
              request.origin.custom.path = `/$${subdomain}`; // use preview prefix
            }

            return callback(null, request);
        };
        EOT
        filename = "index.js"
      }]
      runtime      = local.lambda_runtime
      handler      = local.lambda_handler
      event_type   = "origin-request"
      include_body = false
    }
    viewer_request = {
      source = [{
        content  = <<-EOT
        exports.handler = (event, context, callback) => {
            const { request } = event.Records[0].cf;

            request.headers['x-forwarded-host'] = [
                {
                    key: 'X-Forwarded-Host',
                    value: request.headers.host[0].value
                }
            ];

            return callback(null, request);
        };
        EOT
        filename = "index.js"
      }]
      runtime      = local.lambda_runtime
      handler      = local.lambda_handler
      event_type   = "viewer-request"
      include_body = false
    }
  }

  providers = {
    aws = aws.us-east-1
  }

  context = module.this.context
}
