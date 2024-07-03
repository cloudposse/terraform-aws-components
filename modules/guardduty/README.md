# Component: `guardduty`

This component is responsible for configuring GuardDuty within an AWS Organization.

AWS GuardDuty is a managed threat detection service. It is designed to help protect AWS accounts and workloads by
continuously monitoring for malicious activities and unauthorized behaviors. To detect potential security threats,
GuardDuty analyzes various data sources within your AWS environment, such as AWS CloudTrail logs, VPC Flow Logs, and DNS
logs.

Key features and components of AWS GuardDuty include:

- Threat detection: GuardDuty employs machine learning algorithms, anomaly detection, and integrated threat intelligence
  to identify suspicious activities, unauthorized access attempts, and potential security threats. It analyzes event
  logs and network traffic data to detect patterns, anomalies, and known attack techniques.

- Threat intelligence: GuardDuty leverages threat intelligence feeds from AWS, trusted partners, and the global
  community to enhance its detection capabilities. It uses this intelligence to identify known malicious IP addresses,
  domains, and other indicators of compromise.

- Real-time alerts: When GuardDuty identifies a potential security issue, it generates real-time alerts that can be
  delivered through AWS CloudWatch Events. These alerts can be integrated with other AWS services like Amazon SNS or AWS
  Lambda for immediate action or custom response workflows.

- Multi-account support: GuardDuty can be enabled across multiple AWS accounts, allowing centralized management and
  monitoring of security across an entire organization's AWS infrastructure. This helps to maintain consistent security
  policies and practices.

- Automated remediation: GuardDuty integrates with other AWS services, such as AWS Macie, AWS Security Hub, and AWS
  Systems Manager, to facilitate automated threat response and remediation actions. This helps to minimize the impact of
  security incidents and reduces the need for manual intervention.

- Security findings and reports: GuardDuty provides detailed security findings and reports that include information
  about detected threats, affected AWS resources, and recommended remediation actions. These findings can be accessed
  through the AWS Management Console or retrieved via APIs for further analysis and reporting.

GuardDuty offers a scalable and flexible approach to threat detection within AWS environments, providing organizations
with an additional layer of security to proactively identify and respond to potential security risks.

## Usage

**Stack Level**: Regional

## Deployment Overview

This component is complex in that it must be deployed multiple times with different variables set to configure the AWS
Organization successfully.

It is further complicated by the fact that you must deploy each of the the component instances described below to every
region that existed before March 2019 and to any regions that have been opted-in as described in the
[AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-regions).

In the examples below, we assume that the AWS Organization Management account is `root` and the AWS Organization
Delegated Administrator account is `security`, both in the `core` tenant.

### Deploy to Delegated Admininstrator Account

First, the component is deployed to the
[Delegated Admininstrator](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html) account in each
region in order to configure the central GuardDuty detector that each account will send its findings to.

```yaml
# core-ue1-security
components:
  terraform:
    guardduty/delegated-administrator/ue1:
      metadata:
        component: guardduty
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: ue1
        region: us-east-1
```

```bash
atmos terraform apply guardduty/delegated-administrator/ue1 -s core-ue1-security
atmos terraform apply guardduty/delegated-administrator/ue2 -s core-ue2-security
atmos terraform apply guardduty/delegated-administrator/uw1 -s core-uw1-security
# ... other regions
```

### Deploy to Organization Management (root) Account

Next, the component is deployed to the AWS Organization Management, a/k/a `root`, Account in order to set the AWS
Organization Designated Admininstrator account.

Note that you must use the `SuperAdmin` permissions as we are deploying to the AWS Organization Managment account. Since
we are using the `SuperAdmin` user, it will already have access to the state bucket, so we set the `role_arn` of the
backend config to null and set `var.privileged` to `true`.

```yaml
# core-ue1-root
components:
  terraform:
    guardduty/root/ue1:
      metadata:
        component: guardduty
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
atmos terraform apply guardduty/root/ue1 -s core-ue1-root
atmos terraform apply guardduty/root/ue2 -s core-ue2-root
atmos terraform apply guardduty/root/uw1 -s core-uw1-root
# ... other regions
```

### Deploy Organization Settings in Delegated Administrator Account

Finally, the component is deployed to the Delegated Administrator Account again in order to create the organization-wide
configuration for the AWS Organization, but with `var.admin_delegated` set to `true` to indicate that the delegation has
already been performed from the Organization Management account.

```yaml
# core-ue1-security
components:
  terraform:
    guardduty/org-settings/ue1:
      metadata:
        component: guardduty
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: use1
        region: us-east-1
        admin_delegated: true
```

```bash
atmos terraform apply guardduty/org-settings/ue1 -s core-ue1-security
atmos terraform apply guardduty/org-settings/ue2 -s core-ue2-security
atmos terraform apply guardduty/org-settings/uw1 -s core-uw1-security
# ... other regions
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 5.0), version: >= 5.0
- [`awsutils`](https://registry.terraform.io/modules/awsutils/>= 0.16.0), version: >= 0.16.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 5.0
- `awsutils`, version: >= 0.16.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`guardduty` | 0.5.0 | [`cloudposse/guardduty/aws`](https://registry.terraform.io/modules/cloudposse/guardduty/aws/0.5.0) | If we are are in the AWS Org designated administrator account, enable the GuardDuty detector and optionally create an SNS topic for notifications and CloudWatch event rules for findings
`guardduty_delegated_detector` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_guardduty_organization_admin_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) (resource)
  - [`aws_guardduty_organization_configuration.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) (resource)
  - [`awsutils_guardduty_organization_settings.this`](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/guardduty_organization_settings) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
    This is for some rare cases where resources want additional configuration of tags<br/>
    and therefore take a list of maps with tag key, value, and additional configuration.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
    in the order they appear in the list. New attributes are appended to the<br/>
    end of the list. The elements of the list are joined by the `delimiter`<br/>
    and treated as a single ID element.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` (`any`) <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** 
    ```hcl
    {
      "additional_tag_map": {},
      "attributes": [],
      "delimiter": null,
      "descriptor_formats": {},
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "labels_as_tags": [
        "unset"
      ],
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {},
      "tenant": null
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between ID elements.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`descriptor_formats` (`any`) <i>optional</i></dt>
  <dd>
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
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** `{}`
  </dd>
  <dt>`enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to prevent the module from creating any resources<br/>
    **Required:** No<br/>
    **Type:** `bool`
    **Default value:** `null`
  </dd>
  <dt>`environment` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for keep the existing setting, which defaults to `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
    Does not affect keys of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The order in which the labels (ID elements) appear in the `id`.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of ID elements (labels) as included in `id`,<br/>
    set as tag values, and output by this module individually.<br/>
    Does not affect values of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`labels_as_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    Set of labels (ID elements) to include as tags in the `tags` output.<br/>
    Default is to include all labels.<br/>
    Tags with empty values will not be included in the `tags` output.<br/>
    Set to `[]` to suppress all generated tags.<br/>
    **Notes:**<br/>
      The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
      changed in later chained modules. Attempts to change it will be silently ignored.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `set(string)`
    **Default value:** 
    ```hcl
    [
      "default"
    ]
    ```
    
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
    This is the only ID element not also included as a `tag`.<br/>
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Terraform regular expression (regex) string.<br/>
    Characters matching the regex will be removed from the ID elements.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
    Neither the tag keys nor the tag values will be modified by this module.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`tenant` (`string`) <i>optional</i></dt>
  <dd>
    ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
</dl>

### Required Inputs

<dl>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`account_map_tenant` (`string`) <i>optional</i></dt>
  <dd>
    The tenant where the `account_map` component required by remote-state is deployed<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"core"`
  </dd>
  <dt>`admin_delegated` (`bool`) <i>optional</i></dt>
  <dd>
      A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the GuardDuty<br/>
      Admininstrator account has already been delegated from the AWS Org Management account (usually 'root'). See the<br/>
      Deployment section of the README for more information.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`auto_enable_organization_members` (`string`) <i>optional</i></dt>
  <dd>
    Indicates the auto-enablement configuration of GuardDuty for the member accounts in the organization. Valid values are `ALL`, `NEW`, `NONE`.<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration#auto_enable_organization_members<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"NEW"`
  </dd>
  <dt>`cloudwatch_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate whether CloudWatch logging should be enabled for GuardDuty<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`cloudwatch_event_rule_pattern_detail_type` (`string`) <i>optional</i></dt>
  <dd>
    The detail-type pattern used to match events that will be sent to SNS.<br/>
    <br/>
    For more information, see:<br/>
    https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html<br/>
    https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html<br/>
    https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"GuardDuty Finding"`
  </dd>
  <dt>`create_sns_topic` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS<br/>
    topic, set this to true and provide a valid configuration for subscribers.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`delegated_admininstrator_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the component that created the GuardDuty detector.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"guardduty/delegated-administrator"`
  </dd>
  <dt>`delegated_administrator_account_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the account that is the AWS Organization Delegated Administrator account<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"core-security"`
  </dd>
  <dt>`finding_publishing_frequency` (`string`) <i>optional</i></dt>
  <dd>
    The frequency of notifications sent for finding occurrences. If the detector is a GuardDuty member account, the value<br/>
    is determined by the GuardDuty master account and cannot be modified, otherwise it defaults to SIX_HOURS.<br/>
    <br/>
    For standalone and GuardDuty master accounts, it must be configured in Terraform to enable drift detection.<br/>
    Valid values for standalone and master accounts: FIFTEEN_MINUTES, ONE_HOUR, SIX_HOURS."<br/>
    <br/>
    For more information, see:<br/>
    https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`findings_notification_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.<br/>
    If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set<br/>
    create_sns_topic to false.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`global_environment` (`string`) <i>optional</i></dt>
  <dd>
    Global environment name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`kubernetes_audit_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, enables Kubernetes audit logs as a data source for Kubernetes protection.<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#audit_logs<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`malware_protection_scan_ec2_ebs_volumes_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Configure whether Malware Protection is enabled as data source for EC2 instances EBS Volumes in GuardDuty.<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#malware-protection<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`organization_management_account_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the AWS Organization management account<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`privileged` (`bool`) <i>optional</i></dt>
  <dd>
    true if the default provider already has access to the backend<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`root_account_stage` (`string`) <i>optional</i></dt>
  <dd>
    The stage name for the Organization root (management) account. This is used to lookup account IDs from account names<br/>
    using the `account-map` component.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`s3_protection_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, enables S3 protection.<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector#s3-logs<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`subscribers` <i>optional</i></dt>
  <dd>
    A map of subscription configurations for SNS topics<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription#argument-reference<br/>
    <br/>
    protocol:<br/>
      The protocol to use. The possible values for this are: sqs, sms, lambda, application. (http or https are partially<br/>
      supported, see link) (email is an option but is unsupported in terraform, see link).<br/>
    endpoint:<br/>
      The endpoint to send data to, the contents will vary with the protocol. (see link for more information)<br/>
    endpoint_auto_confirms:<br/>
      Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty. Default is<br/>
      false.<br/>
    raw_message_delivery:<br/>
      Boolean indicating whether or not to enable raw message delivery (the original message is directly passed, not<br/>
      wrapped in JSON with the original message in the message property). Default is false.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    map(object({
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
  }))
    ```
    
    <br/>
    **Default value:** `{}`
  </dd></dl>


### Outputs

<dl>
  <dt>`delegated_administrator_account_id`</dt>
  <dd>
    The AWS Account ID of the AWS Organization delegated administrator account<br/>
  </dd>
  <dt>`guardduty_detector_arn`</dt>
  <dd>
    The ARN of the GuardDuty detector created by the component<br/>
  </dd>
  <dt>`guardduty_detector_id`</dt>
  <dd>
    The ID of the GuardDuty detector created by the component<br/>
  </dd>
  <dt>`sns_topic_name`</dt>
  <dd>
    The name of the SNS topic created by the component<br/>
  </dd>
  <dt>`sns_topic_subscriptions`</dt>
  <dd>
    The SNS topic subscriptions created by the component<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [AWS GuardDuty Documentation](https://aws.amazon.com/guardduty/)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/guardduty/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
