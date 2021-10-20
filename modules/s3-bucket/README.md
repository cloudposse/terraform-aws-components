# Component: `ls3-bucket`

This component is responsible for provisioning S3 buckets.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

`stacks/catalog/s3/s3-defaults.yaml` file (base component for all S3 buckets with default settings):

```yaml
components:
  terraform:
    s3-bucket:
      vars:
        enabled: false
        acl: "private"
        grants: null
        policy: ""
        force_destroy: false
        versioning_enabled: true
        allow_encrypted_uploads_only: false
        lifecycle_rule_enabled: false
        noncurrent_version_glacier_transition_days: 30
        noncurrent_version_deeparchive_transition_days: 60
        noncurrent_version_expiration_days: 90
        standard_transition_days: 30
        glacier_transition_days: 60
        deeparchive_transition_days: 90
        enable_glacier_transition: false
        enable_deeparchive_transition: false
        enable_standard_ia_transition: false
        enable_current_object_expiration: false
        expiration_days: 90
        lifecycle_tags: {}
        block_public_acls: true
        block_public_policy: true
        ignore_public_acls: true
        restrict_public_buckets: true
```

`stacks/catalog/s3/my-documents-bucket`:

```yaml
components:
  terraform:
    my-documents-bucket:
      component: s3-bucket
      vars:
        enabled: true
        name: "my-documents"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 0.18.3 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_s3_bucket"></a> [s3\_bucket](#module\_s3\_bucket) | cloudposse/s3-bucket/aws | 0.42.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.custom_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_abort_incomplete_multipart_upload_days"></a> [abort\_incomplete\_multipart\_upload\_days](#input\_abort\_incomplete\_multipart\_upload\_days) | Maximum time (in days) that you want to allow multipart uploads to remain in progress | `number` | `5` | no |
| <a name="input_acl"></a> [acl](#input\_acl) | The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl) to apply. We recommend `private` to avoid exposing sensitive information. Conflicts with `grants`. | `string` | `"private"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_allow_encrypted_uploads_only"></a> [allow\_encrypted\_uploads\_only](#input\_allow\_encrypted\_uploads\_only) | Set to `true` to prevent uploads of unencrypted objects to S3 bucket | `bool` | `false` | no |
| <a name="input_allow_ssl_requests_only"></a> [allow\_ssl\_requests\_only](#input\_allow\_ssl\_requests\_only) | Set to `true` to require requests to use Secure Socket Layer (HTTPS/SSL). This will explicitly deny access to HTTP requests | `bool` | `false` | no |
| <a name="input_allowed_bucket_actions"></a> [allowed\_bucket\_actions](#input\_allowed\_bucket\_actions) | List of actions the user is permitted to perform on the S3 bucket | `list(string)` | <pre>[<br>  "s3:PutObject",<br>  "s3:PutObjectAcl",<br>  "s3:GetObject",<br>  "s3:DeleteObject",<br>  "s3:ListBucket",<br>  "s3:ListBucketMultipartUploads",<br>  "s3:GetBucketLocation",<br>  "s3:AbortMultipartUpload"<br>]</pre> | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | Set to `false` to disable the blocking of new public access lists on the bucket | `bool` | `true` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | Set to `false` to disable the blocking of new public policies on the bucket | `bool` | `true` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Bucket name. If provided, the bucket will be created with this name instead of generating the name from the context | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_cors_rule_inputs"></a> [cors\_rule\_inputs](#input\_cors\_rule\_inputs) | Specifies the allowed headers, methods, origins and exposed headers when using CORS on this bucket | <pre>list(object({<br>    allowed_headers = list(string)<br>    allowed_methods = list(string)<br>    allowed_origins = list(string)<br>    expose_headers  = list(string)<br>    max_age_seconds = number<br>  }))</pre> | `null` | no |
| <a name="input_custom_policy_account_names"></a> [custom\_policy\_account\_names](#input\_custom\_policy\_account\_names) | List of accounts names to assign as principals for the s3 bucket custom policy | `list(string)` | `[]` | no |
| <a name="input_custom_policy_actions"></a> [custom\_policy\_actions](#input\_custom\_policy\_actions) | List of S3 Actions for the custom policy | `list(string)` | `[]` | no |
| <a name="input_custom_policy_enabled"></a> [custom\_policy\_enabled](#input\_custom\_policy\_enabled) | Whether to enable or disable the custom policy. If enabled, the default policy will be ignored | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean string that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable | `bool` | `false` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | An ACL policy grant. Conflicts with `acl`. Set `acl` to `null` to use this. | <pre>list(object({<br>    id          = string<br>    type        = string<br>    permissions = list(string)<br>    uri         = string<br>  }))</pre> | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | Set to `false` to disable the ignoring of public access lists on the bucket | `bool` | `true` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | IAM Profile to use when importing a resource | `string` | `null` | no |
| <a name="input_kms_master_key_arn"></a> [kms\_master\_key\_arn](#input\_kms\_master\_key\_arn) | The AWS KMS master key ARN used for the `SSE-KMS` encryption. This can only be used when you set the value of `sse_algorithm` as `aws:kms`. The default aws/s3 AWS KMS master key is used if this element is absent while the `sse_algorithm` is `aws:kms` | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | A list of lifecycle rules | <pre>list(object({<br>    prefix  = string<br>    enabled = bool<br>    tags    = map(string)<br><br>    enable_glacier_transition        = bool<br>    enable_deeparchive_transition    = bool<br>    enable_standard_ia_transition    = bool<br>    enable_current_object_expiration = bool<br><br>    abort_incomplete_multipart_upload_days         = number<br>    noncurrent_version_glacier_transition_days     = number<br>    noncurrent_version_deeparchive_transition_days = number<br>    noncurrent_version_expiration_days             = number<br><br>    standard_transition_days    = number<br>    glacier_transition_days     = number<br>    deeparchive_transition_days = number<br>    expiration_days             = number<br>  }))</pre> | <pre>[<br>  {<br>    "abort_incomplete_multipart_upload_days": 90,<br>    "deeparchive_transition_days": 90,<br>    "enable_current_object_expiration": true,<br>    "enable_deeparchive_transition": false,<br>    "enable_glacier_transition": true,<br>    "enable_standard_ia_transition": false,<br>    "enabled": false,<br>    "expiration_days": 90,<br>    "glacier_transition_days": 60,<br>    "noncurrent_version_deeparchive_transition_days": 60,<br>    "noncurrent_version_expiration_days": 90,<br>    "noncurrent_version_glacier_transition_days": 30,<br>    "prefix": "",<br>    "standard_transition_days": 30,<br>    "tags": {}<br>  }<br>]</pre> | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Bucket access logging configuration. | <pre>object({<br>    bucket_name = string<br>    prefix      = string<br>  })</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely. | <pre>object({<br>    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.<br>    days  = number<br>    years = number<br>  })</pre> | `null` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid bucket policy JSON document. Note that if the policy document is not specific enough (but still valid), Terraform may view the policy as constantly changing in a terraform plan. In this case, please make sure you use the verbose/specific version of the policy | `string` | `""` | no |
| <a name="input_privileged_principal_actions"></a> [privileged\_principal\_actions](#input\_privileged\_principal\_actions) | List of actions to permit `privileged_principal_arns` to perform on bucket and bucket prefixes (see `privileged_principal_arns`) | `list(string)` | `[]` | no |
| <a name="input_privileged_principal_arns"></a> [privileged\_principal\_arns](#input\_privileged\_principal\_arns) | Map of IAM Principal ARNs to lists of S3 path prefixes to grant `privileged_principal_actions` permissions.<br>Resource list will include the bucket itself along with all the prefixes. Prefixes should not begin with '/'. | `map(list(string))` | `{}` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | Set to `false` to disable the restricting of making the bucket public | `bool` | `true` | no |
| <a name="input_s3_replica_bucket_arn"></a> [s3\_replica\_bucket\_arn](#input\_s3\_replica\_bucket\_arn) | A single S3 bucket ARN to use for all replication rules.<br>Note: The destination bucket can be specified in the replication rule itself<br>(which allows for multiple destinations), in which case it will take precedence over this variable. | `string` | `""` | no |
| <a name="input_s3_replication_enabled"></a> [s3\_replication\_enabled](#input\_s3\_replication\_enabled) | Set this to true and specify `s3_replication_rules` to enable replication. `versioning_enabled` must also be `true`. | `bool` | `false` | no |
| <a name="input_s3_replication_rules"></a> [s3\_replication\_rules](#input\_s3\_replication\_rules) | Specifies the replication rules for S3 bucket replication if enabled. You must also set s3\_replication\_enabled to true. | `list(any)` | `null` | no |
| <a name="input_s3_replication_source_roles"></a> [s3\_replication\_source\_roles](#input\_s3\_replication\_source\_roles) | Cross-account IAM Role ARNs that will be allowed to perform S3 replication to this bucket (for replication within the same AWS account, it's not necessary to adjust the bucket policy). | `list(string)` | `[]` | no |
| <a name="input_sse_algorithm"></a> [sse\_algorithm](#input\_sse\_algorithm) | The server-side encryption algorithm to use. Valid values are `AES256` and `aws:kms` | `string` | `"AES256"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_transfer_acceleration_enabled"></a> [transfer\_acceleration\_enabled](#input\_transfer\_acceleration\_enabled) | Set this to true to enable S3 Transfer Acceleration for the bucket. | `bool` | `false` | no |
| <a name="input_user_enabled"></a> [user\_enabled](#input\_user\_enabled) | Set to `true` to create an IAM user with permission to access the bucket | `bool` | `false` | no |
| <a name="input_versioning_enabled"></a> [versioning\_enabled](#input\_versioning\_enabled) | A state of versioning. Versioning is a means of keeping multiple variants of an object in the same bucket | `bool` | `true` | no |
| <a name="input_website_inputs"></a> [website\_inputs](#input\_website\_inputs) | Specifies the static website hosting configuration object. | <pre>list(object({<br>    index_document           = string<br>    error_document           = string<br>    redirect_all_requests_to = string<br>    routing_rules            = string<br>  }))</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | Bucket ARN |
| <a name="output_bucket_domain_name"></a> [bucket\_domain\_name](#output\_bucket\_domain\_name) | Bucket domain name |
| <a name="output_bucket_id"></a> [bucket\_id](#output\_bucket\_id) | Bucket ID |
| <a name="output_bucket_region"></a> [bucket\_region](#output\_bucket\_region) | Bucket region |
| <a name="output_bucket_regional_domain_name"></a> [bucket\_regional\_domain\_name](#output\_bucket\_regional\_domain\_name) | Bucket region-specific domain name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/s3-bucket) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
