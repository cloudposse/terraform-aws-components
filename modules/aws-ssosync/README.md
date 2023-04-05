# Component: `aws-ssosync`

Deploys [AWS ssosync](https://github.com/awslabs/ssosync) to sync Google Groups with AWS SSO.

AWS `ssosync` is a Lambda application that regularly manages Identity Store users.

## Usage

We recommend following a similar process to what the [AWS ssosync](https://github.com/awslabs/ssosync)
documentation recommends.

### Clickops

Overview of steps:
1. Deploy the `aws-sso` component
1. Configure GSuite
1. Deploy the `aws-ssosync` component to the `gbl-identity` stack

#### Deploy the `aws-sso` component

Follow the [aws-sso](../aws-sso/) component documentation to deploy the `aws-sso` component.
Once this is done, you'll want to grab a few pieces of information.

Go to the AWS Single Sign-On console in the region you have set up AWS SSO and
select `Settings`. Click `Enable automatic provisioning`.

A pop up will appear with URL and the Access Token. The Access Token will only
appear at this stage. You want to copy both of these as a parameter to the ssosync command.

To pass parameters to the `ssosync` command, you'll need to decide on a path
in SSM Parameter Store, `google_credentials_ssm_path`.

In SSM Parameter Store on your `identity` account, create a parameter with the
name `<google_credentials_ssm_path>/scim_endpoint_url` and the value of the
URL from the previous step. Also create a parameter with the name
`<google_credentials_ssm_path>/scim_endpoint_access_token` and the value of the
Access Token from the previous step.

One more parameter you'll need is your Identity Store ID.
To obtain your Identity store ID, go to the AWS Identity Center console and
select `Settings`. Under the `Identity Source` section, copy the Identity Store ID.
Back in the `identity` account, create a parameter with the name
`<google_credentials_ssm_path>/identity_store_id`.

Lastly, go ahead and [Delegate administration](https://docs.aws.amazon.com/singlesignon/latest/userguide/delegated-admin.html)
from the `root` account to the `identity` account

#### Configure GSuite

_steps taken directly from [ssosync README.md](https://github.com/awslabs/ssosync/blob/master/README.md#google)_

First, you have to setup your API. In the project you want to use go to the 
[Console](https://console.developers.google.com/apis) and select *API & Service * >
*Enable APIs and Services*. Search for *Admin SDK* and *Enable* the API.

You have to perform this
[tutorial](https://developers.google.com/admin-sdk/directory/v1/guides/delegation)
to create a service account that you use to sync your users. Save
the `JSON file` you create during the process and rename it to `google_credentials.json`.

Head back in to your `identity` account in AWS and create a parameter in SSM
Parameter Store with the name `<google_credentials_ssm_path>/google_credentials` and
give it the contents of the `google_credentials.json` file.

In the domain-wide delegation for the Admin API, you have to specify the
following scopes for the user.

* https://www.googleapis.com/auth/admin.directory.group.readonly
* https://www.googleapis.com/auth/admin.directory.group.member.readonly
* https://www.googleapis.com/auth/admin.directory.user.readonly

Back in the Console go to the Dashboard for the API & Services and select 
`Enable API and Services`.
In the Search box type `Admin` and select the `Admin SDK` option. Click the 
`Enable` button.

#### Deploy the `aws-ssosync` component

Make sure that all four of the following SSM parameters exist in the `identity` account:
* `<google_credentials_ssm_path>/scim_endpoint_url`
* `<google_credentials_ssm_path>/scim_endpoint_access_token`
* `<google_credentials_ssm_path>/identity_store_id`
* `<google_credentials_ssm_path>/google_credentials`

You should be able to deploy the `aws-ssosync` component to the `gbl-identity` stack
with `atmos terraform deploy aws-ssosync -s gbl-identity`.

### Atmos

**Stack Level**: Global
**Deployment**: Must be deployed by root-admin using `atmos` CLI

Add catalog to `gbl-identity` root stack.


#### Example
The example snippet below shows how to use this module with various combinations (plain YAML, YAML Anchors and a combination of the two):

```yaml
components:
  terraform:
    aws-ssosync:
      vars:
        google_credentials_ssm_path: /ssosync
        google_admin_email: admin+ssosync@acme.com
        
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_ssosync_artifact"></a> [ssosync\_artifact](#module\_ssosync\_artifact) | cloudposse/module-artifact/external | 0.7.2 |
| <a name="module_tfstate"></a> [tfstate](#module\_tfstate) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.ssosync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.ssosync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_lambda_function.ssosync](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_iam_policy_document.ssosync_lambda_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssosync_lambda_identity_center](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.google_credentials](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.identity_store_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.scim_endpoint_access_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.scim_endpoint_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | Architecture of the Lambda function | `string` | `"x86_64"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_google_admin_email"></a> [google\_admin\_email](#input\_google\_admin\_email) | Google Admin email | `string` | n/a | yes |
| <a name="input_google_credentials_ssm_path"></a> [google\_credentials\_ssm\_path](#input\_google\_credentials\_ssm\_path) | SSM Path for `ssosync` secrets | `string` | n/a | yes |
| <a name="input_google_group_match"></a> [google\_group\_match](#input\_google\_group\_match) | Google Workspace group filter query parameter, example: 'name:Admin* email:aws-*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-groups | `string` | `""` | no |
| <a name="input_google_user_match"></a> [google\_user\_match](#input\_google\_user\_match) | Google Workspace user filter query parameter, example: 'name:John* email:admin*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-users | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_ignore_groups"></a> [ignore\_groups](#input\_ignore\_groups) | Ignore these Google Workspace groups | `string` | `""` | no |
| <a name="input_ignore_users"></a> [ignore\_users](#input\_ignore\_users) | Ignore these Google Workspace users | `string` | `""` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_include_groups"></a> [include\_groups](#input\_include\_groups) | Include only these Google Workspace groups. (Only applicable for sync\_method user\_groups) | `string` | `""` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_log_format"></a> [log\_format](#input\_log\_format) | Log format for Lambda function logging | `string` | `"json"` | no |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Log level for Lambda function logging | `string` | `"warn"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where AWS SSO is enabled | `string` | n/a | yes |
| <a name="input_schedule_expression"></a> [schedule\_expression](#input\_schedule\_expression) | Schedule for trigger the execution of ssosync (see CloudWatch schedule expressions) | `string` | `"rate(15 minutes)"` | no |
| <a name="input_ssosync_url_prefix"></a> [ssosync\_url\_prefix](#input\_ssosync\_url\_prefix) | URL prefix for ssosync binary | `string` | `"https://github.com/awslabs/ssosync/releases/download"` | no |
| <a name="input_ssosync_version"></a> [ssosync\_version](#input\_ssosync\_version) | Version of ssosync to use | `string` | `"v2.0.2"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_sync_method"></a> [sync\_method](#input\_sync\_method) | Sync method to use | `string` | `"groups"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-aws-sso][39]

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>][40]

[1]:	https://docs.aws.amazon.com/singlesignon/latest/userguide/permissionsetsconcept.html
[2]:	#requirement%5C_terraform
[3]:	#requirement%5C_aws
[4]:	#requirement%5C_external
[5]:	#requirement%5C_local
[6]:	#requirement%5C_template
[7]:	#requirement%5C_utils
[8]:	#provider%5C_aws
[9]:	#module%5C_account%5C_map
[10]:	#module%5C_permission%5C_sets
[11]:	#module%5C_role%5C_prefix
[12]:	#module%5C_sso%5C_account%5C_assignments
[13]:	#module%5C_this
[14]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[15]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[16]:	https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document
[17]:	#input%5C_account%5C_assignments
[18]:	#input%5C_additional%5C_tag%5C_map
[19]:	#input%5C_attributes
[20]:	#input%5C_context
[21]:	#input%5C_delimiter
[22]:	#input%5C_enabled
[23]:	#input%5C_environment
[24]:	#input%5C_global%5C_environment%5C_name
[25]:	#input%5C_iam%5C_primary%5C_roles%5C_stage%5C_name
[26]:	#input%5C_id%5C_length%5C_limit
[27]:	#input%5C_identity%5C_roles%5C_accessible
[28]:	#input%5C_label%5C_key%5C_case
[29]:	#input%5C_label%5C_order
[30]:	#input%5C_label%5C_value%5C_case
[31]:	#input%5C_name
[32]:	#input%5C_namespace
[33]:	#input%5C_privileged
[34]:	#input%5C_regex%5C_replace%5C_chars
[35]:	#input%5C_region
[36]:	#input%5C_root%5C_account%5C_stage%5C_name
[37]:	#input%5C_stage
[38]:	#input%5C_tags
[39]:	https://github.com/cloudposse/terraform-aws-sso
[40]:	https://cpco.io/component
