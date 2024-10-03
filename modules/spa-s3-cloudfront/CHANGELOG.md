## Component PRs [#991](https://github.com/cloudposse/terraform-aws-components/pull/991) and [#995](https://github.com/cloudposse/terraform-aws-components/pull/995)

### Drop `lambda_edge_redirect_404`

This PRs removes the `lambda_edge_redirect_404` functionality because it leads to significant costs. Use native
CloudFront error pages configs instead.

```yaml
cloudfront_custom_error_response:
  - error_code: 404
    response_code: 404
    response_page_path: /404.html
```

## Components PR [#978](https://github.com/cloudposse/terraform-aws-components/pull/978)

### Lambda@Edge Submodule Refactor

This PR has significantly refactored how Lambda@Edge functions are managed by Terraform with this component. Previously,
the specific use cases for Lambda@Edge functions were handled by submodules `lambda-edge-preview` and
`lambda_edge_redirect_404`. These component submodules both called the same Terraform module,
`cloudposse/cloudfront-s3-cdn/aws//modules/lambda@edge`. These submodules have been replaced with a single Terraform
file, `lambda_edge.tf`.

The reason a single file is better than submodules is (1) simplification and (2) adding the ability to deep merge
function configuration. Cloudfront Distributions support a single Lambda@Edge function for each origin/viewer request or
response. With deep merging, we can define default values for function configuration and provide the ability to
overwrite specific values for a given deployment.

Specifically, our own use case is using an authorization Lambda@Edge viewer request only if the paywall is enabled.
Other deployments use an alternative viewer request to redirect 404.

#### Upgrading with `preview_environment_enabled: true` or `lambda_edge_redirect_404_enabled: true`

If you have `var.preview_environment_enabled` or `var.lambda_edge_redirect_404_enabled` set to `true`, Terraform `moved`
will move the previous resource by submodule to the new resource by file. Please give your next Terraform plan a sanity
check. Any existing Lambda functions _should not be destroyed_ by this change.

#### Upgrading with both `preview_environment_enabled: false` and `lambda_edge_redirect_404_enabled: false`

If you have no Lambda@Edge functions deployed and where both `var.preview_environment_enabled` and
`var.lambda_edge_redirect_404_enabled` are `false` (the default value), no change is necessary.

### Lambda Runtime Version

The previous PR [#946](https://github.com/cloudposse/terraform-aws-components/pull/946) introduced the
`var.lambda_runtime` input. Previously, the version of node in both submodules was hard-coded to be `nodejs12.x`. This
PR renames that variable to `var.lambda_edge_runtime` and sets the default to `nodejs16.x`.

If you want to maintain the previous version of Node, set `var.lambda_edge_runtime` to `nodejs12.x`, though be aware
that AWS deprecated that version on March 31, 2023, and lambdas using that environment may no longer work. Otherwise,
this component will attempt to deploy the functions with runtime `nodejs16.x`.

- [See all available runtimes here](https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime)
- [See runtime environment deprecation dates here](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html#runtime-support-policy)
