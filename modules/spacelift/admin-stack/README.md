# Component: `spacelift/admin-stack`

This component is responsible for creating an administrative [stack](https://docs.spacelift.io/concepts/stack/) and its
corresponding child stacks in the Spacelift organization.

The component uses a series of `context_filters` to select atmos component instances to manage as child stacks.

## Usage

**Stack Level**: Global

The following are example snippets of how to use this component. For more on Spacelift admin stack usage, see the
[Spacelift README](https://docs.cloudposse.com/components/library/aws/spacelift/)

First define the default configuration for any admin stack:

```yaml
# stacks/catalog/spacelift/admin-stack.yaml
components:
  terraform:
    admin-stack/default:
      metadata:
        type: abstract
        component: spacelift/admin-stack
      settings:
        spacelift:
          administrative: true
          autodeploy: true
          before_apply:
            - spacelift-configure-paths
          before_init:
            - spacelift-configure-paths
            - spacelift-write-vars
            - spacelift-tf-workspace
          before_plan:
            - spacelift-configure-paths
          drift_detection_enabled: true
          drift_detection_reconcile: true
          drift_detection_schedule:
            - 0 4 * * *
          manage_state: false
          policies: {}
      vars:
        # Organization specific configuration
        branch: main
        repository: infrastructure
        worker_pool_name: "acme-core-ue1-auto-spacelift-worker-pool"
        runner_image: 111111111111.dkr.ecr.us-east-1.amazonaws.com/infrastructure:latest
        spacelift_spaces_stage_name: "root"
        # These values need to be manually updated as external configuration changes
        # This should match the version set in the Dockerfile and be updated when the version changes.
        terraform_version: "1.3.6"
        # Common configuration
        administrative: true # Whether this stack can manage other stacks
        component_root: components/terraform
```

Then define the root-admin stack:

```yaml
# stacks/orgs/acme/spacelift.yaml
import:
  - mixins/region/global-region
  - orgs/acme/_defaults
  - catalog/terraform/spacelift/admin-stack
  - catalog/terraform/spacelift/spaces

# These intentionally overwrite the default values
vars:
  tenant: root
  environment: gbl
  stage: spacelift

components:
  terraform:
    # This admin stack creates other "admin" stacks
    admin-stack:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - admin-stack/default
      settings:
        spacelift:
          root_administrative: true
          labels:
            - root-admin
            - admin
      vars:
        enabled: true
        root_admin_stack: true # This stack will be created in the root space and will create all the other admin stacks as children.
        context_filters: # context_filters determine which child stacks to manage with this admin stack
          administrative: true # This stack is managing all the other admin stacks
          root_administrative: false # We don't want this stack to also find itself in the config and add itself a second time
        labels:
          - admin
        # attachments only on the root stack
        root_stack_policy_attachments:
          - TRIGGER Global administrator
        # this creates policies for the children (admin) stacks
        child_policy_attachments:
          - TRIGGER Global administrator
```

Finally, define any tenant-specific stacks:

```yaml
# stacks/orgs/acme/core/spacelift.yaml
import:
  - mixins/region/global-region
  - orgs/acme/core/_defaults
  - catalog/terraform/spacelift/admin-stack

vars:
  tenant: core
  environment: gbl
  stage: spacelift

components:
  terraform:
    admin-stack:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - admin-stack/default
      settings:
        spacelift:
          labels: # Additional labels for this stack
            - admin-stack-name:core
      vars:
        enabled: true
        context_filters:
          tenants: ["core"]
        labels: # Additional labels added to all children
          - admin-stack-name:core # will be used to automatically create the `managed-by:stack-name` label
        child_policy_attachments:
          - TRIGGER Dependencies
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3), version: >= 1.3
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`null`](https://registry.terraform.io/modules/null/>= 3.0), version: >= 3.0
- [`spacelift`](https://registry.terraform.io/modules/spacelift/>= 0.1.31), version: >= 0.1.31
- [`utils`](https://registry.terraform.io/modules/utils/>= 1.14.0), version: >= 1.14.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `null`, version: >= 3.0
- `spacelift`, version: >= 0.1.31

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`all_admin_stacks_config` | 1.5.0 | [`cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config`](https://registry.terraform.io/modules/cloudposse/cloud-infrastructure-automation/spacelift/modules/spacelift-stacks-from-atmos-config/1.5.0) | This gets the atmos stack config for all of the administrative stacks
`child_stack` | 1.6.0 | [`cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stack`](https://registry.terraform.io/modules/cloudposse/cloud-infrastructure-automation/spacelift/modules/spacelift-stack/1.6.0) | n/a
`child_stacks_config` | 1.5.0 | [`cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config`](https://registry.terraform.io/modules/cloudposse/cloud-infrastructure-automation/spacelift/modules/spacelift-stacks-from-atmos-config/1.5.0) | Get all of the stack configurations from the atmos config that matched the context_filters and create a stack for each one.
`root_admin_stack` | 1.6.0 | [`cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stack`](https://registry.terraform.io/modules/cloudposse/cloud-infrastructure-automation/spacelift/modules/spacelift-stack/1.6.0) | n/a
`root_admin_stack_config` | 1.5.0 | [`cloudposse/cloud-infrastructure-automation/spacelift//modules/spacelift-stacks-from-atmos-config`](https://registry.terraform.io/modules/cloudposse/cloud-infrastructure-automation/spacelift/modules/spacelift-stacks-from-atmos-config/1.5.0) | The root admin stack is a special stack that is used to manage all of the other admin stacks in the the Spacelift organization. This stack is denoted by setting the root_administrative property to true in the atmos config. Only one such stack is allowed in the Spacelift organization.
`spaces` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`null_resource.child_stack_parent_precondition`](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
  - [`null_resource.public_workers_precondition`](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
  - [`null_resource.spaces_precondition`](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
  - [`null_resource.workers_precondition`](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)
  - [`spacelift_policy_attachment.root`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/resources/policy_attachment) (resource)

### Data Sources

The following data sources are used by this module:

  - [`spacelift_policies.this`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/data-sources/policies) (data source)
  - [`spacelift_stacks.this`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/data-sources/stacks) (data source)
  - [`spacelift_worker_pools.this`](https://registry.terraform.io/providers/spacelift-io/spacelift/latest/docs/data-sources/worker_pools) (data source)

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
  <dt>`component_root` (`string`) <i>required</i></dt>
  <dd>
    The path, relative to the root of the repository, where the component can be found<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`context_filters` <i>required</i></dt>
  <dd>
    Context filters to select atmos stacks matching specific criteria to create as children.<br/>

    **Type:** 

    ```hcl
    object({
    namespaces          = optional(list(string), [])
    environments        = optional(list(string), [])
    tenants             = optional(list(string), [])
    stages              = optional(list(string), [])
    tags                = optional(map(string), {})
    administrative      = optional(bool)
    root_administrative = optional(bool)
  })
    ```
    
    <br/>
    **Default value:** ``

  </dd>
  <dt>`repository` (`string`) <i>required</i></dt>
  <dd>
    The name of your infrastructure repo<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`admin_stack_label` (`string`) <i>optional</i></dt>
  <dd>
    Label to use to identify the admin stack when creating the child stacks<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"admin-stack-name"`
  </dd>
  <dt>`allow_public_workers` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to allow public workers to be used for this stack<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`autodeploy` (`bool`) <i>optional</i></dt>
  <dd>
    Controls the Spacelift 'autodeploy' option for a stack<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`autoretry` (`bool`) <i>optional</i></dt>
  <dd>
    Controls the Spacelift 'autoretry' option for a stack<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`aws_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    ARN of the AWS IAM role to assume and put its temporary credentials in the runtime environment<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`aws_role_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable Spacelift to use AWS STS to assume the supplied IAM role and put its temporary credentials in the runtime environment<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`aws_role_external_id` (`string`) <i>optional</i></dt>
  <dd>
    Custom external ID (works only for private workers). See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html for more details<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`aws_role_generate_credentials_in_worker` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable generating AWS credentials in the private worker after assuming the supplied IAM role<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`azure_devops` (`map(any)`) <i>optional</i></dt>
  <dd>
    Azure DevOps VCS settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`bitbucket_cloud` (`map(any)`) <i>optional</i></dt>
  <dd>
    Bitbucket Cloud VCS settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`bitbucket_datacenter` (`map(any)`) <i>optional</i></dt>
  <dd>
    Bitbucket Datacenter VCS settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`branch` (`string`) <i>optional</i></dt>
  <dd>
    Specify which branch to use within your infrastructure repo<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"main"`
  </dd>
  <dt>`child_policy_attachments` (`set(string)`) <i>optional</i></dt>
  <dd>
    List of policy attachments to attach to the child stacks created by this module<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`cloudformation` (`map(any)`) <i>optional</i></dt>
  <dd>
    CloudFormation-specific configuration. Presence means this Stack is a CloudFormation Stack.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`commit_sha` (`string`) <i>optional</i></dt>
  <dd>
    The commit SHA for which to trigger a run. Requires `var.spacelift_run_enabled` to be set to `true`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`component_env` (`any`) <i>optional</i></dt>
  <dd>
    Map of component ENV variables<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`component_vars` (`any`) <i>optional</i></dt>
  <dd>
    All Terraform values to be applied to the stack via a mounted file<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`context_attachments` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of context IDs to attach to this stack<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`description` (`string`) <i>optional</i></dt>
  <dd>
    Specify description of stack<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`drift_detection_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable drift detection on the infrastructure stacks<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`drift_detection_reconcile` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable infrastructure stacks drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`drift_detection_schedule` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of cron expressions to schedule drift detection for the infrastructure stacks<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "0 4 * * *"
    ]
    ```
    
  </dd>
  <dt>`drift_detection_timezone` (`string`) <i>optional</i></dt>
  <dd>
    Timezone in which the schedule is expressed. Defaults to UTC.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`excluded_context_filters` <i>optional</i></dt>
  <dd>
    Context filters to exclude from stacks matching specific criteria of `var.context_filters`.<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    namespaces   = optional(list(string), [])
    environments = optional(list(string), [])
    tenants      = optional(list(string), [])
    stages       = optional(list(string), [])
    tags         = optional(map(string), {})
  })
    ```
    
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`github_enterprise` (`map(any)`) <i>optional</i></dt>
  <dd>
    GitHub Enterprise (self-hosted) VCS settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`gitlab` (`map(any)`) <i>optional</i></dt>
  <dd>
    GitLab VCS settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`labels` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of labels for the stack<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`local_preview_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Indicates whether local preview runs can be triggered on this Stack<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`manage_state` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable manage_state setting in stack<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`protect_from_deletion` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable deletion protection.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`pulumi` (`map(any)`) <i>optional</i></dt>
  <dd>
    Pulumi-specific configuration. Presence means this Stack is a Pulumi Stack.<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`root_admin_stack` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to indicate if this stack is the root admin stack. In this case, the stack will be created in the root space and will create all the other admin stacks as children.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`root_stack_policy_attachments` (`set(string)`) <i>optional</i></dt>
  <dd>
    List of policy attachments to attach to the root admin stack<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`runner_image` (`string`) <i>optional</i></dt>
  <dd>
    The full image name and tag of the Docker image to use in Spacelift<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`showcase` (`map(any)`) <i>optional</i></dt>
  <dd>
    Showcase settings<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`space_id` (`string`) <i>optional</i></dt>
  <dd>
    Place the stack in the specified space_id<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`spacelift_run_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable/disable creation of the `spacelift_run` resource<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`spacelift_spaces_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The component name of the spacelift spaces component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"spacelift/spaces"`
  </dd>
  <dt>`spacelift_spaces_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The environment name of the spacelift spaces component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`spacelift_spaces_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The stage name of the spacelift spaces component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`spacelift_spaces_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The tenant name of the spacelift spaces component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`spacelift_stack_dependency_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If enabled, the `spacelift_stack_dependency` Spacelift resource will be used to create dependencies between stacks instead of using the `depends-on` labels. The `depends-on` labels will be removed from the stacks and the trigger policies for dependencies will be detached<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`stack_destructor_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable the stack destructor to destroy the resources of the stack before deleting the stack itself<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`stack_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the Spacelift stack<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`terraform_smart_sanitization` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to enable [Smart Sanitization](https://docs.spacelift.io/vendors/terraform/resource-sanitization) which will only sanitize values marked as sensitive.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`terraform_version` (`string`) <i>optional</i></dt>
  <dd>
    Specify the version of Terraform to use for the stack<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`terraform_version_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    A map to determine which Terraform patch version to use for each minor version<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`terraform_workflow_tool` (`string`) <i>optional</i></dt>
  <dd>
    Defines the tool that will be used to execute the workflow. This can be one of OPEN_TOFU, TERRAFORM_FOSS or CUSTOM. Defaults to TERRAFORM_FOSS.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"TERRAFORM_FOSS"`
  </dd>
  <dt>`terraform_workspace` (`string`) <i>optional</i></dt>
  <dd>
    Specify the Terraform workspace to use for the stack<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`webhook_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable the webhook endpoint to which Spacelift sends the POST requests about run state changes<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`webhook_endpoint` (`string`) <i>optional</i></dt>
  <dd>
    Webhook endpoint to which Spacelift sends the POST requests about run state changes<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`webhook_secret` (`string`) <i>optional</i></dt>
  <dd>
    Webhook secret used to sign each POST request so you're able to verify that the requests come from Spacelift<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`worker_pool_name` (`string`) <i>optional</i></dt>
  <dd>
    The atmos stack name of the worker pool. Example: `acme-core-ue2-auto-spacelift-default-worker-pool`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd></dl>


### Outputs

<dl>
  <dt>`child_stacks`</dt>
  <dd>
    All children stacks managed by this component<br/>
  </dd>
  <dt>`root_stack`</dt>
  <dd>
    The root stack, if enabled and created by this component<br/>
  </dd>
  <dt>`root_stack_id`</dt>
  <dd>
    The stack id<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->
