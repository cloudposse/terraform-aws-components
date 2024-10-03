variable "sqs_notifications" {
  type = map(object({
    sqs_arn = optional(string)
    sqs_component = optional(object({
      component   = string
      environment = optional(string)
      tenant      = optional(string)
      stage       = optional(string)
    }))
    batch_size          = optional(number)
    source_account      = optional(string)
    on_failure_arn      = optional(string)
    maximum_concurrency = optional(number)
  }))
  description = "A map of SQS queue notifications to trigger the Lambda function"
  default     = {}
}

module "sqs_queue" {
  for_each = { for k, v in var.sqs_notifications : k => v if v.sqs_component != null }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = each.value.sqs_component.component

  tenant      = each.value.sqs_component.tenant
  environment = each.value.sqs_component.environment
  stage       = each.value.sqs_component.stage

  context = module.this.context
}

module "sqs_iam_policy" {
  for_each = var.sqs_notifications

  source  = "cloudposse/iam-policy/aws"
  version = "1.0.1"

  iam_policy_enabled = true
  iam_policy = {
    version = "2012-10-17"
    statements = [
      {
        effect    = "Allow"
        actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"]
        resources = each.value.sqs_arn != null ? [each.value.sqs_arn.sqs_arn] : [module.sqs_queue[each.key].outputs.sqs_queue.queue_arn]
      },
    ]
  }
  context = module.this.context
}

resource "aws_iam_role_policy_attachment" "sqs_default" {
  for_each = var.sqs_notifications

  role       = module.lambda.role_name
  policy_arn = module.sqs_iam_policy[each.key].policy_arn
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  for_each = var.sqs_notifications

  event_source_arn = each.value.sqs_arn != null ? [each.value.sqs_arn.sqs_arn] : module.sqs_queue[each.key].outputs.sqs_queue.queue_arn
  function_name    = module.lambda.function_name
  batch_size       = each.value.batch_size == null ? 1 : each.value.batch_size

  scaling_config {
    maximum_concurrency = each.value.maximum_concurrency
  }
  dynamic "destination_config" {
    for_each = { for k, v in each.value : k => v if k == "on_failure_arn" && v != null }
    content {
      on_failure {
        destination_arn = destination_config.value
      }
    }
  }

  depends_on = [aws_iam_role_policy_attachment.sqs_default]
}
