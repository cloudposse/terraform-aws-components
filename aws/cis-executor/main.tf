terraform {
  required_version = ">= 0.11.2"

  backend "s3" {}
}

provider "aws" {
  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

locals {
  executor_role_name = "cis-executor"
}

module "default" {
  source = "git::https://github.com/cloudposse/terraform-aws-iam-role.git?ref=tags/0.3.0"

  enabled            = "${var.enabled}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  name               = "${local.executor_role_name}"
  use_fullname       = "false"
  attributes         = ["${var.attributes}"]
  role_description   = "IAM Role in all target accounts for Stack Set operations"
  policy_description = "IAM Policy in all target accounts for Stack Set operations"

  principals = {
    AWS = ["${var.administrator_role_arn}"]
  }

  policy_documents = ["${data.aws_iam_policy_document.executor.json}"]
}

data "aws_iam_policy_document" "executor" {
  statement {
    effect = "Allow"

    resources = [
      "arn:aws:s3:::*",
      "arn:aws:s3:::*/*",
    ]

    actions = [
      "s3:CreateBucket",
      "s3:DeleteBucket",
      "s3:DeleteBucketPolicy",
      "s3:DeleteBucketWebsite",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetAccelerateConfiguration",
      "s3:GetAccountPublicAccessBlock",
      "s3:GetAnalyticsConfiguration",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketLocation",
      "s3:GetBucketLogging",
      "s3:GetBucketNotification",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketPolicy",
      "s3:GetBucketPolicyStatus",
      "s3:GetBucketPublicAccessBlock",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketTagging",
      "s3:GetBucketVersioning",
      "s3:GetBucketWebsite",
      "s3:GetEncryptionConfiguration",
      "s3:GetInventoryConfiguration",
      "s3:GetLifecycleConfiguration",
      "s3:GetMetricsConfiguration",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectLegalHold",
      "s3:GetObjectRetention",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionForReplication",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:GetReplicationConfiguration",
      "s3:HeadBucket",
      "s3:ListAllMyBuckets",
      "s3:ListBucket",
      "s3:ListBucketByTags",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
      "s3:ListMultipartUploadParts",
      "s3:ObjectOwnerOverrideToBucketOwner",
      "s3:PutAccelerateConfiguration",
      "s3:PutAccountPublicAccessBlock",
      "s3:PutAnalyticsConfiguration",
      "s3:PutBucketAcl",
      "s3:PutBucketCORS",
      "s3:PutBucketLogging",
      "s3:PutBucketNotification",
      "s3:PutBucketObjectLockConfiguration",
      "s3:PutBucketPolicy",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketRequestPayment",
      "s3:PutBucketTagging",
      "s3:PutBucketVersioning",
      "s3:PutBucketWebsite",
      "s3:PutEncryptionConfiguration",
      "s3:PutInventoryConfiguration",
      "s3:PutLifecycleConfiguration",
      "s3:PutMetricsConfiguration",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectLegalHold",
      "s3:PutObjectRetention",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:PutReplicationConfiguration",
      "s3:ReplicateDelete",
      "s3:ReplicateObject",
      "s3:ReplicateTags",
      "s3:RestoreObject",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:iam::*:policy/*",
      "arn:aws:iam::*:role/*",
    ]

    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:DeletePolicy",
      "iam:DeletePolicyVersion",
      "iam:DeleteRole",
      "iam:DeleteRolePermissionsBoundary",
      "iam:DeleteRolePolicy",
      "iam:DeleteServiceLinkedRole",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListEntitiesForPolicy",
      "iam:ListPolicies",
      "iam:ListPoliciesGrantingServiceAccess",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "iam:ListRoleTags",
      "iam:PutRolePermissionsBoundary",
      "iam:PutRolePolicy",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "config:BatchGetResourceConfig",
      "config:DeleteConfigRule",
      "config:DeleteConfigurationRecorder",
      "config:DeleteDeliveryChannel",
      "config:DeleteEvaluationResults",
      "config:DeleteRemediationConfiguration",
      "config:DeleteRetentionConfiguration",
      "config:DeliverConfigSnapshot",
      "config:DescribeComplianceByConfigRule",
      "config:DescribeComplianceByResource",
      "config:DescribeConfigRuleEvaluationStatus",
      "config:DescribeConfigRules",
      "config:DescribeConfigurationRecorders",
      "config:DescribeConfigurationRecorderStatus",
      "config:DescribeDeliveryChannels",
      "config:DescribeDeliveryChannelStatus",
      "config:DescribeRemediationConfigurations",
      "config:DescribeRemediationExecutionStatus",
      "config:DescribeRetentionConfigurations",
      "config:GetComplianceDetailsByConfigRule",
      "config:GetComplianceDetailsByResource",
      "config:GetComplianceSummaryByConfigRule",
      "config:GetComplianceSummaryByResourceType",
      "config:GetDiscoveredResourceCounts",
      "config:GetResourceConfigHistory",
      "config:GetResources",
      "config:GetTagKeys",
      "config:ListDiscoveredResources",
      "config:ListTagsForResource",
      "config:PutConfigRule",
      "config:PutConfigurationRecorder",
      "config:PutDeliveryChannel",
      "config:PutEvaluations",
      "config:PutRemediationConfigurations",
      "config:PutRetentionConfiguration",
      "config:SelectResourceConfig",
      "config:StartConfigRulesEvaluation",
      "config:StartConfigurationRecorder",
      "config:StartRemediationExecution",
      "config:StopConfigurationRecorder",
      "config:TagResource",
      "config:UntagResource",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:lambda:*",
    ]

    actions = [
      "lambda:*",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "arn:aws:logs:*:*:log-group:*:*:*",
      "arn:aws:cloudwatch::*:dashboard/*",
      "arn:aws:cloudwatch:*:*:alarm:*",
      "arn:aws:events:*:*:rule/*",
      "arn:aws:cloudformation:*:*:stack/*/*",
      "arn:aws:cloudformation:*:*:stackset/*:*",
      "arn:aws:cloudtrail:*:*:trail/*",
      "arn:aws:logs:*:*:log-group:*",
      "arn:aws:sns:*:*:*",
    ]

    actions = [
      "cloudformation:*",
      "cloudtrail:*",
      "cloudwatch:*",
      "events:*",
      "logs:*",
      "sns:*",
    ]
  }

  statement {
    effect = "Allow"

    resources = [
      "*",
    ]

    actions = [
      "kms:*",
      "iam:PassRole",
    ]
  }
}
