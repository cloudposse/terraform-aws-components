variable "alb_ingress_cidr_blocks_http" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTP"
}

variable "alb_ingress_cidr_blocks_https" {
  type        = "list"
  default     = ["0.0.0.0/0"]
  description = "List of CIDR blocks allowed to access environment over HTTPS"
}

module "alb" {
  source             = "git::https://github.com/cloudposse/terraform-aws-alb.git?ref=tags/0.2.6"
  name               = "${var.name}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  attributes         = "${var.attributes}"
  vpc_id             = "${module.vpc.vpc_id}"
  ip_address_type    = "ipv4"
  subnet_ids         = ["${module.subnets.public_subnet_ids}"]
  security_group_ids = ["${module.vpc.vpc_default_security_group_id}"]
  access_logs_region = "${var.region}"

  https_enabled             = "true"
  http_ingress_cidr_blocks  = "${var.alb_ingress_cidr_blocks_http}"
  https_ingress_cidr_blocks = "${var.alb_ingress_cidr_blocks_https}"
  certificate_arn           = "${module.acm_request_certificate.arn}"
  health_check_interval     = "60"
}
