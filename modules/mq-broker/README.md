# Component: `mq-broker`

This component is responsible for provisioning an AmazonMQ broker and corresponding security group.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    mq-broker:
      vars:
        enabled: true
        apply_immediately: true
        auto_minor_version_upgrade: true
        deployment_mode: "ACTIVE_STANDBY_MULTI_AZ"
        engine_type: "ActiveMQ"
        engine_version: "5.15.14"
        host_instance_type: "mq.t3.micro"
        publicly_accessible: false
        general_log_enabled: true
        audit_log_enabled: true
        encryption_enabled: true
        use_aws_owned_key: true
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 0.13.0), version: >= 0.13.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`local`](https://registry.terraform.io/modules/local/>= 1.3), version: >= 1.3
- [`template`](https://registry.terraform.io/modules/template/>= 2.2), version: >= 2.2
- [`utils`](https://registry.terraform.io/modules/utils/>= 1.10.0), version: >= 1.10.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`mq_broker` | 0.14.0 | [`cloudposse/mq-broker/aws`](https://registry.terraform.io/modules/cloudposse/mq-broker/aws/0.14.0) | n/a
`this` | 0.24.1 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a




### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Additional attributes (e.g. `1`)<br/>
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
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {}
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
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
    Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for default, which is `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The naming order of the id output and Name tag.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 5 elements, but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    The letter case of output label values (also used in `tags` and `id`).<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    Solution name, e.g. 'app' or 'jenkins'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
</dl>

### Required Inputs

<dl>
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
  <dt>`allowed_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDR blocks that are allowed ingress to the broker's Security Group created in the module<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_security_groups` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of security groups to be allowed to connect to the broker instance<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`apply_immediately` (`bool`) <i>optional</i></dt>
  <dd>
    Specifies whether any cluster modifications are applied immediately, or during the next maintenance window<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`audit_log_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`auto_minor_version_upgrade` (`bool`) <i>optional</i></dt>
  <dd>
    Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`deployment_mode` (`string`) <i>optional</i></dt>
  <dd>
    The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ACTIVE_STANDBY_MULTI_AZ"`
  </dd>
  <dt>`encryption_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable Amazon MQ encryption at rest<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`engine_type` (`string`) <i>optional</i></dt>
  <dd>
    Type of broker engine, `ActiveMQ` or `RabbitMQ`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ActiveMQ"`
  </dd>
  <dt>`engine_version` (`string`) <i>optional</i></dt>
  <dd>
    The version of the broker engine. See https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html for more details<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"5.15.14"`
  </dd>
  <dt>`existing_security_groups` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of existing Security Group IDs to place the broker into. Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the broker<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`general_log_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enables general logging via CloudWatch<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`host_instance_type` (`string`) <i>optional</i></dt>
  <dd>
    The broker's instance type. e.g. mq.t2.micro or mq.m4.large<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"mq.t3.micro"`
  </dd>
  <dt>`kms_mq_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    ARN of the AWS KMS key used for Amazon MQ encryption<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`kms_ssm_key_arn` (`string`) <i>optional</i></dt>
  <dd>
    ARN of the AWS KMS key used for SSM encryption<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"alias/aws/ssm"`
  </dd>
  <dt>`maintenance_day_of_week` (`string`) <i>optional</i></dt>
  <dd>
    The maintenance day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"SUNDAY"`
  </dd>
  <dt>`maintenance_time_of_day` (`string`) <i>optional</i></dt>
  <dd>
    The maintenance time, in 24-hour format. e.g. 02:00<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"03:00"`
  </dd>
  <dt>`maintenance_time_zone` (`string`) <i>optional</i></dt>
  <dd>
    The maintenance time zone, in either the Country/City format, or the UTC offset format. e.g. CET<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"UTC"`
  </dd>
  <dt>`mq_admin_password` (`string`) <i>optional</i></dt>
  <dd>
    Admin password<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`mq_admin_user` (`string`) <i>optional</i></dt>
  <dd>
    Admin username<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`mq_application_password` (`string`) <i>optional</i></dt>
  <dd>
    Application password<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`mq_application_user` (`string`) <i>optional</i></dt>
  <dd>
    Application username<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`overwrite_ssm_parameter` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to overwrite an existing SSM parameter<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`publicly_accessible` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to enable connections from applications outside of the VPC that hosts the broker's subnets<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`ssm_parameter_name_format` (`string`) <i>optional</i></dt>
  <dd>
    SSM parameter name format<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/%s/%s"`
  </dd>
  <dt>`ssm_path` (`string`) <i>optional</i></dt>
  <dd>
    SSM path<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"mq"`
  </dd>
  <dt>`use_aws_owned_key` (`bool`) <i>optional</i></dt>
  <dd>
    Boolean to enable an AWS owned Key Management Service (KMS) Customer Master Key (CMK) for Amazon MQ encryption that is not in your account<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`use_existing_security_groups` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable creation of Security Group in the module. Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the broker into<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`broker_arn`</dt>
  <dd>
    AmazonMQ broker ARN<br/>
  </dd>
  <dt>`broker_id`</dt>
  <dd>
    AmazonMQ broker ID<br/>
  </dd>
  <dt>`primary_amqp_ssl_endpoint`</dt>
  <dd>
    AmazonMQ primary AMQP+SSL endpoint<br/>
  </dd>
  <dt>`primary_console_url`</dt>
  <dd>
    AmazonMQ active web console URL<br/>
  </dd>
  <dt>`primary_ip_address`</dt>
  <dd>
    AmazonMQ primary IP address<br/>
  </dd>
  <dt>`primary_mqtt_ssl_endpoint`</dt>
  <dd>
    AmazonMQ primary MQTT+SSL endpoint<br/>
  </dd>
  <dt>`primary_ssl_endpoint`</dt>
  <dd>
    AmazonMQ primary SSL endpoint<br/>
  </dd>
  <dt>`primary_stomp_ssl_endpoint`</dt>
  <dd>
    AmazonMQ primary STOMP+SSL endpoint<br/>
  </dd>
  <dt>`primary_wss_endpoint`</dt>
  <dd>
    AmazonMQ primary WSS endpoint<br/>
  </dd>
  <dt>`secondary_amqp_ssl_endpoint`</dt>
  <dd>
    AmazonMQ secondary AMQP+SSL endpoint<br/>
  </dd>
  <dt>`secondary_console_url`</dt>
  <dd>
    AmazonMQ secondary web console URL<br/>
  </dd>
  <dt>`secondary_ip_address`</dt>
  <dd>
    AmazonMQ secondary IP address<br/>
  </dd>
  <dt>`secondary_mqtt_ssl_endpoint`</dt>
  <dd>
    AmazonMQ secondary MQTT+SSL endpoint<br/>
  </dd>
  <dt>`secondary_ssl_endpoint`</dt>
  <dd>
    AmazonMQ secondary SSL endpoint<br/>
  </dd>
  <dt>`secondary_stomp_ssl_endpoint`</dt>
  <dd>
    AmazonMQ secondary STOMP+SSL endpoint<br/>
  </dd>
  <dt>`secondary_wss_endpoint`</dt>
  <dd>
    AmazonMQ secondary WSS endpoint<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/mq-broker) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
