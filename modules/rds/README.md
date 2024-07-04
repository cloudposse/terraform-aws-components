# Component: `rds`

This component is responsible for provisioning an RDS instance. It seeds relevant database information (hostnames,
username, password, etc.) into AWS SSM Parameter Store.

## Security Groups Guidance:

By default this component creates a client security group and adds that security group id to the default attached
security group. Ideally other AWS resources that require RDS access can be granted this client security group.
Additionally you can grant access via specific CIDR blocks or security group ids.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

### PostgreSQL

```yaml
components:
  terraform:
    rds/defaults:
      metadata:
        type: abstract
      vars:
        enabled: true
        use_fullname: false
        name: my-postgres-db
        instance_class: db.t3.micro
        database_name: my-postgres-db
        # database_user: admin # enable to specify something specific
        engine: postgres
        engine_version: "15.2"
        database_port: 5432
        db_parameter_group: "postgres15"
        allocated_storage: 10 #GBs
        ssm_enabled: true
        client_security_group_enabled: true
        ## The following settings allow the database to be accessed from anywhere
        # publicly_accessible: true
        # use_private_subnets: false
        # allowed_cidr_blocks:
        #  - 0.0.0.0/0
```

### Microsoft SQL

```yaml
components:
  terraform:
    rds:
      vars:
        enabled: true
        name: mssql
        # SQL Server 2017 Enterprise
        engine: sqlserver-ee
        engine_version: "14.00.3356.20"
        db_parameter_group: "sqlserver-ee-14.0"
        license_model: license-included
        # Required for MSSQL
        database_name: null
        database_port: 1433
        database_user: mssql
        instance_class: db.t3.xlarge
        # There are issues with enabling this
        multi_az: false
        allocated_storage: 20
        publicly_accessible: false
        ssm_enabled: true
        # This does not seem to work correctly
        deletion_protection: false
```

### Provisioning from a snapshot

The snapshot identifier variable can be added to provision an instance from a snapshot HOWEVER- Keep in mind these
instances are provisioned from a unique kms key per rds. For clean terraform runs, you must first provision the key for
the destination instance, then copy the snapshot using that kms key.

Example - I want a new instance `rds-example-new` to be provisioned from a snapshot of `rds-example-old`:

1. Use the console to manually make a snapshot of rds instance `rds-example-old`
1. provision the kms key for `rds-example-new`

   ```
   atmos terraform plan  rds-example-new -s ue1-staging '-target=module.kms_key_rds.aws_kms_key.default[0]'
   atmos terraform apply rds-example-new -s ue1-staging '-target=module.kms_key_rds.aws_kms_key.default[0]'
   ```

1. Use the console to copy the snapshot to a new name using the above provisioned kms key
1. Add `snapshot_identifier` variable to `rds-example-new` catalog and specify the newly copied snapshot that used the
   above key
1. Post provisioning, remove the `snapshot_idenfier` variable and verify terraform runs clean for the copied instance

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `random` | >= 2.3 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |
| `random` | >= 2.3 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dns_gbl_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`kms_key_rds` | 0.12.1 | [`cloudposse/kms-key/aws`](https://registry.terraform.io/modules/cloudposse/kms-key/aws/0.12.1) | n/a
`rds_client_sg` | 2.2.0 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/2.2.0) | n/a
`rds_instance` | 1.1.0 | [`cloudposse/rds/aws`](https://registry.terraform.io/modules/cloudposse/rds/aws/1.1.0) | n/a
`rds_monitoring_role` | 0.17.0 | [`cloudposse/iam-role/aws`](https://registry.terraform.io/modules/cloudposse/iam-role/aws/0.17.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.rds_database_hostname`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(systems-manager.tf#77)
  - [`aws_ssm_parameter.rds_database_password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(systems-manager.tf#66)
  - [`aws_ssm_parameter.rds_database_port`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(systems-manager.tf#87)
  - [`aws_ssm_parameter.rds_database_user`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(systems-manager.tf#56)
  - [`random_password.database_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)(main.tf#113)
  - [`random_pet.database_user`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)(main.tf#100)

## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_iam_policy_document.kms_key_rds`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Outputs

<dl>
  <dt><code>exports</code></dt>
  <dd>
    Map of exports for use in deployment configuration templates<br/>

  </dd>
  <dt><code>kms_key_alias</code></dt>
  <dd>
    The KMS key alias<br/>

  </dd>
  <dt><code>psql_helper</code></dt>
  <dd>
    A helper output to use with psql for connecting to this RDS instance.<br/>

  </dd>
  <dt><code>rds_address</code></dt>
  <dd>
    Address of the instance<br/>

  </dd>
  <dt><code>rds_arn</code></dt>
  <dd>
    ARN of the instance<br/>

  </dd>
  <dt><code>rds_database_ssm_key_prefix</code></dt>
  <dd>
    SSM prefix<br/>

  </dd>
  <dt><code>rds_endpoint</code></dt>
  <dd>
    DNS Endpoint of the instance<br/>

  </dd>
  <dt><code>rds_hostname</code></dt>
  <dd>
    DNS host name of the instance<br/>

  </dd>
  <dt><code>rds_id</code></dt>
  <dd>
    ID of the instance<br/>

  </dd>
  <dt><code>rds_name</code></dt>
  <dd>
    RDS DB name<br/>

  </dd>
  <dt><code>rds_option_group_id</code></dt>
  <dd>
    ID of the Option Group<br/>

  </dd>
  <dt><code>rds_parameter_group_id</code></dt>
  <dd>
    ID of the Parameter Group<br/>

  </dd>
  <dt><code>rds_port</code></dt>
  <dd>
    RDS DB port<br/>

  </dd>
  <dt><code>rds_resource_id</code></dt>
  <dd>
    The RDS Resource ID of this instance.<br/>

  </dd>
  <dt><code>rds_security_group_id</code></dt>
  <dd>
    ID of the Security Group<br/>

  </dd>
  <dt><code>rds_subnet_group_id</code></dt>
  <dd>
    ID of the created Subnet Group<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `allocated_storage` (`number`) <i>required</i>


The allocated storage in GBs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `database_name` (`string`) <i>required</i>


The name of the database to create when the DB instance is created<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `database_port` (`number`) <i>required</i>


Database port (_e.g._ `3306` for `MySQL`). Used in the DB Security Group to allow access to the DB instance from the provided `security_group_ids`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `db_parameter_group` (`string`) <i>required</i>


The DB parameter group family name. The value depends on DB engine used. See [DBParameterGroupFamily](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBParameterGroup.html#API_CreateDBParameterGroup_RequestParameters) for instructions on how to retrieve applicable value.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `engine` (`string`) <i>required</i>


Database engine type<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `engine_version` (`string`) <i>required</i>


Database engine version, depends on engine type<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `instance_class` (`string`) <i>required</i>


Class of RDS instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `allow_major_version_upgrade` (`bool`) <i>optional</i>


Allow major version upgrade<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `allowed_cidr_blocks` (`list(string)`) <i>optional</i>


The whitelisted CIDRs which to allow `ingress` traffic to the DB instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `apply_immediately` (`bool`) <i>optional</i>


Specifies whether any database modifications are applied immediately, or during the next maintenance window<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `associate_security_group_ids` (`list(string)`) <i>optional</i>


The IDs of the existing security groups to associate with the DB instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `auto_minor_version_upgrade` (`bool`) <i>optional</i>


Allow automated minor version upgrade (e.g. from Postgres 9.5.3 to Postgres 9.5.4)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `availability_zone` (`string`) <i>optional</i>


The AZ for the RDS instance. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`. If `availability_zone` is provided, the instance will be placed into the default VPC or EC2 Classic<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `backup_retention_period` (`number`) <i>optional</i>


Backup retention period in days. Must be > 0 to enable backups<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>0</code>
>   </dd>
> </dl>
>


### `backup_window` (`string`) <i>optional</i>


When AWS can perform DB snapshots, can't overlap with maintenance window<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"22:00-03:00"</code>
>   </dd>
> </dl>
>


### `ca_cert_identifier` (`string`) <i>optional</i>


The identifier of the CA certificate for the DB instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `charset_name` (`string`) <i>optional</i>


The character set name to use for DB encoding. [Oracle & Microsoft SQL only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance#character_set_name). For other engines use `db_parameter`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `client_security_group_enabled` (`bool`) <i>optional</i>


create a client security group and include in attached default security group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `copy_tags_to_snapshot` (`bool`) <i>optional</i>


Copy tags from DB to a snapshot<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `database_password` (`string`) <i>optional</i>


Database password for the admin user<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `database_user` (`string`) <i>optional</i>


Database admin user name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `db_options` <i>optional</i>


A list of DB options to apply with an option group. Depends on DB engine<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    db_security_group_memberships  = list(string)
    option_name                    = string
    port                           = number
    version                        = string
    vpc_security_group_memberships = list(string)

    option_settings = list(object({
      name  = string
      value = string
    }))
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `db_parameter` <i>optional</i>


A list of DB parameters to apply. Note that parameters may differ from a DB family to another<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    apply_method = string
    name         = string
    value        = string
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `db_subnet_group_name` (`string`) <i>optional</i>


Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. Specify one of `subnet_ids`, `db_subnet_group_name` or `availability_zone`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `deletion_protection` (`bool`) <i>optional</i>


Set to true to enable deletion protection on the RDS instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `dns_gbl_delegated_environment_name` (`string`) <i>optional</i>


The name of the environment where global `dns_delegated` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"gbl"</code>
>   </dd>
> </dl>
>


### `dns_zone_id` (`string`) <i>optional</i>


The ID of the DNS Zone in Route53 where a new DNS record will be created for the DB host name<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `enabled_cloudwatch_logs_exports` (`list(string)`) <i>optional</i>


List of log types to enable for exporting to CloudWatch logs. If omitted, no logs will be exported. Valid values (depending on engine): alert, audit, error, general, listener, slowquery, trace, postgresql (PostgreSQL), upgrade (PostgreSQL).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `final_snapshot_identifier` (`string`) <i>optional</i>


Final snapshot identifier e.g.: some-db-final-snapshot-2019-06-26-06-05<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `host_name` (`string`) <i>optional</i>


The DB host name created in Route53<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"db"</code>
>   </dd>
> </dl>
>


### `iam_database_authentication_enabled` (`bool`) <i>optional</i>


Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `iops` (`number`) <i>optional</i>


The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'. Default is 0 if rds storage type is not 'io1'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>0</code>
>   </dd>
> </dl>
>


### `kms_alias_name_ssm` (`string`) <i>optional</i>


KMS alias name for SSM<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"alias/aws/ssm"</code>
>   </dd>
> </dl>
>


### `kms_key_arn` (`string`) <i>optional</i>


The ARN of the existing KMS key to encrypt storage<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `license_model` (`string`) <i>optional</i>


License model for this DB. Optional, but required for some DB Engines. Valid values: license-included | bring-your-own-license | general-public-license<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `maintenance_window` (`string`) <i>optional</i>


The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi' UTC <br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"Mon:03:00-Mon:04:00"</code>
>   </dd>
> </dl>
>


### `major_engine_version` (`string`) <i>optional</i>


Database MAJOR engine version, depends on engine type<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `max_allocated_storage` (`number`) <i>optional</i>


The upper limit to which RDS can automatically scale the storage in GBs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>0</code>
>   </dd>
> </dl>
>


### `monitoring_interval` (`string`) <i>optional</i>


The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. Valid Values are 0, 1, 5, 10, 15, 30, 60.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"0"</code>
>   </dd>
> </dl>
>


### `monitoring_role_arn` (`string`) <i>optional</i>


The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `multi_az` (`bool`) <i>optional</i>


Set to true if multi AZ deployment must be supported<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `option_group_name` (`string`) <i>optional</i>


Name of the DB option group to associate<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `parameter_group_name` (`string`) <i>optional</i>


Name of the DB parameter group to associate<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `performance_insights_enabled` (`bool`) <i>optional</i>


Specifies whether Performance Insights are enabled.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `performance_insights_kms_key_id` (`string`) <i>optional</i>


The ARN for the KMS key to encrypt Performance Insights data. Once KMS key is set, it can never be changed.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `performance_insights_retention_period` (`number`) <i>optional</i>


The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>7</code>
>   </dd>
> </dl>
>


### `publicly_accessible` (`bool`) <i>optional</i>


Determines if database can be publicly available (NOT recommended)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `replicate_source_db` (`any`) <i>optional</i>


If the rds db instance is a replica, supply the source database identifier here<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `security_group_ids` (`list(string)`) <i>optional</i>


The IDs of the security groups from which to allow `ingress` traffic to the DB instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `skip_final_snapshot` (`bool`) <i>optional</i>


If true (default), no snapshot will be made before deleting DB<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `snapshot_identifier` (`string`) <i>optional</i>


Snapshot identifier e.g: rds:production-2019-06-26-06-05. If specified, the module create cluster from the snapshot<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `ssm_enabled` (`bool`) <i>optional</i>


If `true` create SSM keys for the database user and password.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `ssm_key_format` (`string`) <i>optional</i>


SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `var.name`, `var.ssm_key_*`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"/%v/%v/%v"</code>
>   </dd>
> </dl>
>


### `ssm_key_hostname` (`string`) <i>optional</i>


The SSM key to save the hostname. See `var.ssm_path_format`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"admin/db_hostname"</code>
>   </dd>
> </dl>
>


### `ssm_key_password` (`string`) <i>optional</i>


The SSM key to save the password. See `var.ssm_path_format`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"admin/db_password"</code>
>   </dd>
> </dl>
>


### `ssm_key_port` (`string`) <i>optional</i>


The SSM key to save the port. See `var.ssm_path_format`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"admin/db_port"</code>
>   </dd>
> </dl>
>


### `ssm_key_prefix` (`string`) <i>optional</i>


SSM path prefix. Omit the leading forward slash `/`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"rds"</code>
>   </dd>
> </dl>
>


### `ssm_key_user` (`string`) <i>optional</i>


The SSM key to save the user. See `var.ssm_path_format`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"admin/db_user"</code>
>   </dd>
> </dl>
>


### `storage_encrypted` (`bool`) <i>optional</i>


(Optional) Specifies whether the DB instance is encrypted. The default is false if not specified<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `storage_throughput` (`number`) <i>optional</i>


The storage throughput value for the DB instance. Can only be set when `storage_type` is `gp3`. Cannot be specified if the `allocated_storage` value is below a per-engine threshold.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `storage_type` (`string`) <i>optional</i>


One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"standard"</code>
>   </dd>
> </dl>
>


### `timezone` (`string`) <i>optional</i>


Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation. See [MSSQL User Guide](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SQLServer.html#SQLServer.Concepts.General.TimeZone) for more information.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `use_dns_delegated` (`bool`) <i>optional</i>


Use the dns-delegated dns_zone_id<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `use_eks_security_group` (`bool`) <i>optional</i>


Use the eks default security group<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `use_private_subnets` (`bool`) <i>optional</i>


Use private subnets<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/rds) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
