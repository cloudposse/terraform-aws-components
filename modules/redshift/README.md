# Component: `redshift`

This component is responsible for provisioning a RedShift instance. It seeds relevant database information (hostnames,
username, password, etc.) into AWS SSM Parameter Store.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    redshift:
      vars:
        enabled: true
        name: redshift
        database_name: redshift
        publicly_accessible: false
        node_type: dc2.large
        number_of_nodes: 1
        cluster_type: single-node
        ssm_enabled: true
        log_exports:
          - userlog
          - connectionlog
          - useractivitylog
        admin_user: redshift
        custom_sg_enabled: true
        custom_sg_rules:
          - type: ingress
            key: postgres
            description: Allow inbound traffic to the redshift cluster
            from_port: 5439
            to_port: 5439
            protocol: tcp
            cidr_blocks:
              - 10.0.0.0/8
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0), version: >= 1.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.17, <=4.67.0), version: >= 4.17, <=4.67.0
- [`random`](https://registry.terraform.io/modules/random/>= 3.0), version: >= 3.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.17, <=4.67.0
- `random`, version: >= 3.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`redshift_cluster` | 1.0.0 | [`cloudposse/redshift-cluster/aws`](https://registry.terraform.io/modules/cloudposse/redshift-cluster/aws/1.0.0) | n/a
`redshift_sg` | 2.2.0 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/2.2.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.redshift_database_hostname`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.redshift_database_name`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.redshift_database_password`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.redshift_database_port`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.redshift_database_user`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`random_password.admin_password`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)
  - [`random_pet.admin_user`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) (resource)

### Data Sources

The following data sources are used by this module:


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
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`admin_password` (`string`) <i>optional</i></dt>
  <dd>
    Password for the master DB user. Required unless a snapshot_identifier is provided<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`admin_user` (`string`) <i>optional</i></dt>
  <dd>
    Username for the master DB user. Required unless a snapshot_identifier is provided<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`allow_version_upgrade` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to enable major version upgrades which are applied during the maintenance window to the Amazon Redshift engine that is running on the cluster<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`cluster_type` (`string`) <i>optional</i></dt>
  <dd>
    The cluster type to use. Either `single-node` or `multi-node`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"single-node"`
  </dd>
  <dt>`custom_sg_allow_all_egress` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to allow all egress traffic or not<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`custom_sg_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to use custom security group or not<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`custom_sg_rules` <i>optional</i></dt>
  <dd>
    An array of custom security groups to create and assign to the cluster.<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    key         = string
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`database_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the first database to be created when the cluster is created<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`engine_version` (`string`) <i>optional</i></dt>
  <dd>
    The version of the Amazon Redshift engine to use. See https://docs.aws.amazon.com/redshift/latest/mgmt/cluster-versions.html<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"1.0"`
  </dd>
  <dt>`kms_alias_name_ssm` (`string`) <i>optional</i></dt>
  <dd>
    KMS alias name for SSM<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"alias/aws/ssm"`
  </dd>
  <dt>`node_type` (`string`) <i>optional</i></dt>
  <dd>
    The node type to be provisioned for the cluster. See https://docs.aws.amazon.com/redshift/latest/mgmt/working-with-clusters.html#working-with-clusters-overview<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dc2.large"`
  </dd>
  <dt>`number_of_nodes` (`number`) <i>optional</i></dt>
  <dd>
    The number of compute nodes in the cluster. This parameter is required when the ClusterType parameter is specified as multi-node<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`port` (`number`) <i>optional</i></dt>
  <dd>
    The port number on which the cluster accepts incoming connections<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `5439`
  </dd>
  <dt>`publicly_accessible` (`bool`) <i>optional</i></dt>
  <dd>
    If true, the cluster can be accessed from a public network<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`security_group_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    An array of security group IDs to associate with the endpoint.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ssm_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true` create SSM keys for the database user and password.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`ssm_key_format` (`string`) <i>optional</i></dt>
  <dd>
    SSM path format. The values will will be used in the following order: `var.ssm_key_prefix`, `var.name`, `var.ssm_key_*`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/%v/%v/%v"`
  </dd>
  <dt>`ssm_key_hostname` (`string`) <i>optional</i></dt>
  <dd>
    The SSM key to save the hostname. See `var.ssm_path_format`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin/db_hostname"`
  </dd>
  <dt>`ssm_key_password` (`string`) <i>optional</i></dt>
  <dd>
    The SSM key to save the password. See `var.ssm_path_format`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin/db_password"`
  </dd>
  <dt>`ssm_key_port` (`string`) <i>optional</i></dt>
  <dd>
    The SSM key to save the port. See `var.ssm_path_format`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin/db_port"`
  </dd>
  <dt>`ssm_key_prefix` (`string`) <i>optional</i></dt>
  <dd>
    SSM path prefix. Omit the leading forward slash `/`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"redshift"`
  </dd>
  <dt>`ssm_key_user` (`string`) <i>optional</i></dt>
  <dd>
    The SSM key to save the user. See `var.ssm_path_format`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin/db_user"`
  </dd>
  <dt>`use_private_subnets` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to use private or public subnets for the Redshift cluster<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    Amazon Resource Name (ARN) of cluster<br/>
  </dd>
  <dt>`cluster_identifier`</dt>
  <dd>
    The Cluster Identifier<br/>
  </dd>
  <dt>`cluster_security_groups`</dt>
  <dd>
    The security groups associated with the cluster<br/>
  </dd>
  <dt>`database_name`</dt>
  <dd>
    The name of the default database in the Cluster<br/>
  </dd>
  <dt>`dns_name`</dt>
  <dd>
    The DNS name of the cluster<br/>
  </dd>
  <dt>`endpoint`</dt>
  <dd>
    The connection endpoint<br/>
  </dd>
  <dt>`id`</dt>
  <dd>
    The Redshift Cluster ID<br/>
  </dd>
  <dt>`port`</dt>
  <dd>
    The Port the cluster responds on<br/>
  </dd>
  <dt>`redshift_database_ssm_key_prefix`</dt>
  <dd>
    SSM prefix<br/>
  </dd>
  <dt>`vpc_security_group_ids`</dt>
  <dd>
    The VPC security group IDs associated with the cluster<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/redshift) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
