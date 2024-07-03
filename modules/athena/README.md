# Component: `athena`

This component is responsible for provisioning an Amazon Athena workgroup, databases, and related resources.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

`stacks/catalog/athena/defaults.yaml` file (base component for all Athena deployments with default settings):

```yaml
components:
  terraform:
    athena/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        tags:
          Team: sre
          Service: athena
        create_s3_bucket: true
        create_kms_key: true
        athena_kms_key_deletion_window: 7
        bytes_scanned_cutoff_per_query: null
        enforce_workgroup_configuration: true
        publish_cloudwatch_metrics_enabled: true
        encryption_option: "SSE_KMS"
        s3_output_path: ""
        workgroup_state: "ENABLED"
        database: []
```

```yaml
import:
  - catalog/athena/defaults

components:
  terraform:
    athena/example:
      metadata:
        component: athena
        inherits:
          - athena/defaults
      vars:
        enabled: true
        name: athena-example
        workgroup_description: "My Example Athena Workgroup"
        database:
          - example_db_1
          - example_db_2
```

### CloudTrail Integration

Using Athena with CloudTrail logs is a powerful way to enhance your analysis of AWS service activity. This component
supports creating a CloudTrail table for each account and setting up queries to read CloudTrail logs from a centralized
location.

To set up the CloudTrail Integration, first create the `create` and `alter` queries in Athena with this component. When
`var.cloudtrail_database` is defined, this component will create these queries.

```yaml
import:
  - catalog/athena/defaults

components:
  terraform:
    athena/audit:
      metadata:
        component: athena
        inherits:
          - athena/defaults
      vars:
        enabled: true
        name: athena-audit
        workgroup_description: "Athena Workgroup for Auditing"
        cloudtrail_database: audit
        databases:
          audit:
            comment: "Auditor database for Athena"
            properties: {}
        named_queries:
          platform_dev:
            database: audit
            description: "example query against CloudTrail logs"
            query: |
              SELECT
               useridentity.arn,
               eventname,
               sourceipaddress,
               eventtime
              FROM %s.platform_dev_cloudtrail_logs
              LIMIT 100;
```

Once those are created, run the `create` and then the `alter` queries in the AWS Console to create and then fill the
tables in Athena.

:::info

Athena runs queries with the permissions of the user executing the query. In order to be able to query CloudTrail logs,
the `audit` account must have access to the KMS key used to encrypt CloudTrails logs. Set `var.audit_access_enabled` to
`true` in the `cloudtrail` component

:::

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`athena` | 0.1.1 | [`cloudposse/athena/aws`](https://registry.terraform.io/modules/cloudposse/athena/aws/0.1.1) | n/a
`cloudtrail_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_athena_named_query.cloudtrail_query_alter_tables`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) (resource)
  - [`aws_athena_named_query.cloudtrail_query_create_tables`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) (resource)

### Data Sources

The following data sources are used by this module:


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
  <dt>`databases` (`map(any)`) <i>required</i></dt>
  <dd>
    Map of Athena databases and related configuration.<br/>

    **Type:** `map(any)`
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
  <dt>`athena_kms_key` (`string`) <i>optional</i></dt>
  <dd>
    Use an existing KMS key for Athena if `create_kms_key` is `false`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`athena_kms_key_deletion_window` (`number`) <i>optional</i></dt>
  <dd>
    KMS key deletion window (in days).<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `7`
  </dd>
  <dt>`athena_s3_bucket_id` (`string`) <i>optional</i></dt>
  <dd>
    Use an existing S3 bucket for Athena query results if `create_s3_bucket` is `false`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`bytes_scanned_cutoff_per_query` (`number`) <i>optional</i></dt>
  <dd>
    Integer for the upper data usage limit (cutoff) for the amount of bytes a single query in a workgroup is allowed to scan. Must be at least 10485760.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`cloudtrail_bucket_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the CloudTrail bucket component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"cloudtrail-bucket"`
  </dd>
  <dt>`cloudtrail_database` (`string`) <i>optional</i></dt>
  <dd>
    The name of the Athena Database to use for CloudTrail logs. If set, an Athena table will be created for the CloudTrail trail.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`create_kms_key` (`bool`) <i>optional</i></dt>
  <dd>
    Enable the creation of a KMS key used by Athena workgroup.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`create_s3_bucket` (`bool`) <i>optional</i></dt>
  <dd>
    Enable the creation of an S3 bucket to use for Athena query results<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`data_catalogs` (`map(any)`) <i>optional</i></dt>
  <dd>
    Map of Athena data catalogs and parameters<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`enforce_workgroup_configuration` (`bool`) <i>optional</i></dt>
  <dd>
    Boolean whether the settings for the workgroup override client-side settings.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`named_queries` (`map(map(string))`) <i>optional</i></dt>
  <dd>
    Map of Athena named queries and parameters<br/>
    <br/>
    **Type:** `map(map(string))`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`publish_cloudwatch_metrics_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Boolean whether Amazon CloudWatch metrics are enabled for the workgroup.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`s3_output_path` (`string`) <i>optional</i></dt>
  <dd>
    The S3 bucket path used to store query results.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`workgroup_description` (`string`) <i>optional</i></dt>
  <dd>
    Description of the Athena workgroup.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`workgroup_encryption_option` (`string`) <i>optional</i></dt>
  <dd>
    Indicates whether Amazon S3 server-side encryption with Amazon S3-managed keys (SSE_S3), server-side encryption with KMS-managed keys (SSE_KMS), or client-side encryption with KMS-managed keys (CSE_KMS) is used.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"SSE_KMS"`
  </dd>
  <dt>`workgroup_force_destroy` (`bool`) <i>optional</i></dt>
  <dd>
    The option to delete the workgroup and its contents even if the workgroup contains any named queries.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`workgroup_state` (`string`) <i>optional</i></dt>
  <dd>
    State of the workgroup. Valid values are `DISABLED` or `ENABLED`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ENABLED"`
  </dd></dl>


### Outputs

<dl>
  <dt>`data_catalogs`</dt>
  <dd>
    List of newly created Athena data catalogs.<br/>
  </dd>
  <dt>`databases`</dt>
  <dd>
    List of newly created Athena databases.<br/>
  </dd>
  <dt>`kms_key_arn`</dt>
  <dd>
    ARN of KMS key used by Athena.<br/>
  </dd>
  <dt>`named_queries`</dt>
  <dd>
    List of newly created Athena named queries.<br/>
  </dd>
  <dt>`s3_bucket_id`</dt>
  <dd>
    ID of S3 bucket used for Athena query results.<br/>
  </dd>
  <dt>`workgroup_id`</dt>
  <dd>
    ID of newly created Athena workgroup.<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/athena) -
  Cloud Posse's upstream component
- [Querying AWS CloudTrail logs with AWS Athena](https://docs.aws.amazon.com/athena/latest/ug/cloudtrail-logs.html)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
