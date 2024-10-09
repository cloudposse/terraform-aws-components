variable "region" {
  type        = string
  description = "AWS Region."
}

variable "parent_zone_name" {
  type        = string
  default     = ""
  description = "Parent domain name of site to publish. Defaults to format(parent_zone_name_pattern, stage, environment)."
}

variable "process_domain_validation_options" {
  type        = bool
  default     = true
  description = "Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation"
}

variable "site_fqdn" {
  type        = string
  default     = ""
  description = "Fully qualified domain name of site to publish. Overrides site_subdomain and parent_zone_name."
}

variable "site_subdomain" {
  type        = string
  default     = ""
  description = "Subdomain to plug into site_name_pattern to make site FQDN."
}

variable "external_aliases" {
  type        = list(string)
  default     = []
  description = <<-EOT
    List of FQDN's - Used to set the Alternate Domain Names (CNAMEs) setting on CloudFront. No new Route53 records will be created for these.

    Setting `process_domain_validation_options` to true may cause the component to fail if an external_alias DNS zone is not controlled by Terraform.

    Setting `preview_environment_enabled` to `true` will cause this variable to be ignored.
    EOT
}

variable "s3_website_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    Set to true to enable the created S3 bucket to serve as a website independently of CloudFront,
    and to use that website as the origin.

    Setting `preview_environment_enabled` will implicitly set this to `true`.
    EOT
}

variable "s3_website_password_enabled" {
  type        = bool
  default     = false
  description = <<-EOT
    If set to true, and `s3_website_enabled` is also true, a password will be required in the `Referrer` field of the
    HTTP request in order to access the website, and CloudFront will be configured to pass this password in its requests.
    This will make it much harder for people to bypass CloudFront and access the S3 website directly via its website endpoint.
    EOT
}

variable "s3_object_ownership" {
  type        = string
  default     = "ObjectWriter"
  description = "Specifies the S3 object ownership control on the origin bucket. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'."
}

variable "s3_origins" {
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_path = string
    s3_origin_config = object({
      origin_access_identity = string
    })
  }))
  default     = []
  description = <<-EOT
    A list of S3 [origins](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) (in addition to the one created by this component) for this distribution.
    S3 buckets configured as websites are `custom_origins`, not `s3_origins`.
    Specifying `s3_origin_config.origin_access_identity` as `null` or `""` will have it translated to the `origin_access_identity` used by the origin created by this component.
    EOT
}

variable "origin_bucket" {
  type        = string
  default     = null
  description = "Name of an existing S3 bucket to use as the origin. If this is not provided, this component will create a new s3 bucket using `var.name` and other context related inputs"
}

variable "origin_s3_access_logging_enabled" {
  type        = bool
  default     = null
  description = <<-EOF
    Set `true` to deliver S3 Access Logs to the `origin_s3_access_log_bucket_name` bucket.
    Defaults to `false` if `origin_s3_access_log_bucket_name` is empty (the default), `true` otherwise.
    Must be set explicitly if the access log bucket is being created at the same time as this module is being invoked.
    EOF
}

variable "origin_s3_access_log_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the existing S3 bucket where S3 Access Logs for the origin Bucket will be delivered. Default is not to enable S3 Access Logging for the origin Bucket."
}

variable "origin_s3_access_log_bucket_name_rendering_enabled" {
  type        = bool
  description = <<-EOT
  If set to `true`, then the S3 origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.origin_s3_access_log_bucket_name)`.
  Otherwise, the value for `origin_s3_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.

  For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `origin_s3_access_log_bucket_name` is set to
  `example-s3-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-s3-access-logs`.
  EOT
  default     = false
}

variable "origin_s3_access_log_prefix" {
  type        = string
  default     = ""
  description = "Prefix to use for S3 Access Log object keys. Defaults to `logs/$${module.this.id}`"
}

variable "origin_force_destroy" {
  type        = bool
  default     = false
  description = "A boolean string that indicates all objects should be deleted from the origin Bucket so that the Bucket can be destroyed without error. These objects are not recoverable."
}

variable "origin_versioning_enabled" {
  type        = bool
  default     = false
  description = "Enable or disable versioning for the origin Bucket. Versioning is a means of keeping multiple variants of an object in the same bucket."
}

variable "origin_deployment_principal_arns" {
  type        = list(string)
  description = "List of role ARNs to grant deployment permissions to the origin Bucket."
  default     = []
}

variable "origin_deployment_actions" {
  type = list(string)
  default = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]
  description = "List of actions to permit `origin_deployment_principal_arns` to perform on bucket and bucket prefixes (see `origin_deployment_principal_arns`)"
}

variable "origin_allow_ssl_requests_only" {
  type        = bool
  default     = true
  description = "Set to `true` in order to have the origin bucket require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests"
}

variable "block_origin_public_access_enabled" {
  type        = bool
  default     = true
  description = "When set to 'true' the s3 origin bucket will have public access block enabled."
}

variable "origin_encryption_enabled" {
  type        = bool
  default     = true
  description = "When set to 'true' the origin Bucket will have aes256 encryption enabled by default."
}

variable "cloudfront_allowed_methods" {
  type        = list(string)
  default     = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront."
}

variable "cloudfront_cached_methods" {
  type        = list(string)
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)."
}

variable "cloudfront_compress" {
  type        = bool
  default     = false
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header."
}

variable "cloudfront_custom_error_response" {
  # http://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/custom-error-pages.html#custom-error-pages-procedure
  # https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#custom-error-response-arguments
  type = list(object({
    error_caching_min_ttl = optional(string, "10")
    error_code            = string
    response_code         = string
    response_page_path    = string
  }))

  description = "List of one or more custom error response element maps."
  default     = []
}

variable "cloudfront_access_log_create_bucket" {
  type        = bool
  default     = true
  description = <<-EOT
    When `true` and `cloudfront_access_logging_enabled` is also true, this module will create a new,
    separate S3 bucket to receive CloudFront Access Logs.
    EOT
}

variable "cloudfront_access_log_bucket_name" {
  type        = string
  default     = ""
  description = <<-EOT
    When `cloudfront_access_log_create_bucket` is `false`, this is the name of the existing S3 Bucket where
    CloudFront Access Logs are to be delivered and is required. IGNORED when `cloudfront_access_log_create_bucket` is `true`.
    EOT
}

variable "cloudfront_access_log_bucket_name_rendering_enabled" {
  type        = bool
  description = <<-EOT
  If set to `true`, then the CloudFront origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.cloudfront_access_log_bucket_name)`.
  Otherwise, the value for `cloudfront_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.

  For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `cloudfront_access_log_bucket_name` is set to
  `example-cloudfront-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-cloudfront-access-logs`.
  EOT
  default     = false
}

variable "cloudfront_access_log_prefix" {
  type        = string
  default     = ""
  description = "Prefix to use for CloudFront Access Log object keys. Defaults to no prefix."
}

variable "cloudfront_access_log_prefix_rendering_enabled" {
  type        = bool
  default     = false
  description = "Whether or not to dynamically render $${module.this.id} at the end of `var.cloudfront_access_log_prefix`."
}

variable "cloudfront_aws_shield_protection_enabled" {
  description = "Enable or disable AWS Shield Advanced protection for the CloudFront distribution. If set to 'true', a subscription to AWS Shield Advanced must exist in this account."
  type        = bool
  default     = false
}

variable "cloudfront_aws_waf_protection_enabled" {
  description = <<-EOT
  Enable or disable AWS WAF for the CloudFront distribution.

  This assumes that the `aws-waf-acl-default-cloudfront` component has been deployed to the regional stack corresponding
  to `var.waf_acl_environment`.
  EOT
  type        = bool
  default     = true
}

variable "cloudfront_aws_waf_environment" {
  type        = string
  description = "The environment where the WAF ACL for CloudFront distribution exists."
  default     = null
}

variable "cloudfront_aws_waf_component_name" {
  type        = string
  description = "The name of the component used when deploying WAF ACL"
  default     = "waf"
}

variable "cloudfront_default_root_object" {
  type        = string
  default     = "index.html"
  description = "Object that CloudFront return when requests the root URL."
}

variable "cloudfront_default_ttl" {
  type        = number
  default     = 60
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache."
}

variable "cloudfront_min_ttl" {
  type        = number
  default     = 0
  description = "Minimum amount of time that you want objects to stay in CloudFront caches."
}

variable "cloudfront_max_ttl" {
  type        = number
  default     = 31536000
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache."
}

variable "cloudfront_index_document" {
  type        = string
  default     = "index.html"
  description = "Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders."
}

variable "cloudfront_ipv6_enabled" {
  type        = bool
  default     = true
  description = "Set to true to enable an AAAA DNS record to be set as well as the A record."
}

variable "cloudfront_viewer_protocol_policy" {
  type        = string
  description = "Limit the protocol users can use to access content. One of `allow-all`, `https-only`, or `redirect-to-https`."
  default     = "redirect-to-https"
}

variable "cloudfront_lambda_function_association" {
  type = list(object({
    event_type   = string
    include_body = bool
    lambda_arn   = string
  }))

  description = "A config block that configures the CloudFront distribution with lambda@edge functions for specific events."
  default     = []
}

variable "custom_origins" {
  type = list(object({
    domain_name = string
    origin_id   = string
    origin_path = string
    custom_headers = list(object({
      name  = string
      value = string
    }))
    custom_origin_config = object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = number
      origin_read_timeout      = number
    })
  }))
  default     = []
  description = <<-EOT
    A list of additional custom website [origins](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) for this distribution.
    EOT
}

variable "dns_delegated_environment_name" {
  description = "The environment where `dns-delegated` component is deployed to"
  type        = string
  default     = "gbl"
}

variable "failover_criteria_status_codes" {
  type        = list(string)
  description = "List of HTTP Status Codes to use as the origin group failover criteria."
  default = [
    403,
    404,
    500,
    502
  ]
}

variable "failover_s3_origin_format" {
  type        = string
  description = <<-EOT
  If `var.failover_s3_origin_environment` is supplied, this is the format to use for the failover S3 origin bucket name when
  building the name via `format([format], var.namespace, var.failover_s3_origin_environment, var.stage, var.name)`
  and then looking it up via the `aws_s3_bucket` Data Source.

  For example, if this component creates an origin of name `eg-ue1-devplatform-example` and `var.failover_s3_origin_environment`
  is set to `uw1`, then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`.
  EOT
  default     = "%v-%v-%v-%v-failover"
}

variable "failover_s3_origin_environment" {
  type        = string
  description = <<-EOT
  The [fixed name](https://github.com/cloudposse/terraform-aws-utils/blob/399951e552483a4f4c1dc7fbe2675c443f3dbd83/main.tf#L10) of the AWS Region where the
  failover S3 origin exists. Setting this variable will enable use of a failover S3 origin, but it is required for the
  failover S3 origin to exist beforehand. This variable is used in conjunction with `var.failover_s3_origin_format` to
  build out the name of the Failover S3 origin in the specified region.

  For example, if this component creates an origin of name `eg-ue1-devplatform-example` and this variable is set to `uw1`,
  then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`.
  EOT
  default     = null
}

variable "forward_cookies" {
  type        = string
  default     = "none"
  description = "Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'"
}

variable "forward_header_values" {
  type        = list(string)
  description = "A list of whitelisted header values to forward to the origin (incompatible with `cache_policy_id`)"
  default     = ["Access-Control-Request-Headers", "Access-Control-Request-Method", "Origin"]
}

variable "ordered_cache" {
  type = list(object({
    target_origin_id = string
    path_pattern     = string

    allowed_methods    = list(string)
    cached_methods     = list(string)
    compress           = bool
    trusted_signers    = list(string)
    trusted_key_groups = list(string)

    cache_policy_name          = optional(string)
    cache_policy_id            = optional(string)
    origin_request_policy_name = optional(string)
    origin_request_policy_id   = optional(string)

    viewer_protocol_policy     = string
    min_ttl                    = number
    default_ttl                = number
    max_ttl                    = number
    response_headers_policy_id = string

    forward_query_string              = bool
    forward_header_values             = list(string)
    forward_cookies                   = string
    forward_cookies_whitelisted_names = list(string)

    lambda_function_association = list(object({
      event_type   = string
      include_body = bool
      lambda_arn   = string
    }))

    function_association = list(object({
      event_type   = string
      function_arn = string
    }))

    origin_request_policy = optional(object({
      cookie_behavior       = optional(string, "none")
      header_behavior       = optional(string, "none")
      query_string_behavior = optional(string, "none")

      cookies       = optional(list(string), [])
      headers       = optional(list(string), [])
      query_strings = optional(list(string), [])
    }), {})
  }))
  default     = []
  description = <<-EOT
    An ordered list of [cache behaviors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cache-behavior-arguments) resource for this distribution.
    List in order of precedence (first match wins). This is in addition to the default cache policy.
    Set `target_origin_id` to `""` to specify the S3 bucket origin created by this module.
    Set `cache_policy_id` to `""` to use `cache_policy_name` for creating a new policy. At least one of the two must be set.
    Set `origin_request_policy_id` to `""` to use `origin_request_policy_name` for creating a new policy. At least one of the two must be set.
    EOT
}

variable "preview_environment_enabled" {
  type        = bool
  description = <<-EOT
  Enable or disable SPA Preview Environments via Lambda@Edge, i.e. mapping `subdomain.example.com` to the `/subdomain`
  path in the origin S3 bucket.

  This variable implicitly affects the following variables:

  * `s3_website_enabled`
  * `s3_website_password_enabled`
  * `block_origin_public_access_enabled`
  * `origin_allow_ssl_requests_only`
  * `forward_header_values`
  * `cloudfront_default_ttl`
  * `cloudfront_min_ttl`
  * `cloudfront_max_ttl`
  * `cloudfront_lambda_function_association`
  EOT
  default     = false
}

variable "github_runners_deployment_principal_arn_enabled" {
  type        = bool
  description = "A flag that is used to decide whether or not to include the GitHub Runner's IAM role in origin_deployment_principal_arns list"
  default     = true
}

variable "github_runners_component_name" {
  type        = string
  description = "The name of the component that deploys GitHub Runners, used in remote-state lookup"
  default     = "github-runners"
}

variable "github_runners_environment_name" {
  type        = string
  description = "The name of the environment where the CloudTrail bucket is provisioned"
  default     = "ue2"
}

variable "github_runners_stage_name" {
  type        = string
  description = "The stage name where the CloudTrail bucket is provisioned"
  default     = "auto"
}

variable "github_runners_tenant_name" {
  type        = string
  description = "The tenant name where the GitHub Runners are provisioned"
  default     = null
}

variable "lambda_edge_functions" {
  type = map(object({
    source = optional(list(object({
      filename = string
      content  = string
    })))
    source_dir   = optional(string)
    source_zip   = optional(string)
    runtime      = string
    handler      = string
    event_type   = string
    include_body = bool
  }))
  description = <<-EOT
  Lambda@Edge functions to create.

  The key of this map is the name of the Lambda@Edge function.

  This map will be deep merged with each enabled default function. Use deep merge to change or overwrite specific values passed by those function objects.
  EOT
  default     = {}
}

variable "lambda_edge_runtime" {
  type        = string
  description = <<-EOT
  The default Lambda@Edge runtime for all functions.

  This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function.
  EOT
  default     = "nodejs16.x"
}

variable "lambda_edge_handler" {
  type        = string
  description = <<-EOT
  The default Lambda@Edge handler for all functions.

  This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function.
  EOT
  default     = "index.handler"
}

variable "lambda_edge_allowed_ssm_parameters" {
  type        = list(string)
  description = "The Lambda@Edge functions will be allowed to access the list of AWS SSM parameter with these ARNs"
  default     = []
}

variable "lambda_edge_destruction_delay" {
  type        = string
  description = <<-EOT
  The delay, in [Golang ParseDuration](https://pkg.go.dev/time#ParseDuration) format, to wait before destroying the Lambda@Edge
  functions.

  This delay is meant to circumvent Lambda@Edge functions not being immediately deletable following their dissociation from
  a CloudFront distribution, since they are replicated to CloudFront Edge servers around the world.

  If set to `null`, no delay will be introduced.

  By default, the delay is 20 minutes. This is because it takes about 3 minutes to destroy a CloudFront distribution, and
  around 15 minutes until the Lambda@Edge function is available for deletion, in most cases.

  For more information, see: https://github.com/hashicorp/terraform-provider-aws/issues/1721.
  EOT
  default     = "20m"
}

variable "http_version" {
  type        = string
  default     = "http2"
  description = "The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3"
}

variable "comment" {
  type        = string
  description = "Any comments you want to include about the distribution."
  default     = "Managed by Terraform"
}
