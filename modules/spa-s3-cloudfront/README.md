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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `aws` | >= 4.9.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`acm_request_certificate` | 0.18.0 | [`cloudposse/acm-request-certificate/aws`](https://registry.terraform.io/modules/cloudposse/acm-request-certificate/aws/0.18.0) | Create an ACM and explicitly set it to us-east-1 (requirement of CloudFront)
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`gha_assume_role` | latest | [`../account-map/modules/team-assume-role-policy`](https://registry.terraform.io/modules/../account-map/modules/team-assume-role-policy/) | n/a
`gha_role_name` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`github_runners` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`lambda_edge` | 0.92.0 | [`cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge`](https://registry.terraform.io/modules/cloudposse/cloudfront-s3-cdn/aws/modules/lambda@edge/0.92.0) | n/a
`lambda_edge_functions` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a
`spa_web` | 0.95.0 | [`cloudposse/cloudfront-s3-cdn/aws`](https://registry.terraform.io/modules/cloudposse/cloudfront-s3-cdn/aws/0.95.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 1.3.0 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/1.3.0) | n/a
`waf` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_cloudfront_cache_policy.created_cache_policies`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_cache_policy) (resource)(ordered_cache.tf#1)
  - [`aws_cloudfront_origin_request_policy.created_origin_request_policies`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_request_policy) (resource)(ordered_cache.tf#24)
  - [`aws_iam_policy.additional_lambda_edge_permission`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(lambda_edge.tf#116)
  - [`aws_iam_role.github_actions`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(github-actions-iam-role.mixin.tf#53)
  - [`aws_iam_role_policy_attachment.additional_lambda_edge_permission`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(lambda_edge.tf#123)
  - [`aws_shield_protection.shield_protection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) (resource)(main.tf#143)

## Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.additional_lambda_edge_permission`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.github_actions_iam_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_s3_bucket.failover_bucket`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) (data source)

## Outputs

<dl>
  <dt><code>cloudfront_distribution_alias</code></dt>
  <dd>
    Cloudfront Distribution Alias Record.<br/>

  </dd>
  <dt><code>cloudfront_distribution_domain_name</code></dt>
  <dd>
    Cloudfront Distribution Domain Name.<br/>

  </dd>
  <dt><code>failover_s3_bucket_name</code></dt>
  <dd>
    Failover Origin bucket name, if enabled.<br/>

  </dd>
  <dt><code>github_actions_iam_role_arn</code></dt>
  <dd>
    ARN of IAM role for GitHub Actions<br/>

  </dd>
  <dt><code>github_actions_iam_role_name</code></dt>
  <dd>
    Name of IAM role for GitHub Actions<br/>

  </dd>
  <dt><code>origin_s3_bucket_arn</code></dt>
  <dd>
    Origin bucket ARN.<br/>

  </dd>
  <dt><code>origin_s3_bucket_name</code></dt>
  <dd>
    Origin bucket name.<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `block_origin_public_access_enabled` (`bool`) <i>optional</i>


When set to 'true' the s3 origin bucket will have public access block enabled.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `cloudfront_access_log_bucket_name` (`string`) <i>optional</i>


When `cloudfront_access_log_create_bucket` is `false`, this is the name of the existing S3 Bucket where<br/>
CloudFront Access Logs are to be delivered and is required. IGNORED when `cloudfront_access_log_create_bucket` is `true`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `cloudfront_access_log_bucket_name_rendering_enabled` (`bool`) <i>optional</i>


If set to `true`, then the CloudFront origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.cloudfront_access_log_bucket_name)`.<br/>
Otherwise, the value for `cloudfront_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.<br/>
<br/>
For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `cloudfront_access_log_bucket_name` is set to<br/>
`example-cloudfront-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-cloudfront-access-logs`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `cloudfront_access_log_create_bucket` (`bool`) <i>optional</i>


When `true` and `cloudfront_access_logging_enabled` is also true, this module will create a new,<br/>
separate S3 bucket to receive CloudFront Access Logs.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `cloudfront_access_log_prefix` (`string`) <i>optional</i>


Prefix to use for CloudFront Access Log object keys. Defaults to no prefix.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `cloudfront_access_log_prefix_rendering_enabled` (`bool`) <i>optional</i>


Whether or not to dynamically render ${module.this.id} at the end of `var.cloudfront_access_log_prefix`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `cloudfront_allowed_methods` (`list(string)`) <i>optional</i>


List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "DELETE",
>
>      "GET",
>
>      "HEAD",
>
>      "OPTIONS",
>
>      "PATCH",
>
>      "POST",
>
>      "PUT"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `cloudfront_aws_shield_protection_enabled` (`bool`) <i>optional</i>


Enable or disable AWS Shield Advanced protection for the CloudFront distribution. If set to 'true', a subscription to AWS Shield Advanced must exist in this account.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `cloudfront_aws_waf_component_name` (`string`) <i>optional</i>


The name of the component used when deploying WAF ACL<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"waf"</code>
>   </dd>
> </dl>
>


### `cloudfront_aws_waf_environment` (`string`) <i>optional</i>


The environment where the WAF ACL for CloudFront distribution exists.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `cloudfront_aws_waf_protection_enabled` (`bool`) <i>optional</i>


Enable or disable AWS WAF for the CloudFront distribution.<br/>
<br/>
This assumes that the `aws-waf-acl-default-cloudfront` component has been deployed to the regional stack corresponding<br/>
to `var.waf_acl_environment`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `cloudfront_cached_methods` (`list(string)`) <i>optional</i>


List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "GET",
>
>      "HEAD"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `cloudfront_compress` (`bool`) <i>optional</i>


Compress content for web requests that include Accept-Encoding: gzip in the request header.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `cloudfront_custom_error_response` <i>optional</i>


List of one or more custom error response element maps.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    error_caching_min_ttl = optional(string, "10")
    error_code            = string
    response_code         = string
    response_page_path    = string
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cloudfront_default_root_object` (`string`) <i>optional</i>


Object that CloudFront return when requests the root URL.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"index.html"</code>
>   </dd>
> </dl>
>


### `cloudfront_default_ttl` (`number`) <i>optional</i>


Default amount of time (in seconds) that an object is in a CloudFront cache.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>60</code>
>   </dd>
> </dl>
>


### `cloudfront_index_document` (`string`) <i>optional</i>


Amazon S3 returns this index document when requests are made to the root domain or any of the subfolders.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"index.html"</code>
>   </dd>
> </dl>
>


### `cloudfront_ipv6_enabled` (`bool`) <i>optional</i>


Set to true to enable an AAAA DNS record to be set as well as the A record.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `cloudfront_lambda_function_association` <i>optional</i>


A config block that configures the CloudFront distribution with lambda@edge functions for specific events.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    event_type   = string
    include_body = bool
    lambda_arn   = string
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `cloudfront_max_ttl` (`number`) <i>optional</i>


Maximum amount of time (in seconds) that an object is in a CloudFront cache.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>31536000</code>
>   </dd>
> </dl>
>


### `cloudfront_min_ttl` (`number`) <i>optional</i>


Minimum amount of time that you want objects to stay in CloudFront caches.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>0</code>
>   </dd>
> </dl>
>


### `cloudfront_viewer_protocol_policy` (`string`) <i>optional</i>


Limit the protocol users can use to access content. One of `allow-all`, `https-only`, or `redirect-to-https`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"redirect-to-https"</code>
>   </dd>
> </dl>
>


### `comment` (`string`) <i>optional</i>


Any comments you want to include about the distribution.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"Managed by Terraform"</code>
>   </dd>
> </dl>
>


### `custom_origins` <i>optional</i>


A list of additional custom website [origins](https://www.terraform.io/docs/providers/aws/r/cloudfront_distribution.html#origin-arguments) for this distribution.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
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
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `dns_delegated_environment_name` (`string`) <i>optional</i>


The environment where `dns-delegated` component is deployed to<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"gbl"</code>
>   </dd>
> </dl>
>


### `external_aliases` (`list(string)`) <i>optional</i>


List of FQDN's - Used to set the Alternate Domain Names (CNAMEs) setting on CloudFront. No new Route53 records will be created for these.<br/>
<br/>
Setting `process_domain_validation_options` to true may cause the component to fail if an external_alias DNS zone is not controlled by Terraform.<br/>
<br/>
Setting `preview_environment_enabled` to `true` will cause this variable to be ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `failover_criteria_status_codes` (`list(string)`) <i>optional</i>


List of HTTP Status Codes to use as the origin group failover criteria.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      403,
>
>      404,
>
>      500,
>
>      502
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `failover_s3_origin_environment` (`string`) <i>optional</i>


The [fixed name](https://github.com/cloudposse/terraform-aws-utils/blob/399951e552483a4f4c1dc7fbe2675c443f3dbd83/main.tf#L10) of the AWS Region where the<br/>
failover S3 origin exists. Setting this variable will enable use of a failover S3 origin, but it is required for the<br/>
failover S3 origin to exist beforehand. This variable is used in conjunction with `var.failover_s3_origin_format` to<br/>
build out the name of the Failover S3 origin in the specified region.<br/>
<br/>
For example, if this component creates an origin of name `eg-ue1-devplatform-example` and this variable is set to `uw1`,<br/>
then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `failover_s3_origin_format` (`string`) <i>optional</i>


If `var.failover_s3_origin_environment` is supplied, this is the format to use for the failover S3 origin bucket name when<br/>
building the name via `format([format], var.namespace, var.failover_s3_origin_environment, var.stage, var.name)`<br/>
and then looking it up via the `aws_s3_bucket` Data Source.<br/>
<br/>
For example, if this component creates an origin of name `eg-ue1-devplatform-example` and `var.failover_s3_origin_environment`<br/>
is set to `uw1`, then it is expected that a bucket with the name `eg-uw1-devplatform-example-failover` exists in `us-west-1`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"%v-%v-%v-%v-failover"</code>
>   </dd>
> </dl>
>


### `forward_cookies` (`string`) <i>optional</i>


Specifies whether you want CloudFront to forward all or no cookies to the origin. Can be 'all' or 'none'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"none"</code>
>   </dd>
> </dl>
>


### `forward_header_values` (`list(string)`) <i>optional</i>


A list of whitelisted header values to forward to the origin (incompatible with `cache_policy_id`)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "Access-Control-Request-Headers",
>
>      "Access-Control-Request-Method",
>
>      "Origin"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `github_actions_allowed_repos` (`list(string)`) <i>optional</i>


  A list of the GitHub repositories that are allowed to assume this role from GitHub Actions. For example,<br/>
  ["cloudposse/infra-live"]. Can contain "*" as wildcard.<br/>
  If org part of repo name is omitted, "cloudposse" will be assumed.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `github_actions_iam_role_attributes` (`list(string)`) <i>optional</i>


Additional attributes to add to the role name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `github_actions_iam_role_enabled` (`bool`) <i>optional</i>


Flag to toggle creation of an IAM Role that GitHub Actions can assume to access AWS resources<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `github_runners_component_name` (`string`) <i>optional</i>


The name of the component that deploys GitHub Runners, used in remote-state lookup<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"github-runners"</code>
>   </dd>
> </dl>
>


### `github_runners_deployment_principal_arn_enabled` (`bool`) <i>optional</i>


A flag that is used to decide whether or not to include the GitHub Runner's IAM role in origin_deployment_principal_arns list<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `github_runners_environment_name` (`string`) <i>optional</i>


The name of the environment where the CloudTrail bucket is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"ue2"</code>
>   </dd>
> </dl>
>


### `github_runners_stage_name` (`string`) <i>optional</i>


The stage name where the CloudTrail bucket is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"auto"</code>
>   </dd>
> </dl>
>


### `github_runners_tenant_name` (`string`) <i>optional</i>


The tenant name where the GitHub Runners are provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `http_version` (`string`) <i>optional</i>


The maximum HTTP version to support on the distribution. Allowed values are http1.1, http2, http2and3 and http3<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"http2"</code>
>   </dd>
> </dl>
>


### `lambda_edge_allowed_ssm_parameters` (`list(string)`) <i>optional</i>


The Lambda@Edge functions will be allowed to access the list of AWS SSM parameter with these ARNs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `lambda_edge_destruction_delay` (`string`) <i>optional</i>


The delay, in [Golang ParseDuration](https://pkg.go.dev/time#ParseDuration) format, to wait before destroying the Lambda@Edge<br/>
functions.<br/>
<br/>
This delay is meant to circumvent Lambda@Edge functions not being immediately deletable following their dissociation from<br/>
a CloudFront distribution, since they are replicated to CloudFront Edge servers around the world.<br/>
<br/>
If set to `null`, no delay will be introduced.<br/>
<br/>
By default, the delay is 20 minutes. This is because it takes about 3 minutes to destroy a CloudFront distribution, and<br/>
around 15 minutes until the Lambda@Edge function is available for deletion, in most cases.<br/>
<br/>
For more information, see: https://github.com/hashicorp/terraform-provider-aws/issues/1721.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"20m"</code>
>   </dd>
> </dl>
>


### `lambda_edge_functions` <i>optional</i>


Lambda@Edge functions to create.<br/>
<br/>
The key of this map is the name of the Lambda@Edge function.<br/>
<br/>
This map will be deep merged with each enabled default function. Use deep merge to change or overwrite specific values passed by those function objects.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
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
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `lambda_edge_handler` (`string`) <i>optional</i>


The default Lambda@Edge handler for all functions.<br/>
<br/>
This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"index.handler"</code>
>   </dd>
> </dl>
>


### `lambda_edge_runtime` (`string`) <i>optional</i>


The default Lambda@Edge runtime for all functions.<br/>
<br/>
This value is deep merged in `module.lambda_edge_functions` with `var.lambda_edge_functions` and can be overwritten for any individual function.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"nodejs16.x"</code>
>   </dd>
> </dl>
>


### `ordered_cache` <i>optional</i>


An ordered list of [cache behaviors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution#cache-behavior-arguments) resource for this distribution.<br/>
List in order of precedence (first match wins). This is in addition to the default cache policy.<br/>
Set `target_origin_id` to `""` to specify the S3 bucket origin created by this module.<br/>
Set `cache_policy_id` to `""` to use `cache_policy_name` for creating a new policy. At least one of the two must be set.<br/>
Set `origin_request_policy_id` to `""` to use `origin_request_policy_name` for creating a new policy. At least one of the two must be set.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
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
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `origin_allow_ssl_requests_only` (`bool`) <i>optional</i>


Set to `true` in order to have the origin bucket require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `origin_deployment_actions` (`list(string)`) <i>optional</i>


List of actions to permit `origin_deployment_principal_arns` to perform on bucket and bucket prefixes (see `origin_deployment_principal_arns`)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "s3:PutObject",
>
>      "s3:PutObjectAcl",
>
>      "s3:GetObject",
>
>      "s3:DeleteObject",
>
>      "s3:ListBucket",
>
>      "s3:ListBucketMultipartUploads",
>
>      "s3:GetBucketLocation",
>
>      "s3:AbortMultipartUpload"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `origin_deployment_principal_arns` (`list(string)`) <i>optional</i>


List of role ARNs to grant deployment permissions to the origin Bucket.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `origin_encryption_enabled` (`bool`) <i>optional</i>


When set to 'true' the origin Bucket will have aes256 encryption enabled by default.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `origin_force_destroy` (`bool`) <i>optional</i>


A boolean string that indicates all objects should be deleted from the origin Bucket so that the Bucket can be destroyed without error. These objects are not recoverable.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `origin_s3_access_log_bucket_name` (`string`) <i>optional</i>


Name of the existing S3 bucket where S3 Access Logs for the origin Bucket will be delivered. Default is not to enable S3 Access Logging for the origin Bucket.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `origin_s3_access_log_bucket_name_rendering_enabled` (`bool`) <i>optional</i>


If set to `true`, then the S3 origin access logs bucket name will be rendered by calling `format("%v-%v-%v-%v", var.namespace, var.environment, var.stage, var.origin_s3_access_log_bucket_name)`.<br/>
Otherwise, the value for `origin_s3_access_log_bucket_name` will need to be the globally unique name of the access logs bucket.<br/>
<br/>
For example, if this component produces an origin bucket named `eg-ue1-devplatform-example` and `origin_s3_access_log_bucket_name` is set to<br/>
`example-s3-access-logs`, then the bucket name will be rendered to be `eg-ue1-devplatform-example-s3-access-logs`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `origin_s3_access_log_prefix` (`string`) <i>optional</i>


Prefix to use for S3 Access Log object keys. Defaults to `logs/${module.this.id}`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `origin_s3_access_logging_enabled` (`bool`) <i>optional</i>


Set `true` to deliver S3 Access Logs to the `origin_s3_access_log_bucket_name` bucket.<br/>
Defaults to `false` if `origin_s3_access_log_bucket_name` is empty (the default), `true` otherwise.<br/>
Must be set explicitly if the access log bucket is being created at the same time as this module is being invoked.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `origin_versioning_enabled` (`bool`) <i>optional</i>


Enable or disable versioning for the origin Bucket. Versioning is a means of keeping multiple variants of an object in the same bucket.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `parent_zone_name` (`string`) <i>optional</i>


Parent domain name of site to publish. Defaults to format(parent_zone_name_pattern, stage, environment).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `preview_environment_enabled` (`bool`) <i>optional</i>


Enable or disable SPA Preview Environments via Lambda@Edge, i.e. mapping `subdomain.example.com` to the `/subdomain`<br/>
path in the origin S3 bucket.<br/>
<br/>
This variable implicitly affects the following variables:<br/>
<br/>
* `s3_website_enabled`<br/>
* `s3_website_password_enabled`<br/>
* `block_origin_public_access_enabled`<br/>
* `origin_allow_ssl_requests_only`<br/>
* `forward_header_values`<br/>
* `cloudfront_default_ttl`<br/>
* `cloudfront_min_ttl`<br/>
* `cloudfront_max_ttl`<br/>
* `cloudfront_lambda_function_association`<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `process_domain_validation_options` (`bool`) <i>optional</i>


Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `s3_object_ownership` (`string`) <i>optional</i>


Specifies the S3 object ownership control on the origin bucket. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"ObjectWriter"</code>
>   </dd>
> </dl>
>


### `s3_website_enabled` (`bool`) <i>optional</i>


Set to true to enable the created S3 bucket to serve as a website independently of CloudFront,<br/>
and to use that website as the origin.<br/>
<br/>
Setting `preview_environment_enabled` will implicitly set this to `true`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `s3_website_password_enabled` (`bool`) <i>optional</i>


If set to true, and `s3_website_enabled` is also true, a password will be required in the `Referrer` field of the<br/>
HTTP request in order to access the website, and CloudFront will be configured to pass this password in its requests.<br/>
This will make it much harder for people to bypass CloudFront and access the S3 website directly via its website endpoint.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `site_fqdn` (`string`) <i>optional</i>


Fully qualified domain name of site to publish. Overrides site_subdomain and parent_zone_name.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `site_subdomain` (`string`) <i>optional</i>


Subdomain to plug into site_name_pattern to make site FQDN.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    [
>
>      "default"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/spa-s3-cloudfront) -
  Cloud Posse's upstream component
- [How do I use CloudFront to serve a static website hosted on Amazon S3?](https://aws.amazon.com/premiumsupport/knowledge-center/cloudfront-serve-static-website/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
