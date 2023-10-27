locals {
  enabled = module.this.enabled
}

resource "aws_ssm_association" "install_agent" {
  count = local.enabled ? 1 : 0

  # Owned by AWS
  # https://docs.aws.amazon.com/inspector/latest/userguide/inspector_installing-uninstalling-agents.html
  name = "AmazonInspector-ManageAWSAgent"

  parameters = {
    Operation = "Install"
  }

  targets {
    key    = "InstanceIds"
    values = ["*"]
  }
}

module "inspector" {
  source  = "cloudposse/inspector/aws"
  version = "0.2.8"

  create_iam_role = true
  enabled_rules   = var.enabled_rules

  context = module.this.context
}
