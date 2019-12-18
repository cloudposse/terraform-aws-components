locals {
  enabled = "${contains(var.accounts_enabled, var.stage) == true}"
  account = "${length(var.account) > 0 ? var.account : var.stage}"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.5.4"
  enabled    = "${local.enabled ? "true" : "false"}"
  namespace  = "${var.namespace}"
  stage      = "${local.account}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

# Fetch the OrganizationAccountAccessRole ARNs from SSM
module "organization_account_access_role_arn" {
  enabled        = "${local.enabled ? "true" : "false"}"
  source         = "git::https://github.com/cloudposse/terraform-aws-ssm-parameter-store?ref=tags/0.1.5"
  parameter_read = ["/${var.namespace}/${local.account}/organization_account_access_role"]
}

locals {
  role_arn_values = "${module.organization_account_access_role_arn.values}"
}

data "terraform_remote_state" "stage" {
  count   = "${local.enabled ? 1 : 0}"
  backend = "s3"

  # This assumes stage is using a `terraform-aws-tfstate-backend`
  #   https://github.com/cloudposse/terraform-aws-tfstate-backend
  config {
    role_arn = "${local.role_arn_values[0]}"
    bucket   = "${module.label.id}"
    key      = "${var.key}"
  }
}

locals {
  name_servers = "${flatten(data.terraform_remote_state.stage.*.name_servers)}"
}

resource "aws_route53_record" "dns_zone_ns" {
  count   = "${local.enabled ? 1 : 0}"
  zone_id = "${var.zone_id}"
  name    = "${var.stage}"
  type    = "NS"
  ttl     = "${var.ttl}"
  records = ["${local.name_servers}"]
}
