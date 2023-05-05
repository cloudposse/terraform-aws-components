terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      ## 4.66.0 version cause error
      ## │ Error: listing tags for Application Auto Scaling Target (): InvalidParameter: 1 validation error(s) found.
      ## │ - minimum field size of 1, ListTagsForResourceInput.ResourceARN.
      ## │
      ## │
      ## │   with module.ecs_cloudwatch_autoscaling[0].aws_appautoscaling_target.default[0],
      ## │   on .terraform/modules/ecs_cloudwatch_autoscaling/main.tf line 15, in resource "aws_appautoscaling_target" "default":
      ## │   15: resource "aws_appautoscaling_target" "default" {
      version = ">= 4.66.1"
    }
    template = {
      source  = "cloudposse/template"
      version = ">= 2.2"
    }
  }
}
