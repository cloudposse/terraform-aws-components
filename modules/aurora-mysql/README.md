---
tags:
  - component/aurora-mysql
  - layer/data
  - provider/aws
---

# Component: `aurora-mysql`

This component is responsible for provisioning Aurora MySQL RDS clusters. It seeds relevant database information
(hostnames, username, password, etc.) into AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example for how to use this component.

`stacks/catalog/aurora-mysql/defaults.yaml` file (base component for all Aurora MySQL clusters with default settings):

```yaml
components:
  terraform:
    aurora-mysql/defaults:
      metadata:
        type: abstract
      vars:
        enabled: false
        name: rds
        mysql_deletion_protection: false
        mysql_storage_encrypted: true
        aurora_mysql_engine: "aurora-mysql"
        allowed_cidr_blocks:
          # all automation
          - 10.128.0.0/22
          # all corp
          - 10.128.16.0/22
        eks_component_names:
          - eks/eks
        # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraMySQLReleaseNotes/AuroraMySQL.Updates.3020.html
        # aws rds describe-db-engine-versions --engine aurora-mysql --query 'DBEngineVersions[].EngineVersion'
        aurora_mysql_engine_version: "8.0.mysql_aurora.3.02.0"
        # engine and cluster family are notoriously hard to find.
        # If you know the engine version (example here is "8.0.mysql_aurora.3.02.0"), use Engine and DBParameterGroupFamily from:
        #    aws rds describe-db-engine-versions --engine aurora-mysql --query "DBEngineVersions[]" | \
        #    jq '.[] | select(.EngineVersion == "8.0.mysql_aurora.3.02.0") |
        #       { Engine: .Engine, EngineVersion: .EngineVersion, DBParameterGroupFamily: .DBParameterGroupFamily }'
        #
        #    Returns:
        #    {
        #       "Engine": "aurora-mysql",
        #       "EngineVersion": "8.0.mysql_aurora.3.02.0",
        #       "DBParameterGroupFamily": "aurora-mysql8.0"
        #     }
        aurora_mysql_cluster_family: "aurora-mysql8.0"
        mysql_name: shared
        # 1 writer, 1 reader
        mysql_cluster_size: 2
        mysql_admin_user: "" # generate random username
        mysql_admin_password: "" # generate random password
        mysql_db_name: "" # generate random db name
        # https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Concepts.DBInstanceClass.html
        mysql_instance_type: "db.t3.medium"
        mysql_skip_final_snapshot: false
```

Example configuration for a dev cluster. Import this file into the primary region.
`stacks/catalog/aurora-mysql/dev.yaml` file (override the default settings for the cluster in the `dev` account):

```yaml
import:
  - catalog/aurora-mysql/defaults

components:
  terraform:
    aurora-mysql/dev:
      metadata:
        component: aurora-mysql
        inherits:
          - aurora-mysql/defaults
      vars:
        instance_type: db.r5.large
        mysql_cluster_size: 1
        mysql_name: main
        mysql_db_name: main
```

Example deployment with primary cluster deployed to us-east-1 in a `platform-dev` account:
`atmos terraform apply aurora-mysql/dev -s platform-use1-dev`

## Disaster Recovery with Cross-Region Replication

This component is designed to support cross-region replication with continuous replication. If enabled and deployed, a
secondary cluster will be deployed in a different region than the primary cluster. This approach is highly aggressive and
costly, but in a disaster scenario where the primary cluster fails, the secondary cluster can be promoted to take its
place. Follow these steps to handle a Disaster Recovery.

### Usage

To deploy a secondary cluster for cross-region replication, add the following catalog entries to an alternative region:

Default settings for a secondary, replica cluster. For this example, this file is saved as
`stacks/catalog/aurora-mysql/replica/defaults.yaml`

```yaml
import:
  - catalog/aurora-mysql/defaults

components:
  terraform:
    aurora-mysql/replica/defaults:
      metadata:
        component: aurora-mysql
        inherits:
          - aurora-mysql/defaults
      vars:
        eks_component_names: []
        allowed_cidr_blocks:
          # all automation in primary region (where Spacelift is deployed)
          - 10.128.0.0/22
          # all corp in the same region as this cluster
          - 10.132.16.0/22
        mysql_instance_type: "db.t3.medium"
        mysql_name: "replica"
        primary_cluster_region: use1
        is_read_replica: true
        is_promoted_read_replica: false # False by default, added for visibility
```

Environment specific settings for `dev` as an example:

```yaml
import:
  - catalog/aurora-mysql/replica/defaults

components:
  terraform:
    aurora-mysql/dev:
      metadata:
        component: aurora-mysql
        inherits:
          - aurora-mysql/defaults
          - aurora-mysql/replica/defaults
      vars:
        enabled: true
        primary_cluster_component: aurora-mysql/dev
```

### Promoting the Read Replica

Promoting an existing RDS Replicate cluster to a fully standalone cluster is not currently supported by Terraform:
https://github.com/hashicorp/terraform-provider-aws/issues/6749

Instead, promote the Replicate cluster with the AWS CLI command:
`aws rds promote-read-replica-db-cluster --db-cluster-identifier <identifier>`

After promoting the replica, update the stack configuration to prevent future Terraform runs from re-enabling
replication. In this example, modify `stacks/catalog/aurora-mysql/replica/defaults.yaml`

```yaml
is_promoted_read_replica: true
```

Redeploying the component should show no changes. For example,
`atmos terraform apply aurora-mysql/dev -s platform-use2-dev`

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aurora_mysql"></a> [aurora\_mysql](#module\_aurora\_mysql) | cloudposse/rds-cluster/aws | 1.3.1 |
| <a name="module_cluster"></a> [cluster](#module\_cluster) | cloudposse/label/null | 0.25.0 |
| <a name="module_dns-delegated"></a> [dns-delegated](#module\_dns-delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_kms_key_rds"></a> [kms\_key\_rds](#module\_kms\_key\_rds) | cloudposse/kms-key/aws | 0.12.1 |
| <a name="module_parameter_store_write"></a> [parameter\_store\_write](#module\_parameter\_store\_write) | cloudposse/ssm-parameter-store/aws | 0.11.0 |
| <a name="module_primary_cluster"></a> [primary\_cluster](#module\_primary\_cluster) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_vpc_ingress"></a> [vpc\_ingress](#module\_vpc\_ingress) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [random_password.mysql_admin_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_pet.mysql_admin_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [random_pet.mysql_db_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.kms_key_rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_ssm_parameter.password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allow_ingress_from_vpc_accounts"></a> [allow\_ingress\_from\_vpc\_accounts](#input\_allow\_ingress\_from\_vpc\_accounts) | List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br><br>e.g.<br>{<br>  environment = "ue2",<br>  stage       = "auto",<br>  tenant      = "core"<br>}<br><br>Defaults to the "vpc" component in the given account | <pre>list(object({<br>    vpc         = optional(string, "vpc")<br>    environment = optional(string)<br>    stage       = optional(string)<br>    tenant      = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks to be allowed to connect to the RDS cluster | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aurora_mysql_cluster_family"></a> [aurora\_mysql\_cluster\_family](#input\_aurora\_mysql\_cluster\_family) | DBParameterGroupFamily (e.g. `aurora5.6`, `aurora-mysql5.7` for Aurora MySQL databases). See https://stackoverflow.com/a/55819394 for help finding the right one to use. | `string` | n/a | yes |
| <a name="input_aurora_mysql_cluster_parameters"></a> [aurora\_mysql\_cluster\_parameters](#input\_aurora\_mysql\_cluster\_parameters) | List of DB cluster parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_aurora_mysql_engine"></a> [aurora\_mysql\_engine](#input\_aurora\_mysql\_engine) | Engine for Aurora database: `aurora` for MySQL 5.6, `aurora-mysql` for MySQL 5.7 | `string` | n/a | yes |
| <a name="input_aurora_mysql_engine_version"></a> [aurora\_mysql\_engine\_version](#input\_aurora\_mysql\_engine\_version) | Engine Version for Aurora database. | `string` | `""` | no |
| <a name="input_aurora_mysql_instance_parameters"></a> [aurora\_mysql\_instance\_parameters](#input\_aurora\_mysql\_instance\_parameters) | List of DB instance parameters to apply | <pre>list(object({<br>    apply_method = string<br>    name         = string<br>    value        = string<br>  }))</pre> | `[]` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Automatically update the cluster when a new minor version is released | `bool` | `false` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_names"></a> [eks\_component\_names](#input\_eks\_component\_names) | The names of the eks components | `set(string)` | <pre>[<br>  "eks/cluster"<br>]</pre> | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_is_promoted_read_replica"></a> [is\_promoted\_read\_replica](#input\_is\_promoted\_read\_replica) | If `true`, do not assign a Replication Source to the Cluster. Set to `true` after manually promoting the cluster from a replica to a standalone cluster. | `bool` | `false` | no |
| <a name="input_is_read_replica"></a> [is\_read\_replica](#input\_is\_read\_replica) | If `true`, create this DB cluster as a Read Replica. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_mysql_admin_password"></a> [mysql\_admin\_password](#input\_mysql\_admin\_password) | MySQL password for the admin user | `string` | `""` | no |
| <a name="input_mysql_admin_user"></a> [mysql\_admin\_user](#input\_mysql\_admin\_user) | MySQL admin user name | `string` | `""` | no |
| <a name="input_mysql_backup_retention_period"></a> [mysql\_backup\_retention\_period](#input\_mysql\_backup\_retention\_period) | Number of days for which to retain backups | `number` | `3` | no |
| <a name="input_mysql_backup_window"></a> [mysql\_backup\_window](#input\_mysql\_backup\_window) | Daily time range during which the backups happen | `string` | `"07:00-09:00"` | no |
| <a name="input_mysql_cluster_size"></a> [mysql\_cluster\_size](#input\_mysql\_cluster\_size) | MySQL cluster size | `string` | `2` | no |
| <a name="input_mysql_db_name"></a> [mysql\_db\_name](#input\_mysql\_db\_name) | Database name (default is not to create a database | `string` | `""` | no |
| <a name="input_mysql_deletion_protection"></a> [mysql\_deletion\_protection](#input\_mysql\_deletion\_protection) | Set to `true` to protect the database from deletion | `string` | `true` | no |
| <a name="input_mysql_enabled_cloudwatch_logs_exports"></a> [mysql\_enabled\_cloudwatch\_logs\_exports](#input\_mysql\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery | `list(string)` | <pre>[<br>  "audit",<br>  "error",<br>  "general",<br>  "slowquery"<br>]</pre> | no |
| <a name="input_mysql_instance_type"></a> [mysql\_instance\_type](#input\_mysql\_instance\_type) | EC2 instance type for RDS MySQL cluster | `string` | `"db.t3.medium"` | no |
| <a name="input_mysql_maintenance_window"></a> [mysql\_maintenance\_window](#input\_mysql\_maintenance\_window) | Weekly time range during which system maintenance can occur, in UTC | `string` | `"sat:10:00-sat:10:30"` | no |
| <a name="input_mysql_name"></a> [mysql\_name](#input\_mysql\_name) | MySQL solution name (part of cluster identifier) | `string` | `""` | no |
| <a name="input_mysql_skip_final_snapshot"></a> [mysql\_skip\_final\_snapshot](#input\_mysql\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB cluster is deleted | `string` | `false` | no |
| <a name="input_mysql_storage_encrypted"></a> [mysql\_storage\_encrypted](#input\_mysql\_storage\_encrypted) | Set to `true` to keep the database contents encrypted | `string` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Set `true` to enable Performance Insights | `bool` | `false` | no |
| <a name="input_primary_cluster_component"></a> [primary\_cluster\_component](#input\_primary\_cluster\_component) | If this cluster is a read replica and no replication source is explicitly given, the component name for the primary cluster | `string` | `"aurora-mysql"` | no |
| <a name="input_primary_cluster_region"></a> [primary\_cluster\_region](#input\_primary\_cluster\_region) | If this cluster is a read replica and no replication source is explicitly given, the region to look for a matching cluster | `string` | `""` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Set to true to create the cluster in a public subnet | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_replication_source_identifier"></a> [replication\_source\_identifier](#input\_replication\_source\_identifier) | ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica.<br>If this value is empty and replication is enabled, remote state will attempt to find<br>a matching cluster in the Primary DB Cluster's region | `string` | `""` | no |
| <a name="input_ssm_password_source"></a> [ssm\_password\_source](#input\_ssm\_password\_source) | If `var.ssm_passwords_enabled` is `true`, DB user passwords will be retrieved from SSM using<br>`var.ssm_password_source` and the database username. If this value is not set,<br>a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster. | `string` | `""` | no |
| <a name="input_ssm_path_prefix"></a> [ssm\_path\_prefix](#input\_ssm\_path\_prefix) | SSM path prefix | `string` | `"rds"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of the VPC component | `string` | `"vpc"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aurora_mysql_cluster_arn"></a> [aurora\_mysql\_cluster\_arn](#output\_aurora\_mysql\_cluster\_arn) | The ARN of Aurora cluster |
| <a name="output_aurora_mysql_cluster_id"></a> [aurora\_mysql\_cluster\_id](#output\_aurora\_mysql\_cluster\_id) | The ID of Aurora cluster |
| <a name="output_aurora_mysql_cluster_name"></a> [aurora\_mysql\_cluster\_name](#output\_aurora\_mysql\_cluster\_name) | Aurora MySQL cluster identifier |
| <a name="output_aurora_mysql_endpoint"></a> [aurora\_mysql\_endpoint](#output\_aurora\_mysql\_endpoint) | Aurora MySQL endpoint |
| <a name="output_aurora_mysql_master_hostname"></a> [aurora\_mysql\_master\_hostname](#output\_aurora\_mysql\_master\_hostname) | Aurora MySQL DB master hostname |
| <a name="output_aurora_mysql_master_password"></a> [aurora\_mysql\_master\_password](#output\_aurora\_mysql\_master\_password) | Location of admin password in SSM |
| <a name="output_aurora_mysql_master_password_ssm_key"></a> [aurora\_mysql\_master\_password\_ssm\_key](#output\_aurora\_mysql\_master\_password\_ssm\_key) | SSM key for admin password |
| <a name="output_aurora_mysql_master_username"></a> [aurora\_mysql\_master\_username](#output\_aurora\_mysql\_master\_username) | Aurora MySQL username for the master DB user |
| <a name="output_aurora_mysql_reader_endpoint"></a> [aurora\_mysql\_reader\_endpoint](#output\_aurora\_mysql\_reader\_endpoint) | Aurora MySQL reader endpoint |
| <a name="output_aurora_mysql_replicas_hostname"></a> [aurora\_mysql\_replicas\_hostname](#output\_aurora\_mysql\_replicas\_hostname) | Aurora MySQL replicas hostname |
| <a name="output_cluster_domain"></a> [cluster\_domain](#output\_cluster\_domain) | Cluster DNS name |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS key ARN for Aurora MySQL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-mysql) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
