# Component: `aws-backup`

This component is responsible for provisioning an AWS Backup Plan. It creates a schedule for backing up given ARNs.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    aws-backup:
      vars:
        # https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html
        schedule: cron(0 0 * * ? *)             # Daily At 12:00 AM UTC
        start_window: 60                        # Minutes
        completion_window: 240                  # Minutes
        cold_storage_after: null                # Days
        delete_after: 14                        # Days
        destination_vault_arn: null             # Copy to another Region's Vault
        copy_action_cold_storage_after: null    # Copy to another Region's Vault Cold Storage Config (Days)
        copy_action_delete_after: null          # Copy to another Region's Vault Persistence Config (Days)
        backup_resources: []
        selection_tags:
          - type: "STRINGEQUALS"
            key: "aws-backup/resource_schedule"
            value: "daily-14day-backup"
```

Since most of these values are shared and common, we can put them in a `catalog/aws-backup/` yaml file and share them across environments.

This makes deploying the same configuration to multiple environments easy.

Deploying to a new stack (environment) then only requires:
```yaml
import:
  - catalog/aws-backup/aws-backup-nonprod

components:
  terraform:
    aws-backup: {}
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_backup"></a> [backup](#module\_backup) | cloudposse/backup/aws | 0.8.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_backup_resources"></a> [backup\_resources](#input\_backup\_resources) | An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan | `list(string)` | `[]` | no |
| <a name="input_cold_storage_after"></a> [cold\_storage\_after](#input\_cold\_storage\_after) | Specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_completion_window"></a> [completion\_window](#input\_completion\_window) | The amount of time AWS Backup attempts a backup before canceling the job and returning an error. Must be at least 60 minutes greater than `start_window` | `number` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_copy_action_cold_storage_after"></a> [copy\_action\_cold\_storage\_after](#input\_copy\_action\_cold\_storage\_after) | For copy operation, specifies the number of days after creation that a recovery point is moved to cold storage | `number` | `null` | no |
| <a name="input_copy_action_delete_after"></a> [copy\_action\_delete\_after](#input\_copy\_action\_delete\_after) | For copy operation, specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `copy_action_cold_storage_after` | `number` | `null` | no |
| <a name="input_delete_after"></a> [delete\_after](#input\_delete\_after) | Specifies the number of days after creation that a recovery point is deleted. Must be 90 days greater than `cold_storage_after` | `number` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_destination_vault_arn"></a> [destination\_vault\_arn](#input\_destination\_vault\_arn) | An Amazon Resource Name (ARN) that uniquely identifies the destination backup vault for the copied backup | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_iam_role_enabled"></a> [iam\_role\_enabled](#input\_iam\_role\_enabled) | Whether or not to create a new IAM Role and Policy Attachment | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The server-side encryption key that is used to protect your backups | `string` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | The letter case of output label values (also used in `tags` and `id`).<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_plan_enabled"></a> [plan\_enabled](#input\_plan\_enabled) | Whether or not to create a new Plan | `bool` | `true` | no |
| <a name="input_plan_name_suffix"></a> [plan\_name\_suffix](#input\_plan\_name\_suffix) | The string appended to the plan name | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_schedule"></a> [schedule](#input\_schedule) | A CRON expression specifying when AWS Backup initiates a backup job | `string` | `null` | no |
| <a name="input_selection_tags"></a> [selection\_tags](#input\_selection\_tags) | An array of tag condition objects used to filter resources based on tags for assigning to a backup plan | `list(map(string))` | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_start_window"></a> [start\_window](#input\_start\_window) | The amount of time in minutes before beginning a backup. Minimum value is 60 minutes | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| <a name="input_target_iam_role_name"></a> [target\_iam\_role\_name](#input\_target\_iam\_role\_name) | Override target IAM Name | `string` | `null` | no |
| <a name="input_target_vault_name"></a> [target\_vault\_name](#input\_target\_vault\_name) | Override target Vault Name | `string` | `null` | no |
| <a name="input_vault_enabled"></a> [vault\_enabled](#input\_vault\_enabled) | Whether or not a new Vault should be created | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backup_plan_arn"></a> [backup\_plan\_arn](#output\_backup\_plan\_arn) | Backup Plan ARN |
| <a name="output_backup_plan_version"></a> [backup\_plan\_version](#output\_backup\_plan\_version) | Unique, randomly generated, Unicode, UTF-8 encoded string that serves as the version ID of the backup plan |
| <a name="output_backup_selection_id"></a> [backup\_selection\_id](#output\_backup\_selection\_id) | Backup Selection ID |
| <a name="output_backup_vault_arn"></a> [backup\_vault\_arn](#output\_backup\_vault\_arn) | Backup Vault ARN |
| <a name="output_backup_vault_id"></a> [backup\_vault\_id](#output\_backup\_vault\_id) | Backup Vault ID |
| <a name="output_backup_vault_recovery_points"></a> [backup\_vault\_recovery\_points](#output\_backup\_vault\_recovery\_points) | Backup Vault recovery points |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/aws-backup) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
