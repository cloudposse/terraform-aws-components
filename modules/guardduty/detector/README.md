# Component: `guardduty/detector`

This component is responsible for configuring GuardDuty and it should be used in tandem with the [guardduty/root](../root) component.

AWS GuardDuty is a managed threat detection service. It is designed to help protect AWS accounts and workloads by continuously monitoring for malicious activities and unauthorized behaviors. GuardDuty analyzes various data sources within your AWS environment, such as AWS CloudTrail logs, VPC Flow Logs, and DNS logs, to detect potential security threats.

Key features and components of AWS GuardDuty include:

- Threat detection: GuardDuty employs machine learning algorithms, anomaly detection, and integrated threat intelligence to identify suspicious activities, unauthorized access attempts, and potential security threats. It analyzes event logs and network traffic data to detect patterns, anomalies, and known attack techniques.

- Threat intelligence: GuardDuty leverages threat intelligence feeds from AWS, trusted partners, and the global community to enhance its detection capabilities. It uses this intelligence to identify known malicious IP addresses, domains, and other indicators of compromise.

- Real-time alerts: When GuardDuty identifies a potential security issue, it generates real-time alerts that can be delivered through AWS CloudWatch Events. These alerts can be integrated with other AWS services like Amazon SNS or AWS Lambda for immediate action or custom response workflows.

- Multi-account support: GuardDuty can be enabled across multiple AWS accounts, allowing centralized management and monitoring of security across an entire organization's AWS infrastructure. This helps to maintain consistent security policies and practices.

- Automated remediation: GuardDuty integrates with other AWS services, such as AWS Macie, AWS Security Hub, and AWS Systems Manager, to facilitate automated threat response and remediation actions. This helps to minimize the impact of security incidents and reduces the need for manual intervention.

- Security findings and reports: GuardDuty provides detailed security findings and reports that include information about detected threats, affected AWS resources, and recommended remediation actions. These findings can be accessed through the AWS Management Console or retrieved via APIs for further analysis and reporting.

GuardDuty offers a scalable and flexible approach to threat detection within AWS environments, providing organizations with an additional layer of security to proactively identify and respond to potential security risks.

## Usage

**Stack Level**: Regional

The example snippet below shows how to use this component:

```yaml
components:
  terraform:
    guardduty/detector:
      metadata:
        component: guardduty/detector
      vars:
        enabled: true
        account_map_tenant: core
        central_resource_collector_account: core-security
        region: us-east-2
        environment: ue2
        admin_delegated: true
```

## Deployment

This set of steps assumes that `var.central_resource_collector_account = "core-security"`.

1. Apply `guardduty/detector` to `core-security` with `var.admin_delegated = false`
2. Apply `guardduty/root` to `core-root`
3. Apply `guardduty/detector` to `core-security` with `var.admin_delegated = true`

Example:

```
# Apply guardduty/detector to all regions in core-security
atmos terraform apply guardduty/detector-ue2 -s core-ue2-security -var=admin_delegated=false
atmos terraform apply guardduty/detector-ue1 -s core-ue1-security -var=admin_delegated=false
atmos terraform apply guardduty/detector-uw1 -s core-uw1-security -var=admin_delegated=false
# ... other regions

# Apply guardduty/root to all regions in core-root
atmos terraform apply guardduty/root-ue2 -s core-ue2-root
atmos terraform apply guardduty/root-ue1 -s core-ue1-root
atmos terraform apply guardduty/root-uw1 -s core-uw1-root
# ... other regions

# Apply guardduty/detector to all regions in core-security but with default values for admin_delegated
atmos terraform apply guardduty/detector-ue2 -s core-ue2-security
atmos terraform apply guardduty/detector-ue1 -s core-ue1-security
atmos terraform apply guardduty/detector-uw1 -s core-uw1-security
# ... other regions
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
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.2 |
| <a name="module_guardduty"></a> [guardduty](#module\_guardduty) | cloudposse/guardduty/aws | 0.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [awsutils_guardduty_organization_settings.this](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/guardduty_organization_settings) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_tenant"></a> [account\_map\_tenant](#input\_account\_map\_tenant) | The tenant where the `account_map` component required by remote-state is deployed | `string` | `""` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_delegated"></a> [admin\_delegated](#input\_admin\_delegated) | A flag to indicate if the GuardDuty Admininstrator account has been designated from the root account.<br><br>  This component should be applied with this variable set to false, then the guardduty/root component should be applied<br>  to designate the administrator account, then this component should be applied again with this variable set to `true`. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_central_resource_collector_account"></a> [central\_resource\_collector\_account](#input\_central\_resource\_collector\_account) | The name of the account that is the centralized aggregation account | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment"></a> [global\_environment](#input\_global\_environment) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
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
| <a name="output_guardduty_detector_arn"></a> [guardduty\_detector\_arn](#output\_guardduty\_detector\_arn) | GuardDuty detector ARN |
| <a name="output_guardduty_detector_id"></a> [guardduty\_detector\_id](#output\_guardduty\_detector\_id) | GuardDuty detector ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [AWS Config Documentation](https://aws.amazon.com/guardduty/)
* [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/guardduty/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
