locals {
  enabled     = module.this.enabled
  vpc_outputs = module.vpc.outputs
}

module "kafka" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "2.3.0"

  # VPC and subnets
  vpc_id     = local.vpc_outputs.vpc_id
  subnet_ids = local.vpc_outputs.private_subnet_ids

  # Cluster config
  kafka_version                                = var.kafka_version
  broker_per_zone                              = var.broker_per_zone
  broker_instance_type                         = var.broker_instance_type
  broker_volume_size                           = var.broker_volume_size
  client_broker                                = var.client_broker
  encryption_in_cluster                        = var.encryption_in_cluster
  encryption_at_rest_kms_key_arn               = var.encryption_at_rest_kms_key_arn
  enhanced_monitoring                          = var.enhanced_monitoring
  certificate_authority_arns                   = var.certificate_authority_arns
  client_allow_unauthenticated                 = var.client_allow_unauthenticated
  client_sasl_scram_enabled                    = var.client_sasl_scram_enabled
  client_sasl_scram_secret_association_enabled = var.client_sasl_scram_secret_association_enabled
  client_sasl_scram_secret_association_arns    = var.client_sasl_scram_secret_association_arns
  client_sasl_iam_enabled                      = var.client_sasl_iam_enabled
  client_tls_auth_enabled                      = var.client_tls_auth_enabled
  jmx_exporter_enabled                         = var.jmx_exporter_enabled
  node_exporter_enabled                        = var.node_exporter_enabled
  cloudwatch_logs_enabled                      = var.cloudwatch_logs_enabled
  cloudwatch_logs_log_group                    = var.cloudwatch_logs_log_group
  firehose_logs_enabled                        = var.firehose_logs_enabled
  firehose_delivery_stream                     = var.firehose_delivery_stream
  s3_logs_enabled                              = var.s3_logs_enabled
  s3_logs_bucket                               = var.s3_logs_bucket
  s3_logs_prefix                               = var.s3_logs_prefix
  properties                                   = var.properties
  autoscaling_enabled                          = var.autoscaling_enabled
  storage_autoscaling_target_value             = var.storage_autoscaling_target_value
  storage_autoscaling_max_capacity             = var.storage_autoscaling_max_capacity
  storage_autoscaling_disable_scale_in         = var.storage_autoscaling_disable_scale_in
  security_group_rule_description              = var.security_group_rule_description
  public_access_enabled                        = var.public_access_enabled

  # DNS hostname records
  zone_id                  = module.dns_delegated.outputs.default_dns_zone_id
  broker_dns_records_count = var.broker_dns_records_count
  custom_broker_dns_name   = var.custom_broker_dns_name

  # Cluster Security Group
  allowed_security_group_ids           = var.allowed_security_group_ids
  allowed_cidr_blocks                  = var.allowed_cidr_blocks
  associated_security_group_ids        = var.associated_security_group_ids
  create_security_group                = var.create_security_group
  security_group_name                  = var.security_group_name
  security_group_description           = var.security_group_description
  security_group_create_before_destroy = var.security_group_create_before_destroy
  preserve_security_group_id           = var.preserve_security_group_id
  security_group_create_timeout        = var.security_group_create_timeout
  security_group_delete_timeout        = var.security_group_delete_timeout
  allow_all_egress                     = var.allow_all_egress
  additional_security_group_rules      = var.additional_security_group_rules
  inline_rules_enabled                 = var.inline_rules_enabled

  context = module.this.context
}
