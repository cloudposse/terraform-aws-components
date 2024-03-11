## PR [#814](https://github.com/cloudposse/terraform-aws-components/pull/814)

### Possible Breaking Change

The `module "datadog_integration"` and `module "store_write"` had been changed in an earlier PR from a module without a
`count` to a module with a `count` of zero or one. This PR changes it back to a module without a count. If you were
using the module with a `count` of zero or one, applying this new version will cause it be destroyed and recreated. This
should only cause a very brief outage in your Datadog monitoring.

### New Integration Options

This PR adds the following new integration options:

- `cspm_resource_collection_enabled` - Enable Datadog Cloud Security Posture Management scanning of your AWS account.
  See [announcement](https://www.datadoghq.com/product/cloud-security-management/cloud-security-posture-management/) for
  details.
- `metrics_collection_enabled` - When enabled, a metric-by-metric crawl of the CloudWatch API pulls data and sends it to
  Datadog. New metrics are pulled every ten minutes, on average.
- `resource_collection_enabled` - Some Datadog products leverage information about how your AWS resources ( such as S3
  Buckets, RDS snapshots, and CloudFront distributions) are configured. When `resource_collection_enabled` is `true`,
  Datadog collects this information by making read-only API calls into your AWS account.
