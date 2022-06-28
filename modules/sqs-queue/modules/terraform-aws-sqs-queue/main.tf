locals {
  enabled = module.this.enabled
}

resource "aws_sqs_queue" "default" {
  count = local.enabled ? 1 : 0

  name                              = var.fifo_queue ? "${module.this.id}.fifo" : module.this.id
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  policy                            = try(var.policy[0], null)
  redrive_policy                    = try(var.redrive_policy[0], null)
  fifo_queue                        = var.fifo_queue
  fifo_throughput_limit             = try(var.fifo_throughput_limit[0], null)
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = try(var.kms_master_key_id[0], null)
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  deduplication_scope               = try(var.deduplication_scope[0], null)

  tags = module.this.tags
}
