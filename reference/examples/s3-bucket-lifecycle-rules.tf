module "assets_bucket_label" {
  source    = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace = "eg"
  stage     = "dev"
  name      = "assets"
}

resource "aws_s3_bucket" "assets" {
  bucket        = "${module.assets_bucket_label.id}"
  tags          = "${module.assets_bucket_label.tags}"
  acl           = "private"
  region        = "us-west-2"
  force_destroy = false

  lifecycle_rule {
    id      = "${module.assets_bucket_label.id}"
    enabled = true

    prefix = ""
    tags   = "${module.assets_bucket_label.tags}"

    noncurrent_version_expiration {
      days = "90"
    }

    noncurrent_version_transition {
      days          = "60"
      storage_class = "GLACIER"
    }

    transition {
      days          = "30"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "60"
      storage_class = "GLACIER"
    }

    expiration {
      days = "180"
    }
  }
}
