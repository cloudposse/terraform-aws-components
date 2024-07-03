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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`postgresql`](https://registry.terraform.io/modules/postgresql/>= 1.17.1), version: >= 1.17.1

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0
- `postgresql`, version: >= 1.17.1

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`additional_grants` | latest | [`./modules/postgresql-user`](https://registry.terraform.io/modules/./modules/postgresql-user/) | n/a
`additional_users` | latest | [`./modules/postgresql-user`](https://registry.terraform.io/modules/./modules/postgresql-user/) | n/a
`aurora_postgres` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`postgresql_database.additional`](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) (resource)
  - [`postgresql_schema.additional`](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/schema) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.admin_password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
  ### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>
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

---


  ### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>
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

---


  ### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>
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

---


  ### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>
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

---


  ### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>
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

---


  ### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
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

---


  ### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>
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

---


  ### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>
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

---


  ### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>
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

---


  ### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>
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

---


  ### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>
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

---


  ### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
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

---


  ### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>
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

---


  ### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
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

---


  ### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>
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

---


  ### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
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

---


</details>

### Required Inputs
  ### `region` (`string`) <i>required</i>


AWS Region<br/>
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

---



### Optional Inputs
  ### `additional_databases` (`set(string)`) <i>optional</i>


Additional databases to be created with the cluster<br/>
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

---


  ### `additional_grants` <i>optional</i>


Create additional database user with specified grants.<br/>
If `var.ssm_password_source` is set, passwords will be retrieved from SSM parameter store,<br/>
otherwise, passwords will be generated and stored in SSM parameter store under the service's key.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(list(object({
    grant : list(string)
    db : string
  })))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `additional_schemas` <i>optional</i>


Create additonal schemas for a given database.<br/>
If no database is given, the schema will use the database used by the provider configuration<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(object({
    database : string
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `additional_users` <i>optional</i>


Create additional database user for a service, specifying username, grants, and optional password.<br/>
If no password is specified, one will be generated. Username and password will be stored in<br/>
SSM parameter store under the service's key.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(object({
    db_user : string
    db_password : string
    grants : list(object({
      grant : list(string)
      db : string
      schema : string
      object_type : string
    }))
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `admin_password` (`string`) <i>optional</i>


postgresql password for the admin user<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `aurora_postgres_component_name` (`string`) <i>optional</i>


Aurora Postgres component name to read the remote state from<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"aurora-postgres"`
  </dd>
</dl>

---


  ### `cluster_enabled` (`string`) <i>optional</i>


Set to `false` to prevent the module from creating any resources<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `db_name` (`string`) <i>optional</i>


Database name (default is not to create a database)<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `read_passwords_from_ssm` (`bool`) <i>optional</i>


When `true`, fetch user passwords from SSM<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `ssm_password_source` (`string`) <i>optional</i>


If var.read_passwords_from_ssm is true, DB user passwords will be retrieved from SSM using `var.ssm_password_source` and the database username. If this value is not set, a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `ssm_path_prefix` (`string`) <i>optional</i>


SSM path prefix<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"aurora-postgres"`
  </dd>
</dl>

---



### Outputs

<dl>
  <dt>`additional_databases`</dt>
  <dd>
    Additional databases<br/>
  </dd>
  <dt>`additional_grants`</dt>
  <dd>
    Additional grants<br/>
  </dd>
  <dt>`additional_schemas`</dt>
  <dd>
    Additional schemas<br/>
  </dd>
  <dt>`additional_users`</dt>
  <dd>
    Additional users<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-postgres-resources) -
  Cloud Posse's upstream component

- PostgreSQL references (select the correct version of PostgreSQL at the top of the page):
  - [GRANT command](https://www.postgresql.org/docs/14/sql-grant.html)
  - [Privileges that can be GRANTed](https://www.postgresql.org/docs/14/ddl-priv.html)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
