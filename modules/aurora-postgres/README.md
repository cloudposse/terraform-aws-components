# Component: `aurora-postgres`

This component is responsible for provisioning a global Aurora Postgres RDS cluster across two regions. It seeds relevant database information (hostnames, username, password, etc.) into AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    aurora-postgres:
      vars:
        enabled: true
        db_name: example
        db_port: 5432
        region: us-west-2
        region_secondary: us-east-2
        environment_secondary: ue2
        engine: aurora-postgresql
        engine_version: "12.4"
        engine_mode: global
        cluster_family: aurora-postgresql12
        cluster_size: 1
        instance_type: db.r4.large
        iam_database_authentication_enabled: true
        storage_encrypted: true
        deletion_protection: false
        # example of additional databases to provision on top of db_name
        additional_databases:
          - cluster
          - moniter
          - app
        additional_users:
          cluster:
            db_user: cluster
            db_password: "" # if empty, generate a password
            # NOTE: if ALL is used, then terraform plan will show a persistent diff
            # see https://github.com/cyrilgdn/terraform-provider-postgresql/issues/32
            grants:
            - grant: ["CREATE", "CONNECT", "TEMPORARY", "TEMP"]
              db: "*"
              schema: null
              object_type: database
          monitor:
            db_user: monitor
            db_password: "" # if empty, generate a password
            grants:
            - grant: ["REPLICATION CLIENT"]
              db: "*"
              schema: null
              object_type: database
          app:
            db_user: monitor
            db_password: "" # if empty, generate a password
            grants:
            - grant: ["select","insert","delete","update"]
              db: "*"
              schema: null
              object_type: database
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >= 1.11.2 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.3 |
| <a name="requirement_sdm"></a> [sdm](#requirement\_sdm) | >= 1.0.19 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.7.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.0 |
| <a name="provider_aws.sdm_api_keys"></a> [aws.sdm\_api\_keys](#provider\_aws.sdm\_api\_keys) | >= 3.0 |
| <a name="provider_postgresql"></a> [postgresql](#provider\_postgresql) | >= 1.11.2 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.3 |
| <a name="provider_sdm"></a> [sdm](#provider\_sdm) | >= 1.0.19 |
| <a name="provider_time"></a> [time](#provider\_time) | >= 0.7.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_additional_users"></a> [additional\_users](#module\_additional\_users) | ./modules/postgresql-user | n/a |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | cloudposse/label/null | 0.24.1 |
| <a name="module_dns_gbl_delegated"></a> [dns\_gbl\_delegated](#module\_dns\_gbl\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 0.17.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 0.17.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_network"></a> [iam\_roles\_network](#module\_iam\_roles\_network) | ../account-map/modules/iam-roles | n/a |
| <a name="module_kms_key_rds_primary"></a> [kms\_key\_rds\_primary](#module\_kms\_key\_rds\_primary) | cloudposse/kms-key/aws | 0.10.0 |
| <a name="module_kms_key_rds_secondary"></a> [kms\_key\_rds\_secondary](#module\_kms\_key\_rds\_secondary) | cloudposse/kms-key/aws | 0.10.0 |
| <a name="module_primary_aurora_postgres_cluster"></a> [primary\_aurora\_postgres\_cluster](#module\_primary\_aurora\_postgres\_cluster) | cloudposse/rds-cluster/aws | 0.45.0 |
| <a name="module_read_only_cluster_user"></a> [read\_only\_cluster\_user](#module\_read\_only\_cluster\_user) | ./modules/postgresql-user | n/a |
| <a name="module_read_only_db_users"></a> [read\_only\_db\_users](#module\_read\_only\_db\_users) | ./modules/postgresql-user | n/a |
| <a name="module_secondary_aurora_postgres_cluster"></a> [secondary\_aurora\_postgres\_cluster](#module\_secondary\_aurora\_postgres\_cluster) | cloudposse/rds-cluster/aws | 0.45.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |
| <a name="module_vpc_primary"></a> [vpc\_primary](#module\_vpc\_primary) | cloudposse/stack-config/yaml//modules/remote-state | 0.17.0 |
| <a name="module_vpc_secondary"></a> [vpc\_secondary](#module\_vpc\_secondary) | cloudposse/stack-config/yaml//modules/remote-state | 0.17.0 |

## Resources

| Name | Type |
|------|------|
| [aws_rds_global_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster) | resource |
| [aws_security_group_rule.ingress_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_admin_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_admin_username](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_cluster_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_master_hostname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_master_port](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.primary_aurora_postgres_replicas_hostname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secondary_aurora_postgres_cluster_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.secondary_aurora_postgres_replicas_hostname](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [postgresql_database.additional](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/database) | resource |
| [postgresql_default_privileges.read_only_tables_cluster](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [postgresql_default_privileges.read_only_tables_users](https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs/resources/default_privileges) | resource |
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.admin_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [sdm_resource.postgres_cluster_admin](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/resource) | resource |
| [sdm_resource.postgres_cluster_ro](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/resource) | resource |
| [sdm_resource.postgres_ro_users](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/resource) | resource |
| [sdm_resource.postgres_users](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/resource) | resource |
| [sdm_role_grant.postgres](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/role_grant) | resource |
| [sdm_role_grant.postgres_cluster_ro](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/role_grant) | resource |
| [sdm_role_grant.postgres_ro_users](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/role_grant) | resource |
| [sdm_role_grant.postgres_users](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/role_grant) | resource |
| [time_sleep.db_cluster_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.api_access_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.api_secret_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [sdm_role.db_user](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/data-sources/role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_databases"></a> [additional\_databases](#input\_additional\_databases) | n/a | `set(string)` | `[]` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_additional_users"></a> [additional\_users](#input\_additional\_users) | Additional users to create. The map key is the service name which becomes part of SSM key name. | <pre>map(object({<br>    db_user : string<br>    db_password : string<br>    grants : list(object({<br>      grant : list(string)<br>      db : string<br>      schema : string<br>      object_type : string<br>    }))<br>    superuser : bool<br>  }))</pre> | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Postgres password for the admin user | `string` | `""` | no |
| <a name="input_admin_user"></a> [admin\_user](#input\_admin\_user) | Postgres admin user name | `string` | `""` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions. Defaults to false. | `bool` | `false` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the cluster | `list(string)` | `[]` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `true` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Whether to enable cluster autoscaling | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of instances to be maintained by the autoscaler | `number` | `5` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of instances to be maintained by the autoscaler | `number` | `1` | no |
| <a name="input_autoscaling_policy_type"></a> [autoscaling\_policy\_type](#input\_autoscaling\_policy\_type) | Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported | `string` | `"TargetTrackingScaling"` | no |
| <a name="input_autoscaling_scale_in_cooldown"></a> [autoscaling\_scale\_in\_cooldown](#input\_autoscaling\_scale\_in\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. Default is 300s | `number` | `300` | no |
| <a name="input_autoscaling_scale_out_cooldown"></a> [autoscaling\_scale\_out\_cooldown](#input\_autoscaling\_scale\_out\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. Default is 300s | `number` | `300` | no |
| <a name="input_autoscaling_target_metrics"></a> [autoscaling\_target\_metrics](#input\_autoscaling\_target\_metrics) | The metrics type to use. If this value isn't provided the default is CPU utilization | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| <a name="input_autoscaling_target_value"></a> [autoscaling\_target\_value](#input\_autoscaling\_target\_value) | The target value to scale with respect to target metrics | `number` | `75` | no |
| <a name="input_backtrack_window"></a> [backtrack\_window](#input\_backtrack\_window) | The target backtrack window, in seconds. Only available for aurora engine currently. Must be between 0 and 259200 (72 hours) | `number` | `0` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Daily time range during which the backups happen | `string` | `"07:00-09:00"` | no |
| <a name="input_cluster_dns_name"></a> [cluster\_dns\_name](#input\_cluster\_dns\_name) | Name of the cluster CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `master.var.name` | `string` | `""` | no |
| <a name="input_cluster_family"></a> [cluster\_family](#input\_cluster\_family) | The family of the DB cluster parameter group | `string` | `"aurora5.6"` | no |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | The RDS Cluster Identifier. Will use generated label ID if not supplied | `string` | `""` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Short name for this cluster | `string` | n/a | yes |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | List of DB cluster parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Number of DB instances to create in the cluster | `number` | `2` | no |
| <a name="input_cluster_type"></a> [cluster\_type](#input\_cluster\_type) | Either `regional` or `global`.<br>If `regional` will be created as a normal, standalone DB.<br>If `global`, will be made part of a Global cluster (requires `global_cluster_identifier`). | `string` | `"regional"` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#input\_copy\_tags\_to\_snapshot) | Copy tags to backup snapshots | `bool` | `false` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Database name (default is not to create a database) | `string` | `""` | no |
| <a name="input_db_port"></a> [db\_port](#input\_db\_port) | Database port | `number` | `3306` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_dns_gbl_delegated_environment_name"></a> [dns\_gbl\_delegated\_environment\_name](#input\_dns\_gbl\_delegated\_environment\_name) | The name of the environment where global `dns_delegated` is provisioned | `string` | `"gbl"` | no |
| <a name="input_enable_http_endpoint"></a> [enable\_http\_endpoint](#input\_enable\_http\_endpoint) | Enable HTTP endpoint (data API). Only valid when engine\_mode is set to serverless | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The name of the database engine to be used for this DB cluster. Valid values: `aurora`, `aurora-mysql`, `aurora-postgresql` | `string` | `"aurora"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The database engine mode. Valid values: `parallelquery`, `provisioned`, `serverless` | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the database engine to use. See `aws rds describe-db-engine-versions` | `string` | `""` | no |
| <a name="input_enhanced_monitoring_role_enabled"></a> [enhanced\_monitoring\_role\_enabled](#input\_enhanced\_monitoring\_role\_enabled) | A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environment_secondary"></a> [environment\_secondary](#input\_environment\_secondary) | Secondary region, e.g. 'uw2', 'uw1', 'en1', 'gbl' | `string` | n/a | yes |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | ID of the Aurora global cluster | `string` | `""` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `false` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | Iam roles for the Aurora cluster | `list(string)` | `[]` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | IAM Profile to use when importing a resource | `string` | `null` | no |
| <a name="input_instance_availability_zone"></a> [instance\_availability\_zone](#input\_instance\_availability\_zone) | Optional parameter to place cluster instances in a specific availability zone. If left empty, will place randomly | `string` | `""` | no |
| <a name="input_instance_parameters"></a> [instance\_parameters](#input\_instance\_parameters) | List of DB instance parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type to use | `string` | `"db.t2.small"` | no |
| <a name="input_kms_alias_name_ssm"></a> [kms\_alias\_name\_ssm](#input\_kms\_alias\_name\_ssm) | KMS alias name for SSM | `string` | `"alias/aws/ssm"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN for the KMS encryption key. When specifying `kms_key_arn`, `storage_encrypted` needs to be set to `true` | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Weekly time range during which system maintenance can occur, in UTC | `string` | `"wed:03:00-wed:04:00"` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. When specifying `performance_insights_kms_key_id`, `performance_insights_enabled` needs to be set to true | `string` | `""` | no |
| <a name="input_primary_cluster_dns_name_part"></a> [primary\_cluster\_dns\_name\_part](#input\_primary\_cluster\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for primary cluster endpoint | `string` | `"primary-cluster"` | no |
| <a name="input_primary_reader_dns_name_part"></a> [primary\_reader\_dns\_name\_part](#input\_primary\_reader\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for primary cluster reader | `string` | `"primary-replicas"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set to true if you want your cluster to be publicly accessible (such as via QuickSight) | `bool` | `false` | no |
| <a name="input_rds_monitoring_interval"></a> [rds\_monitoring\_interval](#input\_rds\_monitoring\_interval) | The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60 | `number` | `0` | no |
| <a name="input_rds_monitoring_role_arn"></a> [rds\_monitoring\_role\_arn](#input\_rds\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs | `string` | `null` | no |
| <a name="input_read_only_users_enabled"></a> [read\_only\_users\_enabled](#input\_read\_only\_users\_enabled) | Set `true` to automatically create read-only users for every database | `bool` | `false` | no |
| <a name="input_reader_dns_name"></a> [reader\_dns\_name](#input\_reader\_dns\_name) | Name of the reader endpoint CNAME record to create in the parent DNS zone specified by `zone_id`. If left empty, the name will be auto-asigned using the format `replicas.var.name` | `string` | `""` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_region_secondary"></a> [region\_secondary](#input\_region\_secondary) | Secondary AWS Region | `string` | n/a | yes |
| <a name="input_replication_source_identifier"></a> [replication\_source\_identifier](#input\_replication\_source\_identifier) | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica | `string` | `""` | no |
| <a name="input_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#input\_restore\_to\_point\_in\_time) | List point-in-time recovery options. Only valid actions are `source_cluster_identifier`, `restore_type` and `use_latest_restorable_time` | <pre>list(object({<br>    source_cluster_identifier  = string<br>    restore_type               = string<br>    use_latest_restorable_time = bool<br>  }))</pre> | `[]` | no |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Number of days to retain backups for | `number` | `5` | no |
| <a name="input_s3_import"></a> [s3\_import](#input\_s3\_import) | Restore from a Percona Xtrabackup in S3. The `bucket_name` is required to be in the same region as the resource. | <pre>object({<br>    bucket_name           = string<br>    bucket_prefix         = string<br>    ingestion_role        = string<br>    source_engine         = string<br>    source_engine_version = string<br>  })</pre> | `null` | no |
| <a name="input_scaling_configuration"></a> [scaling\_configuration](#input\_scaling\_configuration) | List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless` | <pre>list(object({<br>    auto_pause               = bool<br>    max_capacity             = number<br>    min_capacity             = number<br>    seconds_until_auto_pause = number<br>    timeout_action           = string<br>  }))</pre> | `[]` | no |
| <a name="input_sdm_enabled"></a> [sdm\_enabled](#input\_sdm\_enabled) | Set to `true` to enable strongdm. | `bool` | `false` | no |
| <a name="input_sdm_ssm_account"></a> [sdm\_ssm\_account](#input\_sdm\_ssm\_account) | Account (stage) housing SSM parameters | `string` | n/a | yes |
| <a name="input_sdm_ssm_region"></a> [sdm\_ssm\_region](#input\_sdm\_ssm\_region) | AWS Region housing SSM parameters | `string` | n/a | yes |
| <a name="input_secondary_cluster_dns_name_part"></a> [secondary\_cluster\_dns\_name\_part](#input\_secondary\_cluster\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for secondary cluster endpoint | `string` | `"secondary-cluster"` | no |
| <a name="input_secondary_reader_dns_name_part"></a> [secondary\_reader\_dns\_name\_part](#input\_secondary\_reader\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for secondary reader endpoint | `string` | `"secondary-replicas"` | no |
| <a name="input_secondary_region_enabled"></a> [secondary\_region\_enabled](#input\_secondary\_region\_enabled) | Set true to create a read replica in a second region. | `bool` | `true` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security groups to be allowed to connect to the DB instance | `list(string)` | `[]` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted | `bool` | `true` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot | `string` | `null` | no |
| <a name="input_source_region"></a> [source\_region](#input\_source\_region) | Source Region of primary cluster, needed when using encrypted storage and region replicas | `string` | `""` | no |
| <a name="input_ssm_path_prefix"></a> [ssm\_path\_prefix](#input\_ssm\_path\_prefix) | SSM path prefix (without leading or trailing slash) | `string` | `"aurora-postgres"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted. The default is `false` for `provisioned` `engine_mode` and `true` for `serverless` `engine_mode` | `bool` | `false` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of VPC subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_timeouts_configuration"></a> [timeouts\_configuration](#input\_timeouts\_configuration) | List of timeout values per action. Only valid actions are `create`, `update` and `delete` | <pre>list(object({<br>    create = string<br>    update = string<br>    delete = string<br>  }))</pre> | `[]` | no |
| <a name="input_use_eks_security_group"></a> [use\_eks\_security\_group](#input\_use\_eks\_security\_group) | Use the eks default security group | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to create the cluster in (e.g. `vpc-a22222ee`) | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | Additional security group IDs to apply to the cluster, in addition to the provisioned default security group with ingress traffic from existing CIDR blocks and existing security groups | `list(string)` | `[]` | no |
| <a name="input_zone_id"></a> [zone\_id](#input\_zone\_id) | Route53 parent zone ID. If provided (not empty), the module will create sub-domain DNS records for the DB master and replicas | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_postgres_admin_password_info"></a> [aurora\_postgres\_admin\_password\_info](#output\_aurora\_postgres\_admin\_password\_info) | Location of Postgres master password |
| <a name="output_aurora_postgres_admin_username"></a> [aurora\_postgres\_admin\_username](#output\_aurora\_postgres\_admin\_username) | Aurora Postgres Username for the master DB user |
| <a name="output_aurora_postgres_database_name"></a> [aurora\_postgres\_database\_name](#output\_aurora\_postgres\_database\_name) | Aurora Postgres Database name |
| <a name="output_aurora_postgres_master_password_ssm_key"></a> [aurora\_postgres\_master\_password\_ssm\_key](#output\_aurora\_postgres\_master\_password\_ssm\_key) | SSM key of Postgres master password |
| <a name="output_aurora_postgres_ssm_key_prefix"></a> [aurora\_postgres\_ssm\_key\_prefix](#output\_aurora\_postgres\_ssm\_key\_prefix) | SSM key prefix of all parameters stored for this cluster |
| <a name="output_datasource_names"></a> [datasource\_names](#output\_datasource\_names) | All the data source names. |
| <a name="output_primary_aurora_postgres_cluster_identifier"></a> [primary\_aurora\_postgres\_cluster\_identifier](#output\_primary\_aurora\_postgres\_cluster\_identifier) | Primary Aurora Postgres Cluster Identifier |
| <a name="output_primary_aurora_postgres_cluster_security_group_id"></a> [primary\_aurora\_postgres\_cluster\_security\_group\_id](#output\_primary\_aurora\_postgres\_cluster\_security\_group\_id) | Primary Aurora Postgres Cluster Security Group |
| <a name="output_primary_aurora_postgres_master_hostname"></a> [primary\_aurora\_postgres\_master\_hostname](#output\_primary\_aurora\_postgres\_master\_hostname) | Primary Aurora Postgres DB Master hostname |
| <a name="output_primary_aurora_postgres_replicas_hostname"></a> [primary\_aurora\_postgres\_replicas\_hostname](#output\_primary\_aurora\_postgres\_replicas\_hostname) | Primary Aurora Postgres Replicas hostname |
| <a name="output_read_only_users"></a> [read\_only\_users](#output\_read\_only\_users) | List of all read only users without a db user password. |
| <a name="output_secondary_aurora_postgres_cluster_identifier"></a> [secondary\_aurora\_postgres\_cluster\_identifier](#output\_secondary\_aurora\_postgres\_cluster\_identifier) | Secondary Aurora Postgres Cluster Identifier |
| <a name="output_secondary_aurora_postgres_cluster_security_group_id"></a> [secondary\_aurora\_postgres\_cluster\_security\_group\_id](#output\_secondary\_aurora\_postgres\_cluster\_security\_group\_id) | Secondary Aurora Postgres Cluster Security Group |
| <a name="output_secondary_aurora_postgres_replicas_hostname"></a> [secondary\_aurora\_postgres\_replicas\_hostname](#output\_secondary\_aurora\_postgres\_replicas\_hostname) | Secondary Aurora Postgres Replicas hostname |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/TODO) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
