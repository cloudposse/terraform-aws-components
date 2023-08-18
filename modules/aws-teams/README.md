# Component: `aws-teams`

This component is responsible for provisioning all primary user and system roles into the centralized identity account.
This is expected to be used alongside [the `aws-team-roles` component](../aws-team-roles) to provide
fine-grained role delegation across the account hierarchy.

### Teams Function Like Groups and are Implemented as Roles
The "teams" created in the `identity` account by this module can be thought of as access control "groups":
a user who is allowed access one of these teams gets access to a set of roles (and corresponding permissions)
across a set of accounts. Generally, there is nothing else provisioned in the `identity` account,
so the teams have limited access to resources in the `identity` account by design.

Teams are implemented as IAM Roles in each account. Access to the "teams" in the `identity`
account is controlled by the `aws-saml` and `aws-sso` components. Access to the roles in all the
other accounts is controlled by the "assume role" policies of those roles, which allow the "team"
or AWS SSO Permission set to assume the role (or not).

### Privileges are Defined for Each Role in Each Account by `aws-team-roles`
Every account besides the `identity` account has a set of IAM roles created by the
`aws-team-roles` component. In that component, the account's roles are assigned privileges,
and those privileges ultimately determine what a user can do in that account.


Access to the roles can be granted in a number of ways.
One way is by listing "teams" created by this component as "trusted" (`trusted_teams`),
meaning that users who have access to the team role in the `identity` account are
allowed (trusted) to assume the role configured in the target account.
Another is by listing an AWS SSO Permission Set in the account (`trusted_permission_sets`).

### Role Access is Enabled by SAML and/or AWS SSO configuration
Users can again access to a role in the `identity` account through either (or both) of 2 mechanisms:

#### SAML Access
- SAML access is globally configured via the `aws-saml` component, enabling an external
SAML Identity Provider (IdP) to control access to roles in the `identity` account.
(SAML access can be separately configured for other accounts, see the `aws-saml` and `aws-team-roles` components for more on that.)
- Individual roles are enabled for SAML access by setting `aws_saml_login_enabled: true` in the role configuration.
- Individual users are granted access to these roles by configuration in the SAML IdP.

#### AWS SSO Access
The `aws-sso` component can create AWS Permission Sets that allow users to assume specific roles
in the `identity` account. See the `aws-sso` component for details.

## Usage

**Stack Level**: Global
**Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

Here's an example snippet for how to use this component. The component should only be applied once,
which is typically done via the identity stack (e.g. `gbl-identity.yaml`).

```yaml
components:
  terraform:
    aws-teams:
      backend:
        s3:
          role_arn: null
      vars:
        teams_config:
          # Viewer has the same permissions as Observer but only in this account. It is not allowed access to other accounts.
          # Viewer also serves as the default configuration for all roles via the YAML anchor.
          viewer: &user-template
            # `max_session_duration` set the maximum session duration (in seconds) for the IAM roles.
            # This setting can have a value from 3600 (1 hour) to 43200 (12 hours).
            # For roles people log into via SAML, a long duration is convenient to prevent them
            # from having to frequently re-authenticate.
            # For roles assumed from some other role, the setting is practically irrelevant, because
            # the AssumeRole API limits the duration to 1 hour in any case.
            # References:
            # - https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use.html
            # - https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
            max_session_duration: 43200 # 12 hours in seconds

            # role_policy_arns are the IAM Policy ARNs to attach to this policy. In addition to real ARNs,
            # you can use keys in the `custom_policy_map` in `main.tf` to select policies defined in the component.
            # If you are using keys from the map, plans look better if you put them after the real role ARNs.
            role_policy_arns:
              - "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
            role_description: "Team restricted to viewing resources in the identity account"
            # If `aws_saml_login_enabled: true` then the role will be available via SAML logins.
            # Otherwise, it will only be accessible via `assume role`.
            aws_saml_login_enabled: false

            # The following attributes control access to this role via `assume role`.
            # `trusted_*` grants access, `denied_*` denies access.
            # If a role is both trusted and denied, it will not be able to access this role.

            # Permission sets specify users operating from the given AWS SSO permission set in this account.
            trusted_permission_sets: [ ]
            denied_permission_sets: [ ]

            # Primary roles specify the short role names of roles in the primary (identity)
            # account that are allowed to assume this role.
            trusted_teams: [ ]
            denied_teams: [ "viewer" ]

            # Role ARNs specify Role ARNs in any account that are allowed to assume this role.
            # BE CAREFUL: there is nothing limiting these Role ARNs to roles within our organization.
            trusted_role_arns: [ ]
            denied_role_arns: [ ]

          admin:
            <<: *user-template
            role_description: "Team with PowerUserAccess permissions in `identity` and AdministratorAccess to all other accounts except `root`"
            # Limit `admin` to Power User to prevent accidentally destroying the admin role itself
            # Use SuperAdmin to administer IAM access
            role_policy_arns: [ "arn:aws:iam::aws:policy/PowerUserAccess" ]

            # TODO Create a "security" team with AdministratorAccess to audit and security, remove "admin" write access to those accounts
            aws_saml_login_enabled: true
            # list of roles in primary that can assume into this role in delegated accounts
            # primary admin can assume delegated admin
            trusted_teams: [ "admin" ]
            # GH runner should be moved to its own `ghrunner` role
            trusted_permission_sets: [ "IdentityAdminTeamAccess" ]


          spacelift:
            <<: *user-template
            role_description: Team for our privileged Spacelift server
            role_policy_arns:
            - team_role_access
            aws_saml_login_enabled: false
            trusted_teams:
            - admin
            trusted_role_arns: ["arn:aws:iam::123456789012:role/eg-ue2-auto-spacelift-worker-pool-admin"]

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | >= 1.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_local"></a> [local](#provider\_local) | >= 1.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_assume_role"></a> [assume\_role](#module\_assume\_role) | ../account-map/modules/team-assume-role-policy | n/a |
| <a name="module_aws_saml"></a> [aws\_saml](#module\_aws\_saml) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.team_role_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [local_file.account_info](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [aws_iam_policy_document.assume_role_aggregated](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.team_role_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_saml_environment_name"></a> [aws\_saml\_environment\_name](#input\_aws\_saml\_environment\_name) | The name of the environment where SSO is provisioned | `string` | `"gbl"` | no |
| <a name="input_aws_saml_stage_name"></a> [aws\_saml\_stage\_name](#input\_aws\_saml\_stage\_name) | The name of the stage where SSO is provisioned | `string` | `"identity"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_teams_config"></a> [teams\_config](#input\_teams\_config) | A roles map to configure the accounts. | <pre>map(object({<br>    denied_teams            = list(string)<br>    denied_permission_sets  = list(string)<br>    denied_role_arns        = list(string)<br>    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)<br>    role_description        = string<br>    role_policy_arns        = list(string)<br>    aws_saml_login_enabled  = bool<br>    trusted_teams           = list(string)<br>    trusted_permission_sets = list(string)<br>    trusted_role_arns       = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_trusted_github_repos"></a> [trusted\_github\_repos](#input\_trusted\_github\_repos) | Map where keys are role names (same keys as `teams_config`) and values are lists of<br>GitHub repositories allowed to assume those roles. See `account-map/modules/github-assume-role-policy.mixin.tf`<br>for specifics about repository designations. | `map(list(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arns"></a> [role\_arns](#output\_role\_arns) | List of role ARNs |
| <a name="output_team_name_role_arn_map"></a> [team\_name\_role\_arn\_map](#output\_team\_name\_role\_arn\_map) | Map of team names to role ARNs |
| <a name="output_team_names"></a> [team\_names](#output\_team\_names) | List of team names |
| <a name="output_teams_config"></a> [teams\_config](#output\_teams\_config) | Map of team config with name, target arn, and description |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Known Problems

### Error: `assume role policy: LimitExceeded: Cannot exceed quota for ACLSizePerRole: 2048`

The `aws-teams` architecture, when enabling access to a role via lots of AWS SSO Profiles, can create large "assume role" policies, large enough to exceed the default quota of 2048 characters. If you run into this limitation, you will get an error like this:

```
Error: error updating IAM Role (acme-gbl-root-tfstate-backend-analytics-ro) assume role policy: LimitExceeded: Cannot exceed quota for ACLSizePerRole: 2048
```

This can happen in either/both the `identity` and `root` accounts (for Terraform state access). So far, we have always been able to resolve this by requesting a quota increase, which is automatically granted a few minutes after making the request. To request the quota increase:

- Log in to the AWS Web console as admin in the affected account

- Set your region to N. Virginia  `us-east-1`

- Navigate to the Service Quotas page via the account dropdown menu

- Click on AWS Services in the left sidebar

- Search for "IAM" and select "AWS Identity and Access Management (IAM)". (If you don't find that option, make sure you have selected the `us-east-1` region.

- Find and select "Role trust policy length"

- Request an increase to 4096 characters

- Wait for the request to be approved, usually less than a few minutes


## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components)- Cloud Posse's upstream component
