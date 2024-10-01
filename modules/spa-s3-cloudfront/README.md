---
tags:
  - component/spa-s3-cloudfront
  - layer/addons
  - provider/aws
---

# Component: `spa-s3-cloudfront`

This component is responsible for provisioning:

- S3 bucket
- CloudFront distribution for a Single Page Application
- ACM placed in us-east-1 regardless of the stack region (requirement of CloudFront)

NOTE: The component does not use the ACM created by `dns-delegated`, because the ACM region has to be us-east-1.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

An import for all instantiations of the `spa-s3-cloudfront` component can be created at `stacks/spa/spa-defaults.yaml`:

```yaml
components:
  terraform:
    spa-s3-cloudfront:
      vars:
        # lookup GitHub Runner IAM role via remote state
        github_runners_deployment_principal_arn_enabled: true
        github_runners_component_name: github-runners
        github_runners_tenant_name: core
        github_runners_environment_name: ue2
        github_runners_stage_name: auto
        origin_force_destroy: false
        origin_versioning_enabled: true
        origin_block_public_acls: true
        origin_block_public_policy: true
        origin_ignore_public_acls: true
        origin_restrict_public_buckets: true
        origin_encryption_enabled: true
        cloudfront_index_document: index.html
        cloudfront_ipv6_enabled: false
        cloudfront_compress: true
        cloudfront_default_root_object: index.html
        cloudfront_viewer_protocol_policy: redirect-to-https
```

An import for all instantiations for a specific SPA can be created at `stacks/spa/example-spa.yaml`:

```yaml
components:
  terraform:
    example-spa:
      component: spa-s3-cloudfront
      vars:
        name: example-spa
        site_subdomain: example-spa
        cloudfront_allowed_methods:
          - GET
          - HEAD
        cloudfront_cached_methods:
          - GET
          - HEAD
        cloudfront_custom_error_response:
          - error_caching_min_ttl: 1
            error_code: 403
            response_code: 200
            response_page_path: /index.html
        cloudfront_default_ttl: 60
        cloudfront_min_ttl: 60
        cloudfront_max_ttl: 60
```

Finally, the `spa-s3-cloudfront` component can be instantiated in a stack config:

```yaml
import:
  - spa/example-spa

components:
  terraform:
    example-spa:
      component: spa-s3-cloudfront
      settings:
        spacelift:
          workspace_enabled: true
      vars: {}
```

### Failover Origins

Failover origins are supported via `var.failover_s3_origin_name` and `var.failover_s3_origin_region`.

### Preview Environments

SPA Preview environments (i.e. `subdomain.example.com` mapping to a `/subdomain` path in the S3 bucket) powered by
Lambda@Edge are supported via `var.preview_environment_enabled`. See the both the variable description and inline
documentation for an extensive explanation for how these preview environments work.

### Customizing Lambda@Edge

This component supports customizing Lambda@Edge functions for the CloudFront distribution. All Lambda@Edge function
configuration is deep merged before being passed to the `cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge` module.
You can add additional functions and overwrite existing functions as such:

```yaml
import:
  - catalog/spa-s3-cloudfront/defaults

components:
  terraform:
    refarch-docs-site-spa:
      metadata:
        component: spa-s3-cloudfront
        inherits:
          - spa-s3-cloudfront-defaults
      vars:
        enabled: true
        lambda_edge_functions:
          viewer_request: # overwrite existing function
            source: null # this overwrites the 404 viewer request source with deep merging
            source_zip: "./dist/lambda_edge_paywall_viewer_request.zip"
            runtime: "nodejs16.x"
            handler: "index.handler"
            event_type: "viewer-request"
            include_body: false
          viewer_response: # new function
            source_zip: "./dist/lambda_edge_paywall_viewer_response.zip"
            runtime: "nodejs16.x"
            handler: "index.handler"
            event_type: "viewer-response"
            include_body: false
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_aws.failover"></a> [aws.failover](#provider\_aws.failover) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_request_certificate"></a> [acm\_request\_certificate](#module\_acm\_request\_certificate) | cloudposse/acm-request-certificate/aws | 0.18.0 |
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_gha_assume_role"></a> [gha\_assume\_role](#module\_gha\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_gha_role_name"></a> [gha\_role\_name](#module\_gha\_role\_name) | cloudposse/label/null | 0.25.0 |
| <a name="module_github_runners"></a> [github\_runners](#module\_github\_runners) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_lambda_edge"></a> [lambda\_edge](#module\_lambda\_edge) | cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge | 0.92.0 |
| <a name="module_lambda_edge_functions"></a> [lambda\_edge\_functions](#module\_lambda\_edge\_functions) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |
| <a name="module_spa_web"></a> [spa\_web](#module\_spa\_web) | cloudposse/cloudfront-s3-cdn/aws | 0.95.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 1.3.0 |
| <a name="module_waf"></a> [waf](#module\_waf) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_cache_policy.created_cache_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) | resource |
| [aws_cloudfront_origin_request_policy.created_origin_request_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) | resource |
| [aws_iam_policy.additional_lambda_edge_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.github_actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.additional_lambda_edge_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_shield_protection.shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_iam_policy_document.additional_lambda_edge_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.github_actions_iam_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.failover_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_block_origin_public_access_enabled"></a> [block\_origin\_public\_access\_enabled](#input\_block\_origin\_public\_access\_enabled) | When set to 'true' the s3 origin bucket will have public access block enabled. | `bool` | `true` | no |
| <a name="input_cloudfront_access_log_bucket_name"></a> [cloudfront\_access\_log\_bucket\_name](#input\_cloudfront\_access\_log\_bucket\_name) | When `cloudfront_access_log_create_bucket` is `false`, this is the name of the existing S3 Bucket where<br>CloudFront Access Logs are to be delivered and is required. IGNORED when `cloudfront_access_log_create_bucket` is `true`. | `string` | `""` | no |
| <a name="input_cloudfront_access_log_bucket_name_rendering_enabled"></a> [cloudfront\_access\_log\_bucket\_name\_rendering\_enabled](#input\_cloudfront\_access\_log\_bucket\_name\_rendering\_enabled) | If set to `true`, then the CloudFront origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.cloudfront_access_log_bucket_name)`.<br>Otherwise, the value for `cloudfront_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.<br><br>For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `cloudfront_access_log_bucket_name` is set to<br>`example-cloudfront-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-cloudfront-access-logs`. | `bool` | `false` | no |
| <a name="input_cloudfront_access_log_create_bucket"></a> [cloudfront\_access\_log\_create\_bucket](#input\_cloudfront\_access\_log\_create\_bucket) | When `true` and `cloudfront_access_logging_enabled` is also true, this module will create a new,<br>separate S3 bucket to receive CloudFront Access Logs. | `bool` | `true` | no |
| <a name="input_cloudfront_access_log_prefix"></a> [cloudfront\_access\_log\_prefix](#input\_cloudfront\_access\_log\_prefix) | Prefix to use for CloudFront Access Log object keys. Defaults to no prefix. | `string` | `""` | no |
| <a name="input_cloudfront_access_log_prefix_rendering_enabled"></a> [cloudfront\_access\_log\_prefix\_rendering\_enabled](#input\_cloudfront\_access\_log\_prefix\_rendering\_enabled) | Whether or not to dynamically render ${module.this.id} at the end of `var.cloudfront_access_log_prefix`. | `bool` | `false` | no |
| <a name="input_cloudfront_allowed_methods"></a> [cloudfront\_allowed\_methods](#input\_cloudfront\_allowed\_methods) | List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront. | `list(string)` | <pre>[<br>  "DELETE",<br>  "GET",<br>  "HEAD",<br>  "OPTIONS",<br>  "PATCH",<br>  "POST",<br>  "PUT"<br>]</pre> | no |
| <a name="input_cloudfront_aws_shield_protection_enabled"></a> [cloudfront\_aws\_shield\_protection\_enabled](#input\_cloudfront\_aws\_shield\_protection\_enabled) | Enable or disable AWS Shield Advanced protection for the CloudFront distribution. If set to 'true', a subscription to AWS Shield Advanced must exist in this account. | `bool` | `false` | no |
| <a name="input_cloudfront_aws_waf_component_name"></a> [cloudfront\_aws\_waf\_component\_name](#input\_cloudfront\_aws\_waf\_component\_name) | The name of the component used when deploying WAF ACL | `string` | `"waf"` | no |
| <a name="input_cloudfront_aws_waf_environment"></a> [cloudfront\_aws\_waf\_environment](#input\_cloudfront\_aws\_waf\_environment) | The environment where the WAF ACL for CloudFront distribution exists. | `string` | `null` | no |
| <a name="input_cloudfront_aws_waf_protection_enabled"></a> [cloudfront\_aws\_waf\_protection\_enabled](#input\_cloudfront\_aws\_waf\_protection\_enabled) | Enable or disable AWS WAF for the CloudFront distribution.<br><br>This assumes that the `aws-waf-acl-default-cloudfront` component has been deployed to the regional stack corresponding<br>to `var.waf_acl_environment`. | `bool` | `true` | no |
| <a name="input_cloudfront_cached_methods"></a> [cloudfront\_cached\_methods](#input\_cloudfront\_cached\_methods) | List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD). | `list(string)` | <pre>[<br>  "GET",<br>  "HEAD"<br>]</pre> | no |
| <a name="input_cloudfront_compress"></a> [cloudfront\_compress](#input\_cloudfront\_compress) | Compress content for web requests that include Accept-Encoding: gzip in the request header. | `bool` | `false` | no |
| <a name="input_cloudfront_custom_error_response"></a> [cloudfront\_custom\_error\_response](#input\_cloudfront\_custom\_error\_response) | List of one or more custom error response element maps. | <pre>list(object({<br>    error_caching_min_ttl = optional(string, "10")<br>    error_code            = string<br>    response_code         = string<br>    response_page_path    = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_default_root_object"></a> [cloudfront\_default\_root\_object](#input\_cloudfront\_default\_root\_object) | Object that CloudFront return when requests the root URL. | `string` | `"index.html"` | no |
| <a name="input_cloudfront_default_ttl"></a> [cloudfront\_default\_ttl](#input\_cloudfront\_default\_ttl) | Default amount of time (in seconds) that an object is in a CloudFront cache. | `number` | `60` | no |
| <a name="input_cloudfront_index_document"></a> [cloudfront\_index\_document](#input\_cloudfront\_index\_document) | Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders. | `string` | `"index.html"` | no |
| <a name="input_cloudfront_ipv6_enabled"></a> [cloudfront\_ipv6\_enabled](#input\_cloudfront\_ipv6\_enabled) | Set to true to enable an AAAA DNS record to be set as well as the A record. | `bool` | `true` | no |
| <a name="input_cloudfront_lambda_function_association"></a> [cloudfront\_lambda\_function\_association](#input\_cloudfront\_lambda\_function\_association) | A config block that configures the CloudFront distribution with lambda@edge functions for specific events. | <pre>list(object({<br>    event_type   = string<br>    include_body = bool<br>    lambda_arn   = string<br>  }))</pre> | `[]` | no |
| <a name="input_cloudfront_max_ttl"></a> [cloudfront\_max\_ttl](#input\_cloudfront\_max\_ttl) | Maximum amount of time (in seconds) that an object is in a CloudFront cache. | `number` | `31536000` | no |
| <a name="input_cloudfront_min_ttl"></a> [cloudfront\_min\_ttl](#input\_cloudfront\_min\_ttl) | Minimum amount of time that you want objects to stay in CloudFront caches. | `number` | `0` | no |
| <a name="input_cloudfront_viewer_protocol_policy"></a> [cloudfront\_viewer\_protocol\_policy](#input\_cloudfront\_viewer\_protocol\_policy) | Limit the protocol users can use to access content. One of `allow-all`, `https-only`, or `redirect-to-https`. | `string` | `"redirect-to-https"` | no |
| <a name="input_comment"></a> [comment](#input\_comment) | Any comments you want to include about the distribution. | `string` | `"Managed by Terraform"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_custom_origins"></a> [custom\_origins](#input\_custom\_origins) | A list of additional custom website [origins](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) for this distribution. | <pre>list(object({<br>    domain_name = string<br>    origin_id   = string<br>    origin_path = string<br>    custom_headers = list(object({<br>      name  = string<br>      value = string<br>    }))<br>    custom_origin_config = object({<br>      http_port                = number<br>      https_port               = number<br>      origin_protocol_policy   = string<br>      origin_ssl_protocols     = list(string)<br>      origin_keepalive_timeout = number<br>      origin_read_timeout      = number<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | The environment where `dns-delegated` component is deployed to | `string` | `"gbl"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_external_aliases"></a> [external\_aliases](#input\_external\_aliases) | List of FQDN's - Used to set the Alternate Domain Names (CNAMEs) setting on CloudFront. No new Route53 records will be created for these.<br><br>Setting `process_domain_validation_options` to true may cause the component to fail if an external\_alias DNS zone is not controlled by Terraform.<br><br>Setting `preview_environment_enabled` to `true` will cause this variable to be ignored. | `list(string)` | `[]` | no |
| <a name="input_failover_criteria_status_codes"></a> [failover\_criteria\_status\_codes](#input\_failover\_criteria\_status\_codes) | List of HTTP Status Codes to use as the origin group failover criteria. | `list(string)` | <pre>[<br>  403,<br>  404,<br>  500,<br>  502<br>]</pre> | no |
| <a name="input_failover_s3_origin_environment"></a> [failover\_s3\_origin\_environment](#input\_failover\_s3\_origin\_environment) | The [fixed name](https://github.com/cloudposse/terraform-aws-utils/blob/399951e552483a4f4c1dc7fbe2675c443f3dbd83/main.tf#L10) of the AWS Region where the<br>failover S3 origin exists. Setting this variable will enable use of a failover S3 origin, but it is required for the<br>failover S3 origin to exist beforehand. This variable is used in conjunction with `var.failover_s3_origin_format` to<br>build out the name of the Failover S3 origin in the specified region.<br><br>For example, if this component creates an origin of name `eg-ue1-devplatform-example` and this variable is set to `uw1`,<br>then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`. | `string` | `null` | no |
| <a name="input_failover_s3_origin_format"></a> [failover\_s3\_origin\_format](#input\_failover\_s3\_origin\_format) | If `var.failover_s3_origin_environment` is supplied, this is the format to use for the failover S3 origin bucket name when<br>building the name via `format([format], var.namespace, var.failover_s3_origin_environment, var.stage, var.name)`<br>and then looking it up via the `aws_s3_bucket` Data Source.<br><br>For example, if this component creates an origin of name `eg-ue1-devplatform-example` and `var.failover_s3_origin_environment`<br>is set to `uw1`, then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`. | `string` | `"%v-%v-%v-%v-failover"` | no |
| <a name="input_forward_cookies"></a> [forward\_cookies](#input\_forward\_cookies) | Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none' | `string` | `"none"` | no |
| <a name="input_forward_header_values"></a> [forward\_header\_values](#input\_forward\_header\_values) | A list of whitelisted header values to forward to the origin (incompatible with `cache_policy_id`) | `list(string)` | <pre>[<br>  "Access-Control-Request-Headers",<br>  "Access-Control-Request-Method",<br>  "Origin"<br>]</pre> | no |
| <a name="input_github_actions_allowed_repos"></a> [github\_actions\_allowed\_repos](#input\_github\_actions\_allowed\_repos) | A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br>  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br>  If org part of repo name is omitted, "cloudposse" will be assumed. | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_attributes"></a> [github\_actions\_iam\_role\_attributes](#input\_github\_actions\_iam\_role\_attributes) | Additional attributes to add to the role name | `list(string)` | `[]` | no |
| <a name="input_github_actions_iam_role_enabled"></a> [github\_actions\_iam\_role\_enabled](#input\_github\_actions\_iam\_role\_enabled) | Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources | `bool` | `false` | no |
| <a name="input_github_runners_component_name"></a> [github\_runners\_component\_name](#input\_github\_runners\_component\_name) | The name of the component that deploys GitHub Runners, used in remote-state lookup | `string` | `"github-runners"` | no |
| <a name="input_github_runners_deployment_principal_arn_enabled"></a> [github\_runners\_deployment\_principal\_arn\_enabled](#input\_github\_runners\_deployment\_principal\_arn\_enabled) | A flag that is used to decide whether or not to include the GitHub Runner's IAM role in origin\_deployment\_principal\_arns list | `bool` | `true` | no |
| <a name="input_github_runners_environment_name"></a> [github\_runners\_environment\_name](#input\_github\_runners\_environment\_name) | The name of the environment where the CloudTrail bucket is provisioned | `string` | `"ue2"` | no |
| <a name="input_github_runners_stage_name"></a> [github\_runners\_stage\_name](#input\_github\_runners\_stage\_name) | The stage name where the CloudTrail bucket is provisioned | `string` | `"auto"` | no |
| <a name="input_github_runners_tenant_name"></a> [github\_runners\_tenant\_name](#input\_github\_runners\_tenant\_name) | The tenant name where the GitHub Runners are provisioned | `string` | `null` | no |
| <a name="input_http_version"></a> [http\_version](#input\_http\_version) | The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3 | `string` | `"http2"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_edge_allowed_ssm_parameters"></a> [lambda\_edge\_allowed\_ssm\_parameters](#input\_lambda\_edge\_allowed\_ssm\_parameters) | The Lambda@Edge functions will be allowed to access the list of AWS SSM parameter with these ARNs | `list(string)` | `[]` | no |
| <a name="input_lambda_edge_destruction_delay"></a> [lambda\_edge\_destruction\_delay](#input\_lambda\_edge\_destruction\_delay) | The delay, in [Golang ParseDuration](https://pkg.go.dev/time#ParseDuration) format, to wait before destroying the Lambda@Edge<br>functions.<br><br>This delay is meant to circumvent Lambda@Edge functions not being immediately deletable following their dissociation from<br>a CloudFront distribution, since they are replicated to CloudFront Edge servers around the world.<br><br>If set to `null`, no delay will be introduced.<br><br>By default, the delay is 20 minutes. This is because it takes about 3 minutes to destroy a CloudFront distribution, and<br>around 15 minutes until the Lambda@Edge function is available for deletion, in most cases.<br><br>For more information, see: https://github.com/hashicorp/terraform-provider-aws/issues/1721. | `string` | `"20m"` | no |
| <a name="input_lambda_edge_functions"></a> [lambda\_edge\_functions](#input\_lambda\_edge\_functions) | Lambda@Edge functions to create.<br><br>The key of this map is the name of the Lambda@Edge function.<br><br>This map will be deep merged with each enabled default function. Use deep merge to change or overwrite specific values passed by those function objects. | <pre>map(object({<br>    source = optional(list(object({<br>      filename = string<br>      content  = string<br>    })))<br>    source_dir   = optional(string)<br>    source_zip   = optional(string)<br>    runtime      = string<br>    handler      = string<br>    event_type   = string<br>    include_body = bool<br>  }))</pre> | `{}` | no |
| <a name="input_lambda_edge_handler"></a> [lambda\_edge\_handler](#input\_lambda\_edge\_handler) | The default Lambda@Edge handler for all functions.<br><br>This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function. | `string` | `"index.handler"` | no |
| <a name="input_lambda_edge_runtime"></a> [lambda\_edge\_runtime](#input\_lambda\_edge\_runtime) | The default Lambda@Edge runtime for all functions.<br><br>This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function. | `string` | `"nodejs16.x"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_ordered_cache"></a> [ordered\_cache](#input\_ordered\_cache) | An ordered list of [cache behaviors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cache-behavior-arguments) resource for this distribution.<br>List in order of precedence (first match wins). This is in addition to the default cache policy.<br>Set `target_origin_id` to `""` to specify the S3 bucket origin created by this module.<br>Set `cache_policy_id` to `""` to use `cache_policy_name` for creating a new policy. At least one of the two must be set.<br>Set `origin_request_policy_id` to `""` to use `origin_request_policy_name` for creating a new policy. At least one of the two must be set. | <pre>list(object({<br>    target_origin_id = string<br>    path_pattern     = string<br><br>    allowed_methods    = list(string)<br>    cached_methods     = list(string)<br>    compress           = bool<br>    trusted_signers    = list(string)<br>    trusted_key_groups = list(string)<br><br>    cache_policy_name          = optional(string)<br>    cache_policy_id            = optional(string)<br>    origin_request_policy_name = optional(string)<br>    origin_request_policy_id   = optional(string)<br><br>    viewer_protocol_policy     = string<br>    min_ttl                    = number<br>    default_ttl                = number<br>    max_ttl                    = number<br>    response_headers_policy_id = string<br><br>    forward_query_string              = bool<br>    forward_header_values             = list(string)<br>    forward_cookies                   = string<br>    forward_cookies_whitelisted_names = list(string)<br><br>    lambda_function_association = list(object({<br>      event_type   = string<br>      include_body = bool<br>      lambda_arn   = string<br>    }))<br><br>    function_association = list(object({<br>      event_type   = string<br>      function_arn = string<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_origin_allow_ssl_requests_only"></a> [origin\_allow\_ssl\_requests\_only](#input\_origin\_allow\_ssl\_requests\_only) | Set to `true` in order to have the origin bucket require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests | `bool` | `true` | no |
| <a name="input_origin_bucket"></a> [origin\_bucket](#input\_origin\_bucket) | Name of an existing S3 bucket to use as the origin. If this is not provided, this component will create a new s3 bucket using `var.name` and other context related inputs | `string` | `null` | no |
| <a name="input_origin_deployment_actions"></a> [origin\_deployment\_actions](#input\_origin\_deployment\_actions) | List of actions to permit `origin_deployment_principal_arns` to perform on bucket and bucket prefixes (see `origin_deployment_principal_arns`) | `list(string)` | <pre>[<br>  "s3:PutObject",<br>  "s3:PutObjectAcl",<br>  "s3:GetObject",<br>  "s3:DeleteObject",<br>  "s3:ListBucket",<br>  "s3:ListBucketMultipartUploads",<br>  "s3:GetBucketLocation",<br>  "s3:AbortMultipartUpload"<br>]</pre> | no |
| <a name="input_origin_deployment_principal_arns"></a> [origin\_deployment\_principal\_arns](#input\_origin\_deployment\_principal\_arns) | List of role ARNs to grant deployment permissions to the origin Bucket. | `list(string)` | `[]` | no |
| <a name="input_origin_encryption_enabled"></a> [origin\_encryption\_enabled](#input\_origin\_encryption\_enabled) | When set to 'true' the origin Bucket will have aes256 encryption enabled by default. | `bool` | `true` | no |
| <a name="input_origin_force_destroy"></a> [origin\_force\_destroy](#input\_origin\_force\_destroy) | A boolean string that indicates all objects should be deleted from the origin Bucket so that the Bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_origin_s3_access_log_bucket_name"></a> [origin\_s3\_access\_log\_bucket\_name](#input\_origin\_s3\_access\_log\_bucket\_name) | Name of the existing S3 bucket where S3 Access Logs for the origin Bucket will be delivered. Default is not to enable S3 Access Logging for the origin Bucket. | `string` | `""` | no |
| <a name="input_origin_s3_access_log_bucket_name_rendering_enabled"></a> [origin\_s3\_access\_log\_bucket\_name\_rendering\_enabled](#input\_origin\_s3\_access\_log\_bucket\_name\_rendering\_enabled) | If set to `true`, then the S3 origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.origin_s3_access_log_bucket_name)`.<br>Otherwise, the value for `origin_s3_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.<br><br>For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `origin_s3_access_log_bucket_name` is set to<br>`example-s3-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-s3-access-logs`. | `bool` | `false` | no |
| <a name="input_origin_s3_access_log_prefix"></a> [origin\_s3\_access\_log\_prefix](#input\_origin\_s3\_access\_log\_prefix) | Prefix to use for S3 Access Log object keys. Defaults to `logs/${module.this.id}` | `string` | `""` | no |
| <a name="input_origin_s3_access_logging_enabled"></a> [origin\_s3\_access\_logging\_enabled](#input\_origin\_s3\_access\_logging\_enabled) | Set `true` to deliver S3 Access Logs to the `origin_s3_access_log_bucket_name` bucket.<br>Defaults to `false` if `origin_s3_access_log_bucket_name` is empty (the default), `true` otherwise.<br>Must be set explicitly if the access log bucket is being created at the same time as this module is being invoked. | `bool` | `null` | no |
| <a name="input_origin_versioning_enabled"></a> [origin\_versioning\_enabled](#input\_origin\_versioning\_enabled) | Enable or disable versioning for the origin Bucket. Versioning is a means of keeping multiple variants of an object in the same bucket. | `bool` | `false` | no |
| <a name="input_parent_zone_name"></a> [parent\_zone\_name](#input\_parent\_zone\_name) | Parent domain name of site to publish. Defaults to format(parent\_zone\_name\_pattern, stage, environment). | `string` | `""` | no |
| <a name="input_preview_environment_enabled"></a> [preview\_environment\_enabled](#input\_preview\_environment\_enabled) | Enable or disable SPA Preview Environments via Lambda@Edge, i.e. mapping `subdomain.example.com` to the `/subdomain`<br>path in the origin S3 bucket.<br><br>This variable implicitly affects the following variables:<br><br>* `s3_website_enabled`<br>* `s3_website_password_enabled`<br>* `block_origin_public_access_enabled`<br>* `origin_allow_ssl_requests_only`<br>* `forward_header_values`<br>* `cloudfront_default_ttl`<br>* `cloudfront_min_ttl`<br>* `cloudfront_max_ttl`<br>* `cloudfront_lambda_function_association` | `bool` | `false` | no |
| <a name="input_process_domain_validation_options"></a> [process\_domain\_validation\_options](#input\_process\_domain\_validation\_options) | Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_s3_object_ownership"></a> [s3\_object\_ownership](#input\_s3\_object\_ownership) | Specifies the S3 object ownership control on the origin bucket. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'. | `string` | `"ObjectWriter"` | no |
| <a name="input_s3_origins"></a> [s3\_origins](#input\_s3\_origins) | A list of S3 [origins](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) (in addition to the one created by this component) for this distribution.<br>S3 buckets configured as websites are `custom_origins`, not `s3_origins`.<br>Specifying `s3_origin_config.origin_access_identity` as `null` or `""` will have it translated to the `origin_access_identity` used by the origin created by this component. | <pre>list(object({<br>    domain_name = string<br>    origin_id   = string<br>    origin_path = string<br>    s3_origin_config = object({<br>      origin_access_identity = string<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_s3_website_enabled"></a> [s3\_website\_enabled](#input\_s3\_website\_enabled) | Set to true to enable the created S3 bucket to serve as a website independently of CloudFront,<br>and to use that website as the origin.<br><br>Setting `preview_environment_enabled` will implicitly set this to `true`. | `bool` | `false` | no |
| <a name="input_s3_website_password_enabled"></a> [s3\_website\_password\_enabled](#input\_s3\_website\_password\_enabled) | If set to true, and `s3_website_enabled` is also true, a password will be required in the `Referrer` field of the<br>HTTP request in order to access the website, and CloudFront will be configured to pass this password in its requests.<br>This will make it much harder for people to bypass CloudFront and access the S3 website directly via its website endpoint. | `bool` | `false` | no |
| <a name="input_site_fqdn"></a> [site\_fqdn](#input\_site\_fqdn) | Fully qualified domain name of site to publish. Overrides site\_subdomain and parent\_zone\_name. | `string` | `""` | no |
| <a name="input_site_subdomain"></a> [site\_subdomain](#input\_site\_subdomain) | Subdomain to plug into site\_name\_pattern to make site FQDN. | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudfront_distribution_alias"></a> [cloudfront\_distribution\_alias](#output\_cloudfront\_distribution\_alias) | Cloudfront Distribution Alias Record. |
| <a name="output_cloudfront_distribution_domain_name"></a> [cloudfront\_distribution\_domain\_name](#output\_cloudfront\_distribution\_domain\_name) | Cloudfront Distribution Domain Name. |
| <a name="output_cloudfront_distribution_identity_arn"></a> [cloudfront\_distribution\_identity\_arn](#output\_cloudfront\_distribution\_identity\_arn) | CloudFront Distribution Origin Access Identity IAM ARN. |
| <a name="output_failover_s3_bucket_name"></a> [failover\_s3\_bucket\_name](#output\_failover\_s3\_bucket\_name) | Failover Origin bucket name, if enabled. |
| <a name="output_github_actions_iam_role_arn"></a> [github\_actions\_iam\_role\_arn](#output\_github\_actions\_iam\_role\_arn) | ARN of IAM role for GitHub Actions |
| <a name="output_github_actions_iam_role_name"></a> [github\_actions\_iam\_role\_name](#output\_github\_actions\_iam\_role\_name) | Name of IAM role for GitHub Actions |
| <a name="output_origin_s3_bucket_arn"></a> [origin\_s3\_bucket\_arn](#output\_origin\_s3\_bucket\_arn) | Origin bucket ARN. |
| <a name="output_origin_s3_bucket_name"></a> [origin\_s3\_bucket\_name](#output\_origin\_s3\_bucket\_name) | Origin bucket name. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/spa-s3-cloudfront) -
  Cloud Posse's upstream component
- [How do I use CloudFront to serve a static website hosted on Amazon S3?](https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-serve-static-website/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
