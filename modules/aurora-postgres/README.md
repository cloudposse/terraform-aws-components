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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`postgresql`](https://registry.terraform.io/modules/postgresql/>= 1.17.1), version: >= 1.17.1
- [`random`](https://registry.terraform.io/modules/random/>= 2.3), version: >= 2.3

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0
- `random`, version: >= 2.3

### Modules

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


### Resources

The following resources are used by this module:

  - [`random_password.admin_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
  - [`random_pet.admin_user`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)
  - [`random_pet.database_name`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_iam_policy_document.kms_key_rds`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_security_groups.allowed`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) (data source)

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
  <dt>`cluster_name` (`string`) <i>required</i></dt>
  <dd>
    Short name for this cluster<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`cluster_size` (`number`) <i>required</i></dt>
  <dd>
    Postgres cluster size<br/>

    **Type:** `number`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`engine_mode` (`string`) <i>required</i></dt>
  <dd>
    The database engine mode. Valid values: `global`, `multimaster`, `parallelquery`, `provisioned`, `serverless`<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`instance_type` (`string`) <i>required</i></dt>
  <dd>
    EC2 instance type for Postgres cluster<br/>

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
  <dt>`admin_password` (`string`) <i>optional</i></dt>
  <dd>
    Postgres password for the admin user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`admin_user` (`string`) <i>optional</i></dt>
  <dd>
    Postgres admin user name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`allow_ingress_from_vpc_accounts` <i>optional</i></dt>
  <dd>
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
  <dt>`allow_major_version_upgrade` (`bool`) <i>optional</i></dt>
  <dd>
    Enable to allow major engine version upgrades when changing engine versions. Defaults to false.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`allowed_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDRs allowed to access the database (in addition to security groups and subnets)<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_security_group_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of security group names (tags) that should be allowed access to the database<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`autoscaling_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable cluster autoscaling<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`autoscaling_max_capacity` (`number`) <i>optional</i></dt>
  <dd>
    Maximum number of instances to be maintained by the autoscaler<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5`
  </dd>
  <dt>`autoscaling_min_capacity` (`number`) <i>optional</i></dt>
  <dd>
    Minimum number of instances to be maintained by the autoscaler<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`autoscaling_policy_type` (`string`) <i>optional</i></dt>
  <dd>
    Autoscaling policy type. `TargetTrackingScaling` and `StepScaling` are supported<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"TargetTrackingScaling"`
  </dd>
  <dt>`autoscaling_scale_in_cooldown` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time, in seconds, after a scaling activity completes and before the next scaling down activity can start. Default is 300s<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `300`
  </dd>
  <dt>`autoscaling_scale_out_cooldown` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time, in seconds, after a scaling activity completes and before the next scaling up activity can start. Default is 300s<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `300`
  </dd>
  <dt>`autoscaling_target_metrics` (`string`) <i>optional</i></dt>
  <dd>
    The metrics type to use. If this value isn't provided the default is CPU utilization<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"RDSReaderAverageCPUUtilization"`
  </dd>
  <dt>`autoscaling_target_value` (`number`) <i>optional</i></dt>
  <dd>
    The target value to scale with respect to target metrics<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `75`
  </dd>
  <dt>`backup_window` (`string`) <i>optional</i></dt>
  <dd>
    Daily time range during which the backups happen, UTC<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"07:00-09:00"`
  </dd>
  <dt>`ca_cert_identifier` (`string`) <i>optional</i></dt>
  <dd>
    The identifier of the CA certificate for the DB instance<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`cluster_dns_name_part` (`string`) <i>optional</i></dt>
  <dd>
    Part of DNS name added to module and cluster name for DNS for cluster endpoint<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"writer"`
  </dd>
  <dt>`cluster_family` (`string`) <i>optional</i></dt>
  <dd>
    Family of the DB parameter group. Valid values for Aurora PostgreSQL: `aurora-postgresql9.6`, `aurora-postgresql10`, `aurora-postgresql11`, `aurora-postgresql12`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"aurora-postgresql13"`
  </dd>
  <dt>`cluster_parameters` <i>optional</i></dt>
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
  <dt>`database_name` (`string`) <i>optional</i></dt>
  <dd>
    Name for an automatically created database on cluster creation. An empty name will generate a db name.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`database_port` (`number`) <i>optional</i></dt>
  <dd>
    Database port<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5432`
  </dd>
  <dt>`deletion_protection` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether the Cluster should have deletion protection enabled. The database can't be deleted when this value is set to `true`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`dns_gbl_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where global `dns_delegated` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
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
  <dt>`eks_security_group_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Use the eks default security group<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`enabled_cloudwatch_logs_exports` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of log types to export to cloudwatch. The following log types are supported: audit, error, general, slowquery<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`engine` (`string`) <i>optional</i></dt>
  <dd>
    Name of the database engine to be used for the DB cluster<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"postgresql"`
  </dd>
  <dt>`engine_version` (`string`) <i>optional</i></dt>
  <dd>
    Engine version of the Aurora global database<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"13.4"`
  </dd>
  <dt>`enhanced_monitoring_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Attributes used to format the Enhanced Monitoring IAM role. If this role hits IAM role length restrictions (max 64 characters), consider shortening these strings.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "enhanced-monitoring"
    ]
    ```
    
  </dd>
  <dt>`enhanced_monitoring_role_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`iam_database_authentication_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`intra_security_group_traffic_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to allow traffic between resources inside the database's security group.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`maintenance_window` (`string`) <i>optional</i></dt>
  <dd>
    Weekly time range during which system maintenance can occur, in UTC<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"wed:03:00-wed:04:00"`
  </dd>
  <dt>`performance_insights_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable Performance Insights<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`publicly_accessible` (`bool`) <i>optional</i></dt>
  <dd>
    Set true to make this database accessible from the public internet<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`rds_monitoring_interval` (`number`) <i>optional</i></dt>
  <dd>
    The interval, in seconds, between points when enhanced monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `60`
  </dd>
  <dt>`reader_dns_name_part` (`string`) <i>optional</i></dt>
  <dd>
    Part of DNS name added to module and cluster name for DNS for cluster reader<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"reader"`
  </dd>
  <dt>`retention_period` (`number`) <i>optional</i></dt>
  <dd>
    Number of days to retain backups for<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5`
  </dd>
  <dt>`scaling_configuration` <i>optional</i></dt>
  <dd>
    List of nested attributes with scaling properties. Only valid when `engine_mode` is set to `serverless`. This is required for Serverless v1<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    auto_pause               = bool
    max_capacity             = number
    min_capacity             = number
    seconds_until_auto_pause = number
    timeout_action           = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`serverlessv2_scaling_configuration` <i>optional</i></dt>
  <dd>
    Nested attribute with scaling properties for ServerlessV2. Only valid when `engine_mode` is set to `provisioned.` This is required for Serverless v2<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    min_capacity = number
    max_capacity = number
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`skip_final_snapshot` (`bool`) <i>optional</i></dt>
  <dd>
    Normally AWS makes a snapshot of the database before deleting it. Set this to `true` in order to skip this.<br/>
    NOTE: The final snapshot has a name derived from the cluster name. If you delete a cluster, get a final snapshot,<br/>
    then create a cluster of the same name, its final snapshot will fail with a name collision unless you delete<br/>
    the previous final snapshot first.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`snapshot_identifier` (`string`) <i>optional</i></dt>
  <dd>
    Specifies whether or not to create this cluster from a snapshot<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ssm_path_prefix` (`string`) <i>optional</i></dt>
  <dd>
    Top level SSM path prefix (without leading or trailing slash)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"aurora-postgres"`
  </dd>
  <dt>`storage_encrypted` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether the DB cluster is encrypted<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
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
  <dt>`admin_username`</dt>
  <dd>
    Postgres admin username<br/>
  </dd>
  <dt>`allowed_security_groups`</dt>
  <dd>
    The resulting list of security group IDs that are allowed to connect to the Aurora Postgres cluster.<br/>
  </dd>
  <dt>`cluster_identifier`</dt>
  <dd>
    Postgres cluster identifier<br/>
  </dd>
  <dt>`config_map`</dt>
  <dd>
    Map containing information pertinent to a PostgreSQL client configuration.<br/>
  </dd>
  <dt>`database_name`</dt>
  <dd>
    Postgres database name<br/>
  </dd>
  <dt>`kms_key_arn`</dt>
  <dd>
    KMS key ARN for Aurora Postgres<br/>
  </dd>
  <dt>`master_hostname`</dt>
  <dd>
    Postgres master hostname<br/>
  </dd>
  <dt>`replicas_hostname`</dt>
  <dd>
    Postgres replicas hostname<br/>
  </dd>
  <dt>`ssm_key_paths`</dt>
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
