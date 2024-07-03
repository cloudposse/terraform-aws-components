# Component: `dms/endpoint`

This component provisions DMS endpoints.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
components:
  terraform:
    dms/endpoint/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
          autodeploy: false
      vars:
        enabled: true

    dms-endpoint-source-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: source-example
        endpoint_type: source
        engine_name: aurora-postgresql
        server_name: ""
        database_name: ""
        port: 5432
        extra_connection_attributes: ""
        secrets_manager_access_role_arn: ""
        secrets_manager_arn: ""
        ssl_mode: none
        attributes:
          - source

    dms-endpoint-target-example:
      metadata:
        component: dms/endpoint
        inherits:
          - dms/endpoint/defaults
      vars:
        name: target-example
        endpoint_type: target
        engine_name: s3
        extra_connection_attributes: ""
        s3_settings:
          bucket_name: ""
          bucket_folder: null
          cdc_inserts_only: false
          csv_row_delimiter: " "
          csv_delimiter: ","
          data_format: parquet
          compression_type: GZIP
          date_partition_delimiter: NONE
          date_partition_enabled: true
          date_partition_sequence: YYYYMMDD
          include_op_for_full_load: true
          parquet_timestamp_in_millisecond: true
          timestamp_column_name: timestamp
          service_access_role_arn: ""
        attributes:
          - target
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0), version: >= 1.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.26.0), version: >= 4.26.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.26.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dms_endpoint` | 0.1.1 | [`cloudposse/dms/aws//modules/dms-endpoint`](https://registry.terraform.io/modules/cloudposse/dms/aws/modules/dms-endpoint/0.1.1) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.username`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

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
  <dt>`endpoint_type` (`string`) <i>required</i></dt>
  <dd>
    Type of endpoint. Valid values are `source`, `target`<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`engine_name` (`string`) <i>required</i></dt>
  <dd>
    Type of engine for the endpoint. Valid values are `aurora`, `aurora-postgresql`, `azuredb`, `db2`, `docdb`, `dynamodb`, `elasticsearch`, `kafka`, `kinesis`, `mariadb`, `mongodb`, `mysql`, `opensearch`, `oracle`, `postgres`, `redshift`, `s3`, `sqlserver`, `sybase`<br/>

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
  <dt>`certificate_arn` (`string`) <i>optional</i></dt>
  <dd>
    Certificate ARN<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`database_name` (`string`) <i>optional</i></dt>
  <dd>
    Name of the endpoint database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`elasticsearch_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for OpenSearch settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`extra_connection_attributes` (`string`) <i>optional</i></dt>
  <dd>
    Additional attributes associated with the connection to the source database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kafka_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for Kafka settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`kinesis_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for Kinesis settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`kms_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    (Required when engine_name is `mongodb`, optional otherwise). ARN for the KMS key that will be used to encrypt the connection parameters. If you do not specify a value for `kms_key_arn`, then AWS DMS will use your default encryption key<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`mongodb_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for MongoDB settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`password` (`string`) <i>optional</i></dt>
  <dd>
    Password to be used to login to the endpoint database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`password_path` (`string`) <i>optional</i></dt>
  <dd>
    If set, the path in AWS SSM Parameter Store to fetch the password for the DMS admin user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`port` (`number`) <i>optional</i></dt>
  <dd>
    Port used by the endpoint database<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`redshift_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for Redshift settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`s3_settings` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for S3 settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`secrets_manager_access_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    ARN of the IAM role that specifies AWS DMS as the trusted entity and has the required permissions to access the value in SecretsManagerSecret<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`secrets_manager_arn` (`string`) <i>optional</i></dt>
  <dd>
    Full ARN, partial ARN, or friendly name of the SecretsManagerSecret that contains the endpoint connection details. Supported only for engine_name as aurora, aurora-postgresql, mariadb, mongodb, mysql, oracle, postgres, redshift or sqlserver<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`server_name` (`string`) <i>optional</i></dt>
  <dd>
    Host name of the database server<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`service_access_role` (`string`) <i>optional</i></dt>
  <dd>
    ARN used by the service access IAM role for DynamoDB endpoints<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ssl_mode` (`string`) <i>optional</i></dt>
  <dd>
    The SSL mode to use for the connection. Can be one of `none`, `require`, `verify-ca`, `verify-full`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"none"`
  </dd>
  <dt>`username` (`string`) <i>optional</i></dt>
  <dd>
    User name to be used to login to the endpoint database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`username_path` (`string`) <i>optional</i></dt>
  <dd>
    If set, the path in AWS SSM Parameter Store to fetch the username for the DMS admin user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd></dl>


### Outputs

<dl>
  <dt>`dms_endpoint_arn`</dt>
  <dd>
    DMS endpoint ARN<br/>
  </dd>
  <dt>`dms_endpoint_id`</dt>
  <dd>
    DMS endpoint ID<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dms/modules/dms-endpoint) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
