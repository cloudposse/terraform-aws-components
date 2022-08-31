locals {
  enabled = module.this.enabled
}

module "sqs_queue" {
  source = "./modules/terraform-aws-sqs-queue"

  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  policy                            = try([var.policy[0]], [])
  redrive_policy                    = try([var.redrive_policy[0]], [])
  fifo_queue                        = var.fifo_queue
  fifo_throughput_limit             = try([var.fifo_throughput_limit[0]], [])
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = try([var.kms_master_key_id[0]], [])
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  deduplication_scope               = try([var.deduplication_scope[0]], [])

  context = module.this.context
}
