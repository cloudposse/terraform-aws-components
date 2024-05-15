locals {
  enabled            = module.this.enabled
  aws_account_number = one(data.aws_caller_identity.current[*].account_id)
  policy_enabled     = local.enabled && length(var.iam_policy) > 0
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
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

module "queue_policy" {
  count = local.policy_enabled ? 1 : 0

  source  = "cloudposse/iam-policy/aws"
  version = "2.0.1"

  iam_policy = [
    for policy in var.iam_policy : {
      policy_id = policy.policy_id
      version   = policy.version

      statements = [
        for statement in policy.statements :
        merge(
          statement,
          {
            resources = [module.sqs_queue.arn]
          },
          var.iam_policy_limit_to_current_account ? {
            conditions = concat(statement.conditions, [
              {
                test     = "StringEquals"
                variable = "aws:SourceAccount"
                values   = [local.aws_account_number]
              }
            ])
          } : {}
        )
      ]
    }
  ]

  context = module.this.context
}

resource "aws_sqs_queue_policy" "sqs_queue_policy" {
  count = local.policy_enabled ? 1 : 0

  queue_url = module.sqs_queue.url
  policy    = one(module.queue_policy[*].json)
}
