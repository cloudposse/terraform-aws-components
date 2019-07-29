variable "flow_logs_enabled" {
  type    = "string"
  default = "true"
}

module "flow_logs" {
  source = "git::https://github.com/cloudposse/terraform-aws-vpc-flow-logs-s3-bucket.git?ref=init"

  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"
  attributes = "${var.attributes}"
  delimiter  = "${var.delimiter}"

  region = "${var.region}"

  enabled = "${var.flow_logs_enabled}"

  vpc_id = "${module.vpc.vpc_id}"
}
