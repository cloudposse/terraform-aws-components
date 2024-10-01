---
tags:
  - component/aurora-postgres
  - layer/data
  - provider/aws
---

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

Use the following to query the AWS API by `engine-mode`. Both provisioned and Serverless v2 use the `provisioned` engine
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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | >= 1.17.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora_postgres_cluster"></a> [aurora\_postgres\_cluster](#module\_aurora\_postgres\_cluster) | cloudposse/rds-cluster/aws | 1.3.2 |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | cloudposse/label/null | 0.25.0 |
| <a name="module_dns_gbl_delegated"></a> [dns\_gbl\_delegated](#module\_dns\_gbl\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_kms_key_rds"></a> [kms\_key\_rds](#module\_kms\_key\_rds) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_parameter_store_write"></a> [parameter\_store\_write](#module\_parameter\_store\_write) | cloudposse/ssm-parameter-store/aws | 0.11.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.admin_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.database_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_security_groups.allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Postgres password for the admin user | `string` | `""` | no |
| <a name="input_admin_user"></a> [admin\_user](#input\_admin\_user) | Postgres admin user name | `string` | `""` | no |
| <a name="input_allow_ingress_from_vpc_accounts"></a> [allow\_ingress\_from\_vpc\_accounts](#input\_allow\_ingress\_from\_vpc\_accounts) | List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br>e.g.<br>{<br>  environment = "ue2",<br>  stage       = "auto",<br>  tenant      = "core"<br>}<br><br>Defaults to the "vpc" component in the given account | <pre>list(object({<br>    vpc         = optional(string, "vpc")<br>    environment = optional(string)<br>    stage       = optional(string)<br>    tenant      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions. Defaults to false. | `bool` | `false` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDRs allowed to access the database (in addition to security groups and subnets) | `list(string)` | `[]` | no |
| <a name="input_allowed_security_group_names"></a> [allowed\_security\_group\_names](#input\_allowed\_security\_group\_names) | List of security group names (tags) that should be allowed access to the database | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_enabled"></a> [autoscaling\_enabled](#input\_autoscaling\_enabled) | Whether to enable cluster autoscaling | `bool` | `false` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of instances to be maintained by the autoscaler | `number` | `5` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of instances to be maintained by the autoscaler | `number` | `1` | no |
| <a name="input_autoscaling_policy_type"></a> [autoscaling\_policy\_type](#input\_autoscaling\_policy\_type) | Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported | `string` | `"TargetTrackingScaling"` | no |
| <a name="input_autoscaling_scale_in_cooldown"></a> [autoscaling\_scale\_in\_cooldown](#input\_autoscaling\_scale\_in\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. Default is 300s | `number` | `300` | no |
| <a name="input_autoscaling_scale_out_cooldown"></a> [autoscaling\_scale\_out\_cooldown](#input\_autoscaling\_scale\_out\_cooldown) | The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. Default is 300s | `number` | `300` | no |
| <a name="input_autoscaling_target_metrics"></a> [autoscaling\_target\_metrics](#input\_autoscaling\_target\_metrics) | The metrics type to use. If this value isn't provided the default is CPU utilization | `string` | `"RDSReaderAverageCPUUtilization"` | no |
| <a name="input_autoscaling_target_value"></a> [autoscaling\_target\_value](#input\_autoscaling\_target\_value) | The target value to scale with respect to target metrics | `number` | `75` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Daily time range during which the backups happen, UTC | `string` | `"07:00-09:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance | `string` | `null` | no |
| <a name="input_cluster_dns_name_part"></a> [cluster\_dns\_name\_part](#input\_cluster\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for cluster endpoint | `string` | `"writer"` | no |
| <a name="input_cluster_family"></a> [cluster\_family](#input\_cluster\_family) | Family of the DB parameter group. Valid values for Aurora PostgreSQL: `aurora-postgresql9.6`, `aurora-postgresql10`, `aurora-postgresql11`, `aurora-postgresql12` | `string` | `"aurora-postgresql13"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Short name for this cluster | `string` | n/a | yes |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | List of DB cluster parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | Postgres cluster size | `number` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | Name for an automatically created database on cluster creation. An empty name will generate a db name. | `string` | `""` | no |
| <a name="input_database_port"></a> [database\_port](#input\_database\_port) | Database port | `number` | `5432` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Specifies whether the Cluster should have deletion protection enabled. The database can't be deleted when this value is set to `true` | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_gbl_delegated_environment_name"></a> [dns\_gbl\_delegated\_environment\_name](#input\_dns\_gbl\_delegated\_environment\_name) | The name of the environment where global `dns_delegated` is provisioned | `string` | `"gbl"` | no |
| <a name="input_eks_component_names"></a> [eks\_component\_names](#input\_eks\_component\_names) | The names of the eks components | `set(string)` | <pre>[<br>  "eks/cluster"<br>]</pre> | no |
| <a name="input_eks_security_group_enabled"></a> [eks\_security\_group\_enabled](#input\_eks\_security\_group\_enabled) | Use the eks default security group | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | Name of the database engine to be used for the DB cluster | `string` | `"postgresql"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless` | `string` | n/a | yes |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | Engine version of the Aurora global database | `string` | `"13.4"` | no |
| <a name="input_enhanced_monitoring_attributes"></a> [enhanced\_monitoring\_attributes](#input\_enhanced\_monitoring\_attributes) | Attributes used to format the Enhanced Monitoring IAM role. If this role hits IAM role length restrictions (max 64 characters), consider shortening these strings. | `list(string)` | <pre>[<br>  "enhanced-monitoring"<br>]</pre> | no |
| <a name="input_enhanced_monitoring_role_enabled"></a> [enhanced\_monitoring\_role\_enabled](#input\_enhanced\_monitoring\_role\_enabled) | A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type for Postgres cluster | `string` | n/a | yes |
| <a name="input_intra_security_group_traffic_enabled"></a> [intra\_security\_group\_traffic\_enabled](#input\_intra\_security\_group\_traffic\_enabled) | Whether to allow traffic between resources inside the database's security group. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Weekly time range during which system maintenance can occur, in UTC | `string` | `"wed:03:00-wed:04:00"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Whether to enable Performance Insights | `bool` | `false` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set true to make this database accessible from the public internet | `bool` | `false` | no |
| <a name="input_rds_monitoring_interval"></a> [rds\_monitoring\_interval](#input\_rds\_monitoring\_interval) | The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60 | `number` | `60` | no |
| <a name="input_reader_dns_name_part"></a> [reader\_dns\_name\_part](#input\_reader\_dns\_name\_part) | Part of DNS name added to module and cluster name for DNS for cluster reader | `string` | `"reader"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_retention_period"></a> [retention\_period](#input\_retention\_period) | Number of days to retain backups for | `number` | `5` | no |
| <a name="input_scaling_configuration"></a> [scaling\_configuration](#input\_scaling\_configuration) | List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`. This is required for Serverless v1 | <pre>list(object({<br>    auto_pause               = bool<br>    max_capacity             = number<br>    min_capacity             = number<br>    seconds_until_auto_pause = number<br>    timeout_action           = string<br>  }))</pre> | `[]` | no |
| <a name="input_serverlessv2_scaling_configuration"></a> [serverlessv2\_scaling\_configuration](#input\_serverlessv2\_scaling\_configuration) | Nested attribute with scaling properties for ServerlessV2. Only valid when `engine_mode` is set to `provisioned.` This is required for Serverless v2 | <pre>object({<br>    min_capacity = number<br>    max_capacity = number<br>  })</pre> | `null` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Normally AWS makes a snapshot of the database before deleting it. Set this to `true` in order to skip this.<br>NOTE: The final snapshot has a name derived from the cluster name. If you delete a cluster, get a final snapshot,<br>then create a cluster of the same name, its final snapshot will fail with a name collision unless you delete<br>the previous final snapshot first. | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Specifies whether or not to create this cluster from a snapshot | `string` | `null` | no |
| <a name="input_ssm_path_prefix"></a> [ssm\_path\_prefix](#input\_ssm\_path\_prefix) | Top level SSM path prefix (without leading or trailing slash) | `string` | `"aurora-postgres"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of the VPC component | `string` | `"vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_username"></a> [admin\_username](#output\_admin\_username) | Postgres admin username |
| <a name="output_allowed_security_groups"></a> [allowed\_security\_groups](#output\_allowed\_security\_groups) | The resulting list of security group IDs that are allowed to connect to the Aurora Postgres cluster. |
| <a name="output_cluster_identifier"></a> [cluster\_identifier](#output\_cluster\_identifier) | Postgres cluster identifier |
| <a name="output_config_map"></a> [config\_map](#output\_config\_map) | Map containing information pertinent to a PostgreSQL client configuration. |
| <a name="output_database_name"></a> [database\_name](#output\_database\_name) | Postgres database name |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN for Aurora Postgres |
| <a name="output_master_hostname"></a> [master\_hostname](#output\_master\_hostname) | Postgres master hostname |
| <a name="output_replicas_hostname"></a> [replicas\_hostname](#output\_replicas\_hostname) | Postgres replicas hostname |
| <a name="output_ssm_key_paths"></a> [ssm\_key\_paths](#output\_ssm\_key\_paths) | Names (key paths) of all SSM parameters stored for this cluster |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-postgres) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
