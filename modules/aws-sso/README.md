# Component: `aws-sso`

This component is responsible for creating [AWS SSO Permission Sets][1] and creating AWS SSO Account Assignments, that
is, assigning IdP (Okta) groups and/or users to AWS SSO permission sets in specific AWS Accounts.

This component assumes that AWS SSO has already been enabled via the AWS Console (there isn't terraform or AWS CLI
support for this currently) and that the IdP has been configured to sync users and groups to AWS SSO.

## Usage

### Clickops

1. Go to root admin account
1. Select primary region
1. Go to AWS SSO
1. Enable AWS SSO

#### Delegation no longer recommended

Previously, Cloud Posse recommended delegating SSO to the identity account by following the next 2 steps:

1. Click Settings > Management
1. Delegate Identity as an administrator. This can take up to 30 minutes to take effect.

However, this is no longer recommended. Because the delegated SSO administrator cannot make changes in the `root`
account and this component needs to be able to make changes in the `root` account, any purported security advantage
achieved by delegating SSO to the `identity` account is lost.

Nevertheless, it is also not worth the effort to remove the delegation. If you have already delegated SSO to the
`identity`, continue on, leaving the stack configuration in the `gbl-identity` stack rather than the currently
recommended `gbl-root` stack.

### Google Workspace

:::important

> Your identity source is currently configured as 'External identity provider'. To add new groups or edit their
> memberships, you must do this using your external identity provider.

Groups _cannot_ be created with ClickOps in the AWS console and instead must be created with AWS API.

:::

Google Workspace is now supported by AWS Identity Center, but Group creation is not automatically handled. After
[configuring SAML and SCIM with Google Workspace and IAM Identity Center following the AWS documentation](https://docs.aws.amazon.com/singlesignon/latest/userguide/gs-gwp.html),
add any Group name to `var.groups` to create the Group with Terraform. Once the setup steps as described in the AWS
documentation have been completed and the Groups are created with Terraform, Users should automatically populate each
created Group.

```yaml
components:
  terraform:
    aws-sso:
      vars:
        groups:
          - "Developers"
          - "Dev Ops"
```

### Atmos

**Stack Level**: Global **Deployment**: Must be deployed by root-admin using `atmos` CLI

Add catalog to `gbl-root` root stack.

#### `account_assignments`

The `account_assignments` setting configures access to permission sets for users and groups in accounts, in the
following structure:

```yaml
<account-name>:
  groups:
    <group-name>:
      permission_sets:
        - <permission-set-name>
  users:
    <user-name>:
      permission_sets:
        - <permission-set-name>
```

- The account names (a.k.a. "stages") must already be configured via the `accounts` component.
- The user and group names must already exist in AWS SSO. Usually this is accomplished by configuring them in Okta and
  syncing Okta with AWS SSO.
- The permission sets are defined (by convention) in files names `policy-<permission-set-name>.tf` in the `aws-sso`
  component. The definition includes the name of the permission set. See
  `components/terraform/aws-sso/policy-AdminstratorAccess.tf` for an example.

#### `identity_roles_accessible`

The `identity_roles_accessible` element provides a list of role names corresponding to roles created in the
`iam-primary-roles` component. For each named role, a corresponding permission set will be created which allows the user
to assume that role. The permission set name is generated in Terraform from the role name using this statement:

```
format("Identity%sTeamAccess", replace(title(role), "-", ""))
```

### Defining a new permission set

1. Give the permission set a name, capitalized, in CamelCase, e.g. `AuditManager`. We will use `NAME` as a placeholder
   for the name in the instructions below. In Terraform, convert the name to lowercase snake case, e.g. `audit_manager`.
2. Create a file in the `aws-sso` directory with the name `policy-NAME.tf`.
3. In that file, create a policy as follows:

   ```hcl
   data "aws_iam_policy_document" "TerraformUpdateAccess" {
     # Define the custom policy here
   }

   locals {
     NAME_permission_set = {                         # e.g. audit_manager_permission_set
       name                                = "NAME",  # e.g. AuditManager
       description                         = "<description>",
       relay_state                         = "",
       session_duration                    = "PT1H", # One hour, maximum allowed for chained assumed roles
       tags                                = {},
       inline_policy                       = data.aws_iam_policy_document.NAME.json,
       policy_attachments                  = []  # ARNs of AWS managed IAM policies to attach, e.g. arn:aws:iam::aws:policy/ReadOnlyAccess
       customer_managed_policy_attachments = []  # ARNs of customer managed IAM policies to attach
     }
   }
   ```

4. Create a file named `additional-permission-sets-list_override.tf` in the `aws-sso` directory (if it does not already
   exist). This is a [terraform override file](https://developer.hashicorp.com/terraform/language/files/override),
   meaning its contents will be merged with the main terraform file, and any locals defined in it will override locals
   defined in other files. Having your code in this separate override file makes it possible for the component to
   provide a placeholder local variable so that it works without customization, while allowing you to customize the
   component and still update it without losing your customizations.
5. In that file, redefine the local variable `overridable_additional_permission_sets` as follows:

   ```hcl
   locals {
     overridable_additional_permission_sets = [
       local.NAME_permission_set,
     ]
   }
   ```

   If you have multiple custom policies, add each one to the list.

6. With that done, the new permission set will be created when the changes are applied. You can then use it just like
   the others.
7. If you want the permission set to be able to use Terraform, enable access to the Terraform state read/write (default)
   role in `tfstate-backend`.

#### Example

The example snippet below shows how to use this module with various combinations (plain YAML, YAML Anchors and a
combination of the two):

```yaml
prod-cloud-engineers: &prod-cloud-engineers
  Production Cloud Infrastructure Engineers:
    permission_sets:
      - AdministratorAccess
      - ReadOnlyAccess

components:
  terraform:
    aws-sso:
      vars:
        account_assignments:
          audit:
            groups:
              <<: *prod-cloud-engineers
              Production Cloud Engineers:
                permission_sets:
                  - ReadOnlyAccess
          corp:
            groups: *prod-cloud-engineers
          prod:
            groups:
              Admininstrators:
                permission_sets:
                  - AdministratorAccess
                  - ReadOnlyAccess
              Developers:
                permission_sets:
                  - ReadOnlyAccess
          dev:
            groups:
              Admininstrators:
                permission_sets:
                  - AdministratorAccess
                  - ReadOnlyAccess
              Developers:
                permission_sets:
                  - AdministratorAccess
                  - ReadOnlyAccess
        aws_teams_accessible:
          - "developers"
          - "devops"
          - "managers"
          - "support"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`account_map` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`iam_roles_root` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`permission_sets` | 1.1.1 | [`cloudposse/sso/aws//modules/permission-sets`](https://registry.terraform.io/modules/cloudposse/sso/aws/modules/permission-sets/1.1.1) | n/a
`role_map` | latest | [`../account-map/modules/roles-to-principals`](https://registry.terraform.io/modules/../account-map/modules/roles-to-principals/) | n/a
`sso_account_assignments` | 1.1.1 | [`cloudposse/sso/aws//modules/account-assignments`](https://registry.terraform.io/modules/cloudposse/sso/aws/modules/account-assignments/1.1.1) | n/a
`sso_account_assignments_root` | 1.1.1 | [`cloudposse/sso/aws//modules/account-assignments`](https://registry.terraform.io/modules/cloudposse/sso/aws/modules/account-assignments/1.1.1) | n/a
`tfstate` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_identitystore_group.manual`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/identitystore_group) (resource)(main.tf#67)

### Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.assume_aws_team`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.dns_administrator_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.eks_read_only`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.terraform_update_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_ssoadmin_instances.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

</details

---


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

</details

---


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  
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
</dl>

</details

---


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


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

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

</details

---


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `number`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


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

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `set(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "default"
  ]
  ```
  
  </dd>
</dl>

</details

---


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

</details

---


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---



</details>

### Required Inputs
### `region` (`string`) <i>required</i>


AWS Region<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

</details

---



### Optional Inputs
### `account_assignments` <i>optional</i>


Enables access to permission sets for users and groups in accounts, in the following structure:<br/>
<br/>
```yaml<br/>
<account-name>:<br/>
  groups:<br/>
    <group-name>:<br/>
      permission_sets:<br/>
        - <permission-set-name><br/>
  users:<br/>
    <user-name>:<br/>
      permission_sets:<br/>
        - <permission-set-name><br/>
```<br/>
<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(map(map(object({
    permission_sets = list(string)
    }
  ))))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

</details

---


### `aws_teams_accessible` (`set(string)`) <i>optional</i>


List of IAM roles (e.g. ["admin", "terraform"]) for which to create permission<br/>
sets that allow the user to assume that role. Named like<br/>
admin -> IdentityAdminTeamAccess<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `set(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

</details

---


### `groups` (`list(string)`) <i>optional</i>


List of AWS Identity Center Groups to be created with the AWS API.<br/>
<br/>
When provisioning the Google Workspace Integration with AWS, Groups need to be created with API in order for automatic provisioning to work as intended.<br/>
<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

</details

---


### `privileged` (`bool`) <i>optional</i>


True if the user running the Terraform command already has access to the Terraform backend<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

</details

---


### `tfstate_environment_name` (`string`) <i>optional</i>


The name of the environment where `tfstate-backend` is provisioned. If not set, the TerraformUpdateAccess permission set will not be created.<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

</details

---



### Outputs

<dl>
  <dt><code>group_ids</code></dt>
  <dd>
    Group IDs created for Identity Center<br/>
  </dd>
  <dt><code>permission_sets</code></dt>
  <dd>
    Permission sets<br/>
  </dd>
  <dt><code>sso_account_assignments</code></dt>
  <dd>
    SSO account assignments<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-sso][39]

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>][40]

[1]: https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html
[2]: #requirement%5C_terraform
[3]: #requirement%5C_aws
[4]: #requirement%5C_external
[5]: #requirement%5C_local
[6]: #requirement%5C_template
[7]: #requirement%5C_utils
[8]: #provider%5C_aws
[9]: #module%5C_account%5C_map
[10]: #module%5C_permission%5C_sets
[11]: #module%5C_role%5C_prefix
[12]: #module%5C_sso%5C_account%5C_assignments
[13]: #module%5C_this
[14]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[15]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[16]: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[17]: #input%5C_account%5C_assignments
[18]: #input%5C_additional%5C_tag%5C_map
[19]: #input%5C_attributes
[20]: #input%5C_context
[21]: #input%5C_delimiter
[22]: #input%5C_enabled
[23]: #input%5C_environment
[24]: #input%5C_global%5C_environment%5C_name
[25]: #input%5C_iam%5C_primary%5C_roles%5C_stage%5C_name
[26]: #input%5C_id%5C_length%5C_limit
[27]: #input%5C_identity%5C_roles%5C_accessible
[28]: #input%5C_label%5C_key%5C_case
[29]: #input%5C_label%5C_order
[30]: #input%5C_label%5C_value%5C_case
[31]: #input%5C_name
[32]: #input%5C_namespace
[33]: #input%5C_privileged
[34]: #input%5C_regex%5C_replace%5C_chars
[35]: #input%5C_region
[36]: #input%5C_root%5C_account%5C_stage%5C_name
[37]: #input%5C_stage
[38]: #input%5C_tags
[39]: https://github.com/cloudposse/terraform-aws-sso
[40]: https://cpco.io/component
