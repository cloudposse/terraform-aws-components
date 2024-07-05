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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 0.13.0 |
| `aws` | >= 3.0 |
| `local` | >= 1.3 |
| `template` | >= 2.2 |
| `utils` | >= 1.10.0 |




## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`mq_broker` | 0.14.0 | [`cloudposse/mq-broker/aws`](https://registry.terraform.io/modules/cloudposse/mq-broker/aws/0.14.0) | n/a
`this` | 0.24.1 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a




## Outputs

<dl>
  <dt><code>broker_arn</code></dt>
  <dd>
  AmazonMQ broker ARN<br/>

  </dd>
  <dt><code>broker_id</code></dt>
  <dd>
  AmazonMQ broker ID<br/>

  </dd>
  <dt><code>primary_amqp_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ primary AMQP+SSL endpoint<br/>

  </dd>
  <dt><code>primary_console_url</code></dt>
  <dd>
  AmazonMQ active web console URL<br/>

  </dd>
  <dt><code>primary_ip_address</code></dt>
  <dd>
  AmazonMQ primary IP address<br/>

  </dd>
  <dt><code>primary_mqtt_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ primary MQTT+SSL endpoint<br/>

  </dd>
  <dt><code>primary_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ primary SSL endpoint<br/>

  </dd>
  <dt><code>primary_stomp_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ primary STOMP+SSL endpoint<br/>

  </dd>
  <dt><code>primary_wss_endpoint</code></dt>
  <dd>
  AmazonMQ primary WSS endpoint<br/>

  </dd>
  <dt><code>secondary_amqp_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ secondary AMQP+SSL endpoint<br/>

  </dd>
  <dt><code>secondary_console_url</code></dt>
  <dd>
  AmazonMQ secondary web console URL<br/>

  </dd>
  <dt><code>secondary_ip_address</code></dt>
  <dd>
  AmazonMQ secondary IP address<br/>

  </dd>
  <dt><code>secondary_mqtt_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ secondary MQTT+SSL endpoint<br/>

  </dd>
  <dt><code>secondary_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ secondary SSL endpoint<br/>

  </dd>
  <dt><code>secondary_stomp_ssl_endpoint</code></dt>
  <dd>
  AmazonMQ secondary STOMP+SSL endpoint<br/>

  </dd>
  <dt><code>secondary_wss_endpoint</code></dt>
  <dd>
  AmazonMQ secondary WSS endpoint<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `allowed_cidr_blocks` (`list(string)`) <i>optional</i>


List of CIDR blocks that are allowed ingress to the broker's Security Group created in the module<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `allowed_security_groups` (`list(string)`) <i>optional</i>


List of security groups to be allowed to connect to the broker instance<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `apply_immediately` (`bool`) <i>optional</i>


Specifies whether any cluster modifications are applied immediately, or during the next maintenance window<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `audit_log_enabled` (`bool`) <i>optional</i>


Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `auto_minor_version_upgrade` (`bool`) <i>optional</i>


Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `deployment_mode` (`string`) <i>optional</i>


The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"ACTIVE_STANDBY_MULTI_AZ"</code>
>   </dd>
> </dl>
>


### `encryption_enabled` (`bool`) <i>optional</i>


Flag to enable/disable Amazon MQ encryption at rest<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `engine_type` (`string`) <i>optional</i>


Type of broker engine, `ActiveMQ` or `RabbitMQ`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"ActiveMQ"</code>
>   </dd>
> </dl>
>


### `engine_version` (`string`) <i>optional</i>


The version of the broker engine. See https://docs.aws.amazon.com/amazon-mq/latest/developer-guide/broker-engine.html for more details<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"5.15.14"</code>
>   </dd>
> </dl>
>


### `existing_security_groups` (`list(string)`) <i>optional</i>


List of existing Security Group IDs to place the broker into. Set `use_existing_security_groups` to `true` to enable using `existing_security_groups` as Security Groups for the broker<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `general_log_enabled` (`bool`) <i>optional</i>


Enables general logging via CloudWatch<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `host_instance_type` (`string`) <i>optional</i>


The broker's instance type. e.g. mq.t2.micro or mq.m4.large<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"mq.t3.micro"</code>
>   </dd>
> </dl>
>


### `kms_mq_key_arn` (`string`) <i>optional</i>


ARN of the AWS KMS key used for Amazon MQ encryption<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `kms_ssm_key_arn` (`string`) <i>optional</i>


ARN of the AWS KMS key used for SSM encryption<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"alias/aws/ssm"</code>
>   </dd>
> </dl>
>


### `maintenance_day_of_week` (`string`) <i>optional</i>


The maintenance day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"SUNDAY"</code>
>   </dd>
> </dl>
>


### `maintenance_time_of_day` (`string`) <i>optional</i>


The maintenance time, in 24-hour format. e.g. 02:00<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"03:00"</code>
>   </dd>
> </dl>
>


### `maintenance_time_zone` (`string`) <i>optional</i>


The maintenance time zone, in either the Country/City format, or the UTC offset format. e.g. CET<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"UTC"</code>
>   </dd>
> </dl>
>


### `mq_admin_password` (`string`) <i>optional</i>


Admin password<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `mq_admin_user` (`string`) <i>optional</i>


Admin username<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `mq_application_password` (`string`) <i>optional</i>


Application password<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `mq_application_user` (`string`) <i>optional</i>


Application username<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `overwrite_ssm_parameter` (`bool`) <i>optional</i>


Whether to overwrite an existing SSM parameter<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `publicly_accessible` (`bool`) <i>optional</i>


Whether to enable connections from applications outside of the VPC that hosts the broker's subnets<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `ssm_parameter_name_format` (`string`) <i>optional</i>


SSM parameter name format<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"/%s/%s"</code>
>   </dd>
> </dl>
>


### `ssm_path` (`string`) <i>optional</i>


SSM path<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"mq"</code>
>   </dd>
> </dl>
>


### `use_aws_owned_key` (`bool`) <i>optional</i>


Boolean to enable an AWS owned Key Management Service (KMS) Customer Master Key (CMK) for Amazon MQ encryption that is not in your account<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `use_existing_security_groups` (`bool`) <i>optional</i>


Flag to enable/disable creation of Security Group in the module. Set to `true` to disable Security Group creation and provide a list of existing security Group IDs in `existing_security_groups` to place the broker into<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


Additional attributes (e.g. `1`)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {}
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for default, which is `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br/>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The naming order of the id output and Name tag.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 5 elements, but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


The letter case of output label values (also used in `tags` and `id`).<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


Solution name, e.g. 'app' or 'jenkins'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/mq-broker) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
