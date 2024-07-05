# Component: `glue/job`

This component provisions Glue jobs.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    glue/job/example:
      metadata:
        component: glue/job
      vars:
        enabled: true
        name: example
        job_description: Glue job example
        glue_version: "2.0"
        worker_type: Standard
        number_of_workers: 2
        max_retries: 2
        timeout: 20
        glue_iam_component_name: "glue/iam"
        glue_job_s3_bucket_component_name: "s3/datalake"
        glue_job_s3_bucket_script_path: "glue/glue_job.py"
        glue_job_command_name: glueetl
        glue_job_command_python_version: 3
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.0 |
| `utils` | >= 1.15.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`glue_iam_role` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`glue_job` | 0.4.0 | [`cloudposse/glue/aws//modules/glue-job`](https://registry.terraform.io/modules/cloudposse/glue/aws/modules/glue-job/0.4.0) | n/a
`glue_job_s3_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_policy.glue_job_aws_tools_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(iam.tf#58)
  - [`aws_iam_role_policy_attachment.glue_jobs_aws_tools_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(iam.tf#66)
  - [`aws_iam_role_policy_attachment.glue_redshift_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(iam.tf#73)

## Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.glue_job_aws_tools_access`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)

## Outputs

<dl>
  <dt><code>job_arn</code></dt>
  <dd>
  Glue job ARN<br/>

  </dd>
  <dt><code>job_id</code></dt>
  <dd>
  Glue job ID<br/>

  </dd>
  <dt><code>job_name</code></dt>
  <dd>
  Glue job name<br/>

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
### `command` (`map(any)`) <i>optional</i>


The command of the job<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(any)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `connections` (`list(string)`) <i>optional</i>


The list of connections used for this job<br/>

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


### `default_arguments` (`map(string)`) <i>optional</i>


The map of default arguments for the job. You can specify arguments here that your own job-execution script consumes, as well as arguments that AWS Glue itself consumes<br/>

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
>   <code>null</code>
>   </dd>
> </dl>
>


### `execution_property` <i>optional</i>


Execution property of the job<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    # The maximum number of concurrent runs allowed for the job. The default is 1.
    max_concurrent_runs = number
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `glue_iam_component_name` (`string`) <i>optional</i>


Glue IAM component name. Used to get the Glue IAM role from the remote state<br/>

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
>   <code>"glue/iam"</code>
>   </dd>
> </dl>
>


### `glue_job_command_name` (`string`) <i>optional</i>


The name of the job command. Defaults to glueetl. Use pythonshell for Python Shell Job Type, or gluestreaming for Streaming Job Type. max_capacity needs to be set if pythonshell is chosen<br/>

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
>   <code>"glueetl"</code>
>   </dd>
> </dl>
>


### `glue_job_command_python_version` (`number`) <i>optional</i>


The Python version being used to execute a Python shell job. Allowed values are 2, 3 or 3.9. Version 3 refers to Python 3.6<br/>

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
>   <code>3</code>
>   </dd>
> </dl>
>


### `glue_job_s3_bucket_component_name` (`string`) <i>optional</i>


Glue job S3 bucket component name. Used to get the remote state of the S3 bucket where the Glue job script is located<br/>

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


### `glue_job_s3_bucket_script_path` (`string`) <i>optional</i>


Glue job script path in the S3 bucket<br/>

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


### `glue_version` (`string`) <i>optional</i>


The version of Glue to use<br/>

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
>   <code>"2.0"</code>
>   </dd>
> </dl>
>


### `job_description` (`string`) <i>optional</i>


Glue job description<br/>

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


### `job_name` (`string`) <i>optional</i>


Glue job name. If not provided, the name will be generated from the context<br/>

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


### `max_capacity` (`number`) <i>optional</i>


The maximum number of AWS Glue data processing units (DPUs) that can be allocated when the job runs. Required when `pythonshell` is set, accept either 0.0625 or 1.0. Use `number_of_workers` and `worker_type` arguments instead with `glue_version` 2.0 and above<br/>

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


### `max_retries` (`number`) <i>optional</i>


 The maximum number of times to retry the job if it fails<br/>

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


### `non_overridable_arguments` (`map(string)`) <i>optional</i>


Non-overridable arguments for this job, specified as name-value pairs<br/>

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
>   <code>null</code>
>   </dd>
> </dl>
>


### `notification_property` <i>optional</i>


Notification property of the job<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    # After a job run starts, the number of minutes to wait before sending a job run delay notification
    notify_delay_after = number
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `number_of_workers` (`number`) <i>optional</i>


The number of workers of a defined `worker_type` that are allocated when a job runs<br/>

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


### `security_configuration` (`string`) <i>optional</i>


The name of the Security Configuration to be associated with the job<br/>

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


### `timeout` (`number`) <i>optional</i>


The job timeout in minutes. The default is 2880 minutes (48 hours) for `glueetl` and `pythonshell` jobs, and `null` (unlimted) for `gluestreaming` jobs<br/>

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
>   <code>2880</code>
>   </dd>
> </dl>
>


### `worker_type` (`string`) <i>optional</i>


The type of predefined worker that is allocated when a job runs. Accepts a value of `Standard`, `G.1X`, or `G.2X`<br/>

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



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

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


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
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
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
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


### `descriptor_formats` (`any`) <i>optional</i>


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
>   <code>{}</code>
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


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

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
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
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


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
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


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
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


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
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


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
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


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

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


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
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


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

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


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

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


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

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



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/glue/job) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
