# Component: `iam-primary-roles`

This component is responsible for provisioning all primary user and system roles into the centralized identity account. This is expected to be use alongside [the `iam-delegated-roles` component](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/iam-delegated-roles) to provide fine grained role delegation across the account hierarchy.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. The component should only be applied once, which is typically done via the identity stack (e.g. `gbl-identity.yaml`).

```yaml
components:
  terraform:
    iam-primary-roles:
      vars:
        # When assume_role_restricted is true, assuming other roles in the identity
        # account is restricted based on the role configuration, but that can only
        # be set up after the roles are created. When the roles do not yet exist,
        # such as during cold start, set assume_role_restricted false, and all
        # roles will be able to assume other roles.
        assume_role_restricted: true

        # AWS SSO assigns users to unpredictable roles, so we cannot whitelist them
        # and must by default allow other roles in the identity account to assume
        # the identity roles, relying on their own IAM restrictions to limit them.
        default_assume_role_enabled: true

        primary_account_stage_name: "identity"

        # The maximum session duration (in seconds) that you want to set for the IAM roles.
        # If you do not specify a value for this setting, the default maximum of one hour is applied.
        # This setting can have a value from 3600 (1 hour) to 43200 (12 hours)
        iam_role_max_session_duration: 43200

        # delegated_ roles_config is not just the set of roles for the identity account, it is
        # also the template for roles in all other "delegated" accounts.
        #
        # The role_policy_arn defines the policy for that role in the identity account,
        # which is why, for example, poweruser has ViewOnlyAccess. The policy for the
        # role in the delegated accounts is set in the iam-delegated-roles project.
        #
        # The trusted_primary_roles list indicates which roles in identity are allowed
        # to access those roles. So "ops" can access "poweruser", for example.
        delegated_roles_config:
          admin:
            role_policy_arns: [ "arn:aws:iam::aws:policy/AdministratorAccess" ]
            role_description: "Role with AdministratorAccess permissions"
            sso_login_enabled: true
            # list of roles in primary that can assume into this role in delegated accounts
            # primary admin can assume delegated admin
            trusted_primary_roles: [ "admin" ]

          ops:
            role_policy_arns: [ "arn:aws:iam::aws:policy/PowerUserAccess" ]
            role_description: "Role for OPS personnel"
            sso_login_enabled: true
            trusted_primary_roles: [ "admin", "ops" ]

          poweruser:
            role_policy_arns:
              - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
              - "delegated_assume_role"
            role_description: "Role for Power Users (read/write)"
            sso_login_enabled: true
            trusted_primary_roles: [ "admin", "ops", "poweruser" ]

          observer:
            role_policy_arns:
              - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
              - "delegated_assume_role"
            role_description: "Observer (read-only) role"
            sso_login_enabled: true
            trusted_primary_roles: [ "admin", "ops", "observer" ]

          terraform:
            role_policy_arns:
              - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
              - "delegated_assume_role"
            role_description: "Role with permissions for terraform automation"
            sso_login_enabled: false
            # Terraform is too powerful a role to allow powerusers to access it
            trusted_primary_roles: [ "admin", "ops", "cicd", "terraform" ]

          helm:
            role_policy_arns:
              - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
              - "delegated_assume_role"
            role_description: "Role with permissions for helm automation"
            sso_login_enabled: false
            # Helm is too powerful a role to allow powerusers to access it
            trusted_primary_roles: [ "admin", "ops", "cicd", "helm" ]

        # primary_roles_config is for roles that only appear in the identity account.
        # Users or services log in with one of these roles and assume
        # delegated roles in other accounts.
        primary_roles_config:
          cicd:
            role_policy_arns: [ "cicd" ]
            role_description: "Role for our privileged CI/CD Runner"
            sso_login_enabled: false
            trusted_primary_roles: [ "admin", "ops" ]

        # retrieve roles from spacelift-worker-pool to allow role assumption
        spacelift_roles_enabled: true
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
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_introspection"></a> [introspection](#module\_introspection) | cloudposse/label/null | 0.25.0 |
| <a name="module_spacelift_worker_pool"></a> [spacelift\_worker\_pool](#module\_spacelift\_worker\_pool) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.0 |
| <a name="module_sso"></a> [sso](#module\_sso) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.billing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.billing_admin](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.cicd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.delegated_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.support](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy.aws_billing_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.aws_billing_admin_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy.aws_support_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.aggregated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.billing_admin_access_aggregated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.cicd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.delegated_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.empty](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.primary_roles_assume_blacklist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.primary_roles_assume_whitelist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.saml_provider_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.support_access_aggregated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.support_access_trusted_advisor](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_assume_role_restricted"></a> [assume\_role\_restricted](#input\_assume\_role\_restricted) | Set true to restrict (via trust policy) who can assume into a role | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_cicd_sa_roles"></a> [cicd\_sa\_roles](#input\_cicd\_sa\_roles) | A list of Role ARNs that cicd runners may start with. Will be allowed to assume xxx-gbl-identity-cicd | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_assume_role_enabled"></a> [default\_assume\_role\_enabled](#input\_default\_assume\_role\_enabled) | Set true to allow unknown roles to assume this role (e.g. for AWS SSO) | `bool` | `false` | no |
| <a name="input_delegated_roles_config"></a> [delegated\_roles\_config](#input\_delegated\_roles\_config) | A roles map to configure the accounts. | <pre>map(object({<br>    role_policy_arns      = list(string)<br>    role_description      = string<br>    sso_login_enabled     = bool<br>    trusted_primary_roles = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_role_max_session_duration"></a> [iam\_role\_max\_session\_duration](#input\_iam\_role\_max\_session\_duration) | The maximum session duration (in seconds) that you want to set for the IAM roles.<br>This setting can have a value from 3600 (1 hour) to 43200 (12 hours). | `number` | `43200` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_primary_account_id"></a> [primary\_account\_id](#input\_primary\_account\_id) | Primary authentication account ID used as the source for assume role | `string` | `""` | no |
| <a name="input_primary_account_stage_name"></a> [primary\_account\_stage\_name](#input\_primary\_account\_stage\_name) | Primary authentication account name used as the source for assume role | `string` | `"identity"` | no |
| <a name="input_primary_roles_config"></a> [primary\_roles\_config](#input\_primary\_roles\_config) | A roles map to configure the accounts. | <pre>map(object({<br>    role_policy_arns      = list(string)<br>    role_description      = string<br>    sso_login_enabled     = bool<br>    trusted_primary_roles = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_required_tags"></a> [required\_tags](#input\_required\_tags) | List of required tag names | `list(string)` | `[]` | no |
| <a name="input_root_account_tenant_name"></a> [root\_account\_tenant\_name](#input\_root\_account\_tenant\_name) | The tenant name for the root account | `string` | `null` | no |
| <a name="input_spacelift_roles"></a> [spacelift\_roles](#input\_spacelift\_roles) | A list of Spacelift role ARNs. Will be allowed to assume xxx-gbl-identity-ops | `list(string)` | `[]` | no |
| <a name="input_spacelift_roles_enabled"></a> [spacelift\_roles\_enabled](#input\_spacelift\_roles\_enabled) | Whether or not to allow designated Spacelift roles to assume the Identity Ops role (and pull Spacelift roles from the remote state of the `spacelift-worker-pool` component) | `bool` | `false` | no |
| <a name="input_spacelift_worker_pool_environment_name"></a> [spacelift\_worker\_pool\_environment\_name](#input\_spacelift\_worker\_pool\_environment\_name) | The name of the stage where spacelift\_worker\_pool is provisioned | `string` | `"ue2"` | no |
| <a name="input_spacelift_worker_pool_stage_name"></a> [spacelift\_worker\_pool\_stage\_name](#input\_spacelift\_worker\_pool\_stage\_name) | The name of the stage where spacelift\_worker\_pool is provisioned | `string` | `"auto"` | no |
| <a name="input_sso_environment_name"></a> [sso\_environment\_name](#input\_sso\_environment\_name) | The name of the environment where SSO is provisioned | `string` | `"gbl"` | no |
| <a name="input_sso_stage_name"></a> [sso\_stage\_name](#input\_sso\_stage\_name) | The name of the stage where SSO is provisioned | `string` | `"identity"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_delegated_role_arns"></a> [delegated\_role\_arns](#output\_delegated\_role\_arns) | List of delegated role ARNs |
| <a name="output_delegated_role_name_role_arn_map"></a> [delegated\_role\_name\_role\_arn\_map](#output\_delegated\_role\_name\_role\_arn\_map) | Map of delegated role names to role ARNs |
| <a name="output_delegated_role_names"></a> [delegated\_role\_names](#output\_delegated\_role\_names) | List of delegated role names |
| <a name="output_delegated_roles_config"></a> [delegated\_roles\_config](#output\_delegated\_roles\_config) | Map of delegated role config with name, target arn, and description |
| <a name="output_primary_roles_config"></a> [primary\_roles\_config](#output\_primary\_roles\_config) | Map of role config with name, target arn, and description |
| <a name="output_role_arns"></a> [role\_arns](#output\_role\_arns) | List of role ARNs |
| <a name="output_role_name_role_arn_map"></a> [role\_name\_role\_arn\_map](#output\_role\_name\_role\_arn\_map) | Map of role names to role ARNs |
| <a name="output_role_names"></a> [role\_names](#output\_role\_names) | List of role names |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/iam-primary-roles) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
