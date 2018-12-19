module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

data "terraform_remote_state" "stage" {
  backend = "s3"

  # This assumes stage is using a `terraform-aws-tfstate-backend`
  #   https://github.com/cloudposse/terraform-aws-tfstate-backend
  config {
    role_arn = "${var.role_arn}"
    bucket   = "${module.label.id}"
    key      = "${var.key}"
  }
}

locals {
  name_servers = "${data.terraform_remote_state.stage.name_servers}"
}

resource "aws_route53_record" "dns_zone_ns" {
  count   = "${signum(length(local.name_servers))}"
  zone_id = "${var.zone_id}"
  name    = "${var.stage}"
  type    = "NS"
  ttl     = "${var.ttl}"
  records = ["${local.name_servers}"]
}
