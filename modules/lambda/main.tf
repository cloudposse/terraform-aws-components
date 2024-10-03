locals {
  enabled                = module.this.enabled
  var_iam_policy_enabled = local.enabled && (try(length(var.iam_policy), 0) > 0 || var.policy_json != null)
  iam_policy_enabled     = local.enabled && local.var_iam_policy_enabled

  s3_bucket_name = var.s3_bucket_name != null ? var.s3_bucket_name : one(module.s3_bucket[*].outputs.bucket_id)

  function_name = coalesce(var.function_name, module.this.id)

  var_policy_json = local.var_iam_policy_enabled ? [var.policy_json] : []

  lambda_files = fileset("${path.module}/lambdas/${var.zip.input_dir == null ? "" : var.zip.input_dir}", "*")
  file_content_map = var.zip.enabled ? [
    for f in local.lambda_files : filebase64sha256("${path.module}/lambdas/${coalesce(var.zip.input_dir, var.name)}/${f}")
  ] : []
  output_zip_file = local.enabled && var.zip.enabled ? "${path.module}/lambdas/${random_pet.zip_recreator[0].id}.zip" : null

  cicd_s3_key_format = var.cicd_s3_key_format != null ? var.cicd_s3_key_format : "stage/${module.this.stage}/lambda/${local.function_name}/%s"
  s3_key             = var.s3_key != null ? var.s3_key : format(local.cicd_s3_key_format, coalesce(one(data.aws_ssm_parameter.cicd_ssm_param[*].value), "example"))
}

data "aws_ssm_parameter" "cicd_ssm_param" {
  count = local.enabled && var.cicd_ssm_param_name != null ? 1 : 0

  name = var.cicd_ssm_param_name
}

module "iam_policy" {
  count   = local.iam_policy_enabled ? 1 : 0
  source  = "cloudposse/iam-policy/aws"
  version = "1.0.1"

  iam_policy_enabled          = true
  iam_policy                  = var.iam_policy
  iam_source_policy_documents = local.var_policy_json != null ? local.var_policy_json : []
  context                     = module.this.context
}

resource "aws_iam_role_policy_attachment" "default" {
  count = local.iam_policy_enabled ? 1 : 0

  role       = module.lambda.role_name
  policy_arn = module.iam_policy[0].policy_arn
}

data "archive_file" "lambdazip" {
  count = local.enabled && var.zip.enabled ? 1 : 0
  type  = "zip"

  output_path = local.output_zip_file
  source_dir  = "${path.module}/lambdas/${var.zip.input_dir}"

  depends_on = [random_pet.zip_recreator]
}

resource "random_pet" "zip_recreator" {
  count = local.enabled && var.zip.enabled ? 1 : 0

  prefix = coalesce(module.this.name, "lambda")
  keepers = {
    file_content = join(",", local.file_content_map)
  }
}

module "lambda" {
  source  = "cloudposse/lambda-function/aws"
  version = "0.6.1"

  function_name      = local.function_name
  description        = var.description
  handler            = var.handler
  lambda_environment = var.lambda_environment
  image_uri          = var.image_uri
  image_config       = var.image_config

  filename          = var.zip.enabled ? coalesce(data.archive_file.lambdazip[0].output_path, var.filename) : var.filename
  s3_bucket         = local.s3_bucket_name
  s3_key            = local.s3_key
  s3_object_version = var.s3_object_version

  architectures                      = var.architectures
  cloudwatch_lambda_insights_enabled = var.cloudwatch_lambda_insights_enabled
  cloudwatch_logs_retention_in_days  = var.cloudwatch_logs_retention_in_days
  cloudwatch_logs_kms_key_arn        = var.cloudwatch_logs_kms_key_arn
  kms_key_arn                        = var.kms_key_arn
  lambda_at_edge_enabled             = var.lambda_at_edge_enabled
  layers                             = var.layers
  memory_size                        = var.memory_size
  package_type                       = var.package_type
  permissions_boundary               = var.permissions_boundary
  publish                            = var.publish
  reserved_concurrent_executions     = var.reserved_concurrent_executions
  runtime                            = var.runtime
  source_code_hash                   = var.source_code_hash
  ssm_parameter_names                = var.ssm_parameter_names
  timeout                            = var.timeout
  tracing_config_mode                = var.tracing_config_mode
  vpc_config                         = var.vpc_config
  custom_iam_policy_arns             = var.custom_iam_policy_arns
  dead_letter_config_target_arn      = var.dead_letter_config_target_arn
  iam_policy_description             = var.iam_policy_description

  context = module.this.context
}

resource "aws_lambda_function_url" "lambda_url" {
  count              = var.function_url_enabled ? 1 : 0
  function_name      = module.lambda.function_name
  authorization_type = "AWS_IAM"

  cors {
    allow_credentials = true
    allow_origins     = ["*"]
    allow_methods     = ["*"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}
