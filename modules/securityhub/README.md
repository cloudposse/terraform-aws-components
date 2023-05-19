# Component: `securityhub`

This component is responsible for configuring Security Hub and it should be used in tandem with the [securityhub-root](../securityhub-root) component.

Amazon Security Hub enables users to centrally manage and monitor the security and compliance of their AWS accounts and resources. It aggregates, organizes, and prioritizes security findings from various AWS services, third-party tools, and integrated partner solutions.

Here are the key features and capabilities of Amazon Security Hub:

- Centralized security management: Security Hub provides a centralized dashboard where users can view and manage security findings from multiple AWS accounts and regions. This allows for a unified view of the security posture across the entire AWS environment.

- Automated security checks: Security Hub automatically performs continuous security checks on AWS resources, configurations, and security best practices. It leverages industry standards and compliance frameworks, such as AWS CIS Foundations Benchmark, to identify potential security issues.

- Integrated partner solutions: Security Hub integrates with a wide range of AWS native services, as well as third-party security products and solutions. This integration enables the ingestion and analysis of security findings from diverse sources, offering a comprehensive security view.

- Security standards and compliance: Security Hub provides compliance checks against industry standards and regulatory frameworks, such as PCI DSS, HIPAA, and GDPR. It identifies non-compliant resources and provides guidance on remediation actions to ensure adherence to security best practices.

- Prioritized security findings: Security Hub analyzes and prioritizes security findings based on severity, enabling users to focus on the most critical issues. It assigns severity levels and generates a consolidated view of security alerts, allowing for efficient threat response and remediation.

- Custom insights and event aggregation: Security Hub supports custom insights, allowing users to create their own rules and filters to focus on specific security criteria or requirements. It also provides event aggregation and correlation capabilities to identify related security findings and potential attack patterns.

- Integration with other AWS services: Security Hub seamlessly integrates with other AWS services, such as AWS CloudTrail, Amazon GuardDuty, AWS Config, and AWS IAM Access Analyzer. This integration allows for enhanced visibility, automated remediation, and streamlined security operations.

- Alert notifications and automation: Security Hub supports alert notifications through Amazon SNS, enabling users to receive real-time notifications of security findings. It also facilitates automation and response through integration with AWS Lambda, allowing for automated remediation actions.

By utilizing Amazon Security Hub, organizations can improve their security posture, gain insights into security risks, and effectively manage security compliance across their AWS accounts and resources.

## Usage

**Stack Level**: Regional

The example snippet below shows how to use this component:

```yaml
components:
  terraform:
    securityhub:
      metadata:
        component: securityhub
      vars:
        enabled: true
        region: us-east-2
        environment: ue2
        account_map_tenant: core
        central_resource_collector_account: core-security
        admin_delegated: true
        central_logging_account: core-audit
        global_resource_collector_region: us-east-2
        create_sns_topic: false
        enabled_standards:
          - ruleset/cis-aws-foundations-benchmark/v/1.2.0
          - standards/aws-foundational-security-best-practices/v/1.0.0
        opsgenie_sns_topic_subscription_enabled: false
        opsgenie_integration_uri_ssm_account: core-corp
        opsgenie_integration_uri_ssm_region: us-east-2
```

## Deployment

This set of steps assumes that `var.central_resource_collector_account = "core-security"`.

1. Apply `securityhub` to `core-security` with `var.admin_delegated = false`
2. Apply `securityhub-root` to `core-root`
3. Apply `securityhub` to `core-security` with `var.admin_delegated = true`

Example:

```
# Apply securityhub to all regions in core-security
atmos terraform apply securityhub-ue2 -s core-ue2-security -var=admin_delegated=false
atmos terraform apply securityhub-ue1 -s core-ue1-security -var=admin_delegated=false
atmos terraform apply securityhub-uw1 -s core-uw1-security -var=admin_delegated=false
# ... other regions

# Apply securityhub-root to all regions in core-root
atmos terraform apply securityhub-root-ue2 -s core-ue2-root
atmos terraform apply securityhub-root-ue1 -s core-ue1-root
atmos terraform apply securityhub-root-uw1 -s core-uw1-root
# ... other regions

# Apply securityhub to all regions in core-security but with default values for admin_delegated
atmos terraform apply securityhub-ue2 -s core-ue2-security
atmos terraform apply securityhub-ue1 -s core-ue1-security
atmos terraform apply securityhub-uw1 -s core-uw1-security
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
| <a name="provider_aws.ssm"></a> [aws.ssm](#provider\_aws.ssm) | >= 4.0 |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.2 |
| <a name="module_control_disablements"></a> [control\_disablements](#module\_control\_disablements) | cloudposse/security-hub/aws//modules/control-disablements | 0.9.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_security_hub"></a> [security\_hub](#module\_security\_hub) | cloudposse/security-hub/aws | 0.9.0 |
| <a name="module_securityhub_opsgenie_integration_ssm_role"></a> [securityhub\_opsgenie\_integration\_ssm\_role](#module\_securityhub\_opsgenie\_integration\_ssm\_role) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [awsutils_security_hub_control_disablement.ec2_multiple_enis](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_control_disablement) | resource |
| [awsutils_security_hub_control_disablement.global](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_control_disablement) | resource |
| [awsutils_security_hub_control_disablement.hardware_mfa_cis](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_control_disablement) | resource |
| [awsutils_security_hub_control_disablement.hardware_mfa_foundational](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_control_disablement) | resource |
| [awsutils_security_hub_organization_settings.this](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_organization_settings) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_partition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_ssm_parameter.opsgenie_integration_uri](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_tenant"></a> [account\_map\_tenant](#input\_account\_map\_tenant) | The tenant where the `account_map` component required by remote-state is deployed | `string` | `""` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_delegated"></a> [admin\_delegated](#input\_admin\_delegated) | A flag to indicate if the Security Hub Admininstrator account has been designated from the root account.<br><br>  This component should be applied with this variable set to false, then the securityhub-root component should be applied<br>  to designate the administrator account, then this component should be applied again with this variable set to `true`. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_central_logging_account"></a> [central\_logging\_account](#input\_central\_logging\_account) | The name of the account that is the centralized logging account. The config rules associated with logging in the <br>catalog (loggingAccountOnly: true) will be installed only in this account. | `string` | n/a | yes |
| <a name="input_central_resource_collector_account"></a> [central\_resource\_collector\_account](#input\_central\_resource\_collector\_account) | The name of the account that is the centralized aggregation account | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_sns_topic"></a> [create\_sns\_topic](#input\_create\_sns\_topic) | Flag to indicate whether an SNS topic should be created for notifications | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_standards"></a> [enabled\_standards](#input\_enabled\_standards) | A list of standards to enable in the account | `set(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment"></a> [global\_environment](#input\_global\_environment) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_global_resource_collector_region"></a> [global\_resource\_collector\_region](#input\_global\_resource\_collector\_region) | The region that collects AWS Config data for global resources such as IAM | `string` | n/a | yes |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_opsgenie_integration_uri_key"></a> [opsgenie\_integration\_uri\_key](#input\_opsgenie\_integration\_uri\_key) | The key of the SSM Parameter containing the OpsGenie AmazonSecurityHub API Integration Webhook URI.<br>Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`. | `string` | `"opsgenie_securityhub_uri"` | no |
| <a name="input_opsgenie_integration_uri_key_pattern"></a> [opsgenie\_integration\_uri\_key\_pattern](#input\_opsgenie\_integration\_uri\_key\_pattern) | The format string (%v will be replaced by the var.opsgenie\_webhook\_uri\_key) for the<br>key of the SSM Parameter containing the OpsGenie AmazonSecurityHub API Integration Webhook URI.<br>Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`. | `string` | `"/opsgenie/%v"` | no |
| <a name="input_opsgenie_integration_uri_ssm_account"></a> [opsgenie\_integration\_uri\_ssm\_account](#input\_opsgenie\_integration\_uri\_ssm\_account) | Account (stage) holding the SSM Parameter for the OpsGenie AmazonSecurityHub API Integration URI.<br>Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`. | `string` | n/a | yes |
| <a name="input_opsgenie_integration_uri_ssm_region"></a> [opsgenie\_integration\_uri\_ssm\_region](#input\_opsgenie\_integration\_uri\_ssm\_region) | SSM Parameter Store AWS region for the OpsGenie AmazonSecurityHub API Integration URI.<br>Used if `var.opsgenie_sns_topic_subscription_enabled` is set to `true`. | `string` | n/a | yes |
| <a name="input_opsgenie_sns_topic_subscription_enabled"></a> [opsgenie\_sns\_topic\_subscription\_enabled](#input\_opsgenie\_sns\_topic\_subscription\_enabled) | Flag to indicate whether OpsGenie should be subscribed to SecurityHub notifications | `bool` | `false` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage"></a> [root\_account\_stage](#input\_root\_account\_stage) | The stage name for the Organization root (master) account | `string` | `"root"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [AWS Security Hub Documentation](https://aws.amazon.com/security-hub/)
* [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/securityhub/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)