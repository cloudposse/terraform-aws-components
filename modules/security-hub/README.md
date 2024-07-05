# Component: `security-hub`

This component is responsible for configuring Security Hub within an AWS Organization.

Amazon Security Hub enables users to centrally manage and monitor the security and compliance of their AWS accounts and
resources. It aggregates, organizes, and prioritizes security findings from various AWS services, third-party tools, and
integrated partner solutions.

Here are the key features and capabilities of Amazon Security Hub:

- Centralized security management: Security Hub provides a centralized dashboard where users can view and manage
  security findings from multiple AWS accounts and regions. This allows for a unified view of the security posture
  across the entire AWS environment.

- Automated security checks: Security Hub automatically performs continuous security checks on AWS resources,
  configurations, and security best practices. It leverages industry standards and compliance frameworks, such as AWS
  CIS Foundations Benchmark, to identify potential security issues.

- Integrated partner solutions: Security Hub integrates with a wide range of AWS native services, as well as third-party
  security products and solutions. This integration enables the ingestion and analysis of security findings from diverse
  sources, offering a comprehensive security view.

- Security standards and compliance: Security Hub provides compliance checks against industry standards and regulatory
  frameworks, such as PCI DSS, HIPAA, and GDPR. It identifies non-compliant resources and provides guidance on
  remediation actions to ensure adherence to security best practices.

- Prioritized security findings: Security Hub analyzes and prioritizes security findings based on severity, enabling
  users to focus on the most critical issues. It assigns severity levels and generates a consolidated view of security
  alerts, allowing for efficient threat response and remediation.

- Custom insights and event aggregation: Security Hub supports custom insights, allowing users to create their own rules
  and filters to focus on specific security criteria or requirements. It also provides event aggregation and correlation
  capabilities to identify related security findings and potential attack patterns.

- Integration with other AWS services: Security Hub seamlessly integrates with other AWS services, such as AWS
  CloudTrail, Amazon GuardDuty, AWS Config, and AWS IAM Access Analyzer. This integration allows for enhanced
  visibility, automated remediation, and streamlined security operations.

- Alert notifications and automation: Security Hub supports alert notifications through Amazon SNS, enabling users to
  receive real-time notifications of security findings. It also facilitates automation and response through integration
  with AWS Lambda, allowing for automated remediation actions.

By utilizing Amazon Security Hub, organizations can improve their security posture, gain insights into security risks,
and effectively manage security compliance across their AWS accounts and resources.

## Usage

**Stack Level**: Regional

## Deployment Overview

This component is complex in that it must be deployed multiple times with different variables set to configure the AWS
Organization successfully.

It is further complicated by the fact that you must deploy each of the component instances described below to every
region that existed before March 2019 and to any regions that have been opted-in as described in the
[AWS Documentation](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html#concepts-regions).

In the examples below, we assume that the AWS Organization Management account is `root` and the AWS Organization
Delegated Administrator account is `security`, both in the `core` tenant.

### Deploy to Delegated Administrator Account

First, the component is deployed to the
[Delegated Administrator](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_organizations.html) account in each
region to configure the Security Hub instance to which each account will send its findings.

```yaml
# core-ue1-security
components:
  terraform:
    security-hub/delegated-administrator/ue1:
      metadata:
        component: security-hub
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: ue1
        region: us-east-1
```

```bash
atmos terraform apply security-hub/delegated-administrator/ue1 -s core-ue1-security
atmos terraform apply security-hub/delegated-administrator/ue2 -s core-ue2-security
atmos terraform apply security-hub/delegated-administrator/uw1 -s core-uw1-security
# ... other regions
```

### Deploy to Organization Management (root) Account

Next, the component is deployed to the AWS Organization Management (a/k/a `root`) Account in order to set the AWS
Organization Designated Administrator account.

Note that `SuperAdmin` permissions must be used as we are deploying to the AWS Organization Management account. Since we
are using the `SuperAdmin` user, it will already have access to the state bucket, so we set the `role_arn` of the
backend config to null and set `var.privileged` to `true`.

```yaml
# core-ue1-root
components:
  terraform:
    security-hub/root/ue1:
      metadata:
        component: security-hub
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
atmos terraform apply security-hub/root/ue1 -s core-ue1-root
atmos terraform apply security-hub/root/ue2 -s core-ue2-root
atmos terraform apply security-hub/root/uw1 -s core-uw1-root
# ... other regions
```

### Deploy Organization Settings in Delegated Administrator Account

Finally, the component is deployed to the Delegated Administrator Account again in order to create the organization-wide
Security Hub configuration for the AWS Organization, but with `var.admin_delegated` set to `true` this time to indicate
that the delegation from the Organization Management account has already been performed.

```yaml
# core-ue1-security
components:
  terraform:
    security-hub/org-settings/ue1:
      metadata:
        component: security-hub
      vars:
        enabled: true
        delegated_administrator_account_name: core-security
        environment: use1
        region: us-east-1
        admin_delegated: true
```

```bash
atmos terraform apply security-hub/org-settings/ue1 -s core-ue1-security
atmos terraform apply security-hub/org-settings/ue2 -s core-ue2-security
atmos terraform apply security-hub/org-settings/uw1 -s core-uw1-security
# ... other regions
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 5.0 |
| `awsutils` | >= 0.16.0 |


## Providers

| Provider | Version |
| --- | --- |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | >= 5.0 |
| [`awsutils`](https://registry.terraform.io/providers/awsutils/latest) | >= 0.16.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | [![1.5.0](https://img.shields.io/badge/_____1.5.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`iam_roles` | [![latest](https://img.shields.io/badge/____latest-success.svg?style=for-the-badge)](../account-map/modules/iam-roles) | [`../account-map/modules/iam-roles`](../account-map/modules/iam-roles) | n/a
`security_hub` | [![0.10.0](https://img.shields.io/badge/____0.10.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/security-hub/aws/0.10.0) | [`cloudposse/security-hub/aws`](https://registry.terraform.io/modules/cloudposse/security-hub/aws/0.10.0) | If we are running in the AWS Org designated administrator account, enable Security Hub and optionally enable standards and finding aggregation
`this` | [![0.25.0](https://img.shields.io/badge/____0.25.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_securityhub_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) (resource)(main.tf#36)
  - [`aws_securityhub_organization_admin_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_admin_account) (resource)(main.tf#30)
  - [`aws_securityhub_organization_configuration.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration) (resource)(main.tf#72)
  - [`awsutils_security_hub_organization_settings.this`](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_organization_settings) (resource)(main.tf#66)

## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_region.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Outputs

<dl>
  <dt><code>delegated_administrator_account_id</code></dt>
  <dd>

  
  The AWS Account ID of the AWS Organization delegated administrator account<br/>

  </dd>
  <dt><code>sns_topic_name</code></dt>
  <dd>

  
  The name of the SNS topic created by the component<br/>

  </dd>
  <dt><code>sns_topic_subscriptions</code></dt>
  <dd>

  
  The SNS topic subscriptions created by the component<br/>

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
### `account_map_tenant` (`string`) <i>optional</i>


The tenant where the `account_map` component required by remote-state is deployed<br/>

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
>   <code>"core"</code>
>   </dd>
> </dl>
>


### `admin_delegated` (`bool`) <i>optional</i>


  A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the Security<br/>
  Hub Admininstrator account has already been delegated from the AWS Org Management account (usually 'root'). See the<br/>
  Deployment section of the README for more information.<br/>
<br/>

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


### `auto_enable_organization_members` (`bool`) <i>optional</i>


Flag to toggle auto-enablement of Security Hub for new member accounts in the organization.<br/>
<br/>
For more information, see:<br/>
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_organization_configuration#auto_enable<br/>
<br/>

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


### `cloudwatch_event_rule_pattern_detail_type` (`string`) <i>optional</i>


The detail-type pattern used to match events that will be sent to SNS.<br/>
<br/>
For more information, see:<br/>
https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatchEventsandEventPatterns.html<br/>
https://docs.aws.amazon.com/eventbridge/latest/userguide/event-types.html<br/>
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
>   <code>"ecurity Hub Findings - Imported"</code>
>   </dd>
> </dl>
>


### `create_sns_topic` (`bool`) <i>optional</i>


Flag to indicate whether an SNS topic should be created for notifications. If you want to send findings to a new SNS<br/>
topic, set this to true and provide a valid configuration for subscribers.<br/>
<br/>

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


### `default_standards_enabled` (`bool`) <i>optional</i>


Flag to indicate whether default standards should be enabled<br/>

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


### `delegated_administrator_account_name` (`string`) <i>optional</i>


The name of the account that is the AWS Organization Delegated Administrator account<br/>

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
>   <code>"core-security"</code>
>   </dd>
> </dl>
>


### `enabled_standards` (`set(string)`) <i>optional</i>


  A list of standards to enable in the account.<br/>
<br/>
  For example:<br/>
  - standards/aws-foundational-security-best-practices/v/1.0.0<br/>
  - ruleset/cis-aws-foundations-benchmark/v/1.2.0<br/>
  - standards/pci-dss/v/3.2.1<br/>
  - standards/cis-aws-foundations-benchmark/v/1.4.0<br/>
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
>   <code>[]</code>
>   </dd>
> </dl>
>


### `finding_aggregation_region` (`string`) <i>optional</i>


If finding aggreation is enabled, the region that collects findings<br/>

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


### `finding_aggregator_enabled` (`bool`) <i>optional</i>


Flag to indicate whether a finding aggregator should be created<br/>
<br/>
If you want to aggregate findings from one region, set this to `true`.<br/>
<br/>
For more information, see:<br/>
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator<br/>
<br/>

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


### `finding_aggregator_linking_mode` (`string`) <i>optional</i>


Linking mode to use for the finding aggregator.<br/>
<br/>
The possible values are:<br/>
  - `ALL_REGIONS` - Aggregate from all regions<br/>
  - `ALL_REGIONS_EXCEPT_SPECIFIED` - Aggregate from all regions except those specified in `var.finding_aggregator_regions`<br/>
  - `SPECIFIED_REGIONS` - Aggregate from regions specified in `var.finding_aggregator_regions`<br/>
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
>   <code>"ALL_REGIONS"</code>
>   </dd>
> </dl>
>


### `finding_aggregator_regions` (`any`) <i>optional</i>


A list of regions to aggregate findings from.<br/>
<br/>
This is only used if `finding_aggregator_enabled` is `true`.<br/>
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
>   <code>null</code>
>   </dd>
> </dl>
>


### `findings_notification_arn` (`string`) <i>optional</i>


The ARN for an SNS topic to send findings notifications to. This is only used if create_sns_topic is false.<br/>
If you want to send findings to an existing SNS topic, set this to the ARN of the existing topic and set<br/>
create_sns_topic to false.<br/>
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


### `global_environment` (`string`) <i>optional</i>


Global environment name<br/>

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
>   <code>"gbl"</code>
>   </dd>
> </dl>
>


### `import_profile_name` (`string`) <i>optional</i>


AWS Profile name to use when importing a resource<br/>

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


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

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


### `organization_management_account_name` (`string`) <i>optional</i>


The name of the AWS Organization management account<br/>

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


### `privileged` (`bool`) <i>optional</i>


true if the default provider already has access to the backend<br/>

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


### `root_account_stage` (`string`) <i>optional</i>


The stage name for the Organization root (management) account. This is used to lookup account IDs from account names<br/>
using the `account-map` component.<br/>
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
>   <code>"root"</code>
>   </dd>
> </dl>
>


### `subscribers` <i>optional</i>


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
    protocol               = string
    endpoint               = string
    endpoint_auto_confirms = bool
    raw_message_delivery   = bool
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

- [AWS Security Hub Documentation](https://aws.amazon.com/security-hub/)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/security-hub)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
