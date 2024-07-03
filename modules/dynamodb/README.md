# Component: `dynamodb`

This component is responsible for provisioning a DynamoDB table.

## Usage

**Stack Level**: Regional

Here is an example snippet for how to use this component:

```yaml
components:
  terraform:
    dynamodb:
      backend:
        s3:
          workspace_key_prefix: dynamodb
      vars:
        enabled: true
        hash_key: HashKey
        range_key: RangeKey
        billing_mode: PAY_PER_REQUEST
        autoscaler_enabled: false
        encryption_enabled: true
        point_in_time_recovery_enabled: true
        streams_enabled: false
        ttl_enabled: false
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dynamodb_table` | 0.36.0 | [`cloudposse/dynamodb/aws`](https://registry.terraform.io/modules/cloudposse/dynamodb/aws/0.36.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a




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
  <dt>`hash_key` (`string`) <i>required</i></dt>
  <dd>
    DynamoDB table Hash Key<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
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
  <dt>`autoscale_max_read_capacity` (`number`) <i>optional</i></dt>
  <dd>
    DynamoDB autoscaling max read capacity<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `20`
  </dd>
  <dt>`autoscale_max_write_capacity` (`number`) <i>optional</i></dt>
  <dd>
    DynamoDB autoscaling max write capacity<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `20`
  </dd>
  <dt>`autoscale_min_read_capacity` (`number`) <i>optional</i></dt>
  <dd>
    DynamoDB autoscaling min read capacity<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5`
  </dd>
  <dt>`autoscale_min_write_capacity` (`number`) <i>optional</i></dt>
  <dd>
    DynamoDB autoscaling min write capacity<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5`
  </dd>
  <dt>`autoscale_read_target` (`number`) <i>optional</i></dt>
  <dd>
    The target value (in %) for DynamoDB read autoscaling<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `50`
  </dd>
  <dt>`autoscale_write_target` (`number`) <i>optional</i></dt>
  <dd>
    The target value (in %) for DynamoDB write autoscaling<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `50`
  </dd>
  <dt>`autoscaler_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Additional attributes for the autoscaler module<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`autoscaler_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable DynamoDB autoscaling<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`autoscaler_tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional resource tags for the autoscaler module<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`billing_mode` (`string`) <i>optional</i></dt>
  <dd>
    DynamoDB Billing mode. Can be PROVISIONED or PAY_PER_REQUEST<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"PROVISIONED"`
  </dd>
  <dt>`dynamodb_attributes` <i>optional</i></dt>
  <dd>
    Additional DynamoDB attributes in the form of a list of mapped values<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    name = string
    type = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`encryption_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable DynamoDB server-side encryption<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`global_secondary_index_map` <i>optional</i></dt>
  <dd>
    Additional global secondary indexes in the form of a list of mapped values<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    hash_key           = string
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
    read_capacity      = number
    write_capacity     = number
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`hash_key_type` (`string`) <i>optional</i></dt>
  <dd>
    Hash Key type, which must be a scalar type: `S`, `N`, or `B` for String, Number or Binary data, respectively.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"S"`
  </dd>
  <dt>`import_table` <i>optional</i></dt>
  <dd>
    Import Amazon S3 data into a new table.<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    # Valid values are GZIP, ZSTD and NONE
    input_compression_type = optional(string, null)
    # Valid values are CSV, DYNAMODB_JSON, and ION.
    input_format = string
    input_format_options = optional(object({
      csv = object({
        delimiter   = string
        header_list = list(string)
      })
    }), null)
    s3_bucket_source = object({
      bucket       = string
      bucket_owner = optional(string)
      key_prefix   = optional(string)
    })
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`local_secondary_index_map` <i>optional</i></dt>
  <dd>
    Additional local secondary indexes in the form of a list of mapped values<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    name               = string
    non_key_attributes = list(string)
    projection_type    = string
    range_key          = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`point_in_time_recovery_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable DynamoDB point in time recovery<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`range_key` (`string`) <i>optional</i></dt>
  <dd>
    DynamoDB table Range Key<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`range_key_type` (`string`) <i>optional</i></dt>
  <dd>
    Range Key type, which must be a scalar type: `S`, `N`, or `B` for String, Number or Binary data, respectively.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"S"`
  </dd>
  <dt>`replicas` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of regions to create a replica table in<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`server_side_encryption_kms_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the CMK that should be used for the AWS KMS encryption. This attribute should only be specified if the key is different from the default DynamoDB CMK, alias/aws/dynamodb.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`stream_view_type` (`string`) <i>optional</i></dt>
  <dd>
    When an item in the table is modified, what information is written to the stream<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`streams_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable DynamoDB streams<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`table_name` (`string`) <i>optional</i></dt>
  <dd>
    Table name. If provided, the bucket will be created with this name instead of generating the name from the context<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ttl_attribute` (`string`) <i>optional</i></dt>
  <dd>
    DynamoDB table TTL attribute<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ttl_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to disable DynamoDB table TTL<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`global_secondary_index_names`</dt>
  <dd>
    DynamoDB global secondary index names<br/>
  </dd>
  <dt>`hash_key`</dt>
  <dd>
    DynamoDB table hash key<br/>
  </dd>
  <dt>`local_secondary_index_names`</dt>
  <dd>
    DynamoDB local secondary index names<br/>
  </dd>
  <dt>`range_key`</dt>
  <dd>
    DynamoDB table range key<br/>
  </dd>
  <dt>`table_arn`</dt>
  <dd>
    DynamoDB table ARN<br/>
  </dd>
  <dt>`table_id`</dt>
  <dd>
    DynamoDB table ID<br/>
  </dd>
  <dt>`table_name`</dt>
  <dd>
    DynamoDB table name<br/>
  </dd>
  <dt>`table_stream_arn`</dt>
  <dd>
    DynamoDB table stream ARN<br/>
  </dd>
  <dt>`table_stream_label`</dt>
  <dd>
    DynamoDB table stream label<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dynamodb) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
