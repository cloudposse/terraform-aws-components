locals {
  enabled = module.this.enabled
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_region" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_autoscaling_group" "default" {
  count = local.enabled ? 1 : 0

  name = var.autoscaling_group_name
}

resource "aws_autoscaling_lifecycle_hook" "default" {
  count = local.enabled ? 1 : 0

  name                   = module.this.id
  autoscaling_group_name = var.autoscaling_group_name
  heartbeat_timeout      = 500
  default_result         = "CONTINUE"
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

resource "aws_ssm_document" "default" {
  count = local.enabled ? 1 : 0

  name = module.this.id

  document_type   = "Automation"
  document_format = "YAML"
  content         = <<-DOC
  ---
  schemaVersion: '0.3'
  description: "Run Command on Shutdown"
  assumeRole: "{{automationAssumeRole}}"
  parameters:
    automationAssumeRole:
      type: "String"
    ASGName:
      type: "String"
    LCHName:
      type: "String"
    InstanceId:
      type: "String"
  mainSteps:
  - action: "aws:runCommand"
    name: "runCommand"
    inputs:
      Parameters:
        executionTimeout: "300"
        commands:
          - "${var.command}"
      InstanceIds:
        - "{{ InstanceId }}"
      DocumentName: "AWS-RunShellScript"
  - action: "aws:executeAwsApi"
    name: "terminateInstance"
    inputs:
      LifecycleHookName: "{{ LCHName }}"
      InstanceId: "{{ InstanceId }}"
      AutoScalingGroupName: "{{ ASGName }}"
      Service: "autoscaling"
      Api: "CompleteLifecycleAction"
      LifecycleActionResult: "CONTINUE"
  DOC

  tags = module.this.tags
}
