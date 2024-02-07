locals {
  lambda_edge_redirect_404_enabled = local.enabled && var.lambda_edge_redirect_404_enabled
  lambda_edge_paywall_enabled      = local.enabled && var.lambda_edge_paywall_enabled

  cloudfront_lambda_function_association = concat(var.cloudfront_lambda_function_association, module.lambda_edge.lambda_function_association)
}

module "lambda_edge_functions" {
  source  = "cloudposse/config/yaml//modules/deepmerge"
  version = "1.0.2"

  count = local.enabled ? 1 : 0

  maps = [
    local.preview_environment_enabled ? {
      origin_request = {
        source = [{
          content  = <<-EOT
          exports.handler = (event, context, callback) => {
              const site_fqdn = "${local.site_fqdn}";

              const { request } = event.Records[0].cf;
              const default_prefix = "";

              console.log('request:' + JSON.stringify(request));
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
        runtime      = var.lambda_edge_runtime
        handler      = var.lambda_edge_handler
        event_type   = "origin-request"
        include_body = false
      }
    } : {},
    local.lambda_edge_redirect_404_enabled ? {
      origin_response = {
        source = [{
          content  = file("${path.module}/dist/lambda_edge_404_redirect.js")
          filename = "index.js"
        }]
        runtime      = var.lambda_edge_runtime
        handler      = var.lambda_edge_handler
        event_type   = "origin-response"
        include_body = false
      },
      viewer_request = { # if paywall is enabled, this will be overwritten
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
        runtime      = var.lambda_edge_runtime
        handler      = var.lambda_edge_handler
        event_type   = "viewer-request"
        include_body = false
      }
    } : {},
    local.lambda_edge_paywall_enabled ? {
      viewer_request = {
        source       = null # overwrites deep merged result from local.lambda_edge_redirect_404_enabled, if enabled. If not enabled, no change from default value
        source_zip   = "${path.module}/dist/lambda_edge_paywall_viewer_request.zip"
        runtime      = var.lambda_edge_runtime
        handler      = var.lambda_edge_handler
        event_type   = "viewer-request"
        include_body = false
      }
      viewer_response = {
        source_zip   = "${path.module}/dist/lambda_edge_paywall_viewer_response.zip"
        runtime      = var.lambda_edge_runtime
        handler      = var.lambda_edge_handler
        event_type   = "viewer-response"
        include_body = false
      }
    } : {},
    var.lambda_edge_functions,
  ]
}

module "lambda_edge" {
  source  = "cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge"
  version = "0.92.0"

  functions         = jsondecode(local.enabled ? jsonencode(module.lambda_edge_functions[0].merged) : jsonencode({}))
  destruction_delay = var.lambda_edge_destruction_delay

  providers = {
    aws = aws.us-east-1
  }

  context = module.this.context
}

data "aws_iam_policy_document" "additional_lambda_edge_permission" {
  count = local.enabled && (length(var.lambda_edge_allowed_ssm_parameters) > 0) ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameter*"]
    resources = var.lambda_edge_allowed_ssm_parameters
  }
}

resource "aws_iam_policy" "additional_lambda_edge_permission" {
  count = local.enabled && (length(var.lambda_edge_allowed_ssm_parameters) > 0) ? 1 : 0

  name   = "${module.this.id}-read-ssm-vars"
  policy = data.aws_iam_policy_document.additional_lambda_edge_permission[0].json
}

resource "aws_iam_role_policy_attachment" "additional_lambda_edge_permission" {
  for_each = local.enabled && (length(var.lambda_edge_allowed_ssm_parameters) > 0) ? toset(keys(module.lambda_edge_functions[0].merged)) : toset([])

  policy_arn = aws_iam_policy.additional_lambda_edge_permission[0].arn
  role       = split("/", module.lambda_edge.lambda_functions[each.key].role_arn)[1]
}
