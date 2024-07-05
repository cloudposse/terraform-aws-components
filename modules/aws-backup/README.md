# Component: `aws-backup`

This component is responsible for provisioning an AWS Backup Plan. It creates a schedule for backing up given ARNs.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

### Component Abstraction and Separation

By separating the "common" settings from the component, we can first provision the IAM Role and AWS Backup Vault to
prepare resources for future use without incuring cost.

For example, `stacks/catalog/aws-backup/common`:

```yaml
# This configuration creates the AWS Backup Vault and IAM Role, and does not incur any cost on its own.
# See: https://aws.amazon.com/backup/pricing/
components:
  terraform:
    aws-backup:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars: {}

    aws-backup/common:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup
      vars:
        enabled: true
        iam_role_enabled: true # this will be reused
        vault_enabled: true # this will be reused
        plan_enabled: false
## Please be careful when enabling backup_vault_lock_configuration,
#        backup_vault_lock_configuration:
##         `changeable_for_days` enables compliance mode and once the lock is set, the retention policy cannot be changed unless through account deletion!
#          changeable_for_days: 36500
#          max_retention_days: 365
#          min_retention_days: 1
```

Then if we would like to deploy the component into a given stacks we can import the following to deploy our backup
plans.

Since most of these values are shared and common, we can put them in a `catalog/aws-backup/` yaml file and share them
across environments.

This makes deploying the same configuration to multiple environments easy.

`stacks/catalog/aws-backup/defaults`:

```yaml
import:
  - catalog/aws-backup/common

components:
  terraform:
    aws-backup/plan-defaults:
      metadata:
        component: aws-backup
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
        depends_on:
          - aws-backup/common
      vars:
        enabled: true
        iam_role_enabled: false # reuse from aws-backup-vault
        vault_enabled: false # reuse from aws-backup-vault
        plan_enabled: true
        plan_name_suffix: aws-backup-defaults

    aws-backup/daily-plan:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup/plan-defaults
      vars:
        plan_name_suffix: aws-backup-daily
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        rules:
          - name: "plan-daily"
            schedule: "cron(0 5 ? * * *)"
            start_window: 320 # 60 * 8             # minutes
            completion_window: 10080 # 60 * 24 * 7 # minutes
            lifecycle:
              delete_after: 35 # 7 * 5               # days
        selection_tags:
          - type: STRINGEQUALS
            key: aws-backup/efs
            value: daily
          - type: STRINGEQUALS
            key: aws-backup/rds
            value: daily

    aws-backup/weekly-plan:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup/plan-defaults
      vars:
        plan_name_suffix: aws-backup-weekly
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        rules:
          - name: "plan-weekly"
            schedule: "cron(0 5 ? * SAT *)"
            start_window: 320 # 60 * 8              # minutes
            completion_window: 10080 # 60 * 24 * 7  # minutes
            lifecycle:
              delete_after: 90 # 30 * 3               # days
        selection_tags:
          - type: STRINGEQUALS
            key: aws-backup/efs
            value: weekly
          - type: STRINGEQUALS
            key: aws-backup/rds
            value: weekly

    aws-backup/monthly-plan:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup/plan-defaults
      vars:
        plan_name_suffix: aws-backup-monthly
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        rules:
          - name: "plan-monthly"
            schedule: "cron(0 5 1 * ? *)"
            start_window: 320 # 60 * 8              # minutes
            completion_window: 10080 # 60 * 24 * 7  # minutes
            lifecycle:
              delete_after: 2555 # 365 * 7            # days
              cold_storage_after: 90 # 30 * 3         # days
        selection_tags:
          - type: STRINGEQUALS
            key: aws-backup/efs
            value: monthly
          - type: STRINGEQUALS
            key: aws-backup/rds
            value: monthly
```

Deploying to a new stack (environment) then only requires:

```yaml
import:
  - catalog/aws-backup/defaults
```

The above configuration can be used to deploy a new backup to a new region.

---

### Adding Resources to the Backup - Adding Tags

Once an `aws-backup` with a plan and `selection_tags` has been established we can begin adding resources for it to
backup by using the tagging method.

This only requires that we add tags to the resources we wish to backup, which can be done with the following snippet:

```yaml
components:
  terraform:
    <my-resource>
      vars:
        tags:
          aws-backup/resource_schedule: "daily-14day-backup"
```

Just ensure the tag key-value pair matches what was added to your backup plan and aws will take care of the rest.

### Copying across regions

If we want to create a backup vault in another region that we can copy to, then we need to create another vault, and
then specify that we want to copy to it.

To create a vault in a region simply:

```yaml
components:
  terraform:
    aws-backup:
      vars:
        plan_enabled: false # disables the plan (which schedules resource backups)
```

This will output an ARN - which you can then use as the destination in the rule object's `copy_action` (it will be
specific to that particular plan), as seen in the following snippet:

```yaml
components:
  terraform:
    aws-backup/plan-with-cross-region-replication:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup/plan-defaults
      vars:
        plan_name_suffix: aws-backup-cross-region
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        rules:
          - name: "plan-cross-region"
            schedule: "cron(0 5 ? * * *)"
            start_window: 320 # 60 * 8             # minutes
            completion_window: 10080 # 60 * 24 * 7 # minutes
            lifecycle:
              delete_after: 35 # 7 * 5               # days
            copy_action:
              destination_vault_arn: "arn:aws:backup:<other-region>:111111111111:backup-vault:<namespace>-<other-region>-<stage>"
              lifecycle:
                delete_after: 35
```

### Backup Lock Configuration

To enable backup lock configuration, you can use the following snippet:

- [AWS Backup Vault Lock](https://docs.aws.amazon.com/aws-backup/latest/devguide/vault-lock.html)

#### Compliance Mode

Vaults locked in compliance mode cannot be deleted once the cooling-off period ("grace time") expires. During grace
time, you can still remove the vault lock and change the lock configuration.

To enable **Compliance Mode**, set `changeable_for_days` to a value greater than 0. Once the lock is set, the retention
policy cannot be changed unless through account deletion!

```yaml
# Please be careful when enabling backup_vault_lock_configuration,
backup_vault_lock_configuration:
  #         `changeable_for_days` enables compliance mode and once the lock is set, the retention policy cannot be changed unless through account deletion!
  changeable_for_days: 36500
  max_retention_days: 365
  min_retention_days: 1
```

#### Governance Mode

Vaults locked in governance mode can have the lock removed by users with sufficient IAM permissions.

To enable **governance mode**

```yaml
backup_vault_lock_configuration:
  max_retention_days: 365
  min_retention_days: 1
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |




## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`backup` | 1.0.0 | [`cloudposse/backup/aws`](https://registry.terraform.io/modules/cloudposse/backup/aws/1.0.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a




## Outputs

<dl>
  <dt><code>backup_plan_arn</code></dt>
  <dd>
  Backup Plan ARN<br/>

  </dd>
  <dt><code>backup_plan_version</code></dt>
  <dd>
  Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan<br/>

  </dd>
  <dt><code>backup_selection_id</code></dt>
  <dd>
  Backup Selection ID<br/>

  </dd>
  <dt><code>backup_vault_arn</code></dt>
  <dd>
  Backup Vault ARN<br/>

  </dd>
  <dt><code>backup_vault_id</code></dt>
  <dd>
  Backup Vault ID<br/>

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
### `advanced_backup_setting` <i>optional</i>


An object that specifies backup options for each resource type.<br/>

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
    backup_options = string
    resource_type  = string
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


### `backup_resources` (`list(string)`) <i>optional</i>


An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan<br/>

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


### `backup_vault_lock_configuration` <i>optional</i>


The backup vault lock configuration, each vault can have one vault lock in place. This will enable Backup Vault Lock on an AWS Backup vault  it prevents the deletion of backup data for the specified retention period. During this time, the backup data remains immutable and cannot be deleted or modified."<br/>
`changeable_for_days` - The number of days before the lock date. If omitted creates a vault lock in `governance` mode, otherwise it will create a vault lock in `compliance` mode.<br/>
<br/>

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
    changeable_for_days = optional(number)
    max_retention_days  = optional(number)
    min_retention_days  = optional(number)
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


### `iam_role_enabled` (`bool`) <i>optional</i>


Whether or not to create a new IAM Role and Policy Attachment<br/>

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


### `kms_key_arn` (`string`) <i>optional</i>


The server-side encryption key that is used to protect your backups<br/>

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


### `plan_enabled` (`bool`) <i>optional</i>


Whether or not to create a new Plan<br/>

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


### `plan_name_suffix` (`string`) <i>optional</i>


The string appended to the plan name<br/>

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


### `rules` <i>optional</i>


An array of rule maps used to define schedules in a backup plan<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    name                     = string
    schedule                 = optional(string)
    enable_continuous_backup = optional(bool)
    start_window             = optional(number)
    completion_window        = optional(number)
    lifecycle = optional(object({
      cold_storage_after                        = optional(number)
      delete_after                              = optional(number)
      opt_in_to_archive_for_supported_resources = optional(bool)
    }))
    copy_action = optional(object({
      destination_vault_arn = optional(string)
      lifecycle = optional(object({
        cold_storage_after                        = optional(number)
        delete_after                              = optional(number)
        opt_in_to_archive_for_supported_resources = optional(bool)
      }))
    }))
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `selection_tags` (`list(map(string))`) <i>optional</i>


An array of tag condition objects used to filter resources based on tags for assigning to a backup plan<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(map(string))</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `vault_enabled` (`bool`) <i>optional</i>


Whether or not a new Vault should be created<br/>

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

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aws-backup) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)

## Related How-to Guides

- [How to Enable Cross-Region Backups in AWS-Backup](https://docs.cloudposse.com/reference-architecture/how-to-guides/tutorials/how-to-enable-cross-region-backups-in-aws-backup)
