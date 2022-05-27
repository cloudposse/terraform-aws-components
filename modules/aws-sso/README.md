# Component: `aws-sso`

This component is responsible for creating [AWS SSO Permission Sets][1] and creating AWS SSO Account Assignments, that is, assigning IdP (Okta) groups and/or users to AWS SSO permission sets in specific AWS Accounts.

This component assumes that AWS SSO has already been enabled via the AWS Console (there isn't terraform or AWS CLI support for this currently) and that the IdP has been configured to sync users and groups to AWS SSO.

## Usage

**Stack Level**: Global
**Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

#### `account_assignments`
The `account_assignments` setting configures access to permission sets for users and groups in accounts, in the following structure:

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
- The user and group names must already exist in AWS SSO. Usually this is accomplished by configuring them in Okta and syncing Okta with AWS SSO.
- The permission sets are defined (by convention) in files names `policy-<permission-set-name>.tf` in the `aws-sso` component. The definition includes the name of the permission set. See `components/terraform/aws-sso/policy-AdminstratorAccess.tf` for an example.

#### `identity_roles_accessible`
The `identity_roles_accessible` element provides a list of role names corresponding to roles created in the `iam-primary-roles` component. For each names role, a corresponding permission set will be created which allows the user to assume that role. The permission set name is generated in Terraform from the role name using this statement:

```
format("Identity%sRoleAccess", title(role))
```

#### Example
The example snippet below shows how to use this module with various combinations (plain YAML, YAML Anchors and a combination of the two):

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
        identity_roles_accessible:
        - "admin"
        - "ops"
        - "poweruser"
        - "observer"
        - "reader"
        - "support"
        - "viewer"

```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 0.22.2 |
| <a name="module_permission_sets"></a> [permission\_sets](#module\_permission\_sets) | cloudposse/sso/aws//modules/permission-sets | 0.6.2 |
| <a name="module_role_prefix"></a> [role\_prefix](#module\_role\_prefix) | cloudposse/label/null | 0.25.0 |
| <a name="module_sso_account_assignments"></a> [sso\_account\_assignments](#module\_sso\_account\_assignments) | cloudposse/sso/aws//modules/account-assignments | 0.6.2 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.assume_identity_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.dns_administrator_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_assignments"></a> [account\_assignments](#input\_account\_assignments) | Enables access to permission sets for users and groups in accounts, in the following structure:<pre>yaml<br><account-name>:<br>  groups:<br>    <group-name>:<br>      permission_sets:<br>        - <permission-set-name><br>  users:<br>    <user-name>:<br>      permission_sets:<br>        - <permission-set-name></pre> | <pre>map(map(map(object({<br>    permission_sets = list(string)<br>    }<br>  ))))</pre> | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_global_environment_name"></a> [global\_environment\_name](#input\_global\_environment\_name) | Global environment name | `string` | `"gbl"` | no |
| <a name="input_iam_primary_roles_stage_name"></a> [iam\_primary\_roles\_stage\_name](#input\_iam\_primary\_roles\_stage\_name) | The name of the stage where the IAM primary roles are provisioned | `string` | `"identity"` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_identity_roles_accessible"></a> [identity\_roles\_accessible](#input\_identity\_roles\_accessible) | List of IAM roles (e.g. ["admin", "terraform"]) for which to create permission<br>sets that allow the user to assume that role. Named like<br>admin -> IdentityAdminRoleAccess | `set(string)` | `[]` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_privileged"></a> [privileged](#input\_privileged) | True if the default provider already has access to the backend | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_root_account_stage_name"></a> [root\_account\_stage\_name](#input\_root\_account\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-sso][39]

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>][40]

[1]:	https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html
[2]:	#requirement%5C_terraform
[3]:	#requirement%5C_aws
[4]:	#requirement%5C_external
[5]:	#requirement%5C_local
[6]:	#requirement%5C_template
[7]:	#requirement%5C_utils
[8]:	#provider%5C_aws
[9]:	#module%5C_account%5C_map
[10]:	#module%5C_permission%5C_sets
[11]:	#module%5C_role%5C_prefix
[12]:	#module%5C_sso%5C_account%5C_assignments
[13]:	#module%5C_this
[14]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[15]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[16]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[17]:	#input%5C_account%5C_assignments
[18]:	#input%5C_additional%5C_tag%5C_map
[19]:	#input%5C_attributes
[20]:	#input%5C_context
[21]:	#input%5C_delimiter
[22]:	#input%5C_enabled
[23]:	#input%5C_environment
[24]:	#input%5C_global%5C_environment%5C_name
[25]:	#input%5C_iam%5C_primary%5C_roles%5C_stage%5C_name
[26]:	#input%5C_id%5C_length%5C_limit
[27]:	#input%5C_identity%5C_roles%5C_accessible
[28]:	#input%5C_label%5C_key%5C_case
[29]:	#input%5C_label%5C_order
[30]:	#input%5C_label%5C_value%5C_case
[31]:	#input%5C_name
[32]:	#input%5C_namespace
[33]:	#input%5C_privileged
[34]:	#input%5C_regex%5C_replace%5C_chars
[35]:	#input%5C_region
[36]:	#input%5C_root%5C_account%5C_stage%5C_name
[37]:	#input%5C_stage
[38]:	#input%5C_tags
[39]:	https://github.com/cloudposse/terraform-aws-sso
[40]:	https://cpco.io/component
