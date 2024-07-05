# Component: `aws-ssosync`

Deploys [AWS ssosync](https://github.com/awslabs/ssosync) to sync Google Groups with AWS SSO.

AWS `ssosync` is a Lambda application that regularly manages Identity Store users.

This component requires manual deployment by a privileged user because it deploys a role in the root or identity
management account.

## Usage

You should be able to deploy the `aws-ssosync` component to the same account as `aws-sso`. Typically that is the
`core-gbl-root` or `gbl-root` stack.

**Stack Level**: Global **Deployment**: Must be deployed by `managers` or SuperAdmin using `atmos` CLI

The following is an example snippet for how to use this component:

(`stacks/catalog/aws-ssosync.yaml`)

```yaml
components:
  terraform:
    aws-ssosync:
      vars:
        enabled: true
        name: aws-ssosync
        google_admin_email: an-actual-admin@acme.com
        ssosync_url_prefix: "https://github.com/Benbentwo/ssosync/releases/download"
        ssosync_version: "2.0.2"
        google_credentials_ssm_path: "/ssosync"
        log_format: text
        log_level: debug
        schedule_expression: "rate(15 minutes)"
```

We recommend following a similar process to what the [AWS ssosync](https://github.com/awslabs/ssosync) documentation
recommends.

### Deployment

Overview of steps:

1. Configure AWS IAM Identity Center
1. Configure Google Cloud console
1. Configure Google Admin console
1. Deploy the `aws-ssosync` component
1. Deploy the `aws-sso` component

#### 1. Configure AWS IAM Identity Center (AWS SSO)

Follow
[AWS documentation to configure SAML and SCIM with Google Workspace and IAM Identity Center](https://docs.aws.amazon.com/singlesignon/latest/userguide/gs-gwp.html).

As part of this process, save the SCIM endpoint token and URL. Then in AWS SSM Parameter Store, create two
`SecureString` parameters in the same account used for AWS SSO. This is usually the root account in the primary region.

```
/ssosync/scim_endpoint_access_token
/ssosync/scim_endpoint_url
```

One more parameter you'll need is your Identity Store ID. To obtain your Identity Store ID, go to the AWS Identity
Center console and select `Settings`. Under the `Identity Source` section, copy the Identity Store ID. In the same
account used for AWS SSO, create the following parameter:

```
/ssosync/identity_store_id
```

#### 2. Configure Google Cloud console

Within the Google Cloud console, we need to create a new Google Project and Service Account and enable the Admin SDK
API. Follow these steps:

1. Open the Google Cloud console: https://console.cloud.google.com
2. Create a new project. Give the project a descriptive name such as `AWS SSO Sync`
3. Enable Admin SDK in APIs: `APIs & Services > Enabled APIs & Services > + ENABLE APIS AND SERVICES`

![Enable Admin SDK](https://raw.githubusercontent.com/cloudposse/terraform-aws-components/main/modules/aws-ssosync/docs/img/admin_sdk.png) #
use raw URL so that this works in both GitHub and docusaurus

4. Create Service Account: `IAM & Admin > Service Accounts > Create Service Account`
   [(ref)](https://cloud.google.com/iam/docs/service-accounts-create).

![Create Service Account](https://raw.githubusercontent.com/cloudposse/terraform-aws-components/main/modules/aws-ssosync/docs/img/create_service_account.png) #
use raw URL so that this works in both GitHub and docusaurus

5. Download credentials for the new Service Account:
   `IAM & Admin > Service Accounts > select Service Account > Keys > ADD KEY > Create new key > JSON`

![Download Credentials](https://raw.githubusercontent.com/cloudposse/terraform-aws-components/main/modules/aws-ssosync/docs/img/dl_service_account_creds.png) #
use raw URL so that this works in both GitHub and docusaurus

6. Save the JSON credentials as a new `SecureString` AWS SSM parameter in the same account used for AWS SSO. Use the
   full JSON string as the value for the parameter.

```
/ssosync/google_credentials
```

#### 3. Configure Google Admin console

- Open the Google Admin console
- From your domain’s Admin console, go to `Main menu menu > Security > Access and data control > API controls`
  [(ref)](https://developers.google.com/cloud-search/docs/guides/delegation)
- In the Domain wide delegation pane, select `Manage Domain Wide Delegation`.
- Click `Add new`.
- In the Client ID field, enter the client ID obtained from the service account creation steps above.
- In the OAuth Scopes field, enter a comma-delimited list of the scopes required for your application. Use the scope
  `https://www.googleapis.com/auth/cloud_search.query` for search applications using the Query API.
- Add the following permission: [(ref)](https://github.com/awslabs/ssosync?tab=readme-ov-file#google)

```console
https://www.googleapis.com/auth/admin.directory.group.readonly
https://www.googleapis.com/auth/admin.directory.group.member.readonly
https://www.googleapis.com/auth/admin.directory.user.readonly
```

#### 4. Deploy the `aws-ssosync` component

Make sure that all four of the following SSM parameters exist in the target account and region:

- `/ssosync/scim_endpoint_url`
- `/ssosync/scim_endpoint_access_token`
- `/ssosync/identity_store_id`
- `/ssosync/google_credentials`

If deployed successfully, Groups and Users should be programmatically copied from the Google Workspace into AWS IAM
Identity Center on the given schedule.

If these Groups are not showing up, check the CloudWatch logs for the new Lambda function and refer the [FAQs](#FAQ)
included below.

#### 5. Deploy the `aws-sso` component

Use the names of the Groups now provisioned programmatically in the `aws-sso` component catalog. Follow the
[aws-sso](../aws-sso/) component documentation to deploy the `aws-sso` component.

### FAQ

#### Why is the tool forked by `Benbentwo`?

The `awslabs` tool requires AWS Secrets Managers for the Google Credentials. However, we would prefer to use AWS SSM to
store all credentials consistency and not require AWS Secrets Manager. Therefore we've created a Pull Request and will
point to a fork until the PR is merged.

Ref:

- https://github.com/awslabs/ssosync/pull/133
- https://github.com/awslabs/ssosync/issues/93

#### What should I use for the Google Admin Email Address?

The Service Account created will assume the User given by `--google-admin` / `SSOSYNC_GOOGLE_ADMIN` /
`var.google_admin_email`. Therefore, this user email must be a valid Google admin user in your organization.

This is not the same email as the Service Account.

If Google fails to query Groups, you may see the following error:

```console
Notifying Lambda and mark this execution as Failure: googleapi: Error 404: Domain not found., notFound
```

#### Common Group Name Query Error

If filtering group names using query strings, make sure the provided string is valid. For example,
`google_group_match: "name:aws*"` is incorrect. Instead use `google_group_match: "Name:aws*"`

If not, you may again see the same error message:

```console
Notifying Lambda and mark this execution as Failure: googleapi: Error 404: Domain not found., notFound
```

Ref:

> The specific error you are seeing is because the google api doesn't like the query string you provided for the -g
> parameter. try -g "Name:Fuel\*"

https://github.com/awslabs/ssosync/issues/91

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `archive` | >= 2.3.0 |
| `aws` | >= 4.0 |
| `null` | >= 3.0 |


## Providers

| Provider | Version |
| --- | --- |
| [`archive`](https://registry.terraform.io/providers/archive/latest) | >= 2.3.0 |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | >= 4.0 |
| [`null`](https://registry.terraform.io/providers/null/latest) | >= 3.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`ssosync_artifact` | [![0.8.0](https://img.shields.io/badge/_____0.8.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/module-artifact/external/0.8.0) | [`cloudposse/module-artifact/external`](https://registry.terraform.io/modules/cloudposse/module-artifact/external/0.8.0) | n/a
`this` | [![0.25.0](https://img.shields.io/badge/____0.25.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_cloudwatch_event_rule.ssosync`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) (resource)(main.tf#102)
  - [`aws_cloudwatch_event_target.ssosync`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) (resource)(main.tf#111)
  - [`aws_iam_role.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)(iam.tf#37)
  - [`aws_lambda_function.ssosync`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) (resource)(main.tf#67)
  - [`aws_lambda_permission.allow_cloudwatch_execution`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) (resource)(main.tf#120)
  - [`null_resource.extract_my_tgz`](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) (resource)(main.tf#46)

## Data Sources

The following data sources are used by this module:

  - [`archive_file.lambda`](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) (data source)
  - [`aws_iam_policy_document.ssosync_lambda_assume_role`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.ssosync_lambda_identity_center`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_ssm_parameter.google_credentials`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.identity_store_id`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.scim_endpoint_access_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.scim_endpoint_url`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

## Outputs

<dl>
  <dt><code>arn</code></dt>
  <dd>

  
  ARN of the lambda function<br/>

  </dd>
  <dt><code>invoke_arn</code></dt>
  <dd>

  
  Invoke ARN of the lambda function<br/>

  </dd>
  <dt><code>qualified_arn</code></dt>
  <dd>

  
  ARN identifying your Lambda Function Version (if versioning is enabled via publish = true)<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `google_admin_email` (`string`) <i>required</i>


Google Admin email<br/>

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


### `region` (`string`) <i>required</i>


AWS Region where AWS SSO is enabled<br/>

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
### `architecture` (`string`) <i>optional</i>


Architecture of the Lambda function<br/>

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
>   <code>"x86_64"</code>
>   </dd>
> </dl>
>


### `google_credentials_ssm_path` (`string`) <i>optional</i>


SSM Path for `ssosync` secrets<br/>

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
>   <code>"/ssosync"</code>
>   </dd>
> </dl>
>


### `google_group_match` (`string`) <i>optional</i>


Google Workspace group filter query parameter, example: 'name:Admin* email:aws-*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-groups<br/>

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
>   <code>""</code>
>   </dd>
> </dl>
>


### `google_user_match` (`string`) <i>optional</i>


Google Workspace user filter query parameter, example: 'name:John* email:admin*', see: https://developers.google.com/admin-sdk/directory/v1/guides/search-users<br/>

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
>   <code>""</code>
>   </dd>
> </dl>
>


### `ignore_groups` (`string`) <i>optional</i>


Ignore these Google Workspace groups<br/>

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
>   <code>""</code>
>   </dd>
> </dl>
>


### `ignore_users` (`string`) <i>optional</i>


Ignore these Google Workspace users<br/>

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
>   <code>""</code>
>   </dd>
> </dl>
>


### `include_groups` (`string`) <i>optional</i>


Include only these Google Workspace groups. (Only applicable for sync_method user_groups)<br/>

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
>   <code>""</code>
>   </dd>
> </dl>
>


### `log_format` (`string`) <i>optional</i>


Log format for Lambda function logging<br/>

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
>   <code>"json"</code>
>   </dd>
> </dl>
>


### `log_level` (`string`) <i>optional</i>


Log level for Lambda function logging<br/>

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
>   <code>"warn"</code>
>   </dd>
> </dl>
>


### `schedule_expression` (`string`) <i>optional</i>


Schedule for trigger the execution of ssosync (see CloudWatch schedule expressions)<br/>

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
>   <code>"rate(15 minutes)"</code>
>   </dd>
> </dl>
>


### `ssosync_url_prefix` (`string`) <i>optional</i>


URL prefix for ssosync binary<br/>

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
>   <code>"https://github.com/Benbentwo/ssosync/releases/download"</code>
>   </dd>
> </dl>
>


### `ssosync_version` (`string`) <i>optional</i>


Version of ssosync to use<br/>

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
>   <code>"v2.0.2"</code>
>   </dd>
> </dl>
>


### `sync_method` (`string`) <i>optional</i>


Sync method to use<br/>

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
>   <code>"groups"</code>
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

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/aws-ssosync) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
