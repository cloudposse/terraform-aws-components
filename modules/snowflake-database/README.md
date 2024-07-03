# Component: `snowflake-database`

All data in Snowflake is stored in database tables, logically structured as collections of columns and rows. This
component will create and control a Snowflake database, schema, and set of tables.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    snowflake-database:
      vars:
        enabled: true
        tags:
          Team: data
          Service: snowflake
        tables:
          example:
            comment: "An example table"
            columns:
              - name: "data"
                type: "text"
              - name: "DATE"
                type: "TIMESTAMP_NTZ(9)"
              - name: "extra"
                type: "VARIANT"
                comment: "extra data"
            primary_key:
              name: "pk"
              keys:
                - "data"
        views:
          select-example:
            comment: "An example view"
            statement: |
              select * from "example";
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`snowflake`](https://registry.terraform.io/modules/snowflake/>= 0.25), version: >= 0.25

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 3.0
- `snowflake`, version: >= 0.25

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`introspection` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | introspection module will contain the additional tags
`snowflake_account` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`snowflake_database` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`snowflake_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | Create a standard label to define resource name for Snowflake best practice.
`snowflake_schema` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`snowflake_sequence` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 0.8.1 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/0.8.1) | n/a


### Resources

The following resources are used by this module:

  - [`snowflake_database.this`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/database) (resource)
  - [`snowflake_database_grant.grant`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/database_grant) (resource)
  - [`snowflake_schema.this`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/schema) (resource)
  - [`snowflake_schema_grant.grant`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/schema_grant) (resource)
  - [`snowflake_sequence.this`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/sequence) (resource)
  - [`snowflake_table.tables`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/table) (resource)
  - [`snowflake_table_grant.grant`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/table_grant) (resource)
  - [`snowflake_view.view`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/view) (resource)
  - [`snowflake_view_grant.grant`](https://registry.terraform.io/providers/chanzuckerberg/snowflake/latest/docs/resources/view_grant) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.snowflake_private_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.snowflake_username`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

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
  <dt>`data_retention_time_in_days` (`string`) <i>optional</i></dt>
  <dd>
    Time in days to retain data in Snowflake databases, schemas, and tables by default.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`database_comment` (`string`) <i>optional</i></dt>
  <dd>
    The comment to give to the provisioned database.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"A database created for managing programmatically created Snowflake schemas and tables."`
  </dd>
  <dt>`database_grants` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of Grants to give to the database created with component.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "MODIFY",
      "MONITOR",
      "USAGE"
    ]
    ```
    
  </dd>
  <dt>`required_tags` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of required tag names<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`schema_grants` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of Grants to give to the schema created with component.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "MODIFY",
      "MONITOR",
      "USAGE",
      "CREATE TABLE",
      "CREATE VIEW"
    ]
    ```
    
  </dd>
  <dt>`table_grants` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of Grants to give to the tables created with component.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "SELECT",
      "INSERT",
      "UPDATE",
      "DELETE",
      "TRUNCATE",
      "REFERENCES"
    ]
    ```
    
  </dd>
  <dt>`tables` (`map(any)`) <i>optional</i></dt>
  <dd>
    A map of tables to create for Snowflake. A schema and database will be assigned for this group of tables.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`view_grants` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of Grants to give to the views created with component.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "SELECT",
      "REFERENCES"
    ]
    ```
    
  </dd>
  <dt>`views` (`map(any)`) <i>optional</i></dt>
  <dd>
    A map of views to create for Snowflake. The same schema and database will be assigned as for tables.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd></dl>


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/snowflake-database) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
