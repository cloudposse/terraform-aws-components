module "kinesis" {
  source  = "cloudposse/kinesis-stream/aws"
  version = "0.3.0"

  shard_count               = var.shard_count
  retention_period          = var.retention_period
  shard_level_metrics       = var.shard_level_metrics
  enforce_consumer_deletion = var.enforce_consumer_deletion
  encryption_type           = var.encryption_type
  kms_key_id                = var.kms_key_id
  stream_mode               = var.stream_mode
  consumer_count            = var.consumer_count

  context = module.this.context
}
