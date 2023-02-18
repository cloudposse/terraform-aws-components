# Component: `aws-backup`

This component is responsible for provisioning an AWS Backup Plan. It creates a schedule for backing up given ARNs.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

### Component Abstraction and Separation

By separating the "common" settings from the component, we can first provision the IAM Role and AWS Backup Vault to prepare resources for future use without incuring cost.

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
```

Then if we would like to deploy the component into a given stacks we can import the following to deploy our backup plans.

Since most of these values are shared and common, we can put them in a `catalog/aws-backup/` yaml file and share them across environments.

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
        # in minutes
        start_window: 60
        completion_window: 240
        # in days
        cold_storage_after: null
        delete_after: 30 # 1 month
        copy_action_cold_storage_after: null
        copy_action_delete_after: null

    aws-backup/daily-plan:
      metadata:
        component: aws-backup
        inherits:
          - aws-backup/plan-defaults
      vars:
        plan_name_suffix: aws-backup-daily
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        schedule: cron(0 0 ? * * *) # Daily at midnight (UTC)
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
        schedule: cron(0 0 ? * 1 *) # Weekly on first day of week at midnight (UTC)
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
        # delete monthly snapshots after 60 days
        delete_after: 60
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        schedule: cron(0 0 1 * ? *) # Monthly on 1st day of the month (doesn't matter which) at midnight UTC
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

Once an `aws-backup` with a plan and `selection_tags` has been established we can begin adding resources for it to backup by using the tagging method.

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
If we want to create a backup vault in another region that we can copy to, then we need to create another vault, and then specify that we want to copy to it.

To create a vault in a region simply:
```yaml
components:
  terraform:
    aws-backup:
      vars:
        plan_enabled: false # disables the plan (which schedules resource backups)
```

This will output an arn - which you can then use as the copy destination, as seen in the following snippet:
```yaml
components:
  terraform:
    aws-backup:
      vars:
        destination_vault_arn: arn:aws:backup:<other-region>:111111111111:backup-vault:<namespace>-<other-region>-<stage>
        copy_action_delete_after: 14
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup"></a> [backup](#module\_backup) | cloudposse/backup/aws | 0.14.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_backup_resources"></a> [backup\_resources](#input\_backup\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| <a name="input_cold_storage_after"></a> [cold\_storage\_after](#input\_cold\_storage\_after) | Specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_completion_window"></a> [completion\_window](#input\_completion\_window) | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window` | `number` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_copy_action_cold_storage_after"></a> [copy\_action\_cold\_storage\_after](#input\_copy\_action\_cold\_storage\_after) | For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_copy_action_delete_after"></a> [copy\_action\_delete\_after](#input\_copy\_action\_delete\_after) | For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after` | `number` | `null` | no |
| <a name="input_delete_after"></a> [delete\_after](#input\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `number` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_destination_vault_arn"></a> [destination\_vault\_arn](#input\_destination\_vault\_arn) | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_role_enabled"></a> [iam\_role\_enabled](#input\_iam\_role\_enabled) | Whether or not to create a new IAM Role and Policy Attachment | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_plan_enabled"></a> [plan\_enabled](#input\_plan\_enabled) | Whether or not to create a new Plan | `bool` | `true` | no |
| <a name="input_plan_name_suffix"></a> [plan\_name\_suffix](#input\_plan\_name\_suffix) | The string appended to the plan name | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | An array of tag condition objects used to filter resources based on tags for assigning to a backup plan | `list(map(string))` | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_start_window"></a> [start\_window](#input\_start\_window) | The amount of time in minutes before beginning a backup. Minimum value is 60 minutes | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vault_enabled"></a> [vault\_enabled](#input\_vault\_enabled) | Whether or not a new Vault should be created | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arn"></a> [backup\_plan\_arn](#output\_backup\_plan\_arn) | Backup Plan ARN |
| <a name="output_backup_plan_version"></a> [backup\_plan\_version](#output\_backup\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan |
| <a name="output_backup_selection_id"></a> [backup\_selection\_id](#output\_backup\_selection\_id) | Backup Selection ID |
| <a name="output_backup_vault_arn"></a> [backup\_vault\_arn](#output\_backup\_vault\_arn) | Backup Vault ARN |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | Backup Vault ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/aws-backup) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
