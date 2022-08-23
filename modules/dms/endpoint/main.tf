module "dms_endpoint" {
  source  = "cloudposse/dms/aws//modules/dms-endpoint"
  version = "0.1.1"

  endpoint_type                   = var.endpoint_type
  engine_name                     = var.engine_name
  kms_key_arn                     = var.kms_key_arn
  certificate_arn                 = var.certificate_arn
  database_name                   = var.database_name
  password                        = var.password
  port                            = var.port
  extra_connection_attributes     = var.extra_connection_attributes
  secrets_manager_access_role_arn = var.secrets_manager_access_role_arn
  secrets_manager_arn             = var.secrets_manager_arn
  server_name                     = var.server_name
  service_access_role             = var.service_access_role
  ssl_mode                        = var.ssl_mode
  username                        = var.username
  elasticsearch_settings          = var.elasticsearch_settings
  kafka_settings                  = var.kafka_settings
  kinesis_settings                = var.kinesis_settings
  mongodb_settings                = var.mongodb_settings
  redshift_settings               = var.redshift_settings
  s3_settings                     = var.s3_settings

  context = module.this.context
}
