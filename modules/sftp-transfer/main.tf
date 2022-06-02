locals {
  enabled = module.this.enabled

  is_vpc                 = var.vpc_id != null
  security_group_enabled = module.this.enabled && var.security_group_enabled
  user_names             = keys(var.sftp_users)
  user_names_map         = { for idx, user in local.user_names : idx => user }

  account_number = module.account_map.outputs.full_account_map[module.this.stage]

  admin_names     = keys(var.sftp_admins)
  admin_names_map = { for idx, user in local.admin_names : idx => user }

  s3_bucket = var.create_bucket ? join("", module.s3_bucket[*].bucket_id) : var.s3_bucket_name

  ssh_server_host_key = var.ssh_server_host_key_ssm_path != "" ? data.aws_ssm_parameter.ssh_server_host_key[0].value : ""

  zone_id     = var.zone_id != "" ? var.zone_id : module.dns_delegated.outputs.default_dns_zone_id
  domain_name = var.domain_name != "" ? var.domain_name : join(".", [module.this.name, module.dns_delegated.outputs.default_domain_name])
}

data "aws_s3_bucket" "landing" {
  count = local.enabled ? 1 : 0

  bucket = local.s3_bucket
}

resource "aws_transfer_server" "default" {
  count = local.enabled ? 1 : 0

  identity_provider_type          = "SERVICE_MANAGED"
  protocols                       = ["SFTP"]
  domain                          = var.domain
  endpoint_type                   = local.is_vpc ? "VPC" : "PUBLIC"
  force_destroy                   = var.force_destroy
  security_policy_name            = var.security_policy_name
  logging_role                    = join("", aws_iam_role.logging[*].arn)
  pre_authentication_login_banner = var.ssh_banner
  host_key                        = local.ssh_server_host_key

  dynamic "endpoint_details" {
    for_each = local.is_vpc ? [1] : []

    content {
      subnet_ids             = var.subnet_ids
      security_group_ids     = local.security_group_enabled ? module.security_group.*.id : var.vpc_security_group_ids
      vpc_id                 = var.vpc_id
      address_allocation_ids = var.eip_enabled ? aws_eip.sftp.*.id : var.address_allocation_ids
    }
  }

  # The AWS console cheats to set "aws"-prefixed tags which integrates with Route 53
  # to provision a CNAME for the Transfer Server endpoint, and the documentation at
  # https://docs.aws.amazon.com/transfer/latest/userguide/requirements-dns.html for
  # tagging this out-of-band simply doesn't work. Leaving this here to provide more
  # context for why we have a separately managed DNS RR. -MR
  # See also: https://github.com/hashicorp/terraform-provider-aws/issues/6956 

  tags = merge(module.this.tags, {
    "fixme:aws:transfer:route53HostedZoneId" = join("", ["/hostedzone/", local.zone_id])
    "fixme:aws:transfer:customHostname"      = local.domain_name
  })

}

resource "aws_transfer_user" "default" {
  for_each = local.enabled ? var.sftp_users : {}

  server_id = join("", aws_transfer_server.default[*].id)
  role      = aws_iam_role.s3_access_role.arn

  user_name = each.value.user_name

  home_directory_type = var.restricted_home ? "LOGICAL" : "PATH"

  # https://docs.aws.amazon.com/transfer/latest/userguide/logical-dir-mappings.html#implement-log-dirs
  dynamic "home_directory_mappings" {
    for_each = var.restricted_home ? [1] : []

    content {
      entry  = "/"
      target = "/${join("", data.aws_s3_bucket.landing[*].id)}/${each.value.user_name}"
    }
  }

  tags = module.this.tags
}

resource "aws_transfer_ssh_key" "default" {
  for_each = local.enabled ? var.sftp_users : {}

  server_id = join("", aws_transfer_server.default[*].id)

  user_name = each.value.user_name
  body      = each.value.public_key

  depends_on = [
    aws_transfer_user.default
  ]
}

resource "aws_transfer_user" "admin" {
  for_each = local.enabled ? var.sftp_admins : {}

  server_id = join("", aws_transfer_server.default[*].id)
  role      = aws_iam_role.s3_access_role.arn

  user_name = each.value.admin_name

  home_directory_type = "PATH"
  home_directory      = "/${join("", data.aws_s3_bucket.landing[*].id)}"

  tags = module.this.tags
}

resource "aws_transfer_ssh_key" "admin" {
  for_each = local.enabled ? var.sftp_admins : {}

  server_id = join("", aws_transfer_server.default[*].id)

  user_name = each.value.admin_name
  body      = each.value.public_key

  depends_on = [
    aws_transfer_user.admin
  ]
}

resource "aws_eip" "sftp" {
  count = local.enabled && var.eip_enabled ? length(var.subnet_ids) : 0

  vpc = local.is_vpc
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "0.3.1"

  use_name_prefix = var.security_group_use_name_prefix
  rules           = var.security_group_rules
  description     = var.security_group_description
  vpc_id          = local.is_vpc ? var.vpc_id : null

  enabled = local.security_group_enabled
  context = module.this.context
}

# Service Discovery Hostname
resource "aws_route53_record" "main" {
  count = local.enabled && length(local.domain_name) > 0 && length(local.zone_id) > 0 ? 1 : 0

  name    = local.domain_name
  zone_id = local.zone_id
  type    = "CNAME"
  ttl     = "300"

  records = [
    join("", aws_transfer_server.default[*].endpoint)
  ]
}

module "logging_label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = ["transfer", "cloudwatch"]

  context = module.this.context
}

data "aws_iam_policy_document" "assume_role_policy" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      # Specifying server path with precise ARN or wildcard refuses access despite 
      # https://docs.aws.amazon.com/transfer/latest/userguide/confused-deputy.html .
      # This scopes role assumption to any transfer servers in the reigon + account. 
      values = [
        "arn:aws:transfer:${var.region}:${local.account_number}:*"
      ]
    }
  }
}

# Per PLTV3-561 testing and the following documentation, this should be sufficient
# protection without requiring per-user scope down policies.
# https://docs.aws.amazon.com/transfer/latest/userguide/service-managed-users.html#add-s3-user
data "aws_iam_policy_document" "s3_access" {

  statement {
    sid    = "AllowListingOfUserFolder"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      join("", data.aws_s3_bucket.landing[*].arn)
    ]
  }

  statement {
    sid    = "FullBucketObjectAccessChrootedViaUserRestrictions"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]

    resources = [
      "${join("", data.aws_s3_bucket.landing[*].arn)}/*"
    ]
  }
}

# Add to policy when using non-default KMS for S3 SSE (or cross-account SFTP <> bucket access)
#  statement {
#    sid    = "EncryptDecrypt"
#    effect = "Allow"
#
#    actions = [
#      "kms:Decrypt",
#      "kms:Encrypt",
#      "kms:GenerateDataKey"
#    ]
#
#    resources = [
#      "Import S3 KMS key arn here"
#    ]
#  }  
#}

data "aws_iam_policy_document" "logging" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "CloudWatchAccessForAWSTransfer"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]

    resources = ["*"]
  }
}

# All SFTP users and admins reuse same role and policy with permissions
# governed by Transfer Manager logical home directory chrooting.
#module "iam_label" {
#  for_each = local.enabled ? local.user_names_map : {}
#
#  source  = "cloudposse/label/null"
#  version = "0.25.0"
#
#  attributes = ["transfer", "s3", each.value]
#
#  context = module.this.context
#}

resource "aws_iam_policy" "s3_access" {

  name   = "${module.this.id}-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access.json
  tags   = module.this.tags
}

resource "aws_iam_role" "s3_access_role" {

  name = "${module.this.id}-s3-access-role"

  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role_policy[*].json)
  managed_policy_arns = aws_iam_policy.s3_access[*].arn
}

resource "aws_iam_policy" "logging" {
  count = local.enabled ? 1 : 0

  name   = module.logging_label.id
  policy = join("", data.aws_iam_policy_document.logging[*].json)
}

resource "aws_iam_role" "logging" {
  count = local.enabled ? 1 : 0

  name                = module.logging_label.id
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role_policy[*].json)
  managed_policy_arns = [join("", aws_iam_policy.logging[*].arn)]
}
