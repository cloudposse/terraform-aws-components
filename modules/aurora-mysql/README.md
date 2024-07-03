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
secondary cluster will be deployed in a different region than the primary cluster. This approach is highly aggresive and
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

After promoting the replica, update the stack configuration to prevent future Terrafrom runs from re-enabling
replication. In this example, modify `stacks/catalog/aurora-mysql/replica/defaults.yaml`

```yaml
is_promoted_read_replica: true
```

Reploying the component should show no changes. For example,
`atmos terraform apply aurora-mysql/dev -s platform-use2-dev`

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`random`](https://registry.terraform.io/modules/random/>= 2.2), version: >= 2.2

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0
- `random`, version: >= 2.2

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`aurora_mysql` | 1.3.1 | [`cloudposse/rds-cluster/aws`](https://registry.terraform.io/modules/cloudposse/rds-cluster/aws/1.3.1) | n/a
`cluster` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`dns-delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`kms_key_rds` | 0.12.1 | [`cloudposse/kms-key/aws`](https://registry.terraform.io/modules/cloudposse/kms-key/aws/0.12.1) | n/a
`parameter_store_write` | 0.11.0 | [`cloudposse/ssm-parameter-store/aws`](https://registry.terraform.io/modules/cloudposse/ssm-parameter-store/aws/0.11.0) | n/a
`primary_cluster` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`vpc_ingress` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`random_password.mysql_admin_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
  - [`random_pet.mysql_admin_user`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
  - [`random_pet.mysql_db_name`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_iam_policy_document.kms_key_rds`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_ssm_parameter.password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
    This is for some rare cases where resources want additional configuration of tags<br/>
    and therefore take a list of maps with tag key, value, and additional configuration.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
    in the order they appear in the list. New attributes are appended to the<br/>
    end of the list. The elements of the list are joined by the `delimiter`<br/>
    and treated as a single ID element.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` (`any`) <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** 
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
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between ID elements.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`descriptor_formats` (`any`) <i>optional</i></dt>
  <dd>
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
    **Required:** No<br/>
    **Type:** `any`
    **Default value:** `{}`
  </dd>
  <dt>`enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to prevent the module from creating any resources<br/>
    **Required:** No<br/>
    **Type:** `bool`
    **Default value:** `null`
  </dd>
  <dt>`environment` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for keep the existing setting, which defaults to `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
    Does not affect keys of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The order in which the labels (ID elements) appear in the `id`.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    Controls the letter case of ID elements (labels) as included in `id`,<br/>
    set as tag values, and output by this module individually.<br/>
    Does not affect values of tags passed in via the `tags` input.<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`labels_as_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    Set of labels (ID elements) to include as tags in the `tags` output.<br/>
    Default is to include all labels.<br/>
    Tags with empty values will not be included in the `tags` output.<br/>
    Set to `[]` to suppress all generated tags.<br/>
    **Notes:**<br/>
      The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
      Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
      changed in later chained modules. Attempts to change it will be silently ignored.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `set(string)`
    **Default value:** 
    ```hcl
    [
      "default"
    ]
    ```
    
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
    This is the only ID element not also included as a `tag`.<br/>
    The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Terraform regular expression (regex) string.<br/>
    Characters matching the regex will be removed from the ID elements.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
    Neither the tag keys nor the tag values will be modified by this module.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`tenant` (`string`) <i>optional</i></dt>
  <dd>
    ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
</dl>

### Required Inputs

<dl>
  <dt>`aurora_mysql_cluster_family` (`string`) <i>required</i></dt>
  <dd>
    DBParameterGroupFamily (e.g. `aurora5.6`, `aurora-mysql5.7` for Aurora MySQL databases). See https://stackoverflow.com/a/55819394 for help finding the right one to use.<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`aurora_mysql_engine` (`string`) <i>required</i></dt>
  <dd>
    Engine for Aurora database: `aurora` for MySQL 5.6, `aurora-mysql` for MySQL 5.7<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`allow_ingress_from_vpc_accounts` <i>optional</i></dt>
  <dd>
    List of account contexts to pull VPC ingress CIDR and add to cluster security group.<br/>
    <br/>
    e.g.<br/>
    {<br/>
      environment = "ue2",<br/>
      stage       = "auto",<br/>
      tenant      = "core"<br/>
    }<br/>
    <br/>
    Defaults to the "vpc" component in the given account<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    vpc         = optional(string, "vpc")
    environment = optional(string)
    stage       = optional(string)
    tenant      = optional(string)
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDR blocks to be allowed to connect to the RDS cluster<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`aurora_mysql_cluster_parameters` <i>optional</i></dt>
  <dd>
    List of DB cluster parameters to apply<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    apply_method = string
    name         = string
    value        = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`aurora_mysql_engine_version` (`string`) <i>optional</i></dt>
  <dd>
    Engine Version for Aurora database.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`aurora_mysql_instance_parameters` <i>optional</i></dt>
  <dd>
    List of DB instance parameters to apply<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    apply_method = string
    name         = string
    value        = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`auto_minor_version_upgrade` (`bool`) <i>optional</i></dt>
  <dd>
    Automatically update the cluster when a new minor version is released<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`eks_component_names` (`set(string)`) <i>optional</i></dt>
  <dd>
    The names of the eks components<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "eks/cluster"
    ]
    ```
    
  </dd>
  <dt>`is_promoted_read_replica` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, do not assign a Replication Source to the Cluster. Set to `true` after manually promoting the cluster from a replica to a standalone cluster.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`is_read_replica` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, create this DB cluster as a Read Replica.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`mysql_admin_password` (`string`) <i>optional</i></dt>
  <dd>
    MySQL password for the admin user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`mysql_admin_user` (`string`) <i>optional</i></dt>
  <dd>
    MySQL admin user name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`mysql_backup_retention_period` (`number`) <i>optional</i></dt>
  <dd>
    Number of days for which to retain backups<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `3`
  </dd>
  <dt>`mysql_backup_window` (`string`) <i>optional</i></dt>
  <dd>
    Daily time range during which the backups happen<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"07:00-09:00"`
  </dd>
  <dt>`mysql_cluster_size` (`string`) <i>optional</i></dt>
  <dd>
    MySQL cluster size<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `2`
  </dd>
  <dt>`mysql_db_name` (`string`) <i>optional</i></dt>
  <dd>
    Database name (default is not to create a database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`mysql_deletion_protection` (`string`) <i>optional</i></dt>
  <dd>
    Set to `true` to protect the database from deletion<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`mysql_enabled_cloudwatch_logs_exports` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "audit",
      "error",
      "general",
      "slowquery"
    ]
    ```
    
  </dd>
  <dt>`mysql_instance_type` (`string`) <i>optional</i></dt>
  <dd>
    EC2 instance type for RDS MySQL cluster<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"db.t3.medium"`
  </dd>
  <dt>`mysql_maintenance_window` (`string`) <i>optional</i></dt>
  <dd>
    Weekly time range during which system maintenance can occur, in UTC<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"sat:10:00-sat:10:30"`
  </dd>
  <dt>`mysql_name` (`string`) <i>optional</i></dt>
  <dd>
    MySQL solution name (part of cluster identifier)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`mysql_skip_final_snapshot` (`string`) <i>optional</i></dt>
  <dd>
    Determines whether a final DB snapshot is created before the DB cluster is deleted<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`mysql_storage_encrypted` (`string`) <i>optional</i></dt>
  <dd>
    Set to `true` to keep the database contents encrypted<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`performance_insights_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to enable Performance Insights<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`primary_cluster_component` (`string`) <i>optional</i></dt>
  <dd>
    If this cluster is a read replica and no replication source is explicitly given, the component name for the primary cluster<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"aurora-mysql"`
  </dd>
  <dt>`primary_cluster_region` (`string`) <i>optional</i></dt>
  <dd>
    If this cluster is a read replica and no replication source is explicitly given, the region to look for a matching cluster<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`publicly_accessible` (`bool`) <i>optional</i></dt>
  <dd>
    Set to true to create the cluster in a public subnet<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`replication_source_identifier` (`string`) <i>optional</i></dt>
  <dd>
    ARN of a source DB cluster or DB instance if this DB cluster is to be created as a Read Replica.<br/>
    If this value is empty and replication is enabled, remote state will attempt to find<br/>
    a matching cluster in the Primary DB Cluster's region<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ssm_password_source` (`string`) <i>optional</i></dt>
  <dd>
    If `var.ssm_passwords_enabled` is `true`, DB user passwords will be retrieved from SSM using<br/>
    `var.ssm_password_source` and the database username. If this value is not set,<br/>
    a default path will be created using the SSM path prefix and ID of the associated Aurora Cluster.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ssm_path_prefix` (`string`) <i>optional</i></dt>
  <dd>
    SSM path prefix<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"rds"`
  </dd>
  <dt>`vpc_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the VPC component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"vpc"`
  </dd></dl>


### Outputs

<dl>
  <dt>`aurora_mysql_cluster_arn`</dt>
  <dd>
    The ARN of Aurora cluster<br/>
  </dd>
  <dt>`aurora_mysql_cluster_id`</dt>
  <dd>
    The ID of Aurora cluster<br/>
  </dd>
  <dt>`aurora_mysql_cluster_name`</dt>
  <dd>
    Aurora MySQL cluster identifier<br/>
  </dd>
  <dt>`aurora_mysql_endpoint`</dt>
  <dd>
    Aurora MySQL endpoint<br/>
  </dd>
  <dt>`aurora_mysql_master_hostname`</dt>
  <dd>
    Aurora MySQL DB master hostname<br/>
  </dd>
  <dt>`aurora_mysql_master_password`</dt>
  <dd>
    Location of admin password in SSM<br/>
  </dd>
  <dt>`aurora_mysql_master_password_ssm_key`</dt>
  <dd>
    SSM key for admin password<br/>
  </dd>
  <dt>`aurora_mysql_master_username`</dt>
  <dd>
    Aurora MySQL username for the master DB user<br/>
  </dd>
  <dt>`aurora_mysql_reader_endpoint`</dt>
  <dd>
    Aurora MySQL reader endpoint<br/>
  </dd>
  <dt>`aurora_mysql_replicas_hostname`</dt>
  <dd>
    Aurora MySQL replicas hostname<br/>
  </dd>
  <dt>`cluster_domain`</dt>
  <dd>
    Cluster DNS name<br/>
  </dd>
  <dt>`kms_key_arn`</dt>
  <dd>
    KMS key ARN for Aurora MySQL<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aurora-mysql) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
