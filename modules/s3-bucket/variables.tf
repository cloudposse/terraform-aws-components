variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

variable "acl" {
  type        = string
  default     = "private"
  description = <<-EOT
    The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.
    We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`.
    EOT
}

variable "grants" {
  type = list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
  default = []

  description = <<-EOT
    A list of policy grants for the bucket, taking a list of permissions.
    Conflicts with `acl`. Set `acl` to `null` to use this.
    EOT
}

variable "source_policy_documents" {
  type        = list(string)
  default     = []
  description = <<-EOT
    List of IAM policy documents that are merged together into the exported document.
    Statements defined in source_policy_documents or source_json must have unique SIDs.
    Statement having SIDs that match policy SIDs generated by this module will override them.
    EOT
}

variable "force_destroy" {
  type        = bool
  default     = false
  description = <<-EOT
    When `true`, permits a non-empty S3 bucket to be deleted by first deleting all objects in the bucket.
    THESE OBJECTS ARE NOT RECOVERABLE even if they were versioned and stored in Glacier.
    EOT
}

variable "versioning_enabled" {
  type        = bool
  default     = true
  description = "A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket"
}

variable "logging_bucket_name_rendering_enabled" {
  type        = bool
  default     = false
  description = "Whether to render the logging bucket name, prepending context"
}

variable "logging" {
  type = object({
    bucket_name = string
    prefix      = string
  })
  default     = null
  description = "Bucket access logging configuration."
}

variable "sse_algorithm" {
  type        = string
  default     = "AES256"
  description = "The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`"
}

variable "kms_master_key_arn" {
  type        = string
  default     = ""
  description = "The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`"
}

variable "user_enabled" {
  type        = bool
  default     = false
  description = "Set to `true` to create an IAM user with permission to access the bucket"
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions the user is permitted to perform on the S3 bucket"
}

variable "allow_encrypted_uploads_only" {
  type        = bool
  default     = false
  description = "Set to `true` to prevent uploads of unencrypted objects to S3 bucket"
}

variable "allow_ssl_requests_only" {
  type        = bool
  default     = false
  description = "Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
}

/*
Schema for lifecycle_configuration_rules
{
  enabled = true # bool
  id      = string
  abort_incomplete_multipart_upload_days = null # number
  filter_and = {
    object_size_greater_than = null # integer >= 0
    object_size_less_than    = null # integer >= 1
    prefix                   = null # string
    tags                     = {}   # map(string)
  }
  expiration = {
    date                         = null # string, RFC3339 time format, GMT
    days                         = null # integer > 0
    expired_object_delete_marker = null # bool
  }
  noncurrent_version_expiration = {
    newer_noncurrent_versions = null # integer > 0
    noncurrent_days           = null # integer >= 0
  }
  transition = [{
    date          = null # string, RFC3339 time format, GMT
    days          = null # integer >= 0
    storage_class = null # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
  }]
  noncurrent_version_transition = [{
    newer_noncurrent_versions = null # integer >= 0
    noncurrent_days           = null # integer >= 0
    storage_class             = null # string/enum, one of GLACIER, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, DEEP_ARCHIVE, GLACIER_IR.
  }]
}
We only partly specify the object to allow for compatible future extension.
*/

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  default     = []
  description = "A list of lifecycle V2 rules"
}

variable "cors_configuration" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
  default = null

  description = "Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket"
}

variable "block_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public access lists on the bucket"
}

variable "block_public_policy" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the blocking of new public policies on the bucket"
}

variable "ignore_public_acls" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the ignoring of public access lists on the bucket"
}

variable "restrict_public_buckets" {
  type        = bool
  default     = true
  description = "Set to `false` to disable the restricting of making the bucket public"
}

variable "s3_replication_enabled" {
  type        = bool
  default     = false
  description = "Set this to true and specify `s3_replication_rules` to enable replication. `versioning_enabled` must also be `true`."
}

variable "s3_replica_bucket_arn" {
  type        = string
  default     = ""
  description = <<-EOT
    A single S3 bucket ARN to use for all replication rules.
    Note: The destination bucket can be specified in the replication rule itself
    (which allows for multiple destinations), in which case it will take precedence over this variable.
    EOT
}

variable "s3_replication_rules" {
  # type = list(object({
  #   id          = string
  #   priority    = number
  #   prefix      = string
  #   status      = string
  #   delete_marker_replication_status = string
  #   # destination_bucket is specified here rather than inside the destination object
  #   # to make it easier to work with the Terraform type system and create a list of consistent type.
  #   destination_bucket = string # destination bucket ARN, overrides s3_replica_bucket_arn
  #
  #   destination = object({
  #     storage_class              = string
  #     replica_kms_key_id         = string
  #     access_control_translation = object({
  #       owner = string
  #     })
  #     account_id                 = string
  #     metrics                    = object({
  #       status = string
  #     })
  #   })
  #   source_selection_criteria = object({
  #     sse_kms_encrypted_objects = object({
  #       enabled = bool
  #     })
  #   })
  #   # filter.prefix overrides top level prefix
  #   filter = object({
  #     prefix = string
  #     tags = map(string)
  #   })
  # }))

  type        = list(any)
  default     = null
  description = "Specifies the replication rules for S3 bucket replication if enabled. You must also set s3_replication_enabled to true."
}

variable "s3_replication_source_roles" {
  type        = list(string)
  default     = []
  description = "Cross-account IAM Role ARNs that will be allowed to perform S3 replication to this bucket (for replication within the same AWS account, it's not necessary to adjust the bucket policy)."
}

variable "bucket_name" {
  type        = string
  default     = null
  description = "Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context"
}

variable "object_lock_configuration" {
  type = object({
    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
  default     = null
  description = "A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."
}

variable "website_inputs" {
  type = list(object({
    index_document           = string
    error_document           = string
    redirect_all_requests_to = string
    routing_rules            = string
  }))
  default     = null
  description = "Specifies the static website hosting configuration object."
  validation {
    condition     = var.website_inputs == null
    error_message = "The \"cloudposse/s3-bucket/aws\" module v2.0.0 introduced a breaking change for website_inputs and will be fixed with future updates."
  }
}

# Need input to be a list to fix https://github.com/cloudposse/terraform-aws-s3-bucket/issues/102
variable "privileged_principal_arns" {
  #  type        = map(list(string))
  #  default     = {}
  type    = list(map(list(string)))
  default = []

  description = <<-EOT
    List of maps. Each map has one key, an IAM Principal ARN, whose associated value is
    a list of S3 path prefixes to grant `privileged_principal_actions` permissions for that principal,
    in addition to the bucket itself, which is automatically included. Prefixes should not begin with '/'.
    EOT
}

variable "privileged_principal_actions" {
  type        = list(string)
  default     = []
  description = "List of actions to permit `privileged_principal_arns` to perform on bucket and bucket prefixes (see `privileged_principal_arns`)"
}

variable "transfer_acceleration_enabled" {
  type        = bool
  default     = false
  description = "Set this to true to enable S3 Transfer Acceleration for the bucket."
}

variable "s3_object_ownership" {
  type        = string
  default     = "ObjectWriter"
  description = "Specifies the S3 object ownership control. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'."
}

variable "bucket_key_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
  Set this to true to use Amazon S3 Bucket Keys for SSE-KMS, which reduce the cost of AWS KMS requests.
  For more information, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
  EOT
}

variable "custom_policy_actions" {
  description = "List of S3 Actions for the custom policy"
  type        = list(string)
  default     = []
}

variable "custom_policy_account_names" {
  description = "List of accounts names to assign as principals for the s3 bucket custom policy"
  type        = list(string)
  default     = []
}

variable "custom_policy_enabled" {
  description = "Whether to enable or disable the custom policy. If enabled, the default policy will be ignored"
  type        = bool
  default     = false
}

variable "iam_policy_statements" {
  type        = any
  description = "Map of IAM policy statements to use in the bucket policy."
  default     = {}
}

