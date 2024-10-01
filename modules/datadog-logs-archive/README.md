---
tags:
  - component/datadog-logs-archive
  - layer/datadog
  - provider/aws
  - provider/datadog
---

# Component: `datadog-logs-archive`

This component is responsible for provisioning Datadog Log Archives. It creates a single log archive pipeline for each
AWS account. If the `catchall` flag is set, it creates a catchall archive within the same S3 bucket.

Each log archive filters for the tag `env:$env` where $env is the environment/account name (ie sbx, prd, tools, etc), as
well as any tags identified in the additional_tags key. The `catchall` archive, as the name implies, filters for '\*'.

A second bucket is created for cloudtrail, and a cloudtrail is configured to monitor the log archive bucket and log
activity to the cloudtrail bucket. To forward these cloudtrail logs to datadog, the cloudtrail bucket's id must be added
to the s3_buckets key for our datadog-lambda-forwarder component.

Both buckets support object lock, with overridable defaults of COMPLIANCE mode with a duration of 7 days.

## Prerequisites

- Datadog integration set up in target environment
  - We rely on the datadog api and app keys added by our datadog integration component

## Issues, Gotchas, Good-to-Knows

### Destroy/reprovision process

Because of the protections for S3 buckets, if we want to destroy/replace our bucket, we need to do so in two passes or
destroy the bucket manually and then use terraform to clean up the rest. If reprovisioning a recently provisioned
bucket, the two-pass process works well. If the bucket has a full day or more of logs, though, deleting it manually
first will avoid terraform timeouts, and then the terraform process can be used to clean up everything else.

#### Two step process to destroy via terraform

- first set `s3_force_destroy` var to true and apply
- next set `enabled` to false and apply or use tf destroy

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. It's suggested to apply this component to all accounts from
which Datadog receives logs.

```yaml
components:
  terraform:
    datadog-logs-archive:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
  #       additional_query_tags:
  #         - "forwardername:*-dev-datadog-lambda-forwarder-logs"
  #         - "account:123456789012"
```

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.13.0 |
| aws       | >= 2.0    |
| datadog   | >= 3.3.0  |
| local     | >= 1.3    |

## Providers

| Name    | Version  |
| ------- | -------- |
| aws     | >= 2.0   |
| datadog | >= 3.7.0 |
| http    | >= 2.1.0 |

## Modules

| Name                 | Source                              | Version |
| -------------------- | ----------------------------------- | ------- |
| cloudtrail           | cloudposse/cloudtrail/aws           | 0.21.0  |
| cloudtrail_s3_bucket | cloudposse/cloudtrail-s3-bucket/aws | 0.23.1  |
| iam_roles            | ../account-map/modules/iam-roles    | n/a     |
| s3_bucket            | cloudposse/s3-bucket/aws            | 0.46.0  |
| this                 | cloudposse/label/null               | 0.25.0  |

## Resources

| Name                                    | Type        |
| --------------------------------------- | ----------- |
| aws_caller_identity.current             | data source |
| aws_partition.current                   | data source |
| aws_ssm_parameter.datadog_api_key       | data source |
| aws_ssm_parameter.datadog_app_key       | data source |
| aws_ssm_parameter.datadog_aws_role_name | data source |
| aws_ssm_parameter.datadog_external_id   | data source |
| datadog_logs_archive.catchall_archive   | resource    |
| datadog_logs_archive.logs_archive       | resource    |
| http.current_order                      | data source |

## Inputs

| Name                        | Description                                                                                                             | Type     | Default      | Required         |
| --------------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------- | ------------ | ---------------- |
| additional_query_tags       | Additional tags to include in query for logs for this archive                                                           | `list`   | []           | no               |
| catchall                    | Set to true to enable a catchall for logs unmatched by any queries. This should only be used in one environment/account | `bool`   | false        | no               |
| datadog_aws_account_id      | The AWS account ID Datadog's integration servers use for all integrations                                               | `string` | 464622532012 | no               |
| enable_glacier_transition   | Enable/disable transition to glacier. Has no effect unless `lifecycle_rules_enabled` set to true                        | `bool`   | true         | no               |
| glacier_transition_days     | Number of days after which to transition objects to glacier storage                                                     | `number` | 365          | no               |
| lifecycle_rules_enabled     | Enable/disable lifecycle management rules for s3 objects                                                                | `bool`   | true         | no               |
| object_lock_days_archive    | Set duration of archive bucket object lock                                                                              | `number` | 7            | yes              |
| object_lock_days_cloudtrail | Set duration of cloudtrail bucket object lock                                                                           | `number` | 7            | yes              |
| object_lock_mode_archive    | Set mode of archive bucket object lock                                                                                  | `string` | COMPLIANCE   | yes              |
| object_lock_mode_cloudtrail | Set mode of cloudtrail bucket object lock                                                                               | `string` | COMPLIANCE   | yes              |
| s3_force_destroy            | Set to true to delete non-empty buckets when `enabled` is set to false                                                  | `bool`   | false        | for destroy only |

## Outputs

| Name                          | Description                                                 |
| ----------------------------- | ----------------------------------------------------------- |
| archive_id                    | The ID of the environment-specific log archive              |
| bucket_arn                    | The ARN of the bucket used for log archive storage          |
| bucket_domain_name            | The FQDN of the bucket used for log archive storage         |
| bucket_id                     | The ID (name) of the bucket used for log archive storage    |
| bucket_region                 | The region of the bucket used for log archive storage       |
| cloudtrail_bucket_arn         | The ARN of the bucket used for cloudtrail log storage       |
| cloudtrail_bucket_domain_name | The FQDN of the bucket used for cloudtrail log storage      |
| cloudtrail_bucket_id          | The ID (name) of the bucket used for cloudtrail log storage |
| catchall_id                   | The ID of the catchall log archive                          |

## References

- [cloudposse/s3-bucket/aws](https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/latest) - Cloud Posse's S3
  component
- [datadog_logs_archive resource]
  (https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/logs_archive) - Datadog's provider
  documentation for the datadog_logs_archive resource

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
