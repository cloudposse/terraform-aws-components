## Components PR [#948](https://github.com/cloudposse/terraform-aws-components/pull/948)

The previous PR [#946](https://github.com/cloudposse/terraform-aws-components/pull/946) introduced the `var.lambda_runtime` input. Previously, the version of node in both submodules was hard-coded to be `nodejs12.x`. The default value should be the latest, recommended version. This PR sets that default to `nodejs20.x`.

If you want to maintain the previous version of node, set `var.lambda_runtime` to `nodejs12.x`. Otherwise, this component will attempt to deploy the functions with runtime `nodejs20.x`.

- [See all available runtimes here](https://docs.aws.amazon.com/lambda/latest/dg/API_CreateFunction.html#SSS-CreateFunction-request-Runtime)
- [See runtime environment deprecation dates here](https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html#runtime-support-policy)
