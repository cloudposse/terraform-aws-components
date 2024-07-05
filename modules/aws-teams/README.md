# Component: `aws-teams`

This component is responsible for provisioning all primary user and system roles into the centralized identity account.
This is expected to be used alongside [the `aws-team-roles` component](../aws-team-roles) to provide fine-grained role
delegation across the account hierarchy.

### Teams Function Like Groups and are Implemented as Roles

The "teams" created in the `identity` account by this module can be thought of as access control "groups": a user who is
allowed access one of these teams gets access to a set of roles (and corresponding permissions) across a set of
accounts. Generally, there is nothing else provisioned in the `identity` account, so the teams have limited access to
resources in the `identity` account by design.

Teams are implemented as IAM Roles in each account. Access to the "teams" in the `identity` account is controlled by the
`aws-saml` and `aws-sso` components. Access to the roles in all the other accounts is controlled by the "assume role"
policies of those roles, which allow the "team" or AWS SSO Permission set to assume the role (or not).

### Privileges are Defined for Each Role in Each Account by `aws-team-roles`

Every account besides the `identity` account has a set of IAM roles created by the `aws-team-roles` component. In that
component, the account's roles are assigned privileges, and those privileges ultimately determine what a user can do in
that account.

Access to the roles can be granted in a number of ways. One way is by listing "teams" created by this component as
"trusted" (`trusted_teams`), meaning that users who have access to the team role in the `identity` account are allowed
(trusted) to assume the role configured in the target account. Another is by listing an AWS SSO Permission Set in the
account (`trusted_permission_sets`).

### Role Access is Enabled by SAML and/or AWS SSO configuration

Users can again access to a role in the `identity` account through either (or both) of 2 mechanisms:

#### SAML Access

- SAML access is globally configured via the `aws-saml` component, enabling an external SAML Identity Provider (IdP) to
  control access to roles in the `identity` account. (SAML access can be separately configured for other accounts, see
  the `aws-saml` and `aws-team-roles` components for more on that.)
- Individual roles are enabled for SAML access by setting `aws_saml_login_enabled: true` in the role configuration.
- Individual users are granted access to these roles by configuration in the SAML IdP.

#### AWS SSO Access

The `aws-sso` component can create AWS Permission Sets that allow users to assume specific roles in the `identity`
account. See the `aws-sso` component for details.

## Usage

**Stack Level**: Global **Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

Here's an example snippet for how to use this component. The component should only be applied once, which is typically
done via the identity stack (e.g. `gbl-identity.yaml`).

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
            trusted_permission_sets: []
            denied_permission_sets: []

            # Primary roles specify the short role names of roles in the primary (identity)
            # account that are allowed to assume this role.
            trusted_teams: []
            denied_teams: ["viewer"]

            # Role ARNs specify Role ARNs in any account that are allowed to assume this role.
            # BE CAREFUL: there is nothing limiting these Role ARNs to roles within our organization.
            trusted_role_arns: []
            denied_role_arns: []

          admin:
            <<: *user-template
            role_description:
              "Team with PowerUserAccess permissions in `identity` and AdministratorAccess to all other accounts except
              `root`"
            # Limit `admin` to Power User to prevent accidentally destroying the admin role itself
            # Use SuperAdmin to administer IAM access
            role_policy_arns: ["arn:aws:iam::aws:policy/PowerUserAccess"]

            # TODO Create a "security" team with AdministratorAccess to audit and security, remove "admin" write access to those accounts
            aws_saml_login_enabled: true
            # list of roles in primary that can assume into this role in delegated accounts
            # primary admin can assume delegated admin
            trusted_teams: ["admin"]
            # GH runner should be moved to its own `ghrunner` role
            trusted_permission_sets: ["IdentityAdminTeamAccess"]

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

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `local` | >= 1.3 |


## Providers

| Provider | Version |
| --- | --- |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | >= 4.9.0 |
| [`local`](https://registry.terraform.io/providers/local/latest) | >= 1.3 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | [![1.5.0](https://img.shields.io/badge/_____1.5.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`assume_role` | [![latest](https://img.shields.io/badge/____latest-success.svg?style=for-the-badge)](../account-map/modules/team-assume-role-policy) | [`../account-map/modules/team-assume-role-policy`](../account-map/modules/team-assume-role-policy) | n/a
`aws_saml` | [![1.5.0](https://img.shields.io/badge/_____1.5.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`iam_roles` | [![latest](https://img.shields.io/badge/____latest-success.svg?style=for-the-badge)](../account-map/modules/iam-roles) | [`../account-map/modules/iam-roles`](../account-map/modules/iam-roles) | n/a
`this` | [![0.25.0](https://img.shields.io/badge/____0.25.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_policy.team_role_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(policy-team-role-access.tf#27)
  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(main.tf#61)
  - [`aws_iam_role_policy_attachment.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(main.tf#71)
  - [`local_file.account_info`](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) (resource)(outputs.tf#22)

## Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.assume_role_aggregated`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.team_role_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Outputs

<dl>
  <dt><code>role_arns</code></dt>
  <dd>

  
  List of role ARNs<br/>

  </dd>
  <dt><code>team_name_role_arn_map</code></dt>
  <dd>

  
  Map of team names to role ARNs<br/>

  </dd>
  <dt><code>team_names</code></dt>
  <dd>

  
  List of team names<br/>

  </dd>
  <dt><code>teams_config</code></dt>
  <dd>

  
  Map of team config with name, target arn, and description<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `teams_config` <i>required</i>


A roles map to configure the accounts.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    denied_teams            = list(string)
    denied_permission_sets  = list(string)
    denied_role_arns        = list(string)
    max_session_duration    = number # in seconds 3600 <= max <= 43200 (12 hours)
    role_description        = string
    role_policy_arns        = list(string)
    aws_saml_login_enabled  = bool
    allowed_roles           = optional(map(list(string)), {})
    trusted_teams           = list(string)
    trusted_permission_sets = list(string)
    trusted_role_arns       = list(string)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `account_map_environment_name` (`string`) <i>optional</i>


The name of the environment where `account_map` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"gbl"</code>
>   </dd>
> </dl>
>


### `account_map_stage_name` (`string`) <i>optional</i>


The name of the stage where `account_map` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"root"</code>
>   </dd>
> </dl>
>


### `aws_saml_environment_name` (`string`) <i>optional</i>


The name of the environment where SSO is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"gbl"</code>
>   </dd>
> </dl>
>


### `aws_saml_stage_name` (`string`) <i>optional</i>


The name of the stage where SSO is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"identity"</code>
>   </dd>
> </dl>
>


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `trusted_github_repos` (`map(list(string))`) <i>optional</i>


Map where keys are role names (same keys as `teams_config`) and values are lists of<br/>
GitHub repositories allowed to assume those roles. See `account-map/modules/github-assume-role-policy.mixin.tf`<br/>
for specifics about repository designations.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(list(string))</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


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

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## Known Problems

### Error: `assume role policy: LimitExceeded: Cannot exceed quota for ACLSizePerRole: 2048`

The `aws-teams` architecture, when enabling access to a role via lots of AWS SSO Profiles, can create large "assume
role" policies, large enough to exceed the default quota of 2048 characters. If you run into this limitation, you will
get an error like this:

```
Error: error updating IAM Role (acme-gbl-root-tfstate-backend-analytics-ro) assume role policy: LimitExceeded: Cannot exceed quota for ACLSizePerRole: 2048
```

This can happen in either/both the `identity` and `root` accounts (for Terraform state access). So far, we have always
been able to resolve this by requesting a quota increase, which is automatically granted a few minutes after making the
request. To request the quota increase:

- Log in to the AWS Web console as admin in the affected account

- Set your region to N. Virginia `us-east-1`

- Navigate to the Service Quotas page via the account dropdown menu

- Click on AWS Services in the left sidebar

- Search for "IAM" and select "AWS Identity and Access Management (IAM)". (If you don't find that option, make sure you
  have selected the `us-east-1` region.

- Find and select "Role trust policy length"

- Request an increase to 4096 characters

- Wait for the request to be approved, usually less than a few minutes

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components)- Cloud Posse's upstream
  component
