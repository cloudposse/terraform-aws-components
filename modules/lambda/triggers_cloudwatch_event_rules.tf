module "cloudwatch_event_rules_label" {
  for_each = var.cloudwatch_event_rules

  source     = "cloudposse/label/null"
  version    = "0.25.0"
  attributes = [each.key]

  context = module.this.context
}

resource "aws_cloudwatch_event_rule" "event_rules" {
  for_each = var.cloudwatch_event_rules

  name = module.cloudwatch_event_rules_label[each.key].id

  description         = each.value.description
  event_bus_name      = each.value.event_bus_name
  event_pattern       = each.value.event_pattern
  is_enabled          = each.value.is_enabled
  name_prefix         = each.value.name_prefix
  role_arn            = each.value.role_arn
  schedule_expression = each.value.schedule_expression

  tags = module.cloudwatch_event_rules_label[each.key].tags
}

resource "aws_cloudwatch_event_target" "sns" {
  for_each = var.cloudwatch_event_rules

  rule      = aws_cloudwatch_event_rule.event_rules[each.key].name
  target_id = "ScheduleExpression"
  arn       = module.lambda.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  for_each = var.cloudwatch_event_rules

  statement_id  = format("%s-%s", "AllowExecutionFromCloudWatch", each.key)
  action        = "lambda:InvokeFunction"
  function_name = module.lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rules[each.key].arn
}
