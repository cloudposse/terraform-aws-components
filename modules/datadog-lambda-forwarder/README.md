# Component: `datadog-lambda-forwarder`

This component is responsible for provision all the necessary infrastructure to deploy
[Datadog Lambda forwarders](https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring). It
depends on the `datadog-configuration` component to get the Datadog API keys.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    datadog-lambda-forwarder:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: datadog-lambda-forwarder
        # Set `forwarder_rds_enabled`  to `true` and configure `rds-enhanced-monitoring` Log Group when:
        # 1. The account has RDS instances provisioned
        # 2. RDS Enhanced Monitoring is enabled
        # 3. CloudWatch Log Group `RDSOSMetrics` exists (it will be created by AWS automatically when RDS Enhanced Monitoring is enabled)
        forwarder_rds_enabled: true
        forwarder_log_enabled: true
        forwarder_vpc_logs_enabled: true
        cloudwatch_forwarder_log_groups:
          rds-enhanced-monitoring:
            name: "RDSOSMetrics"
            filter_pattern: ""
          eks-cluster:
            # Use either `name` or `name_prefix` with `name_suffix`
            # If `name_prefix` with `name_suffix` are used, the final `name` will be constructed using `name_prefix` + context + `name_suffix`,
            # e.g. "/aws/eks/eg-ue2-prod-eks-cluster/cluster"
            name_prefix: "/aws/eks/"
            name_suffix: "eks-cluster/cluster"
            filter_pattern: ""
          transfer-sftp:
            name: "/aws/transfer/s-xxxxxxxxxxxx"
            filter_pattern: ""
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `datadog` | >= 3.3.0 |


## Providers

| Provider | Version |
| --- | --- |
| `datadog` | >= 3.3.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`datadog-integration` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`datadog_configuration` | latest | [`../datadog-configuration/modules/datadog_keys`](https://registry.terraform.io/modules/../datadog-configuration/modules/datadog_keys/) | n/a
`datadog_lambda_forwarder` | 1.5.3 | [`cloudposse/datadog-lambda-forwarder/aws`](https://registry.terraform.io/modules/cloudposse/datadog-lambda-forwarder/aws/1.5.3) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`log_group_prefix` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`datadog_integration_aws_lambda_arn.log_collector`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) (resource)(main.tf#105)
  - [`datadog_integration_aws_lambda_arn.rds_collector`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) (resource)(main.tf#91)
  - [`datadog_integration_aws_lambda_arn.vpc_logs_collector`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_lambda_arn) (resource)(main.tf#98)
  - [`datadog_integration_aws_log_collection.main`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/integration_aws_log_collection) (resource)(main.tf#112)

## Data Sources

The following data sources are used by this module:


## Outputs

<dl>
  <dt><code>lambda_forwarder_log_function_arn</code></dt>
  <dd>

  
  Datadog Lambda forwarder CloudWatch/S3 function ARN<br/>

  </dd>
  <dt><code>lambda_forwarder_log_function_name</code></dt>
  <dd>

  
  Datadog Lambda forwarder CloudWatch/S3 function name<br/>

  </dd>
  <dt><code>lambda_forwarder_rds_enhanced_monitoring_function_name</code></dt>
  <dd>

  
  Datadog Lambda forwarder RDS Enhanced Monitoring function name<br/>

  </dd>
  <dt><code>lambda_forwarder_rds_function_arn</code></dt>
  <dd>

  
  Datadog Lambda forwarder RDS Enhanced Monitoring function ARN<br/>

  </dd>
  <dt><code>lambda_forwarder_vpc_log_function_arn</code></dt>
  <dd>

  
  Datadog Lambda forwarder VPC Flow Logs function ARN<br/>

  </dd>
  <dt><code>lambda_forwarder_vpc_log_function_name</code></dt>
  <dd>

  
  Datadog Lambda forwarder VPC Flow Logs function name<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `cloudwatch_forwarder_event_patterns` <i>optional</i>


Map of title => CloudWatch Event patterns to forward to Datadog. Event structure from here: <https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html#CloudWatchEventsPatterns><br/>
Example:<br/>
```hcl<br/>
cloudwatch_forwarder_event_rules = {<br/>
  "guardduty" = {<br/>
    source = ["aws.guardduty"]<br/>
    detail-type = ["GuardDuty Finding"]<br/>
  }<br/>
  "ec2-terminated" = {<br/>
    source = ["aws.ec2"]<br/>
    detail-type = ["EC2 Instance State-change Notification"]<br/>
    detail = {<br/>
      state = ["terminated"]<br/>
    }<br/>
  }<br/>
}<br/>
```<br/>
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
    version     = optional(list(string))
    id          = optional(list(string))
    detail-type = optional(list(string))
    source      = optional(list(string))
    account     = optional(list(string))
    time        = optional(list(string))
    region      = optional(list(string))
    resources   = optional(list(string))
    detail      = optional(map(list(string)))
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `cloudwatch_forwarder_log_groups` (`map(map(string))`) <i>optional</i>


    Map of CloudWatch Log Groups with a filter pattern that the Lambda forwarder will send logs from. For example: { mysql1 = { name = "/aws/rds/maincluster", filter_pattern = "" }<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(map(string))</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `context_tags` (`set(string)`) <i>optional</i>


List of context tags to add to each monitor<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "namespace",
>     "tenant",
>     "environment",
>     "stage"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `context_tags_enabled` (`bool`) <i>optional</i>


Whether to add context tags to add to each monitor<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `datadog_forwarder_lambda_environment_variables` (`map(string)`) <i>optional</i>


Map of environment variables to pass to the Lambda Function<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `dd_api_key_kms_ciphertext_blob` (`string`) <i>optional</i>


CiphertextBlob stored in environment variable DD_KMS_API_KEY used by the lambda function, along with the KMS key, to decrypt Datadog API key<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `dd_artifact_filename` (`string`) <i>optional</i>


The Datadog artifact filename minus extension<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"aws-dd-forwarder"</code>
>   </dd>
> </dl>
>


### `dd_forwarder_version` (`string`) <i>optional</i>


Version tag of Datadog lambdas to use. https://github.com/DataDog/datadog-serverless-functions/releases<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"3.66.0"</code>
>   </dd>
> </dl>
>


### `dd_module_name` (`string`) <i>optional</i>


The Datadog GitHub repository name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"datadog-serverless-functions"</code>
>   </dd>
> </dl>
>


### `dd_tags_map` (`map(string)`) <i>optional</i>


A map of Datadog tags to apply to all logs forwarded to Datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `forwarder_lambda_debug_enabled` (`bool`) <i>optional</i>


Whether to enable or disable debug for the Lambda forwarder<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `forwarder_log_artifact_url` (`string`) <i>optional</i>


The URL for the code of the Datadog forwarder for Logs. It can be a local file, URL or git repo<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `forwarder_log_enabled` (`bool`) <i>optional</i>


Flag to enable or disable Datadog log forwarder<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `forwarder_log_layers` (`list(string)`) <i>optional</i>


List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog log forwarder lambda function<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `forwarder_log_retention_days` (`number`) <i>optional</i>


Number of days to retain Datadog forwarder lambda execution logs. One of [0 1 3 5 7 14 30 60 90 120 150 180 365 400 545 731 1827 3653]<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>14</code>
>   </dd>
> </dl>
>


### `forwarder_rds_artifact_url` (`string`) <i>optional</i>


The URL for the code of the Datadog forwarder for RDS. It can be a local file, url or git repo<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `forwarder_rds_enabled` (`bool`) <i>optional</i>


Flag to enable or disable Datadog RDS enhanced monitoring forwarder<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `forwarder_rds_filter_pattern` (`string`) <i>optional</i>


Filter pattern for Lambda forwarder RDS<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `forwarder_rds_layers` (`list(string)`) <i>optional</i>


List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog RDS enhanced monitoring lambda function<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `forwarder_vpc_logs_artifact_url` (`string`) <i>optional</i>


The URL for the code of the Datadog forwarder for VPC Logs. It can be a local file, url or git repo<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `forwarder_vpc_logs_enabled` (`bool`) <i>optional</i>


Flag to enable or disable Datadog VPC flow log forwarder<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `forwarder_vpc_logs_layers` (`list(string)`) <i>optional</i>


List of Lambda Layer Version ARNs (maximum of 5) to attach to Datadog VPC flow log forwarder lambda function<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `forwarder_vpclogs_filter_pattern` (`string`) <i>optional</i>


Filter pattern for Lambda forwarder VPC Logs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kms_key_id` (`string`) <i>optional</i>


Optional KMS key ID to encrypt Datadog Lambda function logs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `lambda_arn_enabled` (`bool`) <i>optional</i>


Enable adding the Lambda Arn to this account integration<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `lambda_policy_source_json` (`string`) <i>optional</i>


Additional IAM policy document that can optionally be passed and merged with the created policy document<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `lambda_reserved_concurrent_executions` (`number`) <i>optional</i>


Amount of reserved concurrent executions for the lambda function. A value of 0 disables Lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>-1</code>
>   </dd>
> </dl>
>


### `lambda_runtime` (`string`) <i>optional</i>


Runtime environment for Datadog Lambda<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"python3.8"</code>
>   </dd>
> </dl>
>


### `log_collection_services` (`list(string)`) <i>optional</i>


List of log collection services to enable<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "apigw-access-logs",
>     "apigw-execution-logs",
>     "elbv2",
>     "elb",
>     "cloudfront",
>     "lambda",
>     "redshift",
>     "s3"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `s3_bucket_kms_arns` (`list(string)`) <i>optional</i>


List of KMS key ARNs for s3 bucket encryption<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `s3_buckets` (`list(string)`) <i>optional</i>


The names of S3 buckets to forward logs to Datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `s3_buckets_with_prefixes` (`map(object({ bucket_name : string, bucket_prefix : string }))`) <i>optional</i>


The names S3 buckets and prefix to forward logs to Datadog<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(object({ bucket_name : string, bucket_prefix : string }))</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `security_group_ids` (`list(string)`) <i>optional</i>


List of security group IDs to use when the Lambda Function runs in a VPC<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `subnet_ids` (`list(string)`) <i>optional</i>


List of subnet IDs to use when deploying the Lambda Function in a VPC<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tracing_config_mode` (`string`) <i>optional</i>


Can be either PassThrough or Active. If PassThrough, Lambda will only trace the request from an upstream service if it contains a tracing header with 'sampled=1'. If Active, Lambda will respect any tracing header it receives from an upstream service<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"PassThrough"</code>
>   </dd>
> </dl>
>


### `vpclogs_cloudwatch_log_group` (`string`) <i>optional</i>


The name of the CloudWatch Log Group for VPC flow logs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- Datadog's [documentation about provisioning keys](https://docs.datadoghq.com/account_management/api-app-keys
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/datadog-lambda-forwarder) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
