# Component: `aws-config`

This component is responsible for configuring AWS Config.

AWS Config service enables you to track changes to your AWS resources over time. It continuously monitors and records
configuration changes to your AWS resources and provides you with a detailed view of the relationships between those
resources. With AWS Config, you can assess, audit, and evaluate the configurations of your AWS resources for compliance,
security, and governance purposes.

Some of the key features of AWS Config include:

- Configuration history: AWS Config maintains a detailed history of changes to your AWS resources, allowing you to see
  when changes were made, who made them, and what the changes were.
- Configuration snapshots: AWS Config can take periodic snapshots of your AWS resources configurations, giving you a
  point-in-time view of their configuration.
- Compliance monitoring: AWS Config provides a range of pre-built rules and checks to monitor your resources for
  compliance with best practices and industry standards.
- Relationship mapping: AWS Config can map the relationships between your AWS resources, enabling you to see how changes
  to one resource can impact others.
- Notifications and alerts: AWS Config can send notifications and alerts when changes are made to your AWS resources
  that could impact their compliance or security posture.

:::caution AWS Config Limitations

You'll also want to be aware of some limitations with AWS Config:

- The maximum number of AWS Config rules that can be evaluated in a single account is 1000.
  - This can be mitigated by removing rules that are duplicated across packs. You'll have to manually search for these
    duplicates.
  - You can also look for rules that do not apply to any resources and remove those. You'll have to manually click
    through rules in the AWS Config interface to see which rules are not being evaluated.
  - If you end up still needing more than 1000 rules, one recommendation is to only run packs on a schedule with a
    lambda that removes the pack after results are collected. If you had different schedule for each day of the week,
    that would mean 7000 rules over the week. The aggregators would not be able to handle this, so you would need to
    make sure to store them somewhere else (i.e. S3) so the findings are not lost.
  - See the
    [Audit Manager docs](https://aws.amazon.com/blogs/mt/integrate-across-the-three-lines-model-part-2-transform-aws-config-conformance-packs-into-aws-audit-manager-assessments/)
    if you think you would like to convert conformance packs to custom Audit Manager assessments.
- The maximum number of AWS Config conformance packs that can be created in a single account is 50.

:::

Overall, AWS Config provides you with a powerful toolset to help you monitor and manage the configurations of your AWS
resources, ensuring that they remain compliant, secure, and properly configured over time.

## Prerequisites

As part of
[CIS AWS Foundations 1.20](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#securityhub-cis-controls-1.20),
this component assumes that a designated support IAM role with the following permissions has been deployed to every
account in the organization:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowSupport",
      "Effect": "Allow",
      "Action": ["support:*"],
      "Resource": "*"
    },
    {
      "Sid": "AllowTrustedAdvisor",
      "Effect": "Allow",
      "Action": "trustedadvisor:Describe*",
      "Resource": "*"
    }
  ]
}
```

Before deploying this AWS Config component `config-bucket` and `cloudtrail-bucket` should be deployed first.

## Usage

**Stack Level**: Regional or Global

This component has a `default_scope` variable for configuring if it will be an organization-wide or account-level
component by default. Note that this can be overridden by the `scope` variable in the `conformance_packs` items.

:::info Using the account default_scope

If default_scope == `account`, AWS Config is regional AWS service, so this component needs to be deployed to all
regions. If an individual `conformance_packs` item has `scope` set to `organization`, that particular pack will be
deployed to the organization level.

:::

:::info Using the organization default_scope

If default_scope == `organization`, AWS Config is global unless overriden in the `conformance_packs` items. You will
need to update your org to allow the `config-multiaccountsetup.amazonaws.com` service access principal for this to work.
If you are using our `account` component, just add that principal to the `aws_service_access_principals` variable.

:::

At the AWS Organizational level, the Components designate an account to be the `central collection account` and a single
region to be the `central collection region` so that compliance information can be aggregated into a central location.

Logs are typically written to the `audit` account and AWS Config deployed into to the `security` account.

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    aws-config:
      vars:
        enabled: true
        account_map_tenant: core
        az_abbreviation_type: fixed
        # In each AWS account, an IAM role should be created in the main region.
        # If the main region is set to us-east-1, the value of the var.create_iam_role variable should be true.
        # For all other regions, the value of var.create_iam_role should be false.
        create_iam_role: false
        central_resource_collector_account: core-security
        global_resource_collector_region: us-east-1
        config_bucket_env: ue1
        config_bucket_stage: audit
        config_bucket_tenant: core
        conformance_packs:
          - name: Operational-Best-Practices-for-CIS-AWS-v1.4-Level2
            conformance_pack: https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml
            parameter_overrides:
              AccessKeysRotatedParamMaxAccessKeyAge: '45'
          - name: Operational-Best-Practices-for-HIPAA-Security.yaml
            conformance_pack: https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-HIPAA-Security.yaml
            parameter_overrides:
          ...
          (etc)
        managed_rules:
          access-keys-rotated:
            identifier: ACCESS_KEYS_ROTATED
            description: "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."
            input_parameters:
              maxAccessKeyAge: "30"
            enabled: true
            tags: { }
```

## Deployment

Apply to your central region security account

```sh
atmos terraform plan aws-config-{central-region} --stack core-{central-region}-security -var=create_iam_role=true
```

For example when central region is `us-east-1`:

```sh
atmos terraform plan aws-config-ue1 --stack core-ue1-security -var=create_iam_role=true
```

Apply aws-config to all stacks in all stages.

```sh
atmos terraform plan aws-config-{each region} --stack {each region}-{each stage}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `awsutils` | >= 0.16.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`aws_config` | 1.1.0 | [`cloudposse/config/aws`](https://registry.terraform.io/modules/cloudposse/config/aws/1.1.0) | n/a
`aws_config_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`aws_team_roles` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`config_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`conformance_pack` | 1.1.0 | [`cloudposse/config/aws//modules/conformance-pack`](https://registry.terraform.io/modules/cloudposse/config/aws/modules/conformance-pack/1.1.0) | n/a
`global_collector_region` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`org_conformance_pack` | latest | [`./modules/org-conformance-pack`](https://registry.terraform.io/modules/./modules/org-conformance-pack/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 1.3.0 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/1.3.0) | n/a


## Resources

The following resources are used by this module:


## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_partition.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_region.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

## Outputs

<dl>
  <dt><code>aws_config_configuration_recorder_id</code></dt>
  <dd>
    The ID of the AWS Config Recorder<br/>

  </dd>
  <dt><code>aws_config_iam_role</code></dt>
  <dd>
    The ARN of the IAM Role used for AWS Config<br/>

  </dd>
  <dt><code>storage_bucket_arn</code></dt>
  <dd>
    Storage Config bucket ARN<br/>

  </dd>
  <dt><code>storage_bucket_id</code></dt>
  <dd>
    Storage Config bucket ID<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `central_resource_collector_account` (`string`) <i>required</i>


The name of the account that is the centralized aggregation account.<br/>

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


### `config_bucket_env` (`string`) <i>required</i>


The environment of the AWS Config S3 Bucket<br/>

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


### `config_bucket_stage` (`string`) <i>required</i>


The stage of the AWS Config S3 Bucket<br/>

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


### `global_resource_collector_region` (`string`) <i>required</i>


The region that collects AWS Config data for global resources such as IAM<br/>

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


### `region` (`string`) <i>required</i>


AWS Region<br/>

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
### `account_map_tenant` (`string`) <i>optional</i>


(Optional) The tenant where the account_map component required by remote-state is deployed.<br/>

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


### `az_abbreviation_type` (`string`) <i>optional</i>


AZ abbreviation type, `fixed` or `short`<br/>

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
>    <code>"fixed"</code>
>   </dd>
> </dl>
>


### `config_bucket_tenant` (`string`) <i>optional</i>


(Optional) The tenant of the AWS Config S3 Bucket<br/>

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


### `conformance_packs` <i>optional</i>


List of conformance packs. Each conformance pack is a map with the following keys: name, conformance_pack, parameter_overrides.<br/>
<br/>
For example:<br/>
conformance_packs = [<br/>
  {<br/>
    name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level1"<br/>
    conformance_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level1.yaml"<br/>
    parameter_overrides   = {<br/>
      "AccessKeysRotatedParamMaxAccessKeyAge" = "45"<br/>
    }<br/>
  },<br/>
  {<br/>
    name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"<br/>
    conformance_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml"<br/>
    parameter_overrides   = {<br/>
      "IamPasswordPolicyParamMaxPasswordAge" = "45"<br/>
    }<br/>
  }<br/>
]<br/>
<br/>
Complete list of AWS Conformance Packs managed by AWSLabs can be found here:<br/>
https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs<br/>
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
    name                = string
    conformance_pack    = string
    parameter_overrides = map(string)
    scope               = optional(string, null)
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


### `create_iam_role` (`bool`) <i>optional</i>


Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config<br/>

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


### `default_scope` (`string`) <i>optional</i>


The default scope of the conformance pack. Valid values are `account` and `organization`.<br/>

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
>    <code>"account"</code>
>   </dd>
> </dl>
>


### `delegated_accounts` (`set(string)`) <i>optional</i>


The account IDs of other accounts that will send their AWS Configuration or Security Hub data to this account<br/>

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
>    <code>null</code>
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
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"gbl"</code>
>   </dd>
> </dl>
>


### `iam_role_arn` (`string`) <i>optional</i>


The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the<br/>
AWS resources associated with the account. This is only used if create_iam_role is false.<br/>
<br/>
If you want to use an existing IAM Role, set the variable to the ARN of the existing role and set create_iam_role to `false`.<br/>
<br/>
See the AWS Docs for further information:<br/>
http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html<br/>
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


### `iam_roles_environment_name` (`string`) <i>optional</i>


The name of the environment where the IAM roles are provisioned<br/>

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


### `managed_rules` <i>optional</i>


A list of AWS Managed Rules that should be enabled on the account.<br/>
<br/>
See the following for a list of possible rules to enable:<br/>
https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html<br/>
<br/>
Example:<br/>
```<br/>
managed_rules = {<br/>
  access-keys-rotated = {<br/>
    identifier  = "ACCESS_KEYS_ROTATED"<br/>
    description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."<br/>
    input_parameters = {<br/>
      maxAccessKeyAge : "90"<br/>
    }<br/>
    enabled = true<br/>
    tags = {}<br/>
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
    description      = string
    identifier       = string
    input_parameters = any
    tags             = map(string)
    enabled          = bool
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


### `privileged` (`bool`) <i>optional</i>


True if the default provider already has access to the backend<br/>

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


### `root_account_stage` (`string`) <i>optional</i>


The stage name for the Organization root (master) account<br/>

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
>    <code>"root"</code>
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

## References

- [AWS Config Documentation](https://docs.aws.amazon.com/config/index.html)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aws-config)
- [Conformance Packs documentation](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html)
- [AWS Managed Sample Conformance Packs](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
