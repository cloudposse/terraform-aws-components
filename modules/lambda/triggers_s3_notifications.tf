variable "s3_notifications" {
  type = map(object({
    bucket_name = optional(string)
    bucket_component = optional(object({
      component   = string
      environment = optional(string)
      tenant      = optional(string)
      stage       = optional(string)
    }))
    events         = optional(list(string))
    filter_prefix  = optional(string)
    filter_suffix  = optional(string)
    source_account = optional(string)
  }))
  description = "A map of S3 bucket notifications to trigger the Lambda function"
  default     = {}
}

module "s3_bucket_notifications_component" {
  for_each = { for k, v in var.s3_notifications : k => v if v.bucket_component != null }

  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.5.0"

  component = each.value.bucket_component.component

  tenant      = each.value.bucket_component.tenant
  environment = each.value.bucket_component.environment
  stage       = each.value.bucket_component.stage

  context = module.this.context
}

resource "aws_lambda_permission" "s3_notification" {
  for_each = var.s3_notifications

  statement_id   = "AllowS3Invoke"
  action         = "lambda:InvokeFunction"
  function_name  = module.lambda.function_name
  principal      = "s3.amazonaws.com"
  source_arn     = format("arn:aws:s3:::%s", each.value.bucket_component == null ? each.value.bucket_name : module.s3_bucket_notifications_component[each.key].outputs.bucket_id)
  source_account = each.value.source_account
}

resource "aws_s3_bucket_notification" "s3_notifications" {
  for_each = var.s3_notifications

  depends_on = [aws_lambda_permission.s3_notification]

  bucket = each.value.bucket_component == null ? each.value.bucket_name : module.s3_bucket_notifications_component[each.key].outputs.bucket_id

  lambda_function {
    lambda_function_arn = module.lambda.arn
    events              = each.value.events == null ? ["s3:ObjectCreated:*"] : each.value.events
    filter_prefix       = each.value.filter_prefix
    filter_suffix       = each.value.filter_suffix
  }
}
