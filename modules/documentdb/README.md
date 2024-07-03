# Component: `documentdb`

This component is responsible for provisioning DocumentDB clusters.

## Usage

**Stack Level**: Regional

Here is an example snippet for how to use this component:

```yaml
components:
  terraform:
    documentdb:
      backend:
        s3:
          workspace_key_prefix: documentdb
      vars:
        enabled: true
        cluster_size: 3
        engine: docdb
        engine_version: 3.6.0
        cluster_family: docdb3.6
        retention_period: 35
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`random`](https://registry.terraform.io/modules/random/>= 3.0), version: >= 3.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 3.0
- `random`, version: >= 3.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`dns_gbl_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`documentdb_cluster` | 0.14.0 | [`cloudposse/documentdb-cluster/aws`](https://registry.terraform.io/modules/cloudposse/documentdb-cluster/aws/0.14.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.master_password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.master_username`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`random_password.master_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)

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
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region.<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`apply_immediately` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether any cluster modifications are applied immediately, or during the next maintenance window<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`auto_minor_version_upgrade` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether any minor engine upgrades will be applied automatically to the DB instance during the maintenance window or not<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`cluster_family` (`string`) <i>optional</i></dt>
  <dd>
    The family of the DocumentDB cluster parameter group. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-cluster-parameter-group-create.html<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"docdb3.6"`
  </dd>
  <dt>`cluster_parameters` <i>optional</i></dt>
  <dd>
    List of DB parameters to apply<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    apply_method = string
    name         = string
    value        = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`cluster_size` (`number`) <i>optional</i></dt>
  <dd>
    Number of DB instances to create in the cluster<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `3`
  </dd>
  <dt>`db_port` (`number`) <i>optional</i></dt>
  <dd>
    DocumentDB port<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `27017`
  </dd>
  <dt>`deletion_protection_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A value that indicates whether the DB cluster has deletion protection enabled<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`eks_security_group_ingress_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to add the Security Group managed by the EKS cluster in the same regional stack to the ingress allowlist of the DocumentDB cluster.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`enabled_cloudwatch_logs_exports` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of log types to export to cloudwatch. The following log types are supported: `audit`, `error`, `general`, `slowquery`<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`encryption_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether the DB cluster is encrypted<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`engine` (`string`) <i>optional</i></dt>
  <dd>
    The name of the database engine to be used for this DB cluster. Defaults to `docdb`. Valid values: `docdb`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"docdb"`
  </dd>
  <dt>`engine_version` (`string`) <i>optional</i></dt>
  <dd>
    The version number of the database engine to use<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"3.6.0"`
  </dd>
  <dt>`instance_class` (`string`) <i>optional</i></dt>
  <dd>
    The instance class to use. For more details, see https://docs.aws.amazon.com/documentdb/latest/developerguide/db-instance-classes.html#db-instance-class-specs<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"db.r4.large"`
  </dd>
  <dt>`master_username` (`string`) <i>optional</i></dt>
  <dd>
    (Required unless a snapshot_identifier is provided) Username for the master DB user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin1"`
  </dd>
  <dt>`preferred_backup_window` (`string`) <i>optional</i></dt>
  <dd>
    Daily time range during which the backups happen<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"07:00-09:00"`
  </dd>
  <dt>`preferred_maintenance_window` (`string`) <i>optional</i></dt>
  <dd>
    The window to perform maintenance in. Syntax: `ddd:hh24:mi-ddd:hh24:mi`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"Mon:22:00-Mon:23:00"`
  </dd>
  <dt>`retention_period` (`number`) <i>optional</i></dt>
  <dd>
    Number of days to retain backups for<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5`
  </dd>
  <dt>`skip_final_snapshot` (`bool`) <i>optional</i></dt>
  <dd>
    Determines whether a final DB snapshot is created before the DB cluster is deleted<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`snapshot_identifier` (`string`) <i>optional</i></dt>
  <dd>
    Specifies whether or not to create this cluster from a snapshot. You can use either the name or ARN when specifying a DB cluster snapshot, or the ARN when specifying a DB snapshot<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    Amazon Resource Name (ARN) of the cluster<br/>
  </dd>
  <dt>`cluster_name`</dt>
  <dd>
    Cluster Identifier<br/>
  </dd>
  <dt>`endpoint`</dt>
  <dd>
    Endpoint of the DocumentDB cluster<br/>
  </dd>
  <dt>`master_host`</dt>
  <dd>
    DB master hostname<br/>
  </dd>
  <dt>`master_username`</dt>
  <dd>
    Username for the master DB user<br/>
  </dd>
  <dt>`reader_endpoint`</dt>
  <dd>
    A read-only endpoint of the DocumentDB cluster, automatically load-balanced across replicas<br/>
  </dd>
  <dt>`replicas_host`</dt>
  <dd>
    DB replicas hostname<br/>
  </dd>
  <dt>`security_group_arn`</dt>
  <dd>
    ARN of the DocumentDB cluster Security Group<br/>
  </dd>
  <dt>`security_group_id`</dt>
  <dd>
    ID of the DocumentDB cluster Security Group<br/>
  </dd>
  <dt>`security_group_name`</dt>
  <dd>
    Name of the DocumentDB cluster Security Group<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/documentdb) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
