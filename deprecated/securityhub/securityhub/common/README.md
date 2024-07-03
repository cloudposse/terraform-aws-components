# Component: `securityhub/common`

This component is responsible for configuring Security Hub and it should be used in tandem with the [securityhub/root](../root) component.

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
    securityhub/common:
      metadata:
        component: securityhub/common
      vars:
        enabled: true
        account_map_tenant: core
        central_resource_collector_account: core-security
        admin_delegated: false
        central_resource_collector_region: us-east-1
        finding_aggregator_enabled: true
        create_sns_topic: true
        enable_default_standards: false
        enabled_standards:
          - standards/cis-aws-foundations-benchmark/v/1.4.0
```

## Deployment

1. Apply `securityhub/common` to all accounts
2. Apply `securityhub/root` to `core-root` account
3. Apply `securityhub/common` to `core-security` with `var.admin_delegated = true`

Example:

```
export regions="use1 use2 usw1 usw2 aps1 apne3 apne2 apne1 apse1 apse2 cac1 euc1 euw1 euw2 euw3 eun1 sae1"

# apply to core-*

export stages="artifacts audit auto corp dns identity network security"
for region in ${regions}; do
  for stage in ${stages}; do
    atmos terraform deploy securityhub/common-${region} -s core-${region}-${stage} || echo "core-${region}-${stage}" >> failures;
  done;
done

# apply to plat-*

export stages="dev prod sandbox staging"
for region in ${regions}; do
  for stage in ${stages}; do
    atmos terraform deploy securityhub/common-${region} -s plat-${region}-${stage} || echo "plat-${region}-${stage}" >> failures;
  done;
done

# apply to "core-root" using "superadmin" privileges

for region in ${regions}; do
  atmos terraform deploy securityhub/root-${region} -s core-${region}-root || echo "core-${region}-root" >> failures;
done

# apply to "core-security" again with "var.admin_delegated=true"

for region in ${regions}; do
  atmos terraform deploy securityhub/common-${region} -s core-${region}-security -var=admin_delegated=true || echo "core-${region}-security" >> failures;
done
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`awsutils`](https://registry.terraform.io/modules/awsutils/>= 0.16.0), version: >= 0.16.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0
- `awsutils`, version: >= 0.16.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.4.2 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.4.2) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`security_hub` | 0.10.0 | [`cloudposse/security-hub/aws`](https://registry.terraform.io/modules/cloudposse/security-hub/aws/0.10.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_securityhub_account.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_account) (resource)
  - [`aws_securityhub_standards_subscription.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_standards_subscription) (resource)
  - [`awsutils_security_hub_organization_settings.this`](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/resources/security_hub_organization_settings) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_partition.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_region.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) (data source)

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
  <dt>`central_resource_collector_account` (`string`) <i>required</i></dt>
  <dd>
    The name of the account that is the centralized aggregation account<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`central_resource_collector_region` (`string`) <i>required</i></dt>
  <dd>
    The region that collects findings<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
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
    **Default value:** `""`
  </dd>
  <dt>`admin_delegated` (`bool`) <i>optional</i></dt>
  <dd>
      A flag to indicate if the Security Hub Admininstrator account has been designated from the root account.<br/>
    <br/>
      This component should be applied with this variable set to `false`, then the securityhub/root component should be applied<br/>
      to designate the administrator account, then this component should be applied again with this variable set to `true`.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`create_sns_topic` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate whether an SNS topic should be created for notifications<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`enable_default_standards` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate whether default standards should be enabled<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`enabled_standards` (`set(string)`) <i>optional</i></dt>
  <dd>
      A list of standards to enable in the account.<br/>
    <br/>
      For example:<br/>
      - standards/aws-foundational-security-best-practices/v/1.0.0<br/>
      - ruleset/cis-aws-foundations-benchmark/v/1.2.0<br/>
      - standards/pci-dss/v/3.2.1<br/>
      - standards/cis-aws-foundations-benchmark/v/1.4.0<br/>
    <br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`finding_aggregator_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate whether a finding aggregator should be created<br/>
    <br/>
    If you want to aggregate findings from one region, set this to `true`.<br/>
    <br/>
    For more information, see:<br/>
    https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_finding_aggregator<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`finding_aggregator_linking_mode` (`string`) <i>optional</i></dt>
  <dd>
    Linking mode to use for the finding aggregator.<br/>
    <br/>
    The possible values are:<br/>
      - `ALL_REGIONS` - Aggregate from all regions<br/>
      - `ALL_REGIONS_EXCEPT_SPECIFIED` - Aggregate from all regions except those specified in `var.finding_aggregator_regions`<br/>
      - `SPECIFIED_REGIONS` - Aggregate from regions specified in `var.finding_aggregator_regions`<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ALL_REGIONS"`
  </dd>
  <dt>`finding_aggregator_regions` (`any`) <i>optional</i></dt>
  <dd>
    A list of regions to aggregate findings from.<br/>
    <br/>
    This is only used if `finding_aggregator_enabled` is `true`.<br/>
    <br/>
    <br/>
    **Type:** `any`
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
  <dt>`privileged` (`bool`) <i>optional</i></dt>
  <dd>
    True if the default provider already has access to the backend<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`root_account_stage` (`string`) <i>optional</i></dt>
  <dd>
    The stage name for the Organization root (management) account<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd></dl>


### Outputs

<dl>
  <dt>`enabled_subscriptions`</dt>
  <dd>
    A list of subscriptions that have been enabled<br/>
  </dd>
  <dt>`sns_topic_name`</dt>
  <dd>
    The SNS topic name that was created<br/>
  </dd>
  <dt>`sns_topic_subscriptions`</dt>
  <dd>
    The SNS topic subscriptions<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [AWS Security Hub Documentation](https://aws.amazon.com/security-hub/)
* [Cloud Posse's upstream component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/securityhub/common/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
