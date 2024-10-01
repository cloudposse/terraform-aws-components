locals {
  fetch_username = !(length(var.username) > 0) && (length(var.username_path) > 0) ? true : false
  fetch_password = !(length(var.password) > 0) && (length(var.password_path) > 0) ? true : false
}

data "aws_ssm_parameter" "username" {
  count = local.fetch_username ? 1 : 0
  name  = var.username_path
}

data "aws_ssm_parameter" "password" {
  count = local.fetch_password ? 1 : 0
  name  = var.password_path
}

module "dms_endpoint" {
  source  = "cloudposse/dms/aws//modules/dms-endpoint"
  version = "0.1.1"

  endpoint_type                   = var.endpoint_type
  engine_name                     = var.engine_name
  kms_key_arn                     = var.kms_key_arn
  certificate_arn                 = var.certificate_arn
  database_name                   = var.database_name
  port                            = var.port
  extra_connection_attributes     = var.extra_connection_attributes
  secrets_manager_access_role_arn = var.secrets_manager_access_role_arn
  secrets_manager_arn             = var.secrets_manager_arn
  server_name                     = var.server_name
  service_access_role             = var.service_access_role
  ssl_mode                        = var.ssl_mode
  username                        = local.fetch_username ? data.aws_ssm_parameter.username[0].value : var.username
  password                        = local.fetch_password ? data.aws_ssm_parameter.password[0].value : var.password
  elasticsearch_settings          = var.elasticsearch_settings
  kafka_settings                  = var.kafka_settings
  kinesis_settings                = var.kinesis_settings
  mongodb_settings                = var.mongodb_settings
  redshift_settings               = var.redshift_settings
  s3_settings                     = var.s3_settings

  context = module.this.context
}
