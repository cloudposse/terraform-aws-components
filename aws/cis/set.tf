# Define composite variables for resources
module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.3"
  enabled    = "${var.enabled}"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "executor_role_name" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.3"
  enabled    = "${var.enabled}"
  context    = "${module.label.context}"
  attributes = ["${concat(var.attributes, list("execution"))}"]
}

module "admin" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=generalize-principals"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${var.name}"
  attributes         = ["admin"]
  role_description   = "IAM Role for the CloudFormation administrator account."
  policy_description = "IAM Policy for the CloudFormation administrator account."

  principals = {
    Service = ["cloudformation.amazonaws.com"]
  }
}

resource "aws_cloudformation_stack_set" "default" {
  administration_role_arn = "${module.admin.arn}"
  execution_role_name     = "${module.executor_role_name.name}"
  name                    = "${module.label.id}"
  tags                    = "${module.label.tags}"

  parameters = "${var.parameters}"

  template_url = "https://aws-quickstart.s3.amazonaws.com/quickstart-compliance-cis-benchmark/templates/main.template"
}
