terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

variable "aws_assume_role_arn" {}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

variable "domain_name" {
  description = "domain name for zone"
}

resource "aws_route53_zone" "default" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "default" {
  zone_id = "${aws_route53_zone.default.id}"
  name    = "${aws_route53_zone.default.name}"
  type    = "SOA"
  ttl     = "60"

  records = [
    "${aws_route53_zone.default.name_servers.0}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400",
  ]
}
