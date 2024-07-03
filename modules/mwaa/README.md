# Component: `mwaa`

This component provisions Amazon managed workflows for Apache Airflow.

The s3 bucket `dag_bucket` stores DAGs to be executed by MWAA.

## Access Modes

### Public

Allows the Airflow UI to be access over the public internet to users granted access by an IAM policy.

### Private

Limits access to users within the VPC to users granted access by an IAM policy.

- MWAA creates a VPC interface endpoint for the Airflow webserver and an interface endpoint for the pgsql metadatabase.
  - the endpoints are created in the AZs mapped to your private subnets
- MWAA binds an IP address from your private subnet to the interface endpoint

### Managing access to VPC endpoings on MWAA

MWAA creates a VPC endpoint in each of the private subnets.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    mwaa:
      vars:
        enabled: true
        name: app
        dag_processing_logs_enabled: true
        dag_processing_logs_level: INFO
        environment_class: mw1.small
        airflow_version: 2.0.2
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_policy` | 0.4.0 | [`cloudposse/iam-policy/aws`](https://registry.terraform.io/modules/cloudposse/iam-policy/aws/0.4.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`mwaa_environment` | 0.4.8 | [`cloudposse/mwaa/aws`](https://registry.terraform.io/modules/cloudposse/mwaa/aws/0.4.8) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`vpc_ingress` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_iam_policy.mwaa_web_server_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)
  - [`aws_iam_role_policy_attachment.mwaa_web_server_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)
  - [`aws_iam_role_policy_attachment.secrets_manager_read_write`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)

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
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`airflow_configuration_options` (`map(string)`) <i>optional</i></dt>
  <dd>
    The Airflow override options<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`airflow_version` (`string`) <i>optional</i></dt>
  <dd>
    Airflow version of the MWAA environment, will be set by default to the latest version that MWAA supports.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`allow_ingress_from_vpc_stages` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of stages to pull VPC ingress cidr and add to security group<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "auto",
      "corp"
    ]
    ```
    
  </dd>
  <dt>`allowed_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDR blocks to be allowed to connect to the MWAA cluster<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_security_groups` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of IDs of Security Groups to allow access to the security group created by this module.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_web_access_role_arns` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of role ARNs to allow airflow web access<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`allowed_web_access_role_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of role names to allow airflow web access<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`create_iam_role` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the creatation of a default IAM Role for AWS MWAA<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`create_s3_bucket` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the creatation of an S3 bucket for AWS MWAA<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`dag_processing_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the collection of logs for processing DAGs<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`dag_processing_logs_level` (`string`) <i>optional</i></dt>
  <dd>
    DAG processing logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INFO"`
  </dd>
  <dt>`dag_s3_path` (`string`) <i>optional</i></dt>
  <dd>
    Path to dags in s3<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dags"`
  </dd>
  <dt>`environment_class` (`string`) <i>optional</i></dt>
  <dd>
    Environment class for the cluster. Possible options are mw1.small, mw1.medium, mw1.large.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"mw1.small"`
  </dd>
  <dt>`execution_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    If `create_iam_role` is `false` then set this to the target MWAA execution role<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`max_workers` (`number`) <i>optional</i></dt>
  <dd>
    The maximum number of workers that can be automatically scaled up. Value need to be between 1 and 25.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `10`
  </dd>
  <dt>`min_workers` (`number`) <i>optional</i></dt>
  <dd>
    The minimum number of workers that you want to run in your environment.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`plugins_s3_object_version` (`string`) <i>optional</i></dt>
  <dd>
    The plugins.zip file version you want to use.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`plugins_s3_path` (`string`) <i>optional</i></dt>
  <dd>
    The relative path to the plugins.zip file on your Amazon S3 storage bucket. For example, plugins.zip. If a relative path is provided in the request, then plugins_s3_object_version is required<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`requirements_s3_object_version` (`string`) <i>optional</i></dt>
  <dd>
    The requirements.txt file version you<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`requirements_s3_path` (`string`) <i>optional</i></dt>
  <dd>
    The relative path to the requirements.txt file on your Amazon S3 storage bucket. For example, requirements.txt. If a relative path is provided in the request, then requirements_s3_object_version is required<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`scheduler_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the collection of logs for the schedulers<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`scheduler_logs_level` (`string`) <i>optional</i></dt>
  <dd>
    Schedulers logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INFO"`
  </dd>
  <dt>`source_bucket_arn` (`string`) <i>optional</i></dt>
  <dd>
    Set this to the Amazon Resource Name (ARN) of your Amazon S3 storage bucket.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`task_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the collection of logs for DAG tasks<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`task_logs_level` (`string`) <i>optional</i></dt>
  <dd>
    DAG tasks logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INFO"`
  </dd>
  <dt>`webserver_access_mode` (`string`) <i>optional</i></dt>
  <dd>
    Specifies whether the webserver is accessible over the internet, PUBLIC_ONLY or PRIVATE_ONLY<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"PRIVATE_ONLY"`
  </dd>
  <dt>`webserver_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the collection of logs for the webservers<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`webserver_logs_level` (`string`) <i>optional</i></dt>
  <dd>
    Webserver logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INFO"`
  </dd>
  <dt>`weekly_maintenance_window_start` (`string`) <i>optional</i></dt>
  <dd>
    Specifies the start date for the weekly maintenance window.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`worker_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enabling or disabling the collection of logs for the workers<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`worker_logs_level` (`string`) <i>optional</i></dt>
  <dd>
    Workers logging level. Valid values: CRITICAL, ERROR, WARNING, INFO, DEBUG<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INFO"`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    ARN of MWAA environment.<br/>
  </dd>
  <dt>`created_at`</dt>
  <dd>
    The Created At date of the Amazon MWAA Environment<br/>
  </dd>
  <dt>`execution_role_arn`</dt>
  <dd>
    IAM Role ARN for Amazon MWAA Execution Role<br/>
  </dd>
  <dt>`logging_configuration`</dt>
  <dd>
    The Logging Configuration of the MWAA Environment<br/>
  </dd>
  <dt>`s3_bucket_arn`</dt>
  <dd>
    ID of S3 bucket.<br/>
  </dd>
  <dt>`security_group_id`</dt>
  <dd>
    ID of the MWAA Security Group(s)<br/>
  </dd>
  <dt>`service_role_arn`</dt>
  <dd>
    The Service Role ARN of the Amazon MWAA Environment<br/>
  </dd>
  <dt>`status`</dt>
  <dd>
    The status of the Amazon MWAA Environment<br/>
  </dd>
  <dt>`tags_all`</dt>
  <dd>
    A map of tags assigned to the resource, including those inherited from the provider for the Amazon MWAA Environment<br/>
  </dd>
  <dt>`webserver_url`</dt>
  <dd>
    The webserver URL of the Amazon MWAA Environment<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/TODO) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
