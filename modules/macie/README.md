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

First, the component is deployed to the
[Delegated Administrator](https://docs.aws.amazon.com/macie/latest/user/accounts-mgmt-ao-integrate.html) account to
configure the central Macie account∑.

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

Note that you must `SuperAdmin` permissions as we are deploying to the AWS Organization Management account. Since we are
using the `SuperAdmin` user, it will already have access to the state bucket, so we set the `role_arn` of the backend
config to null and set `var.privileged` to `true`.

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

Finally, the component is deployed to the Delegated Administrator Account again in order to create the organization-wide
configuration for the AWS Organization, but with `var.admin_delegated` set to `true` to indicate that the delegation has
already been performed from the Organization Management account.

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

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 5.0 |
| `awsutils` | >= 0.17.0 |


## Providers

| Provider | Version |
| --- | --- |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | >= 5.0 |
| [`awsutils`](https://registry.terraform.io/providers/awsutils/latest) | >= 0.17.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | [![1.5.0](https://img.shields.io/badge/1.5.0-success.svg?style=for-the-badge)]([`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state)) | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`iam_roles` | [![latest](https://img.shields.io/badge/latest-success.svg?style=for-the-badge)]([`../account-map/modules/iam-roles`](../account-map/modules/iam-roles)) | [`../account-map/modules/iam-roles`](../account-map/modules/iam-roles) | n/a
`this` | [![0.25.0](https://img.shields.io/badge/0.25.0-success.svg?style=for-the-badge)]([`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0)) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_macie2_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) (resource)(main.tf#36)
  - [`aws_macie2_organization_admin_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_organization_admin_account) (resource)(main.tf#24)
  - [`awsutils_macie2_organization_settings.this`](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/macie2_organization_settings) (resource)(main.tf#29)

## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)

## Outputs

<dl>
  <dt><code>delegated_administrator_account_id</code></dt>
  <dd>

  
  The AWS Account ID of the AWS Organization delegated administrator account<br/>

  </dd>
  <dt><code>macie_account_id</code></dt>
  <dd>

  
  The ID of the Macie account created by the component<br/>

  </dd>
  <dt><code>macie_service_role_arn</code></dt>
  <dd>

  
  The Amazon Resource Name (ARN) of the service-linked role that allows Macie to monitor and analyze data in AWS resources for the account.<br/>

  </dd>
  <dt><code>member_account_ids</code></dt>
  <dd>

  
  The AWS Account IDs of the member accounts<br/>

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


  A flag to indicate if the AWS Organization-wide settings should be created. This can only be done after the GuardDuty<br/>
  Admininstrator account has already been delegated from the AWS Org Management account (usually 'root'). See the<br/>
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


### `delegated_admininstrator_component_name` (`string`) <i>optional</i>


The name of the component that created the Macie account.<br/>

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
>   <code>"macie/delegated-administrator"</code>
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


### `finding_publishing_frequency` (`string`) <i>optional</i>


Specifies how often to publish updates to policy findings for the account. This includes publishing updates to AWS<br/>
Security Hub and Amazon EventBridge (formerly called Amazon CloudWatch Events). For more information, see:<br/>
<br/>
https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_findings_cloudwatch.html#guardduty_findings_cloudwatch_notification_frequency<br/>
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
>   <code>"FIFTEEN_MINUTES"</code>
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


### `member_accounts` (`list(string)`) <i>optional</i>


List of member account names to enable Macie on<br/>

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

- [AWS GuardDuty Documentation](https://aws.amazon.com/guardduty/)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/guardduty/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
