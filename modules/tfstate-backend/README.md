# Component: `tfstate-backend`

This component is responsible for provisioning an S3 Bucket and DynamoDB table that follow security best practices for
usage as a Terraform backend. It also creates IAM roles for access to the Terraform backend.

Once the initial S3 backend is configured, this component can create additional backends, allowing you to segregate them
and control access to each backend separately. This may be desirable because any secret or sensitive information (such
as generated passwords) that Terraform has access to gets stored in the Terraform state backend S3 bucket, so you may
wish to restrict who can read the production Terraform state backend S3 bucket. However, perhaps counter-intuitively,
all Terraform users require read access to the most sensitive accounts, such as `root` and `audit`, in order to read
security configuration information, so careful planning is required when architecting backend splits.

:::info

Part of cold start, so it has to initially be run with `SuperAdmin`, multiple
times: to create the S3 bucket and then to move the state into it. Follow
the guide **[here](https://docs.cloudposse.com/reference-architecture/how-to-guides/implementation/enterprise/implement-aws-cold-start/#provision-tfstate-backend-component)**
to get started.

:::

### Access Control

For each backend, this module will create an IAM role with read/write access and, optionally, an IAM role with read-only
access. You can configure who is allowed to assume these roles.

- While read/write access is required for `terraform apply`, the created role only grants read/write access to the
  Terraform state, it does not grant permission to create/modify/destroy AWS resources.

- Similarly, while the read-only role prohibits making changes to the Terraform state, it does not prevent anyone from
  making changes to AWS resources using a different role.

- Many Cloud Posse components store information about resources they create in the Terraform state via their outputs,
  and many other components read this information from the Terraform state backend via the CloudPosse `remote-state`
  module and use it as part of their configuration. For example, the `account-map` component exists solely for the
  purpose of organizing information about the created AWS accounts and storing it in its Terraform state, making it
  available via `remote-state`. This means that you if you are going to restrict access to some backends, you need to
  carefully orchestrate what is stored there and ensure that you are not storing information a component needs in a
  backend it will not have access to. Typically, information in the most sensitive accounts, such as `root`, `audit`,
  and `security`, is nevertheless needed by every account, for example to know where to send audit logs, so it is not
  obvious and can be counter-intuitive which accounts need access to which backends. Plan carefully.

- Atmos provides separate configuration for Terraform state access via the `backend` and `remote_state_backend`
  settings. Always configure the `backend` setting with a role that has read/write access (and override that setting to
  be `null` for components deployed by SuperAdmin). If a read-only role is available (only helpful if you have more than
  one backend), use that role in `remote_state_backend.s3.role_arn`. Otherwise, use the read/write role in
  `remote_state_backend.s3.role_arn`, to ensure that all components can read the Terraform state, even if
  `backend.s3.role_arn` is set to `null`, as it is with a few critical components meant to be deployed by SuperAdmin.

- Note that the "read-only" in the "read-only role" refers solely to the S3 bucket that stores the backend data. That
  role still has read/write access to the DynamoDB table, which is desirable so that users restricted to the read-only
  role can still perform drift detection by running `terraform plan`. The DynamoDB table only stores checksums and
  mutual-exclusion lock information, so it is not considered sensitive. The worst a malicious user could do would be to
  corrupt the table and cause a denial-of-service (DoS) for Terraform, but such DoS would only affect making changes to
  the infrastructure, it would not affect the operation of the existing infrastructure, so it is an ineffective and
  therefore unlikely vector of attack. (Also note that the entire DynamoDB table is optional and can be deleted
  entirely; Terraform will repopulate it as new activity takes place.)

- For convenience, the component automatically grants access to the backend to the user deploying it. This is helpful
  because it allows that user, presumably SuperAdmin, to deploy the normal components that expect the user does not have
  direct access to Terraform state, without requiring custom configuration. However, you may want to explicitly
  grant SuperAdmin access to the backend in the `allowed_principal_arns` configuration, to ensure that SuperAdmin
  can always access the backend, even if the component is later updated by the `root-admin` role.

### Quotas

When allowing access to both SAML and AWS SSO users, the trust policy for the IAM roles created by this component can
exceed the default 2048 character limit. If you encounter this error, you can increase the limit by requesting a quota
increase [here](https://us-east-1.console.aws.amazon.com/servicequotas/home/services/iam/quotas/L-C07B4B0D). Note that
this is the IAM limit on "The maximum number of characters in an IAM role trust policy" and it must be configured in the
`us-east-1` region, regardless of what region you are deploying to. Normally 3072 characters is sufficient, and is
recommended so that you still have room to expand the trust policy in the future while perhaps considering how to reduce
its size.

## Usage

**Stack Level**: Regional (because DynamoDB is region-specific), but deploy only in a single region and only in the
`root` account **Deployment**: Must be deployed by SuperAdmin using `atmos` CLI

This component configures the shared Terraform backend, and as such is the first component that must be deployed, since
all other components depend on it. In fact, this component even depends on itself, so special deployment procedures are
needed for the initial deployment (documented in the "Cold Start" procedures).

Here's an example snippet for how to use this component.

```yaml
terraform:
  tfstate-backend:
    backend:
      s3:
        role_arn: null
    settings:
      spacelift:
        workspace_enabled: false
    vars:
      enable_server_side_encryption: true
      enabled: true
      force_destroy: false
      name: tfstate
      prevent_unencrypted_uploads: true
      access_roles:
        default: &tfstate-access-template
          write_enabled: true
          allowed_roles:
            core-identity: ["devops", "developers", "managers", "spacelift"]
            core-root: ["admin"]
          denied_roles: {}
          allowed_permission_sets:
            core-identity: ["AdministratorAccess"]
          denied_permission_sets: {}
          allowed_principal_arns: []
          denied_principal_arns: []
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `awsutils` | >= 0.16.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `awsutils` | >= 0.16.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`assume_role` | latest | [`../account-map/modules/team-assume-role-policy`](https://registry.terraform.io/modules/../account-map/modules/team-assume-role-policy/) | n/a
`label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`tfstate_backend` | 1.1.0 | [`cloudposse/tfstate-backend/aws`](https://registry.terraform.io/modules/cloudposse/tfstate-backend/aws/1.1.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(iam.tf#72)

## Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.tfstate`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`awsutils_caller_identity.current`](https://registry.terraform.io/providers/cloudposse/awsutils/latest/docs/data-sources/caller_identity) (data source)

## Outputs

<dl>
  <dt><code>tfstate_backend_access_role_arns</code></dt>
  <dd>
    IAM Role ARNs for accessing the Terraform State Backend<br/>

  </dd>
  <dt><code>tfstate_backend_dynamodb_table_arn</code></dt>
  <dd>
    Terraform state DynamoDB table ARN<br/>

  </dd>
  <dt><code>tfstate_backend_dynamodb_table_id</code></dt>
  <dd>
    Terraform state DynamoDB table ID<br/>

  </dd>
  <dt><code>tfstate_backend_dynamodb_table_name</code></dt>
  <dd>
    Terraform state DynamoDB table name<br/>

  </dd>
  <dt><code>tfstate_backend_s3_bucket_arn</code></dt>
  <dd>
    Terraform state S3 bucket ARN<br/>

  </dd>
  <dt><code>tfstate_backend_s3_bucket_domain_name</code></dt>
  <dd>
    Terraform state S3 bucket domain name<br/>

  </dd>
  <dt><code>tfstate_backend_s3_bucket_id</code></dt>
  <dd>
    Terraform state S3 bucket ID<br/>

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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `access_roles` <i>optional</i>


Map of access roles to create (key is role name, use "default" for same as component). See iam-assume-role-policy module for details.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    write_enabled           = bool
    allowed_roles           = map(list(string))
    denied_roles            = map(list(string))
    allowed_principal_arns  = list(string)
    denied_principal_arns   = list(string)
    allowed_permission_sets = map(list(string))
    denied_permission_sets  = map(list(string))
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `access_roles_enabled` (`bool`) <i>optional</i>


Enable creation of access roles. Set false for cold start (before account-map has been created).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `enable_point_in_time_recovery` (`bool`) <i>optional</i>


Enable DynamoDB point-in-time recovery<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `enable_server_side_encryption` (`bool`) <i>optional</i>


Enable DynamoDB and S3 server-side encryption<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `force_destroy` (`bool`) <i>optional</i>


A boolean that indicates the terraform state S3 bucket can be destroyed even if it contains objects. These objects are not recoverable.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `prevent_unencrypted_uploads` (`bool`) <i>optional</i>


Prevent uploads of unencrypted objects to S3<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/tfstate-backend) -
  Cloud Posse's upstream component
