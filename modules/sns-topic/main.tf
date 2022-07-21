locals {
  enabled = module.this.enabled
}

module "sns_topic" {
  source  = "cloudposse/sns-topic/aws"
  version = "0.20.1"

  subscribers = var.subscribers

  allowed_aws_services_for_sns_published      = var.allowed_aws_services_for_sns_published
  kms_master_key_id                           = var.kms_master_key_id
  encryption_enabled                          = var.encryption_enabled
  sqs_queue_kms_master_key_id                 = var.sqs_queue_kms_master_key_id
  sqs_queue_kms_data_key_reuse_period_seconds = var.sqs_queue_kms_data_key_reuse_period_seconds
  allowed_iam_arns_for_sns_publish            = var.allowed_iam_arns_for_sns_publish
  sns_topic_policy_json                       = var.sns_topic_policy_json
  sqs_dlq_enabled                             = var.sqs_dlq_enabled
  sqs_dlq_max_message_size                    = var.sqs_dlq_max_message_size
  sqs_dlq_message_retention_seconds           = var.sqs_dlq_message_retention_seconds
  delivery_policy                             = var.delivery_policy
  fifo_topic                                  = var.fifo_topic
  fifo_queue_enabled                          = var.fifo_queue_enabled
  content_based_deduplication                 = var.content_based_deduplication
  redrive_policy_max_receiver_count           = var.redrive_policy_max_receiver_count
  redrive_policy                              = var.redrive_policy

  context = module.this.context
}
