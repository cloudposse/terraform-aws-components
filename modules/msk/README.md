# Component: `msk/cluster`

This component is responsible for provisioning [Amazon Managed Streaming](https://aws.amazon.com/msk/) clusters for
[Apache Kafka](https://aws.amazon.com/msk/what-is-kafka/).

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    msk:
      metadata:
        component: "msk"
      vars:
        enabled: true
        name: "msk"
        vpc_component_name: "vpc"
        dns_delegated_component_name: "dns-delegated"
        dns_delegated_environment_name: "gbl"
        # https://docs.aws.amazon.com/msk/latest/developerguide/supported-kafka-versions.html
        kafka_version: "3.4.0"
        public_access_enabled: false
        # https://aws.amazon.com/msk/pricing/
        broker_instance_type: "kafka.m5.large"
        # Number of brokers per AZ
        broker_per_zone: 1
        #  `broker_dns_records_count` specifies how many DNS records to create for the broker endpoints in the DNS zone provided in the `zone_id` variable.
        #  This corresponds to the total number of broker endpoints created by the module.
        #  Calculate this number by multiplying the `broker_per_zone` variable by the subnet count.
        broker_dns_records_count: 3
        broker_volume_size: 500
        client_broker: "TLS_PLAINTEXT"
        encryption_in_cluster: true
        encryption_at_rest_kms_key_arn: ""
        enhanced_monitoring: "DEFAULT"
        certificate_authority_arns: []

        # Authentication methods
        client_allow_unauthenticated: true
        client_sasl_scram_enabled: false
        client_sasl_scram_secret_association_enabled: false
        client_sasl_scram_secret_association_arns: []
        client_sasl_iam_enabled: false
        client_tls_auth_enabled: false

        jmx_exporter_enabled: false
        node_exporter_enabled: false
        cloudwatch_logs_enabled: false
        firehose_logs_enabled: false
        firehose_delivery_stream: ""
        s3_logs_enabled: false
        s3_logs_bucket: ""
        s3_logs_prefix: ""
        properties: {}
        autoscaling_enabled: true
        storage_autoscaling_target_value: 60
        storage_autoscaling_max_capacity: null
        storage_autoscaling_disable_scale_in: false
        create_security_group: true
        security_group_rule_description: "Allow inbound %s traffic"
        # A list of IDs of Security Groups to allow access to the cluster security group
        allowed_security_group_ids: []
        # A list of IPv4 CIDRs to allow access to the cluster security group
        allowed_cidr_blocks: []
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`kafka` | 2.3.0 | [`cloudposse/msk-apache-kafka-cluster/aws`](https://registry.terraform.io/modules/cloudposse/msk-apache-kafka-cluster/aws/2.3.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a




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
  <dt>`broker_instance_type` (`string`) <i>required</i></dt>
  <dd>
    The instance type to use for the Kafka brokers<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`kafka_version` (`string`) <i>required</i></dt>
  <dd>
    The desired Kafka software version.<br/>
    Refer to https://docs.aws.amazon.com/msk/latest/developerguide/supported-kafka-versions.html for more details<br/>
    <br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`vpc_component_name` (`string`) <i>required</i></dt>
  <dd>
    The name of the Atmos VPC component<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`additional_security_group_rules` (`list(any)`) <i>optional</i></dt>
  <dd>
    A list of Security Group rule objects to add to the created security group, in addition to the ones<br/>
    this module normally creates. (To suppress the module's rules, set `create_security_group` to false<br/>
    and supply your own security group(s) via `associated_security_group_ids`.)<br/>
    The keys and values of the objects are fully compatible with the `aws_security_group_rule` resource, except<br/>
    for `security_group_id` which will be ignored, and the optional "key" which, if provided, must be unique and known at "plan" time.<br/>
    For more info see https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule<br/>
    and https://github.com/cloudposse/terraform-aws-security-group.<br/>
    <br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allow_all_egress` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, the created security group will allow egress on all ports and protocols to all IP addresses.<br/>
    If this is false and no egress rules are otherwise specified, then no egress will be allowed.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`allowed_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of IPv4 CIDRs to allow access to the security group created by this module.<br/>
    The length of this list must be known at "plan" time.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_security_group_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of IDs of Security Groups to allow access to the security group created by this module.<br/>
    The length of this list must be known at "plan" time.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`associated_security_group_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of IDs of Security Groups to associate the created resource with, in addition to the created security group.<br/>
    These security groups will not be modified and, if `create_security_group` is `false`, must have rules providing the desired access.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`autoscaling_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    To automatically expand your cluster's storage in response to increased usage, you can enable this. [More info](https://docs.aws.amazon.com/msk/latest/developerguide/msk-autoexpand.html)<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`broker_dns_records_count` (`number`) <i>optional</i></dt>
  <dd>
    This variable specifies how many DNS records to create for the broker endpoints in the DNS zone provided in the `zone_id` variable.<br/>
    This corresponds to the total number of broker endpoints created by the module.<br/>
    Calculate this number by multiplying the `broker_per_zone` variable by the subnet count.<br/>
    This variable is necessary to prevent the Terraform error:<br/>
    The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created.<br/>
    <br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `0`
  </dd>
  <dt>`broker_per_zone` (`number`) <i>optional</i></dt>
  <dd>
    Number of Kafka brokers per zone<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`broker_volume_size` (`number`) <i>optional</i></dt>
  <dd>
    The size in GiB of the EBS volume for the data drive on each broker node<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1000`
  </dd>
  <dt>`certificate_authority_arns` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of ACM Certificate Authority Amazon Resource Names (ARNs) to be used for TLS client authentication<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_allow_unauthenticated` (`bool`) <i>optional</i></dt>
  <dd>
    Enable unauthenticated access<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`client_broker` (`string`) <i>optional</i></dt>
  <dd>
    Encryption setting for data in transit between clients and brokers. Valid values: `TLS`, `TLS_PLAINTEXT`, and `PLAINTEXT`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"TLS"`
  </dd>
  <dt>`client_sasl_iam_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable client authentication via IAM policies. Cannot be set to `true` at the same time as `client_tls_auth_enabled`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`client_sasl_scram_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable SCRAM client authentication via AWS Secrets Manager. Cannot be set to `true` at the same time as `client_tls_auth_enabled`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`client_sasl_scram_secret_association_arns` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of AWS Secrets Manager secret ARNs for SCRAM authentication<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_sasl_scram_secret_association_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable the list of AWS Secrets Manager secret ARNs for SCRAM authentication<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`client_tls_auth_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to enable the Client TLS Authentication<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`cloudwatch_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Indicates whether you want to enable or disable streaming broker logs to Cloudwatch Logs<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`cloudwatch_logs_log_group` (`string`) <i>optional</i></dt>
  <dd>
    Name of the Cloudwatch Log Group to deliver logs to<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`create_security_group` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to create and configure a new security group. If false, `associated_security_group_ids` must be provided.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`custom_broker_dns_name` (`string`) <i>optional</i></dt>
  <dd>
    Custom Route53 DNS hostname for MSK brokers. Use `%%ID%%` key to specify brokers index in the hostname. Example: `kafka-broker%%ID%%.example.com`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`dns_delegated_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The component name of `dns-delegated`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dns-delegated"`
  </dd>
  <dt>`dns_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The environment name of `dns-delegated`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`encryption_at_rest_kms_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`encryption_in_cluster` (`bool`) <i>optional</i></dt>
  <dd>
    Whether data communication among broker nodes is encrypted<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`enhanced_monitoring` (`string`) <i>optional</i></dt>
  <dd>
    Specify the desired enhanced MSK CloudWatch monitoring level. Valid values: `DEFAULT`, `PER_BROKER`, and `PER_TOPIC_PER_BROKER`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"DEFAULT"`
  </dd>
  <dt>`firehose_delivery_stream` (`string`) <i>optional</i></dt>
  <dd>
    Name of the Kinesis Data Firehose delivery stream to deliver logs to<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`firehose_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Indicates whether you want to enable or disable streaming broker logs to Kinesis Data Firehose<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`inline_rules_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources.<br/>
    See [#20046](https://github.com/hashicorp/terraform-provider-aws/issues/20046) for one of several issues with inline rules.<br/>
    See [this post](https://github.com/hashicorp/terraform-provider-aws/pull/9032#issuecomment-639545250) for details on the difference between inline rules and rule resources.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`jmx_exporter_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to enable the JMX Exporter<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`node_exporter_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to enable the Node Exporter<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`preserve_security_group_id` (`bool`) <i>optional</i></dt>
  <dd>
    When `false` and `security_group_create_before_destroy` is `true`, changes to security group rules<br/>
    cause a new security group to be created with the new rules, and the existing security group is then<br/>
    replaced with the new one, eliminating any service interruption.<br/>
    When `true` or when changing the value (from `false` to `true` or from `true` to `false`),<br/>
    existing security group rules will be deleted before new ones are created, resulting in a service interruption,<br/>
    but preserving the security group itself.<br/>
    **NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,<br/>
    it only keeps changes to the security group rules from triggering a replacement.<br/>
    See the [terraform-aws-security-group README](https://github.com/cloudposse/terraform-aws-security-group) for further discussion.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`properties` (`map(string)`) <i>optional</i></dt>
  <dd>
    Contents of the server.properties file. Supported properties are documented in the [MSK Developer Guide](https://docs.aws.amazon.com/msk/latest/developerguide/msk-configuration-properties.html)<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`public_access_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable public access to MSK cluster (given that all of the requirements are met)<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`s3_logs_bucket` (`string`) <i>optional</i></dt>
  <dd>
    Name of the S3 bucket to deliver logs to<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`s3_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
     Indicates whether you want to enable or disable streaming broker logs to S3<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`s3_logs_prefix` (`string`) <i>optional</i></dt>
  <dd>
    Prefix to append to the S3 folder name logs are delivered to<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`security_group_create_before_destroy` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.<br/>
    We only recommend setting this `false` if you are importing an existing security group<br/>
    that you do not want replaced and therefore need full control over its name.<br/>
    Note that changing this value will always cause the security group to be replaced.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`security_group_create_timeout` (`string`) <i>optional</i></dt>
  <dd>
    How long to wait for the security group to be created.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"10m"`
  </dd>
  <dt>`security_group_delete_timeout` (`string`) <i>optional</i></dt>
  <dd>
    How long to retry on `DependencyViolation` errors during security group deletion from<br/>
    lingering ENIs left by certain AWS services such as Elastic Load Balancing.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"15m"`
  </dd>
  <dt>`security_group_description` (`string`) <i>optional</i></dt>
  <dd>
    The description to assign to the created Security Group.<br/>
    Warning: Changing the description causes the security group to be replaced.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"Managed by Terraform"`
  </dd>
  <dt>`security_group_name` (`list(string)`) <i>optional</i></dt>
  <dd>
    The name to assign to the created security group. Must be unique within the VPC.<br/>
    If not provided, will be derived from the `null-label.context` passed in.<br/>
    If `create_before_destroy` is true, will be used as a name prefix.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`security_group_rule_description` (`string`) <i>optional</i></dt>
  <dd>
    The description to place on each security group rule. The %s will be replaced with the protocol name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"Allow inbound %s traffic"`
  </dd>
  <dt>`storage_autoscaling_disable_scale_in` (`bool`) <i>optional</i></dt>
  <dd>
    If the value is true, scale in is disabled and the target tracking policy won't remove capacity from the scalable resource<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`storage_autoscaling_max_capacity` (`number`) <i>optional</i></dt>
  <dd>
    Maximum size the autoscaling policy can scale storage. Defaults to `broker_volume_size`<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`storage_autoscaling_target_value` (`number`) <i>optional</i></dt>
  <dd>
    Percentage of storage used to trigger autoscaled storage increase<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `60`
  </dd></dl>


### Outputs

<dl>
  <dt>`bootstrap_brokers`</dt>
  <dd>
    Comma separated list of one or more hostname:port pairs of Kafka brokers suitable to bootstrap connectivity to the Kafka cluster<br/>
  </dd>
  <dt>`bootstrap_brokers_public_sasl_iam`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and SASL IAM port pairs for public access to the Kafka cluster using SASL/IAM<br/>
  </dd>
  <dt>`bootstrap_brokers_public_sasl_scram`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and SASL SCRAM port pairs for public access to the Kafka cluster using SASL/SCRAM<br/>
  </dd>
  <dt>`bootstrap_brokers_public_tls`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and TLS port pairs for public access to the Kafka cluster using TLS<br/>
  </dd>
  <dt>`bootstrap_brokers_sasl_iam`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and SASL IAM port pairs for access to the Kafka cluster using SASL/IAM<br/>
  </dd>
  <dt>`bootstrap_brokers_sasl_scram`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and SASL SCRAM port pairs for access to the Kafka cluster using SASL/SCRAM<br/>
  </dd>
  <dt>`bootstrap_brokers_tls`</dt>
  <dd>
    Comma separated list of one or more DNS names (or IP addresses) and TLS port pairs for access to the Kafka cluster using TLS<br/>
  </dd>
  <dt>`broker_endpoints`</dt>
  <dd>
    List of broker endpoints<br/>
  </dd>
  <dt>`cluster_arn`</dt>
  <dd>
    Amazon Resource Name (ARN) of the MSK cluster<br/>
  </dd>
  <dt>`cluster_name`</dt>
  <dd>
    The cluster name of the MSK cluster<br/>
  </dd>
  <dt>`config_arn`</dt>
  <dd>
    Amazon Resource Name (ARN) of the MSK configuration<br/>
  </dd>
  <dt>`current_version`</dt>
  <dd>
    Current version of the MSK Cluster<br/>
  </dd>
  <dt>`hostnames`</dt>
  <dd>
    List of MSK Cluster broker DNS hostnames<br/>
  </dd>
  <dt>`latest_revision`</dt>
  <dd>
    Latest revision of the MSK configuration<br/>
  </dd>
  <dt>`security_group_arn`</dt>
  <dd>
    The ARN of the created security group<br/>
  </dd>
  <dt>`security_group_id`</dt>
  <dd>
    The ID of the created security group<br/>
  </dd>
  <dt>`security_group_name`</dt>
  <dd>
    The name of the created security group<br/>
  </dd>
  <dt>`storage_mode`</dt>
  <dd>
    Storage mode for supported storage tiers<br/>
  </dd>
  <dt>`zookeeper_connect_string`</dt>
  <dd>
    Comma separated list of one or more hostname:port pairs to connect to the Apache Zookeeper cluster<br/>
  </dd>
  <dt>`zookeeper_connect_string_tls`</dt>
  <dd>
    Comma separated list of one or more hostname:port pairs to connect to the Apache Zookeeper cluster via TLS<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_cluster
- https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/msk_serverless_cluster
- https://aws.amazon.com/blogs/big-data/securing-apache-kafka-is-easy-and-familiar-with-iam-access-control-for-amazon-msk/
- https://docs.aws.amazon.com/msk/latest/developerguide/security-iam.html
- https://docs.aws.amazon.com/msk/latest/developerguide/iam-access-control.html
- https://docs.aws.amazon.com/msk/latest/developerguide/kafka_apis_iam.html
- https://github.com/aws/aws-msk-iam-auth
- https://www.cloudthat.com/resources/blog/a-guide-to-create-aws-msk-cluster-with-iam-based-authentication
- https://blog.devops.dev/how-to-use-iam-auth-with-aws-msk-a-step-by-step-guide-2023-eb8291781fcb
- https://www.kai-waehner.de/blog/2022/08/30/when-not-to-choose-amazon-msk-serverless-for-apache-kafka/
- https://stackoverflow.com/questions/72508438/connect-python-to-msk-with-iam-role-based-authentication
- https://github.com/aws/aws-msk-iam-auth/issues/10
- https://aws.amazon.com/msk/faqs/
- https://aws.amazon.com/blogs/big-data/secure-connectivity-patterns-to-access-amazon-msk-across-aws-regions/
- https://docs.aws.amazon.com/msk/latest/developerguide/client-access.html
- https://repost.aws/knowledge-center/msk-broker-custom-ports

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
