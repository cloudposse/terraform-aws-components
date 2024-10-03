---
tags:
  - component/aurora-postgres-resources
  - layer/data
  - provider/aws
---

# Component: `aurora-postgres-resources`

This component is responsible for provisioning Aurora Postgres resources: additional databases, users, permissions,
grants, etc.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    aurora-postgres-resources:
      vars:
        aurora_postgres_component_name: aurora-postgres-example
        additional_users:
          example:
            db_user: example
            db_password: ""
            grants:
              - grant: ["ALL"]
                db: example
                object_type: database
                schema: ""
```

## PostgreSQL Quick Reference on Grants

GRANTS can be on database, schema, role, table, and other database objects (e.g. columns in a table for fine control).
Database and schema do not have much to grant. The `object_type` field in the input determines which kind of object the
grant is being applied to. The `db` field is always required. The `schema` field is required unless the `object_type` is
`db`, in which case it should be set to the empty string (`""`).

The keyword PUBLIC indicates that the privileges are to be granted to all roles, including those that might be created
later. PUBLIC can be thought of as an implicitly defined group that always includes all roles. Any particular role will
have the sum of privileges granted directly to it, privileges granted to any role it is presently a member of, and
privileges granted to PUBLIC.

When an object is created, it is assigned an owner. The owner is normally the role that executed the creation statement.
For most kinds of objects, the initial state is that only the owner (or a superuser) can do anything with the object. To
allow other roles to use it, privileges must be granted. (When using AWS managed RDS, you cannot have access to any
superuser roles; superuser is reserved for AWS to use to manage the cluster.)

PostgreSQL grants privileges on some types of objects to PUBLIC by default when the objects are created. No privileges
are granted to PUBLIC by default on tables, table columns, sequences, foreign data wrappers, foreign servers, large
objects, schemas, or tablespaces. For other types of objects, the default privileges granted to PUBLIC are as follows:
CONNECT and TEMPORARY (create temporary tables) privileges for databases; EXECUTE privilege for functions and
procedures; and USAGE privilege for languages and data types (including domains). The object owner can, of course,
REVOKE both default and expressly granted privileges. (For maximum security, issue the REVOKE in the same transaction
that creates the object; then there is no window in which another user can use the object.) Also, these default
privilege settings can be overridden using the ALTER DEFAULT PRIVILEGES command.

The CREATE privilege:

- For databases, allows new schemas and publications to be created within the database, and allows trusted extensions to
  be installed within the database.
- For schemas, allows new objects to be created within the schema. To rename an existing object, you must own the object
  and have this privilege for the containing schema.

For databases and schemas, there are not a lot of other privileges to grant, and all but CREATE are granted by default,
so you might as well grant "ALL". For tables etc., the creator has full control. You grant access to other users via
explicit grants. This component does not allow fine-grained grants. You have to specify the database, and unless the
grant is on the database, you have to specify the schema. For any other object type (table, sequence, function,
procedure, routine, foreign_data_wrapper, foreign_server, column), the component applies the grants to all objects of
that type in the specified schema.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >= 1.17.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | >= 1.17.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_additional_grants"></a> [additional\_grants](#module\_additional\_grants) | ./modules/postgresql-user | n/a |
| <a name="module_additional_users"></a> [additional\_users](#module\_additional\_users) | ./modules/postgresql-user | n/a |
| <a name="module_aurora_postgres"></a> [aurora\_postgres](#module\_aurora\_postgres) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [postgresql_database.additional](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_schema.additional](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) | resource |
| [aws_ssm_parameter.admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_databases"></a> [additional\_databases](#input\_additional\_databases) | Additional databases to be created with the cluster | `set(string)` | `[]` | no |
| <a name="input_additional_grants"></a> [additional\_grants](#input\_additional\_grants) | Create additional database user with specified grants.<br>If `var.ssm_password_source` is set, passwords will be retrieved from SSM parameter store,<br>otherwise, passwords will be generated and stored in SSM parameter store under the service's key. | <pre>map(list(object({<br>    grant : list(string)<br>    db : string<br>  })))</pre> | `{}` | no |
| <a name="input_additional_schemas"></a> [additional\_schemas](#input\_additional\_schemas) | Create additional schemas for a given database.<br>If no database is given, the schema will use the database used by the provider configuration | <pre>map(object({<br>    database : string<br>  }))</pre> | `{}` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_additional_users"></a> [additional\_users](#input\_additional\_users) | Create additional database user for a service, specifying username, grants, and optional password.<br>If no password is specified, one will be generated. Username and password will be stored in<br>SSM parameter store under the service's key. | <pre>map(object({<br>    db_user : string<br>    db_password : string<br>    grants : list(object({<br>      grant : list(string)<br>      db : string<br>      schema : string<br>      object_type : string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | postgresql password for the admin user | `string` | `""` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aurora_postgres_component_name"></a> [aurora\_postgres\_component\_name](#input\_aurora\_postgres\_component\_name) | Aurora Postgres component name to read the remote state from | `string` | `"aurora-postgres"` | no |
| <a name="input_cluster_enabled"></a> [cluster\_enabled](#input\_cluster\_enabled) | Set to `false` to prevent the module from creating any resources | `string` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name (default is not to create a database) | `string` | `""` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_read_passwords_from_ssm"></a> [read\_passwords\_from\_ssm](#input\_read\_passwords\_from\_ssm) | When `true`, fetch user passwords from SSM | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_ssm_password_source"></a> [ssm\_password\_source](#input\_ssm\_password\_source) | If var.read\_passwords\_from\_ssm is true, DB user passwords will be retrieved from SSM using `var.ssm_password_source` and the database username. If this value is not set, a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster. | `string` | `""` | no |
| <a name="input_ssm_path_prefix"></a> [ssm\_path\_prefix](#input\_ssm\_path\_prefix) | SSM path prefix | `string` | `"aurora-postgres"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_additional_databases"></a> [additional\_databases](#output\_additional\_databases) | Additional databases |
| <a name="output_additional_grants"></a> [additional\_grants](#output\_additional\_grants) | Additional grants |
| <a name="output_additional_schemas"></a> [additional\_schemas](#output\_additional\_schemas) | Additional schemas |
| <a name="output_additional_users"></a> [additional\_users](#output\_additional\_users) | Additional users |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-postgres-resources) -
  Cloud Posse's upstream component

- PostgreSQL references (select the correct version of PostgreSQL at the top of the page):
  - [GRANT command](https://www.postgresql.org/docs/14/sql-grant.html)
  - [Privileges that can be GRANTed](https://www.postgresql.org/docs/14/ddl-priv.html)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
