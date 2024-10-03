---
tags:
  - component/aws-config
  - layer/security-and-compliance
  - provider/aws
---

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

> [!WARNING]
>
> #### AWS Config Limitations
>
> You'll also want to be aware of some limitations with AWS Config:
>
> - The maximum number of AWS Config rules that can be evaluated in a single account is 1000.
>   - This can be mitigated by removing rules that are duplicated across packs. You'll have to manually search for these
>     duplicates.
>   - You can also look for rules that do not apply to any resources and remove those. You'll have to manually click
>     through rules in the AWS Config interface to see which rules are not being evaluated.
>   - If you end up still needing more than 1000 rules, one recommendation is to only run packs on a schedule with a
>     lambda that removes the pack after results are collected. If you had different schedule for each day of the week,
>     that would mean 7000 rules over the week. The aggregators would not be able to handle this, so you would need to
>     make sure to store them somewhere else (i.e. S3) so the findings are not lost.
>   - See the
>     [Audit Manager docs](https://aws.amazon.com/blogs/mt/integrate-across-the-three-lines-model-part-2-transform-aws-config-conformance-packs-into-aws-audit-manager-assessments/)
>     if you think you would like to convert conformance packs to custom Audit Manager assessments.
> - The maximum number of AWS Config conformance packs that can be created in a single account is 50.

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

> [!TIP]
>
> #### Using the account default_scope
>
> If default_scope == `account`, AWS Config is regional AWS service, so this component needs to be deployed to all
> regions. If an individual `conformance_packs` item has `scope` set to `organization`, that particular pack will be
> deployed to the organization level.

> [!TIP]
>
> #### Using the organization default_scope
>
> If default_scope == `organization`, AWS Config is global unless overridden in the `conformance_packs` items. You will
> need to update your org to allow the `config-multiaccountsetup.amazonaws.com` service access principal for this to
> work. If you are using our `account` component, just add that principal to the `aws_service_access_principals`
> variable.

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_aws_config"></a> [aws\_config](#module\_aws\_config) | cloudposse/config/aws | 1.1.0 |
| <a name="module_aws_config_label"></a> [aws\_config\_label](#module\_aws\_config\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_aws_team_roles"></a> [aws\_team\_roles](#module\_aws\_team\_roles) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_config_bucket"></a> [config\_bucket](#module\_config\_bucket) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_conformance_pack"></a> [conformance\_pack](#module\_conformance\_pack) | cloudposse/config/aws//modules/conformance-pack | 1.1.0 |
| <a name="module_global_collector_region"></a> [global\_collector\_region](#module\_global\_collector\_region) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_org_conformance_pack"></a> [org\_conformance\_pack](#module\_org\_conformance\_pack) | ./modules/org-conformance-pack | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 1.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_tenant"></a> [account\_map\_tenant](#input\_account\_map\_tenant) | (Optional) The tenant where the account\_map component required by remote-state is deployed. | `string` | `""` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_az_abbreviation_type"></a> [az\_abbreviation\_type](#input\_az\_abbreviation\_type) | AZ abbreviation type, `fixed` or `short` | `string` | `"fixed"` | no |
| <a name="input_central_resource_collector_account"></a> [central\_resource\_collector\_account](#input\_central\_resource\_collector\_account) | The name of the account that is the centralized aggregation account. | `string` | n/a | yes |
| <a name="input_config_bucket_env"></a> [config\_bucket\_env](#input\_config\_bucket\_env) | The environment of the AWS Config S3 Bucket | `string` | n/a | yes |
| <a name="input_config_bucket_stage"></a> [config\_bucket\_stage](#input\_config\_bucket\_stage) | The stage of the AWS Config S3 Bucket | `string` | n/a | yes |
| <a name="input_config_bucket_tenant"></a> [config\_bucket\_tenant](#input\_config\_bucket\_tenant) | (Optional) The tenant of the AWS Config S3 Bucket | `string` | `""` | no |
| <a name="input_conformance_packs"></a> [conformance\_packs](#input\_conformance\_packs) | List of conformance packs. Each conformance pack is a map with the following keys: name, conformance\_pack, parameter\_overrides.<br><br>For example:<br>conformance\_packs = [<br>  {<br>    name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level1"<br>    conformance\_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level1.yaml"<br>    parameter\_overrides   = {<br>      "AccessKeysRotatedParamMaxAccessKeyAge" = "45"<br>    }<br>  },<br>  {<br>    name                  = "Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"<br>    conformance\_pack      = "https://raw.githubusercontent.com/awslabs/aws-config-rules/master/aws-config-conformance-packs/Operational-Best-Practices-for-CIS-AWS-v1.4-Level2.yaml"<br>    parameter\_overrides   = {<br>      "IamPasswordPolicyParamMaxPasswordAge" = "45"<br>    }<br>  }<br>]<br><br>Complete list of AWS Conformance Packs managed by AWSLabs can be found here:<br>https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs | <pre>list(object({<br>    name                = string<br>    conformance_pack    = string<br>    parameter_overrides = map(string)<br>    scope               = optional(string, null)<br>  }))</pre> | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_iam_role"></a> [create\_iam\_role](#input\_create\_iam\_role) | Flag to indicate whether an IAM Role should be created to grant the proper permissions for AWS Config | `bool` | `false` | no |
| <a name="input_default_scope"></a> [default\_scope](#input\_default\_scope) | The default scope of the conformance pack. Valid values are `account` and `organization`. | `string` | `"account"` | no |
| <a name="input_delegated_accounts"></a> [delegated\_accounts](#input\_delegated\_accounts) | The account IDs of other accounts that will send their AWS Configuration or Security Hub data to this account | `set(string)` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment"></a> [global\_environment](#input\_global\_environment) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_global_resource_collector_region"></a> [global\_resource\_collector\_region](#input\_global\_resource\_collector\_region) | The region that collects AWS Config data for global resources such as IAM | `string` | n/a | yes |
| <a name="input_iam_role_arn"></a> [iam\_role\_arn](#input\_iam\_role\_arn) | The ARN for an IAM Role AWS Config uses to make read or write requests to the delivery channel and to describe the<br>AWS resources associated with the account. This is only used if create\_iam\_role is false.<br><br>If you want to use an existing IAM Role, set the variable to the ARN of the existing role and set create\_iam\_role to `false`.<br><br>See the AWS Docs for further information:<br>http://docs.aws.amazon.com/config/latest/developerguide/iamrole-permissions.html | `string` | `null` | no |
| <a name="input_iam_roles_environment_name"></a> [iam\_roles\_environment\_name](#input\_iam\_roles\_environment\_name) | The name of the environment where the IAM roles are provisioned | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | A list of AWS Managed Rules that should be enabled on the account.<br><br>See the following for a list of possible rules to enable:<br>https://docs.aws.amazon.com/config/latest/developerguide/managed-rules-by-aws-config.html<br><br>Example:<pre>managed_rules = {<br>  access-keys-rotated = {<br>    identifier  = "ACCESS_KEYS_ROTATED"<br>    description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is NON_COMPLIANT if the access keys have not been rotated for more than maxAccessKeyAge number of days."<br>    input_parameters = {<br>      maxAccessKeyAge : "90"<br>    }<br>    enabled = true<br>    tags = {}<br>  }<br>}</pre> | <pre>map(object({<br>    description      = string<br>    identifier       = string<br>    input_parameters = any<br>    tags             = map(string)<br>    enabled          = bool<br>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage"></a> [root\_account\_stage](#input\_root\_account\_stage) | The stage name for the Organization root (master) account | `string` | `"root"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_config_configuration_recorder_id"></a> [aws\_config\_configuration\_recorder\_id](#output\_aws\_config\_configuration\_recorder\_id) | The ID of the AWS Config Recorder |
| <a name="output_aws_config_iam_role"></a> [aws\_config\_iam\_role](#output\_aws\_config\_iam\_role) | The ARN of the IAM Role used for AWS Config |
| <a name="output_storage_bucket_arn"></a> [storage\_bucket\_arn](#output\_storage\_bucket\_arn) | Storage Config bucket ARN |
| <a name="output_storage_bucket_id"></a> [storage\_bucket\_id](#output\_storage\_bucket\_id) | Storage Config bucket ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [AWS Config Documentation](https://docs.aws.amazon.com/config/index.html)
- [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aws-config)
- [Conformance Packs documentation](https://docs.aws.amazon.com/config/latest/developerguide/conformance-packs.html)
- [AWS Managed Sample Conformance Packs](https://github.com/awslabs/aws-config-rules/tree/master/aws-config-conformance-packs)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
