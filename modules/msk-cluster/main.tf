locals {
  enabled                 = module.this.enabled
  cloudwatch_logs_enabled = local.enabled && var.cloudwatch_logs_enabled
  vpc_ingress_tenant_name = try(coalesce(var.vpc_ingress_tenant_name, module.this.tenant), null)

  allowed_cidr_blocks = concat(
    var.allowed_cidr_blocks,
    [
      for k in keys(module.vpc_ingress) :
      module.vpc_ingress[k].outputs.vpc_cidr
    ]
  )
}

module "cloudwatch_logs" {
  source  = "cloudposse/cloudwatch-logs/aws"
  version = "0.6.2"

  enabled           = local.cloudwatch_logs_enabled
  iam_role_enabled  = false
  retention_in_days = var.cloudwatch_logs_retention_in_days

  context = module.this.context
}

module "msk_cluster" {
  source  = "cloudposse/msk-apache-kafka-cluster/aws"
  version = "0.8.6"

  vpc_id                     = module.vpc.outputs.vpc_id
  subnet_ids                 = module.vpc.outputs.private_subnet_ids
  allowed_cidr_blocks        = local.allowed_cidr_blocks
  allowed_security_group_ids = compact([module.eks.outputs.eks_cluster_managed_security_group_id])
  zone_id                    = module.gbl_dns_delegated.outputs.default_dns_zone_id

  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  broker_instance_type   = var.broker_instance_type
  broker_volume_size     = var.broker_volume_size

  encryption_in_cluster                     = var.encryption_in_cluster
  encryption_at_rest_kms_key_arn            = var.encryption_at_rest_kms_key_arn
  certificate_authority_arns                = var.certificate_authority_arns
  client_broker                             = var.client_broker
  client_tls_auth_enabled                   = var.client_tls_auth_enabled
  client_sasl_scram_enabled                 = var.client_sasl_scram_enabled
  client_sasl_scram_secret_association_arns = var.client_sasl_scram_secret_association_arns
  client_sasl_iam_enabled                   = var.client_sasl_iam_enabled

  enhanced_monitoring   = var.enhanced_monitoring
  jmx_exporter_enabled  = var.jmx_exporter_enabled
  node_exporter_enabled = var.node_exporter_enabled

  cloudwatch_logs_enabled   = local.cloudwatch_logs_enabled
  cloudwatch_logs_log_group = module.cloudwatch_logs.log_group_name
  firehose_logs_enabled     = var.firehose_logs_enabled
  firehose_delivery_stream  = var.firehose_delivery_stream
  s3_logs_enabled           = var.s3_logs_enabled
  s3_logs_bucket            = var.s3_logs_bucket
  s3_logs_prefix            = var.s3_logs_prefix

  properties = var.properties

  storage_autoscaling_target_value     = var.storage_autoscaling_target_value
  storage_autoscaling_max_capacity     = var.storage_autoscaling_max_capacity
  storage_autoscaling_disable_scale_in = var.storage_autoscaling_disable_scale_in

  context = module.this.context
}
