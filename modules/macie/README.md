# Component: `macie`

This component is responsible for configuring Macie within an AWS Organization.

Amazon Macie is a data security service that discovers sensitive data by using machine learning and pattern matching,
provides visibility into data security risks, and enables automated protection against those risks.

To help you manage the security posture of your organization's Amazon Simple Storage Service (Amazon S3) data estate,
Macie provides you with an inventory of your S3 buckets, and automatically evaluates and monitors the buckets for
security and access control. If Macie detects a potential issue with the security or privacy of your data, such as a
bucket that becomes publicly accessible, Macie generates a finding for you to review and remediate as necessary.

Macie also automates discovery and reporting of sensitive data to provide you with a better understanding of the data
that your organization stores in Amazon S3. To detect sensitive data, you can use built-in criteria and techniques that
Macie provides, custom criteria that you define, or a combination of the two. If Macie detects sensitive data in an S3
object, Macie generates a finding to notify you of the sensitive data that Macie found.

In addition to findings, Macie provides statistics and other data that offer insight into the security posture of your
Amazon S3 data, and where sensitive data might reside in your data estate. The statistics and data can guide your
decisions to perform deeper investigations of specific S3 buckets and objects. You can review and analyze findings,
statistics, and other data by using the Amazon Macie console or the Amazon Macie API. You can also leverage Macie
integration with Amazon EventBridge and AWS Security Hub to monitor, process, and remediate findings by using other
services, applications, and systems.

## Usage

**Stack Level**: Regional

## Deployment Overview

This component is complex in that it must be deployed multiple times with different variables set to configure the AWS
Organization successfully.

In the examples below, we assume that the AWS Organization Management account is `root` and the AWS Organization
Delegated Administrator account is `security`, both in the `core` tenant.

### Deploy to Delegated Administrator Account

First, the component is deployed to the [Delegated
Administrator](https://docs.aws.amazon.com/macie/latest/user/accounts-mgmt-ao-integrate.html) account to configure the
central Macie account∑.

```yaml
# core-ue1-security
components:
  terraform:
    macie/delegated-administrator:
      metadata:
        component: macie
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: ue1
        region: us-east-1
```

```bash
atmos terraform apply macie/delegated-administrator -s core-ue1-security
```

### Deploy to Organization Management (root) Account

Next, the component is deployed to the AWS Organization Management, a/k/a `root`, Account in order to set the AWS
Organization Designated Admininstrator account.

Note that you must `SuperAdmin` permissions as we are deploying to the AWS Organization Management account. Since
we are using the `SuperAdmin` user, it will already have access to the state bucket, so we set the `role_arn` of the
backend config to null and set `var.privileged` to `true`.

```yaml
# core-ue1-root
components:
  terraform:
    guardduty/root:
      metadata:
        component: macie
    backend:
      s3:
        role_arn: null
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: ue1
        region: us-east-1
        privileged: true
```

```bash
atmos terraform apply macie/root -s core-ue1-root
```

### Deploy Organization Settings in Delegated Administrator Account

Finally, the component is deployed to the Delegated Administrator Account again in order to create the
organization-wide configuration for the AWS Organization, but with `var.admin_delegated` set to `true` to indicate that
the delegation has already been performed from the Organization Management account.

```yaml
# core-ue1-security
components:
  terraform:
    macie/org-settings:
      metadata:
        component: macie
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: use1
        region: us-east-1
        admin_delegated: true
```

```bash
atmos terraform apply macie/org-settings/ue1 -s core-ue1-security
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.3 |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | cloudposse/guardduty/aws | 0.5.0 |
| <a name="module_guardduty_delegated_detector"></a> [guardduty\_delegated\_detector](#module\_guardduty\_delegated\_detector) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.3 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [awsutils_guardduty_organization_settings.this](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/guardduty_organization_settings) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_tenant"></a> [account\_map\_tenant](#input\_account\_map\_tenant) | The tenant where the `account_map` component required by remote-state is deployed | `string` | `"core"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_delegated"></a> [admin\_delegated](#input\_admin\_delegated) | A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the GuardDuty<br>  Admininstrator account has already been delegated from the AWS Org Management account (usually 'root'). See the<br>  Deployment section of the README for more information. | `bool` | `false` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auto_enable_organization_members"></a> [auto\_enable\_organization\_members](#input\_auto\_enable\_organization\_members) | Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are `ALL`, `NEW`, `NONE`.<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration#auto_enable_organization_members | `string` | `"NEW"` | no |
| <a name="input_cloudwatch_enabled"></a> [cloudwatch\_enabled](#input\_cloudwatch\_enabled) | Flag to indicate whether CloudWatch logging should be enabled for GuardDuty | `bool` | `false` | no |
| <a name="input_cloudwatch_event_rule_pattern_detail_type"></a> [cloudwatch\_event\_rule\_pattern\_detail\_type](#input\_cloudwatch\_event\_rule\_pattern\_detail\_type) | The detail-type pattern used to match events that will be sent to SNS.<br><br>For more information, see:<br>https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html<br>https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html<br>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html | `string` | `"GuardDuty Finding"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS<br>topic, set this to true and provide a valid configuration for subscribers. | `bool` | `false` | no |
| <a name="input_delegated_admininstrator_component_name"></a> [delegated\_admininstrator\_component\_name](#input\_delegated\_admininstrator\_component\_name) | The name of the component that created the GuardDuty detector. | `string` | `"guardduty/delegated-administrator"` | no |
| <a name="input_delegated_administrator_account_name"></a> [delegated\_administrator\_account\_name](#input\_delegated\_administrator\_account\_name) | The name of the account that is the AWS Organization Delegated Administrator account | `string` | `"core-security"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value<br>is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX\_HOURS.<br><br>For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.<br>Valid values for standalone and master accounts: FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS."<br><br>For more information, see:<br>https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency | `string` | `null` | no |
| <a name="input_findings_notification_arn"></a> [findings\_notification\_arn](#input\_findings\_notification\_arn) | The ARN for an SNS topic to send findings notifications to. This is only used if create\_sns\_topic is false.<br>If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set<br>create\_sns\_topic to false. | `string` | `null` | no |
| <a name="input_global_environment"></a> [global\_environment](#input\_global\_environment) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kubernetes_audit_logs_enabled"></a> [kubernetes\_audit\_logs\_enabled](#input\_kubernetes\_audit\_logs\_enabled) | If `true`, enables Kubernetes audit logs as a data source for Kubernetes protection.<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#audit_logs | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_malware_protection_scan_ec2_ebs_volumes_enabled"></a> [malware\_protection\_scan\_ec2\_ebs\_volumes\_enabled](#input\_malware\_protection\_scan\_ec2\_ebs\_volumes\_enabled) | Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes in GuardDuty.<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#malware-protection | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_organization_management_account_name"></a> [organization\_management\_account\_name](#input\_organization\_management\_account\_name) | The name of the AWS Organization management account | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | true if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage"></a> [root\_account\_stage](#input\_root\_account\_stage) | The stage name for the Organization root (management) account. This is used to lookup account IDs from account names<br>using the `account-map` component. | `string` | `"root"` | no |
| <a name="input_s3_protection_enabled"></a> [s3\_protection\_enabled](#input\_s3\_protection\_enabled) | If `true`, enables S3 protection.<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#s3-logs | `bool` | `true` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subscribers"></a> [subscribers](#input\_subscribers) | A map of subscription configurations for SNS topics<br><br>For more information, see:<br>https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference<br><br>protocol:<br>  The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially<br>  supported, see link) (email is an option but is unsupported in terraform, see link).<br>endpoint:<br>  The endpoint to send data to, the contents will vary with the protocol. (see link for more information)<br>endpoint\_auto\_confirms:<br>  Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is<br>  false.<br>raw\_message\_delivery:<br>  Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not<br>  wrapped in JSON with the original message in the message property). Default is false. | <pre>map(object({<br>    protocol               = string<br>    endpoint               = string<br>    endpoint_auto_confirms = bool<br>    raw_message_delivery   = bool<br>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegated_administrator_account_id"></a> [delegated\_administrator\_account\_id](#output\_delegated\_administrator\_account\_id) | The AWS Account ID of the AWS Organization delegated administrator account |
| <a name="output_guardduty_detector_arn"></a> [guardduty\_detector\_arn](#output\_guardduty\_detector\_arn) | The ARN of the GuardDuty detector created by the component |
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | The ID of the GuardDuty detector created by the component |
| <a name="output_sns_topic_name"></a> [sns\_topic\_name](#output\_sns\_topic\_name) | The name of the SNS topic created by the component |
| <a name="output_sns_topic_subscriptions"></a> [sns\_topic\_subscriptions](#output\_sns\_topic\_subscriptions) | The SNS topic subscriptions created by the component |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [AWS GuardDuty Documentation](https://aws.amazon.com/guardduty/)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/guardduty/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
