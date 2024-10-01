
locals {
  enabled = module.this.enabled

  aws_account_id = join("", data.aws_caller_identity.current.*.account_id)
  aws_partition  = join("", data.aws_partition.current.*.partition)

  datadog_aws_role_name = nonsensitive(join("", data.aws_ssm_parameter.datadog_aws_role_name.*.value))
  principal_names = [
    format("arn:${local.aws_partition}:iam::%s:role/${local.datadog_aws_role_name}", local.aws_account_id),
  ]

  privileged_principal_arns = [
    {
      (local.principal_names[0]) = [""]
    }
  ]

  # in case enabled: false and we have no current order to lookup
  data_current_order_body = one(data.http.current_order.*.response_body) == null ? {} : jsondecode(data.http.current_order[0].response_body)
  # in case there is no response (valid http request but no existing data)
  current_order_data = lookup(local.data_current_order_body, "data", null)

  non_catchall_ids = local.enabled ? [for x in local.current_order_data : x.id if x.attributes.name != "catchall"] : []
  catchall_id      = local.enabled ? [for x in local.current_order_data : x.id if x.attributes.name == "catchall"] : []
  ordered_ids      = concat(local.non_catchall_ids, local.catchall_id)

  policy = local.enabled ? jsondecode(data.aws_iam_policy_document.default[0].json) : null
}

# We use the http data source due to lack of a data source for datadog_logs_archive_order
# While the data source does exist, it doesn't provide useful information, nor how to lookup the id of a log archive order
# This fetches the current order from DD's api so we can shuffle it around if needed to
# keep the catchall in last place.
data "http" "current_order" {
  count = local.enabled ? 1 : 0

  url        = format("https://api.%s/api/v2/logs/config/archives", module.datadog_configuration.datadog_site)
  depends_on = [datadog_logs_archive.logs_archive, datadog_logs_archive.catchall_archive]
  request_headers = {
    Accept             = "application/json",
    DD-API-KEY         = local.datadog_api_key,
    DD-APPLICATION-KEY = local.datadog_app_key
  }
}

# IAM policy document to allow cloudtrail to read and write to the
# cloudtrail bucket

data "aws_iam_policy_document" "default" {
  count = module.this.enabled ? 1 : 0
  statement {
    sid = "AWSCloudTrailAclCheck"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:GetBucketAcl",
    ]

    resources = [
      "arn:${local.aws_partition}:s3:::${module.this.id}-cloudtrail",
    ]
  }

  # We're using two AWSCloudTrailWrite statements with the only
  # difference being the principals identifier to avoid a bug
  # where TF frequently wants to reorder multiple principals
  statement {
    sid = "AWSCloudTrailWrite1"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${local.aws_partition}:s3:::${module.this.id}-cloudtrail/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${local.aws_partition}:cloudtrail:*:${local.aws_account_id}:trail/*datadog-logs-archive",
      ]
    }

  }

  # We're using two AWSCloudTrailWrite statements with the only
  # difference being the principals identifier to avoid a bug
  # where TF frequently wants to reorder multiple principals
  statement {
    sid = "AWSCloudTrailWrite2"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:${local.aws_partition}:s3:::${module.this.id}-cloudtrail/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values = [
        "bucket-owner-full-control",
      ]
    }
    condition {
      test     = "StringLike"
      variable = "aws:SourceArn"
      values = [
        "arn:${local.aws_partition}:cloudtrail:*:${local.aws_account_id}:trail/*datadog-logs-archive",
      ]
    }

  }
}

module "bucket_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "1.0.1"

  iam_policy_statements = try(lookup(local.policy, "Statement"), null)

  context = module.this.context
}

data "aws_ssm_parameter" "datadog_aws_role_name" {
  name = "/datadog/aws_role_name"
}

data "aws_caller_identity" "current" {
  count = local.enabled ? 1 : 0
}

data "aws_partition" "current" {
  count = local.enabled ? 1 : 0
}

module "archive_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  count = local.enabled ? 1 : 0

  acl           = "private"
  enabled       = local.enabled
  force_destroy = var.s3_force_destroy

  lifecycle_rules = [
    {
      prefix  = null
      enabled = var.lifecycle_rules_enabled
      tags    = {}

      abort_incomplete_multipart_upload_days         = null
      enable_glacier_transition                      = var.enable_glacier_transition
      glacier_transition_days                        = var.glacier_transition_days
      noncurrent_version_glacier_transition_days     = 30
      enable_deeparchive_transition                  = false
      deeparchive_transition_days                    = 0
      noncurrent_version_deeparchive_transition_days = 0
      enable_standard_ia_transition                  = false
      standard_transition_days                       = 0
      enable_current_object_expiration               = false
      expiration_days                                = 0
      enable_noncurrent_version_expiration           = false
      noncurrent_version_expiration_days             = 0
    },
  ]

  privileged_principal_actions = [
    "s3:PutObject",
    "s3:GetObject",
    "s3:ListBucket",
  ]

  privileged_principal_arns = local.privileged_principal_arns

  tags = {
    managed-by = "terraform"
    env        = var.stage
    service    = "datadog-logs-archive"
    part-of    = "observability"
  }

  user_enabled       = false
  versioning_enabled = true

  object_lock_configuration = {
    mode  = var.object_lock_mode_archive
    days  = var.object_lock_days_archive
    years = null
  }

  context = module.this.context
}

module "cloudtrail_s3_bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  depends_on = [data.aws_iam_policy_document.default]

  count = local.enabled ? 1 : 0

  name          = "datadog-logs-archive-cloudtrail"
  acl           = "private"
  enabled       = local.enabled
  force_destroy = var.s3_force_destroy

  source_policy_documents = data.aws_iam_policy_document.default.*.json

  lifecycle_rules = [
    {
      prefix  = null
      enabled = var.lifecycle_rules_enabled
      tags    = {}

      abort_incomplete_multipart_upload_days         = null
      enable_glacier_transition                      = var.enable_glacier_transition
      glacier_transition_days                        = 365
      noncurrent_version_glacier_transition_days     = 365
      enable_deeparchive_transition                  = false
      deeparchive_transition_days                    = 0
      noncurrent_version_deeparchive_transition_days = 0
      enable_standard_ia_transition                  = false
      standard_transition_days                       = 0
      enable_current_object_expiration               = false
      expiration_days                                = 0
      enable_noncurrent_version_expiration           = false
      noncurrent_version_expiration_days             = 0
    },
  ]

  tags = {
    managed-by = "terraform"
    env        = var.stage
    service    = "datadog-logs-archive"
    part-of    = "observability"
  }

  user_enabled       = false
  versioning_enabled = true

  label_key_case   = "lower"
  label_value_case = "lower"

  object_lock_configuration = {
    mode  = var.object_lock_mode_cloudtrail
    days  = var.object_lock_days_cloudtrail
    years = null
  }

  # Setting this to `true` causes permanent Terraform drift: terraform plan wants to create it, and then the next plan wants to destroy it.
  # This happens b/c Terraform sees different MD5 hash of the request body
  # https://stackoverflow.com/questions/66605497/terraform-always-says-changes-on-templatefile-for-s3-bucket-policy
  # https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutBucketPolicy.html#API_PutBucketPolicy_RequestSyntax
  # https://hands-on.cloud/terraform-how-to-enforce-tls-https-for-aws-s3-bucket/
  # https://github.com/hashicorp/terraform/issues/4948
  # https://stackoverflow.com/questions/69986387/s3-bucket-terraform-plan-shows-inexistent-changes-on-default-values
  # https://github.com/hashicorp/terraform/issues/5613
  allow_ssl_requests_only = false

  context = module.this.context
}

module "cloudtrail" {
  count = local.enabled ? 1 : 0
  # We explicitly declare this dependency on the entire
  # cloudtrail_s3_bucket module because tf doesn't autodetect the
  # dependency on the attachment of the bucket policy, leading to
  # insufficient permissions issues on cloudtrail creation if it
  # happens to be attempted prior to completion of the policy attachment.
  depends_on = [module.cloudtrail_s3_bucket]
  source     = "cloudposse/cloudtrail/aws"
  version    = "0.21.0"

  enable_log_file_validation    = true
  include_global_service_events = false
  is_multi_region_trail         = false
  enabled                       = local.enabled
  enable_logging                = true
  s3_bucket_name                = module.cloudtrail_s3_bucket[0].bucket_id

  event_selector = [
    {
      include_management_events = true
      read_write_type           = "WriteOnly"
      data_resource = [
        {
          type   = "AWS::S3::Object"
          values = ["${module.archive_bucket[0].bucket_arn}/"]
        }
      ]
    }
  ]

  context = module.this.context
}

resource "datadog_logs_archive_order" "archive_order" {
  count       = var.enabled ? 1 : 0
  archive_ids = local.ordered_ids
}

resource "datadog_logs_archive" "logs_archive" {
  count = local.enabled ? 1 : 0

  name             = var.stage
  include_tags     = true
  rehydration_tags = ["rehydrated:true"]
  query            = join(" OR ", concat([join(":", ["env", var.stage]), join(":", ["account", local.aws_account_id])], var.additional_query_tags))

  s3_archive {
    bucket     = module.archive_bucket[0].bucket_id
    path       = "/"
    account_id = local.aws_account_id
    role_name  = local.datadog_aws_role_name
  }
}

resource "datadog_logs_archive" "catchall_archive" {
  count = local.enabled && var.catchall_enabled ? 1 : 0

  depends_on       = [datadog_logs_archive.logs_archive]
  name             = "catchall"
  include_tags     = true
  rehydration_tags = ["rehydrated:true"]
  query            = "*"

  s3_archive {
    bucket     = module.archive_bucket[0].bucket_id
    path       = "/catchall"
    account_id = local.aws_account_id
    role_name  = local.datadog_aws_role_name
  }
}
