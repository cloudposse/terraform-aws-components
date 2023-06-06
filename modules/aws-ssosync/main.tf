locals {
  enabled                    = module.this.enabled
  google_credentials         = one(data.aws_ssm_parameter.google_credentials[*].value)
  scim_endpoint_url          = one(data.aws_ssm_parameter.scim_endpoint_url[*].value)
  scim_endpoint_access_token = one(data.aws_ssm_parameter.scim_endpoint_access_token[*].value)
  identity_store_id          = one(data.aws_ssm_parameter.identity_store_id[*].value)

  ssosync_artifact_url = "${var.ssosync_url_prefix}/${var.ssosync_version}/ssosync_Linux_${var.architecture}.tar.gz"

  download_artifact = "ssosync.tar.gz"
}

data "aws_ssm_parameter" "google_credentials" {
  count = local.enabled ? 1 : 0
  name  = "${var.google_credentials_ssm_path}/google_credentials"
}

data "aws_ssm_parameter" "scim_endpoint_url" {
  count = local.enabled ? 1 : 0
  name  = "${var.google_credentials_ssm_path}/scim_endpoint_url"
}

data "aws_ssm_parameter" "scim_endpoint_access_token" {
  count = local.enabled ? 1 : 0
  name  = "${var.google_credentials_ssm_path}/scim_endpoint_access_token"
}

data "aws_ssm_parameter" "identity_store_id" {
  count = local.enabled ? 1 : 0
  name  = "${var.google_credentials_ssm_path}/identity_store_id"
}


module "ssosync_artifact" {
  count = local.enabled ? 1 : 0

  source  = "cloudposse/module-artifact/external"
  version = "0.8.0"

  filename    = local.download_artifact
  module_name = "ssosync"
  module_path = path.module
  url         = local.ssosync_artifact_url
}

resource "null_resource" "extract_my_tgz" {
  count = local.enabled ? 1 : 0

  provisioner "local-exec" {
    command = "tar -xzf ${local.download_artifact} -C dist"
  }

  depends_on = [module.ssosync_artifact]
}

data "archive_file" "lambda" {
  count = local.enabled ? 1 : 0

  type        = "zip"
  source_file = "dist/ssosync"
  output_path = "ssosync.zip"

  depends_on = [null_resource.extract_my_tgz]
}


resource "aws_lambda_function" "ssosync" {
  count = local.enabled ? 1 : 0

  function_name    = module.this.id
  filename         = "ssosync.zip"
  source_code_hash = module.ssosync_artifact[0].base64sha256
  description      = "Syncs Google Workspace users and groups to AWS SSO"
  role             = aws_iam_role.default[0].arn
  handler          = "ssosync"
  runtime          = "go1.x"
  timeout          = 300
  memory_size      = 128

  environment {
    variables = {
      SSOSYNC_LOG_LEVEL          = var.log_level
      SSOSYNC_LOG_FORMAT         = var.log_format
      SSOSYNC_GOOGLE_CREDENTIALS = local.google_credentials
      SSOSYNC_GOOGLE_ADMIN       = var.google_admin_email
      SSOSYNC_SCIM_ENDPOINT      = local.scim_endpoint_url
      SSOSYNC_SCIM_ACCESS_TOKEN  = local.scim_endpoint_access_token
      SSOSYNC_REGION             = var.region
      SSOSYNC_IDENTITY_STORE_ID  = local.identity_store_id
      SSOSYNC_USER_MATCH         = var.google_user_match
      SSOSYNC_GROUP_MATCH        = var.google_group_match
      SSOSYNC_SYNC_METHOD        = var.sync_method
      SSOSYNC_IGNORE_GROUPS      = var.ignore_groups
      SSOSYNC_IGNORE_USERS       = var.ignore_users
      SSOSYNC_INCLUDE_GROUPS     = var.include_groups
      SSOSYNC_LOAD_ASM_SECRETS   = false
    }
  }
  depends_on = [null_resource.extract_my_tgz, data.archive_file.lambda]
}

resource "aws_cloudwatch_event_rule" "ssosync" {
  count = var.enabled ? 1 : 0

  name                = module.this.id
  description         = "Run ssosync on a schedule"
  schedule_expression = var.schedule_expression

}

resource "aws_cloudwatch_event_target" "ssosync" {
  count = var.enabled ? 1 : 0

  rule      = aws_cloudwatch_event_rule.ssosync[0].name
  target_id = module.this.id
  arn       = aws_lambda_function.ssosync[0].arn
}


resource "aws_lambda_permission" "allow_cloudwatch_execution" {
  count = local.enabled ? 1 : 0

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ssosync[0].arn
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ssosync[0].arn
}
