terraform {
  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "sns" {
  source = "git::https://github.com/cloudposse/terraform-aws-sns-topic.git?ref=0.1.0"

  attributes = var.attributes
  name       = var.name
  namespace  = var.namespace
  stage      = var.stage

  subscribers = var.subscribers
  # TODO enable after this PR gets merged https://github.com/terraform-providers/terraform-provider-aws/issues/10931
  # sqs_dlq_enabled = var.sqs_dlq_enabled
}

module "sns_monitoring" {
  source  = "git::https://github.com/cloudposse/terraform-aws-sns-cloudwatch-alarms.git?ref=0.1.0"
  enabled = var.monitoring_enabled

  sns_topic_name       = module.sns.sns_topic.name
  sns_topic_alarms_arn = module.sns.sns_topic.arn
}

