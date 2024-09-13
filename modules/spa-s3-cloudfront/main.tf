locals {
  enabled                           = module.this.enabled
  aws_shield_enabled                = local.enabled && var.cloudfront_aws_shield_protection_enabled
  aws_waf_enabled                   = local.enabled && var.cloudfront_aws_waf_protection_enabled
  github_runners_enabled            = local.enabled && var.github_runners_deployment_principal_arn_enabled
  parent_zone_name                  = length(var.parent_zone_name) > 0 ? var.parent_zone_name : try(module.dns_delegated.outputs.default_domain_name, null)
  site_fqdn                         = length(var.site_fqdn) > 0 ? var.site_fqdn : format("%v.%v.%v", var.site_subdomain, module.this.environment, local.parent_zone_name)
  s3_access_log_bucket_name         = var.origin_s3_access_log_bucket_name_rendering_enabled ? format("%[1]v-${module.this.tenant != null ? "%[2]v-" : ""}%[3]v-%[4]v-%[5]v", var.namespace, var.tenant, var.environment, var.stage, var.origin_s3_access_log_bucket_name) : var.origin_s3_access_log_bucket_name
  cloudfront_access_log_bucket_name = var.cloudfront_access_log_bucket_name_rendering_enabled ? format("%[1]v-${module.this.tenant != null ? "%[2]v-" : ""}%[3]v-%[4]v-%[5]v", var.namespace, var.tenant, var.environment, var.stage, var.cloudfront_access_log_bucket_name) : var.cloudfront_access_log_bucket_name
  cloudfront_access_log_prefix      = var.cloudfront_access_log_prefix_rendering_enabled ? "${var.cloudfront_access_log_prefix}${module.this.id}" : var.cloudfront_access_log_prefix
  origin_deployment_principal_arns  = local.github_runners_enabled ? concat(var.origin_deployment_principal_arns, [module.github_runners.outputs.iam_role_arn]) : var.origin_deployment_principal_arns

  # Variables affected by SPA Preview Environments
  #
  # In order for preview environments to work, there are some specific CloudFront Distribution settings that need to be in place (in order of local variables set below this list):
  # 1. A wildcard domain Route53 alias needs to be created for the CloudFront distribution. SANs for the ACM certificate need to be set accordingly.
  # 2. The origin must be a custom origin pointing to the S3 website endpoint, not a S3 REST origin (the set of Lambda@Edge functions in lambda_edge.tf do not support the latter).
  # 3. Because of #2, the bucket in question cannot have a Public Access Block configuration blocking all public ACLs.
  # 4. Because of #2 and #3, it is best practice to enable a password on the S3 website origin so that CloudFront is the single point of entry.
  # 5. Object ACLs should be disabled for the origin bucket in the preview environment, otherwise CI/CD jobs uploading to the origin bucket may create object ACLs preventing the content from being served.
  # 6. The statement in the bucket policy blocking non-TLS requests from CloudFront needs to be disabled.
  # 7. A custom header 'x-forwarded-host' needs to be forwarded to the origin (it is injected by lambda@edge function associated with the Viewer Request event).
  # 8. TTL values will be set to 0, because the preview environment is associated with development and debugging, not long term caching.
  # 9. The Lambda@Edge functions created by lambda_edge.tf need to be associated with the CloudFront Distribution.
  #
  # This isn't necessarily the only way to get preview environments to work, but these are the constraints required to achieve the currently tested implementation in modules/lambda-edge-preview.
  preview_environment_enabled         = local.enabled && var.preview_environment_enabled
  preview_environment_wildcard_domain = format("%v.%v", "*", local.site_fqdn)
  aliases                             = concat([local.site_fqdn], local.preview_environment_enabled ? [local.preview_environment_wildcard_domain] : [])
  external_aliases                    = local.preview_environment_enabled ? [] : var.external_aliases
  subject_alternative_names           = local.preview_environment_enabled ? [local.preview_environment_wildcard_domain] : var.external_aliases
  s3_website_enabled                  = var.s3_website_enabled || local.preview_environment_enabled
  s3_website_password_enabled         = var.s3_website_password_enabled || local.preview_environment_enabled
  s3_object_ownership                 = local.preview_environment_enabled ? "BucketOwnerEnforced" : var.s3_object_ownership
  s3_failover_origin = local.failover_enabled ? [{
    domain_name = data.aws_s3_bucket.failover_bucket[0].bucket_domain_name
    origin_id   = data.aws_s3_bucket.failover_bucket[0].bucket
    origin_path = null
    s3_origin_config = {
      origin_access_identity = null # will get translated to the origin_access_identity used by the origin created by this module.
    }
  }] : []
  s3_origins                         = local.enabled ? concat(local.s3_failover_origin, var.s3_origins) : []
  block_origin_public_access_enabled = var.block_origin_public_access_enabled && !local.preview_environment_enabled

  # SSL Requirements by s3 bucket configuration
  # | s3 website enabled | preview enabled | SSL Enabled |
  # |--------------------|-----------------|-------------|
  # | false              | false           | true        |
  # | true               | false           | false       |
  # | true               | true            | false       |
  # Preview must have website_enabled.
  origin_allow_ssl_requests_only = var.origin_allow_ssl_requests_only && !local.s3_website_enabled

  forward_header_values  = local.preview_environment_enabled ? concat(var.forward_header_values, ["x-forwarded-host"]) : var.forward_header_values
  cloudfront_default_ttl = local.preview_environment_enabled ? 0 : var.cloudfront_default_ttl
  cloudfront_min_ttl     = local.preview_environment_enabled ? 0 : var.cloudfront_min_ttl
  cloudfront_max_ttl     = local.preview_environment_enabled ? 0 : var.cloudfront_max_ttl
}

# Create an ACM and explicitly set it to us-east-1 (requirement of CloudFront)
module "acm_request_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.18.0"
  providers = {
    aws = aws.us-east-1
  }

  domain_name                       = local.site_fqdn
  subject_alternative_names         = local.subject_alternative_names
  zone_name                         = local.parent_zone_name
  process_domain_validation_options = var.process_domain_validation_options
  ttl                               = 300

  context = module.this.context
}

module "spa_web" {
  source  = "cloudposse/cloudfront-s3-cdn/aws"
  version = "0.95.0"

  block_origin_public_access_enabled = local.block_origin_public_access_enabled
  encryption_enabled                 = var.origin_encryption_enabled
  origin_force_destroy               = var.origin_force_destroy
  versioning_enabled                 = var.origin_versioning_enabled
  web_acl_id                         = local.aws_waf_enabled ? module.waf.outputs.acl.arn : null

  cloudfront_access_log_create_bucket = var.cloudfront_access_log_create_bucket
  cloudfront_access_log_bucket_name   = local.cloudfront_access_log_bucket_name
  cloudfront_access_log_prefix        = local.cloudfront_access_log_prefix

  index_document      = var.cloudfront_index_document
  default_root_object = var.cloudfront_default_root_object

  s3_access_logging_enabled = var.origin_s3_access_logging_enabled
  s3_access_log_bucket_name = local.s3_access_log_bucket_name
  s3_access_log_prefix      = var.origin_s3_access_log_prefix

  comment                     = var.comment
  aliases                     = local.aliases
  external_aliases            = local.external_aliases
  parent_zone_name            = local.parent_zone_name
  dns_alias_enabled           = true
  website_enabled             = local.s3_website_enabled
  s3_website_password_enabled = local.s3_website_password_enabled
  allow_ssl_requests_only     = local.origin_allow_ssl_requests_only
  acm_certificate_arn         = module.acm_request_certificate.arn
  ipv6_enabled                = var.cloudfront_ipv6_enabled

  http_version          = var.http_version
  allowed_methods       = var.cloudfront_allowed_methods
  cached_methods        = var.cloudfront_cached_methods
  custom_error_response = var.cloudfront_custom_error_response
  default_ttl           = local.cloudfront_default_ttl
  min_ttl               = local.cloudfront_min_ttl
  max_ttl               = local.cloudfront_max_ttl

  ordered_cache         = local.ordered_cache
  forward_cookies       = var.forward_cookies
  forward_header_values = local.forward_header_values

  compress               = var.cloudfront_compress
  viewer_protocol_policy = var.cloudfront_viewer_protocol_policy

  deployment_principal_arns = { for arn in local.origin_deployment_principal_arns : arn => [""] }
  # Actions the deployment ARNs are allowed to perform on the S3 Origin bucket
  deployment_actions = var.origin_deployment_actions

  lambda_function_association = local.cloudfront_lambda_function_association

  custom_origins = var.custom_origins
  origin_bucket  = var.origin_bucket
  origin_groups = local.failover_enabled ? [{
    primary_origin_id  = null # will get translated to the origin id of the origin created by this module.
    failover_origin_id = data.aws_s3_bucket.failover_bucket[0].bucket
    failover_criteria  = var.failover_criteria_status_codes
  }] : []

  s3_object_ownership = local.s3_object_ownership
  s3_origins          = local.s3_origins

  context = module.this.context
}

resource "aws_shield_protection" "shield_protection" {
  count = local.aws_shield_enabled ? 1 : 0

  name         = module.spa_web.cf_id
  resource_arn = module.spa_web.cf_arn
}
