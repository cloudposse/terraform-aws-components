# Component: `s3-bucket`

This component is responsible for provisioning S3 buckets.

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

`stacks/s3/defaults.yaml` file (base component for all S3 buckets with default settings):

```yaml
components:
  terraform:
    s3-bucket-defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        account_map_tenant_name: core
        # Suggested configuration for all buckets
        user_enabled: false
        acl: "private"
        grants: null
        force_destroy: false
        versioning_enabled: false
        allow_encrypted_uploads_only: true
        block_public_acls: true
        block_public_policy: true
        ignore_public_acls: true
        restrict_public_buckets: true
        allow_ssl_requests_only: true
        lifecycle_configuration_rules:
          - id: default
            enabled: true
            abort_incomplete_multipart_upload_days: 90
            filter_and:
              prefix: ""
              tags: {}
            transition:
              - storage_class: GLACIER
                days: 60
            noncurrent_version_transition:
              - storage_class: GLACIER
                days: 60
            noncurrent_version_expiration:
              days: 90
            expiration:
              days: 120
```

```yaml
import:
  - catalog/s3/defaults

components:
  terraform:
    template-bucket:
      metadata:
        component: s3-bucket
        inherits:
          - s3-bucket-defaults
      vars:
        enabled: true
        name: template
        logging_bucket_name_rendering_enabled: true
        logging:
          bucket_name: s3-access-logs
          prefix: logs/
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`template`](https://registry.terraform.io/modules/template/>= 2.2.0), version: >= 2.2.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0
- `template`, version: >= 2.2.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`bucket_policy` | 0.4.0 | [`cloudposse/iam-policy/aws`](https://registry.terraform.io/modules/cloudposse/iam-policy/aws/0.4.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`s3_bucket` | 3.1.1 | [`cloudposse/s3-bucket/aws`](https://registry.terraform.io/modules/cloudposse/s3-bucket/aws/3.1.1) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.custom_policy`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`template_file.bucket_policy`](https://registry.terraform.io/providers/cloudposse/template/latest/docs/data-sources/file) (data source)

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
  <dt>`account_map_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`account_map_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`account_map_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the tenant where `account_map` is provisioned.<br/>
    <br/>
    If the `tenant` label is not used, leave this as `null`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`acl` (`string`) <i>optional</i></dt>
  <dd>
    The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply.<br/>
    We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"private"`
  </dd>
  <dt>`allow_encrypted_uploads_only` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `true` to prevent uploads of unencrypted objects to S3 bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`allow_ssl_requests_only` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`allowed_bucket_actions` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of actions the user is permitted to perform on the S3 bucket<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload"
    ]
    ```
    
  </dd>
  <dt>`block_public_acls` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `false` to disable the blocking of new public access lists on the bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`block_public_policy` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `false` to disable the blocking of new public policies on the bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`bucket_key_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set this to true to use Amazon S3 Bucket Keys for SSE-KMS, which reduce the cost of AWS KMS requests.<br/>
    For more information, see: https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`bucket_name` (`string`) <i>optional</i></dt>
  <dd>
    Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`cors_configuration` <i>optional</i></dt>
  <dd>
    Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`custom_policy_account_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of accounts names to assign as principals for the s3 bucket custom policy<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`custom_policy_actions` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of S3 Actions for the custom policy<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`custom_policy_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable or disable the custom policy. If enabled, the default policy will be ignored<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`force_destroy` (`bool`) <i>optional</i></dt>
  <dd>
    When `true`, permits a non-empty S3 bucket to be deleted by first deleting all objects in the bucket.<br/>
    THESE OBJECTS ARE NOT RECOVERABLE even if they were versioned and stored in Glacier.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`grants` <i>optional</i></dt>
  <dd>
    A list of policy grants for the bucket, taking a list of permissions.<br/>
    Conflicts with `acl`. Set `acl` to `null` to use this.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    id          = string
    type        = string
    permissions = list(string)
    uri         = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`iam_policy_statements` (`any`) <i>optional</i></dt>
  <dd>
    Map of IAM policy statements to use in the bucket policy.<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`ignore_public_acls` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `false` to disable the ignoring of public access lists on the bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`kms_master_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lifecycle_configuration_rules` <i>optional</i></dt>
  <dd>
    A list of lifecycle V2 rules<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`logging` <i>optional</i></dt>
  <dd>
    Bucket access logging configuration.<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    bucket_name = string
    prefix      = string
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`logging_bucket_name_rendering_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to render the logging bucket name, prepending context<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`logging_bucket_name_rendering_template` (`string`) <i>optional</i></dt>
  <dd>
    The template for the template used to render Bucket Name for the Logging bucket.<br/>
    Default is appropriate when using `tenant` and default label order with `null-label`.<br/>
    Use `"%s-%s-%s-%%s"` when not using `tenant`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"%s-%s-%s-%s-%s"`
  </dd>
  <dt>`logging_bucket_prefix_rendering_template` (`string`) <i>optional</i></dt>
  <dd>
    The template for the template used to render Bucket Prefix for the Logging bucket, uses the format `var.logging.prefix`/`var.name`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"%s/%s/"`
  </dd>
  <dt>`object_lock_configuration` <i>optional</i></dt>
  <dd>
    A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely.<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`privileged_principal_actions` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of actions to permit `privileged_principal_arns` to perform on bucket and bucket prefixes (see `privileged_principal_arns`)<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`privileged_principal_arns` (`list(map(list(string)))`) <i>optional</i></dt>
  <dd>
    List of maps. Each map has one key, an IAM Principal ARN, whose associated value is<br/>
    a list of S3 path prefixes to grant `privileged_principal_actions` permissions for that principal,<br/>
    in addition to the bucket itself, which is automatically included. Prefixes should not begin with '/'.<br/>
    <br/>
    <br/>
    **Type:** `list(map(list(string)))`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`restrict_public_buckets` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `false` to disable the restricting of making the bucket public<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`s3_object_ownership` (`string`) <i>optional</i></dt>
  <dd>
    Specifies the S3 object ownership control. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ObjectWriter"`
  </dd>
  <dt>`s3_replica_bucket_arn` (`string`) <i>optional</i></dt>
  <dd>
    A single S3 bucket ARN to use for all replication rules.<br/>
    Note: The destination bucket can be specified in the replication rule itself<br/>
    (which allows for multiple destinations), in which case it will take precedence over this variable.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`s3_replication_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set this to true and specify `s3_replication_rules` to enable replication. `versioning_enabled` must also be `true`.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`s3_replication_rules` (`list(any)`) <i>optional</i></dt>
  <dd>
    Specifies the replication rules for S3 bucket replication if enabled. You must also set s3_replication_enabled to true.<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`s3_replication_source_roles` (`list(string)`) <i>optional</i></dt>
  <dd>
    Cross-account IAM Role ARNs that will be allowed to perform S3 replication to this bucket (for replication within the same AWS account, it's not necessary to adjust the bucket policy).<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`source_policy_documents` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of IAM policy documents that are merged together into the exported document.<br/>
    Statements defined in source_policy_documents or source_json must have unique SIDs.<br/>
    Statement having SIDs that match policy SIDs generated by this module will override them.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`sse_algorithm` (`string`) <i>optional</i></dt>
  <dd>
    The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"AES256"`
  </dd>
  <dt>`transfer_acceleration_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set this to true to enable S3 Transfer Acceleration for the bucket.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`user_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `true` to create an IAM user with permission to access the bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`versioning_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`website_inputs` <i>optional</i></dt>
  <dd>
    Specifies the static website hosting configuration object.<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    index_document           = string
    error_document           = string
    redirect_all_requests_to = string
    routing_rules            = string
  }))
    ```
    
    <br/>
    **Default value:** `null`
  </dd></dl>


### Outputs

<dl>
  <dt>`bucket_arn`</dt>
  <dd>
    Bucket ARN<br/>
  </dd>
  <dt>`bucket_domain_name`</dt>
  <dd>
    Bucket domain name<br/>
  </dd>
  <dt>`bucket_id`</dt>
  <dd>
    Bucket ID<br/>
  </dd>
  <dt>`bucket_region`</dt>
  <dd>
    Bucket region<br/>
  </dd>
  <dt>`bucket_regional_domain_name`</dt>
  <dd>
    Bucket region-specific domain name<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/s3-bucket) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
