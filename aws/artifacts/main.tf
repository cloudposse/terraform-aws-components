terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

# https://www.terraform.io/artifacts/providers/aws/d/acm_certificate.html
data "aws_acm_certificate" "acm_cloudfront_certificate" {
  provider = "aws.virginia"
  domain   = "${var.domain_name}"
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

locals {
  name               = "artifacts"
  cdn_domain         = "artifacts.${var.domain_name}"
  artifacts_user_arn = "arn:aws:iam::${var.aws_account_id}:user/${var.namespace}-${var.stage}-${local.name}"
}

module "artifacts_user" {
  source    = "git::https://github.com/cloudposse/terraform-aws-iam-system-user.git?ref=tags/0.2.2"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  name      = "${local.name}"
}

module "origin" {
  source               = "git::https://github.com/cloudposse/terraform-aws-s3-website.git?ref=tags/0.5.2"
  namespace            = "${var.namespace}"
  stage                = "${var.stage}"
  name                 = "${local.name}"
  hostname             = "${local.cdn_domain}"
  parent_zone_name     = "${var.domain_name}"
  region               = "${var.region}"
  cors_allowed_headers = ["*"]
  cors_allowed_methods = ["GET"]
  cors_allowed_origins = ["*"]
  cors_max_age_seconds = "3600"
  cors_expose_headers  = ["ETag"]
  index_document       = "index.html"
  error_document       = "404.html"

  deployment_arns = {
    "${local.artifacts_user_arn}" = [""]
  }

  deployment_actions = [
    "s3:PutObjectAcl",
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:AbortMultipartUpload",
  ]
}

# CloudFront CDN fronting origin
module "cdn" {
  source                 = "git::https://github.com/cloudposse/terraform-aws-cloudfront-cdn.git?ref=tags/0.5.7"
  namespace              = "${var.namespace}"
  stage                  = "${var.stage}"
  name                   = "${local.name}"
  aliases                = ["${local.cdn_domain}", "artifacts.cloudposse.com"]
  origin_domain_name     = "${module.origin.s3_bucket_website_endpoint}"
  origin_protocol_policy = "http-only"
  viewer_protocol_policy = "redirect-to-https"
  parent_zone_name       = "${var.domain_name}"
  forward_cookies        = "none"
  forward_headers        = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
  default_ttl            = 60
  min_ttl                = 0
  max_ttl                = 86400
  compress               = "true"
  cached_methods         = ["GET", "HEAD"]
  allowed_methods        = ["GET", "HEAD", "OPTIONS"]
  price_class            = "PriceClass_All"
  default_root_object    = "index.html"
  acm_certificate_arn    = "${data.aws_acm_certificate.acm_cloudfront_certificate.arn}"
}
