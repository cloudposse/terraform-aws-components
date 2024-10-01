---
tags:
  - component/tfstate-backend
  - layer/foundation
  - provider/aws
  - privileged
---

# Component: `tfstate-backend`

This component is responsible for provisioning an S3 Bucket and DynamoDB table that follow security best practices for
usage as a Terraform backend. It also creates IAM roles for access to the Terraform backend.

Once the initial S3 backend is configured, this component can create additional backends, allowing you to segregate them
and control access to each backend separately. This may be desirable because any secret or sensitive information (such
as generated passwords) that Terraform has access to gets stored in the Terraform state backend S3 bucket, so you may
wish to restrict who can read the production Terraform state backend S3 bucket. However, perhaps counter-intuitively,
all Terraform users require read access to the most sensitive accounts, such as `root` and `audit`, in order to read
security configuration information, so careful planning is required when architecting backend splits.

## Prerequisites

> [!TIP]
>
> Part of cold start, so it has to initially be run with `SuperAdmin`, multiple times: to create the S3 bucket and then
> to move the state into it. Follow the guide
> **[here](https://docs.cloudposse.com/layers/accounts/tutorials/manual-configuration/#provision-tfstate-backend-component)**
> to get started.

- This component assumes you are using the `aws-teams` and `aws-team-roles` components.
- Before the `account` and `account-map` components are deployed for the first time, you'll want to run this component
  with `access_roles_enabled` set to `false` to prevent errors due to missing IAM Role ARNs. This will enable only
  enough access to the Terraform state for you to finish provisioning accounts and roles. After those components have
  been deployed, you will want to run this component again with `access_roles_enabled` set to `true` to provide the
  complete access as configured in the stacks.

### Access Control

For each backend, this module will create an IAM role with read/write access and, optionally, an IAM role with read-only
access. You can configure who is allowed to assume these roles.

- While read/write access is required for `terraform apply`, the created role only grants read/write access to the
  Terraform state, it does not grant permission to create/modify/destroy AWS resources.

- Similarly, while the read-only role prohibits making changes to the Terraform state, it does not prevent anyone from
  making changes to AWS resources using a different role.

- Many Cloud Posse components store information about resources they create in the Terraform state via their outputs,
  and many other components read this information from the Terraform state backend via the CloudPosse `remote-state`
  module and use it as part of their configuration. For example, the `account-map` component exists solely for the
  purpose of organizing information about the created AWS accounts and storing it in its Terraform state, making it
  available via `remote-state`. This means that you if you are going to restrict access to some backends, you need to
  carefully orchestrate what is stored there and ensure that you are not storing information a component needs in a
  backend it will not have access to. Typically, information in the most sensitive accounts, such as `root`, `audit`,
  and `security`, is nevertheless needed by every account, for example to know where to send audit logs, so it is not
  obvious and can be counter-intuitive which accounts need access to which backends. Plan carefully.

- Atmos provides separate configuration for Terraform state access via the `backend` and `remote_state_backend`
  settings. Always configure the `backend` setting with a role that has read/write access (and override that setting to
  be `null` for components deployed by SuperAdmin). If a read-only role is available (only helpful if you have more than
  one backend), use that role in `remote_state_backend.s3.role_arn`. Otherwise, use the read/write role in
  `remote_state_backend.s3.role_arn`, to ensure that all components can read the Terraform state, even if
  `backend.s3.role_arn` is set to `null`, as it is with a few critical components meant to be deployed by SuperAdmin.

- Note that the "read-only" in the "read-only role" refers solely to the S3 bucket that stores the backend data. That
  role still has read/write access to the DynamoDB table, which is desirable so that users restricted to the read-only
  role can still perform drift detection by running `terraform plan`. The DynamoDB table only stores checksums and
  mutual-exclusion lock information, so it is not considered sensitive. The worst a malicious user could do would be to
  corrupt the table and cause a denial-of-service (DoS) for Terraform, but such DoS would only affect making changes to
  the infrastructure, it would not affect the operation of the existing infrastructure, so it is an ineffective and
  therefore unlikely vector of attack. (Also note that the entire DynamoDB table is optional and can be deleted
  entirely; Terraform will repopulate it as new activity takes place.)

- For convenience, the component automatically grants access to the backend to the user deploying it. This is helpful
  because it allows that user, presumably SuperAdmin, to deploy the normal components that expect the user does not have
  direct access to Terraform state, without requiring custom configuration. However, you may want to explicitly grant
  SuperAdmin access to the backend in the `allowed_principal_arns` configuration, to ensure that SuperAdmin can always
  access the backend, even if the component is later updated by the `root-admin` role.

### Quotas

When allowing access to both SAML and AWS SSO users, the trust policy for the IAM roles created by this component can
exceed the default 2048 character limit. If you encounter this error, you can increase the limit by requesting a quota
increase [here](https://us-east-1.console.aws.amazon.com/servicequotas/home/services/iam/quotas/L-C07B4B0D). Note that
this is the IAM limit on "The maximum number of characters in an IAM role trust policy" and it must be configured in the
`us-east-1` region, regardless of what region you are deploying to. Normally 3072 characters is sufficient, and is
recommended so that you still have room to expand the trust policy in the future while perhaps considering how to reduce
its size.

## Usage

**Stack Level**: Regional (because DynamoDB is region-specific), but deploy only in a single region and only in the
`root` account **Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

This component configures the shared Terraform backend, and as such is the first component that must be deployed, since
all other components depend on it. In fact, this component even depends on itself, so special deployment procedures are
needed for the initial deployment (documented in the "Cold Start" procedures).

Here's an example snippet for how to use this component.

```yaml
terraform:
  tfstate-backend:
    backend:
      s3:
        role_arn: null
    settings:
      spacelift:
        workspace_enabled: false
    vars:
      enable_server_side_encryption: true
      enabled: true
      force_destroy: false
      name: tfstate
      prevent_unencrypted_uploads: true
      access_roles:
        default: &tfstate-access-template
          write_enabled: true
          allowed_roles:
            core-identity: ["devops", "developers", "managers", "spacelift"]
            core-root: ["admin"]
          denied_roles: {}
          allowed_permission_sets:
            core-identity: ["AdministratorAccess"]
          denied_permission_sets: {}
          allowed_principal_arns: []
          denied_principal_arns: []
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.16.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_awsutils"></a> [awsutils](#provider\_awsutils) | >= 0.16.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_assume_role"></a> [assume\_role](#module\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_label"></a> [label](#module\_label) | cloudposse/label/null | 0.25.0 |
| <a name="module_tfstate_backend"></a> [tfstate\_backend](#module\_tfstate\_backend) | cloudposse/tfstate-backend/aws | 1.1.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_arn.cold_start_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/arn) | data source |
| [aws_iam_policy_document.cold_start_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.tfstate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [awsutils_caller_identity.current](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_roles"></a> [access\_roles](#input\_access\_roles) | Map of access roles to create (key is role name, use "default" for same as component). See iam-assume-role-policy module for details. | <pre>map(object({<br>    write_enabled           = bool<br>    allowed_roles           = map(list(string))<br>    denied_roles            = map(list(string))<br>    allowed_principal_arns  = list(string)<br>    denied_principal_arns   = list(string)<br>    allowed_permission_sets = map(list(string))<br>    denied_permission_sets  = map(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_access_roles_enabled"></a> [access\_roles\_enabled](#input\_access\_roles\_enabled) | Enable access roles to be assumed. Set `false` for cold start (before account-map has been created),<br>because the role to ARN mapping has not yet been created.<br>Note that the current caller and any `allowed_principal_arns` will always be allowed to assume the role. | `bool` | `true` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | Enable DynamoDB point-in-time recovery | `bool` | `true` | no |
| <a name="input_enable_server_side_encryption"></a> [enable\_server\_side\_encryption](#input\_enable\_server\_side\_encryption) | Enable DynamoDB and S3 server-side encryption | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | A boolean that indicates the terraform state S3 bucket can be destroyed even if it contains objects. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_prevent_unencrypted_uploads"></a> [prevent\_unencrypted\_uploads](#input\_prevent\_unencrypted\_uploads) | Prevent uploads of unencrypted objects to S3 | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tfstate_backend_access_role_arns"></a> [tfstate\_backend\_access\_role\_arns](#output\_tfstate\_backend\_access\_role\_arns) | IAM Role ARNs for accessing the Terraform State Backend |
| <a name="output_tfstate_backend_dynamodb_table_arn"></a> [tfstate\_backend\_dynamodb\_table\_arn](#output\_tfstate\_backend\_dynamodb\_table\_arn) | Terraform state DynamoDB table ARN |
| <a name="output_tfstate_backend_dynamodb_table_id"></a> [tfstate\_backend\_dynamodb\_table\_id](#output\_tfstate\_backend\_dynamodb\_table\_id) | Terraform state DynamoDB table ID |
| <a name="output_tfstate_backend_dynamodb_table_name"></a> [tfstate\_backend\_dynamodb\_table\_name](#output\_tfstate\_backend\_dynamodb\_table\_name) | Terraform state DynamoDB table name |
| <a name="output_tfstate_backend_s3_bucket_arn"></a> [tfstate\_backend\_s3\_bucket\_arn](#output\_tfstate\_backend\_s3\_bucket\_arn) | Terraform state S3 bucket ARN |
| <a name="output_tfstate_backend_s3_bucket_domain_name"></a> [tfstate\_backend\_s3\_bucket\_domain\_name](#output\_tfstate\_backend\_s3\_bucket\_domain\_name) | Terraform state S3 bucket domain name |
| <a name="output_tfstate_backend_s3_bucket_id"></a> [tfstate\_backend\_s3\_bucket\_id](#output\_tfstate\_backend\_s3\_bucket\_id) | Terraform state S3 bucket ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/tfstate-backend) -
  Cloud Posse's upstream component
