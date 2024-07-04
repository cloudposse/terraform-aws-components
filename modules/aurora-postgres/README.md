# Component: `aurora-postgres`

This component is responsible for provisioning Aurora Postgres RDS clusters. It seeds relevant database information
(hostnames, username, password, etc.) into AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example for how to use this component.

`stacks/catalog/aurora-postgres/defaults.yaml` file (base component for all Aurora Postgres clusters with default
settings):

```yaml
components:
  terraform:
    aurora-postgres/defaults:
      metadata:
        type: abstract
      vars:
        enabled: true
        name: aurora-postgres
        tags:
          Team: sre
          Service: aurora-postgres
        cluster_name: shared
        deletion_protection: false
        storage_encrypted: true
        engine: aurora-postgresql

        # Provisioned configuration
        engine_mode: provisioned
        engine_version: "15.3"
        cluster_family: aurora-postgresql15
        # 1 writer, 1 reader
        cluster_size: 2
        # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
        instance_type: db.t3.medium

        admin_user: postgres
        admin_password: "" # generate random password
        database_name: postgres
        database_port: 5432
        skip_final_snapshot: false
        # Enhanced Monitoring
        # A boolean flag to enable/disable the creation of the enhanced monitoring IAM role.
        # If set to false, the module will not create a new role and will use rds_monitoring_role_arn for enhanced monitoring
        enhanced_monitoring_role_enabled: true
        # The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance.
        # To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60
        rds_monitoring_interval: 15
        # Allow ingress from the following accounts
        # If any of tenant, stage, or environment aren't given, this will be taken
        allow_ingress_from_vpc_accounts:
          - tenant: core
            stage: auto
```

Example (not actual):

`stacks/uw2-dev.yaml` file (override the default settings for the cluster in the `dev` account, create an additional
database and user):

```yaml
import:
  - catalog/aurora-postgres/defaults

components:
  terraform:
    aurora-postgres:
      metadata:
        component: aurora-postgres
        inherits:
          - aurora-postgres/defaults
      vars:
        enabled: true
```

### Finding Aurora Engine Version

Use the following to query the AWS API by `engine-mode`. Both provisioned and Serverless v2 use the `privisoned` engine
mode, whereas only Serverless v1 uses the `serverless` engine mode.

```bash
aws rds describe-db-engine-versions \
  --engine aurora-postgresql \
  --query 'DBEngineVersions[].EngineVersion' \
  --filters 'Name=engine-mode,Values=serverless'
```

Use the following to query AWS API by `db-instance-class`. Use this query to find supported versions for a specific
instance class, such as `db.serverless` with Serverless v2.

```bash
aws rds describe-orderable-db-instance-options \
  --engine aurora-postgresql \
  --db-instance-class db.serverless \
  --query 'OrderableDBInstanceOptions[].[EngineVersion]'
```

Once a version has been selected, use the following to find the cluster family.

```bash
aws rds describe-db-engine-versions --engine aurora-postgresql --query "DBEngineVersions[]" | \
jq '.[] | select(.EngineVersion == "15.3") |
   { Engine: .Engine, EngineVersion: .EngineVersion, DBParameterGroupFamily: .DBParameterGroupFamily }'
```

## Examples

Generally there are three different engine configurations for Aurora: provisioned, Serverless v1, and Serverless v2.

### Provisioned Aurora Postgres

[See the default usage example above](#usage)

### Serverless v1 Aurora Postgres

Serverless v1 requires `engine-mode` set to `serverless` uses `scaling_configuration` to configure scaling options.

For valid values, see
[ModifyCurrentDBClusterCapacity](https://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_ModifyCurrentDBClusterCapacity.html).

```yaml
components:
  terraform:
    aurora-postgres:
      vars:
        enabled: true
        name: aurora-postgres
        eks_component_names:
          - eks/cluster
        allow_ingress_from_vpc_accounts:
          # Allows Spacelift
          - tenant: core
            stage: auto
            environment: use2
          # Allows VPN
          - tenant: core
            stage: network
            environment: use2
        cluster_name: shared
        engine: aurora-postgresql

        # Serverless v1 configuration
        engine_mode: serverless
        instance_type: "" # serverless engine_mode ignores `var.instance_type`
        engine_version: "13.9" # Latest supported version as of 08/28/2023
        cluster_family: aurora-postgresql13
        cluster_size: 0 # serverless
        scaling_configuration:
          - auto_pause: true
            max_capacity: 5
            min_capacity: 2
            seconds_until_auto_pause: 300
            timeout_action: null

        admin_user: postgres
        admin_password: "" # generate random password
        database_name: postgres
        database_port: 5432
        storage_encrypted: true
        deletion_protection: true
        skip_final_snapshot: false
        # Creating read-only users or additional databases requires Spacelift
        read_only_users_enabled: false
        # Enhanced Monitoring
        # A boolean flag to enable/disable the creation of the enhanced monitoring IAM role.
        # If set to false, the module will not create a new role and will use rds_monitoring_role_arn for enhanced monitoring
        enhanced_monitoring_role_enabled: true
        enhanced_monitoring_attributes: ["monitoring"]
        # The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance.
        # To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60
        rds_monitoring_interval: 15
        iam_database_authentication_enabled: false
        additional_users: {}
```

### Serverless v2 Aurora Postgres

Aurora Postgres Serverless v2 uses the `provisioned` engine mode with `db.serverless` instances. In order to configure
scaling with Serverless v2, use `var.serverlessv2_scaling_configuration`.

For more on valid scaling configurations, see
[Performance and scaling for Aurora Serverless v2](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v2.setting-capacity.html).

```yaml
components:
  terraform:
    aurora-postgres:
      vars:
        enabled: true
        name: aurora-postgres
        eks_component_names:
          - eks/cluster
        allow_ingress_from_vpc_accounts:
          # Allows Spacelift
          - tenant: core
            stage: auto
            environment: use2
          # Allows VPN
          - tenant: core
            stage: network
            environment: use2
        cluster_name: shared
        engine: aurora-postgresql

        # Serverless v2 configuration
        engine_mode: provisioned
        instance_type: "db.serverless"
        engine_version: "15.3"
        cluster_family: aurora-postgresql15
        cluster_size: 2
        serverlessv2_scaling_configuration:
          min_capacity: 2
          max_capacity: 64

        admin_user: postgres
        admin_password: "" # generate random password
        database_name: postgres
        database_port: 5432
        storage_encrypted: true
        deletion_protection: true
        skip_final_snapshot: false
        # Creating read-only users or additional databases requires Spacelift
        read_only_users_enabled: false
        # Enhanced Monitoring
        # A boolean flag to enable/disable the creation of the enhanced monitoring IAM role.
        # If set to false, the module will not create a new role and will use rds_monitoring_role_arn for enhanced monitoring
        enhanced_monitoring_role_enabled: true
        enhanced_monitoring_attributes: ["monitoring"]
        # The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance.
        # To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60
        rds_monitoring_interval: 15
        iam_database_authentication_enabled: false
        additional_users: {}
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |
| `postgresql` | >= 1.17.1 |
| `random` | >= 2.3 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `random` | >= 2.3 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`aurora_postgres_cluster` | 1.3.2 | [`cloudposse/rds-cluster/aws`](https://registry.terraform.io/modules/cloudposse/rds-cluster/aws/1.3.2) | https://www.terraform.io/docs/providers/aws/r/rds_cluster.html
`cluster` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`dns_gbl_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`kms_key_rds` | 0.12.1 | [`cloudposse/kms-key/aws`](https://registry.terraform.io/modules/cloudposse/kms-key/aws/0.12.1) | n/a
`parameter_store_write` | 0.11.0 | [`cloudposse/ssm-parameter-store/aws`](https://registry.terraform.io/modules/cloudposse/ssm-parameter-store/aws/0.11.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`vpc_ingress` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`random_password.admin_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)(main.tf#72)
  - [`random_pet.admin_user`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)(main.tf#60)
  - [`random_pet.database_name`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)(main.tf#49)

## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_iam_policy_document.kms_key_rds`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_security_groups.allowed`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) (data source)

## Required Variables
### `cluster_name` (`string`) <i>required</i>


Short name for this cluster<br/>

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


### `cluster_size` (`number`) <i>required</i>


Postgres cluster size<br/>

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


### `engine_mode` (`string`) <i>required</i>


The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`<br/>

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


### `instance_type` (`string`) <i>required</i>


EC2 instance type for Postgres cluster<br/>

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
### `admin_password` (`string`) <i>optional</i>


Postgres password for the admin user<br/>

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


### `admin_user` (`string`) <i>optional</i>


Postgres admin user name<br/>

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


### `allow_ingress_from_vpc_accounts` <i>optional</i>


List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br/>
e.g.<br/>
{<br/>
  environment = "ue2",<br/>
  stage       = "auto",<br/>
  tenant      = "core"<br/>
}<br/>
<br/>
Defaults to the "vpc" component in the given account<br/>
<br/>

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
    vpc         = optional(string, "vpc")
    environment = optional(string)
    stage       = optional(string)
    tenant      = optional(string)
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


### `allow_major_version_upgrade` (`bool`) <i>optional</i>


Enable to allow major engine version upgrades when changing engine versions. Defaults to false.<br/>

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


List of CIDRs allowed to access the database (in addition to security groups and subnets)<br/>

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


### `allowed_security_group_names` (`list(string)`) <i>optional</i>


List of security group names (tags) that should be allowed access to the database<br/>

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


### `autoscaling_enabled` (`bool`) <i>optional</i>


Whether to enable cluster autoscaling<br/>

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


### `autoscaling_max_capacity` (`number`) <i>optional</i>


Maximum number of instances to be maintained by the autoscaler<br/>

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
>    <code>5</code>
>   </dd>
> </dl>
>


### `autoscaling_min_capacity` (`number`) <i>optional</i>


Minimum number of instances to be maintained by the autoscaler<br/>

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
>    <code>1</code>
>   </dd>
> </dl>
>


### `autoscaling_policy_type` (`string`) <i>optional</i>


Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported<br/>

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
>    <code>"TargetTrackingScaling"</code>
>   </dd>
> </dl>
>


### `autoscaling_scale_in_cooldown` (`number`) <i>optional</i>


The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. Default is 300s<br/>

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
>    <code>300</code>
>   </dd>
> </dl>
>


### `autoscaling_scale_out_cooldown` (`number`) <i>optional</i>


The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. Default is 300s<br/>

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
>    <code>300</code>
>   </dd>
> </dl>
>


### `autoscaling_target_metrics` (`string`) <i>optional</i>


The metrics type to use. If this value isn't provided the default is CPU utilization<br/>

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
>    <code>"RDSReaderAverageCPUUtilization"</code>
>   </dd>
> </dl>
>


### `autoscaling_target_value` (`number`) <i>optional</i>


The target value to scale with respect to target metrics<br/>

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
>    <code>75</code>
>   </dd>
> </dl>
>


### `backup_window` (`string`) <i>optional</i>


Daily time range during which the backups happen, UTC<br/>

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
>    <code>"07:00-09:00"</code>
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


### `cluster_dns_name_part` (`string`) <i>optional</i>


Part of DNS name added to module and cluster name for DNS for cluster endpoint<br/>

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
>    <code>"writer"</code>
>   </dd>
> </dl>
>


### `cluster_family` (`string`) <i>optional</i>


Family of the DB parameter group. Valid values for Aurora PostgreSQL: `aurora-postgresql9.6`, `aurora-postgresql10`, `aurora-postgresql11`, `aurora-postgresql12`<br/>

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
>    <code>"aurora-postgresql13"</code>
>   </dd>
> </dl>
>


### `cluster_parameters` <i>optional</i>


List of DB cluster parameters to apply<br/>

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


### `database_name` (`string`) <i>optional</i>


Name for an automatically created database on cluster creation. An empty name will generate a db name.<br/>

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


### `database_port` (`number`) <i>optional</i>


Database port<br/>

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
>    <code>5432</code>
>   </dd>
> </dl>
>


### `deletion_protection` (`bool`) <i>optional</i>


Specifies whether the Cluster should have deletion protection enabled. The database can't be deleted when this value is set to `true`<br/>

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


### `eks_component_names` (`set(string)`) <i>optional</i>


The names of the eks components<br/>

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
>      "eks/cluster"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `eks_security_group_enabled` (`bool`) <i>optional</i>


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


### `enabled_cloudwatch_logs_exports` (`list(string)`) <i>optional</i>


List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery<br/>

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


### `engine` (`string`) <i>optional</i>


Name of the database engine to be used for the DB cluster<br/>

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
>    <code>"postgresql"</code>
>   </dd>
> </dl>
>


### `engine_version` (`string`) <i>optional</i>


Engine version of the Aurora global database<br/>

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
>    <code>"13.4"</code>
>   </dd>
> </dl>
>


### `enhanced_monitoring_attributes` (`list(string)`) <i>optional</i>


Attributes used to format the Enhanced Monitoring IAM role. If this role hits IAM role length restrictions (max 64 characters), consider shortening these strings.<br/>

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
>    
>
>    ```hcl
>>
>    [
>
>      "enhanced-monitoring"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `enhanced_monitoring_role_enabled` (`bool`) <i>optional</i>


A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring<br/>

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


### `intra_security_group_traffic_enabled` (`bool`) <i>optional</i>


Whether to allow traffic between resources inside the database's security group.<br/>

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


### `maintenance_window` (`string`) <i>optional</i>


Weekly time range during which system maintenance can occur, in UTC<br/>

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
>    <code>"wed:03:00-wed:04:00"</code>
>   </dd>
> </dl>
>


### `performance_insights_enabled` (`bool`) <i>optional</i>


Whether to enable Performance Insights<br/>

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


### `publicly_accessible` (`bool`) <i>optional</i>


Set true to make this database accessible from the public internet<br/>

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


### `rds_monitoring_interval` (`number`) <i>optional</i>


The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60<br/>

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
>    <code>60</code>
>   </dd>
> </dl>
>


### `reader_dns_name_part` (`string`) <i>optional</i>


Part of DNS name added to module and cluster name for DNS for cluster reader<br/>

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
>    <code>"reader"</code>
>   </dd>
> </dl>
>


### `retention_period` (`number`) <i>optional</i>


Number of days to retain backups for<br/>

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
>    <code>5</code>
>   </dd>
> </dl>
>


### `scaling_configuration` <i>optional</i>


List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`. This is required for Serverless v1<br/>

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
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
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


### `serverlessv2_scaling_configuration` <i>optional</i>


Nested attribute with scaling properties for ServerlessV2. Only valid when `engine_mode` is set to `provisioned.` This is required for Serverless v2<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    min_capacity = number
    max_capacity = number
  })
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `skip_final_snapshot` (`bool`) <i>optional</i>


Normally AWS makes a snapshot of the database before deleting it. Set this to `true` in order to skip this.<br/>
NOTE: The final snapshot has a name derived from the cluster name. If you delete a cluster, get a final snapshot,<br/>
then create a cluster of the same name, its final snapshot will fail with a name collision unless you delete<br/>
the previous final snapshot first.<br/>
<br/>

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


### `snapshot_identifier` (`string`) <i>optional</i>


Specifies whether or not to create this cluster from a snapshot<br/>

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


### `ssm_path_prefix` (`string`) <i>optional</i>


Top level SSM path prefix (without leading or trailing slash)<br/>

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
>    <code>"aurora-postgres"</code>
>   </dd>
> </dl>
>


### `storage_encrypted` (`bool`) <i>optional</i>


Specifies whether the DB cluster is encrypted<br/>

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


### `vpc_component_name` (`string`) <i>optional</i>


The name of the VPC component<br/>

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
>    <code>"vpc"</code>
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

## Outputs

<dl>
  <dt><code>admin_username</code></dt>
  <dd>
    Postgres admin username<br/>

  </dd>
  <dt><code>allowed_security_groups</code></dt>
  <dd>
    The resulting list of security group IDs that are allowed to connect to the Aurora Postgres cluster.<br/>

  </dd>
  <dt><code>cluster_identifier</code></dt>
  <dd>
    Postgres cluster identifier<br/>

  </dd>
  <dt><code>config_map</code></dt>
  <dd>
    Map containing information pertinent to a PostgreSQL client configuration.<br/>

  </dd>
  <dt><code>database_name</code></dt>
  <dd>
    Postgres database name<br/>

  </dd>
  <dt><code>kms_key_arn</code></dt>
  <dd>
    KMS key ARN for Aurora Postgres<br/>

  </dd>
  <dt><code>master_hostname</code></dt>
  <dd>
    Postgres master hostname<br/>

  </dd>
  <dt><code>replicas_hostname</code></dt>
  <dd>
    Postgres replicas hostname<br/>

  </dd>
  <dt><code>ssm_key_paths</code></dt>
  <dd>
    Names (key paths) of all SSM parameters stored for this cluster<br/>

  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-postgres) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
