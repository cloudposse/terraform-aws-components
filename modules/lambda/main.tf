locals {
  enabled             = module.this.enabled
  iam_policy_enabled  = local.enabled && (length(var.iam_policy_statements) > 0 || var.policy_json != null)
  s3_bucket_full_name = var.s3_bucket_name != null ? format("%s-%s-%s-%s-%s", module.this.namespace, module.this.tenant, module.this.environment, module.this.stage, var.s3_bucket_name) : null
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = [var.function_name]

  context = module.this.context
}

module "iam_policy" {
  count   = local.iam_policy_enabled ? 1 : 0
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"

  iam_policy_enabled          = true
  iam_policy_statements       = var.iam_policy_statements
  iam_source_policy_documents = [var.policy_json]

  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "default" {
  count = local.iam_policy_enabled ? 1 : 0

  role       = module.lambda.role_name
  policy_arn = module.iam_policy[0].policy_arn
}

data "archive_file" "lambdazip" {
  count       = var.zip.enabled ? 1 : 0
  type        = "zip"
  output_path = "${path.module}/lambdas/${var.zip.output}"
  source_dir  = "${path.module}/lambdas/${var.zip.input_dir}"
}

module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.4.1"

  function_name      = coalesce(var.function_name, module.label.id)
  description        = var.description
  handler            = var.handler
  lambda_environment = var.lambda_environment
  image_uri          = var.image_uri
  image_config       = var.image_config

  filename          = var.filename
  s3_bucket         = local.s3_bucket_full_name
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  architectures                       = var.architectures
  cloudwatch_event_rules              = var.cloudwatch_event_rules
  cloudwatch_lambda_insights_enabled  = var.cloudwatch_lambda_insights_enabled
  cloudwatch_logs_retention_in_days   = var.cloudwatch_logs_retention_in_days
  cloudwatch_logs_kms_key_arn         = var.cloudwatch_logs_kms_key_arn
  cloudwatch_log_subscription_filters = var.cloudwatch_log_subscription_filters
  ignore_external_function_updates    = var.ignore_external_function_updates
  event_source_mappings               = var.event_source_mappings
  kms_key_arn                         = var.kms_key_arn
  lambda_at_edge_enabled              = var.lambda_at_edge_enabled
  layers                              = var.layers
  memory_size                         = var.memory_size
  package_type                        = var.package_type
  permissions_boundary                = var.permissions_boundary
  publish                             = var.publish
  reserved_concurrent_executions      = var.reserved_concurrent_executions
  runtime                             = var.runtime
  sns_subscriptions                   = var.sns_subscriptions
  source_code_hash                    = var.source_code_hash
  ssm_parameter_names                 = var.ssm_parameter_names
  timeout                             = var.timeout
  tracing_config_mode                 = var.tracing_config_mode
  vpc_config                          = var.vpc_config
  custom_iam_policy_arns              = var.custom_iam_policy_arns
  dead_letter_config_target_arn       = var.dead_letter_config_target_arn
  iam_policy_description              = var.iam_policy_description

  context = module.this.context
}
