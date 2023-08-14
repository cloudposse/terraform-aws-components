# Component: `cognito`

This component is responsible for provisioning and managing AWS Cognito resources.

This component can provision the following resources:

  - [Cognito User Pools](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
  - [Cognito User Pool Clients](https://docs.aws.amazon.com/cognito/latest/developerguide/user-pool-settings-client-apps.html)
  - [Cognito User Pool Domains](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-add-custom-domain.html)
  - [Cognito User Pool Identity Providers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-identity-provider.html)
  - [Cognito User Pool Resource Servers](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-define-resource-servers.html)
  - [Cognito User Pool User Groups](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-user-groups.html)


## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    cognito:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        # The full name of the User Pool will be: <namespace>-<environment>-<stage>-<name>
        name: cognito
        schemas:
          - name: "email"
            attribute_data_type: "String"
            developer_only_attribute: false
            mutable: false
            required: true
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cognito_identity_provider.identity_provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) | resource |
| [aws_cognito_resource_server.resource](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) | resource |
| [aws_cognito_user_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_pool.pool](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.client](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_create_user_config"></a> [admin\_create\_user\_config](#input\_admin\_create\_user\_config) | The configuration for AdminCreateUser requests | `map(any)` | `{}` | no |
| <a name="input_admin_create_user_config_allow_admin_create_user_only"></a> [admin\_create\_user\_config\_allow\_admin\_create\_user\_only](#input\_admin\_create\_user\_config\_allow\_admin\_create\_user\_only) | Set to `true` if only the administrator is allowed to create user profiles. Set to `false` if users can sign themselves up via an app | `bool` | `true` | no |
| <a name="input_admin_create_user_config_email_message"></a> [admin\_create\_user\_config\_email\_message](#input\_admin\_create\_user\_config\_email\_message) | The message template for email messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively | `string` | `"{username}, your temporary password is `{####}`"` | no |
| <a name="input_admin_create_user_config_email_subject"></a> [admin\_create\_user\_config\_email\_subject](#input\_admin\_create\_user\_config\_email\_subject) | The subject line for email messages | `string` | `"Your verification code"` | no |
| <a name="input_admin_create_user_config_sms_message"></a> [admin\_create\_user\_config\_sms\_message](#input\_admin\_create\_user\_config\_sms\_message) | The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively | `string` | `"Your username is {username} and temporary password is `{####}`"` | no |
| <a name="input_alias_attributes"></a> [alias\_attributes](#input\_alias\_attributes) | Attributes supported as an alias for this user pool. Possible values: phone\_number, email, or preferred\_username. Conflicts with `username_attributes` | `list(string)` | `null` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auto_verified_attributes"></a> [auto\_verified\_attributes](#input\_auto\_verified\_attributes) | The attributes to be auto-verified. Possible values: email, phone\_number | `list(string)` | `[]` | no |
| <a name="input_client_access_token_validity"></a> [client\_access\_token\_validity](#input\_client\_access\_token\_validity) | Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used. This value will be overridden if you have entered a value in `token_validity_units`. | `number` | `60` | no |
| <a name="input_client_allowed_oauth_flows"></a> [client\_allowed\_oauth\_flows](#input\_client\_allowed\_oauth\_flows) | List of allowed OAuth flows (code, implicit, client\_credentials) | `list(string)` | `[]` | no |
| <a name="input_client_allowed_oauth_flows_user_pool_client"></a> [client\_allowed\_oauth\_flows\_user\_pool\_client](#input\_client\_allowed\_oauth\_flows\_user\_pool\_client) | Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools | `bool` | `true` | no |
| <a name="input_client_allowed_oauth_scopes"></a> [client\_allowed\_oauth\_scopes](#input\_client\_allowed\_oauth\_scopes) | List of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin) | `list(string)` | `[]` | no |
| <a name="input_client_callback_urls"></a> [client\_callback\_urls](#input\_client\_callback\_urls) | List of allowed callback URLs for the identity providers | `list(string)` | `[]` | no |
| <a name="input_client_default_redirect_uri"></a> [client\_default\_redirect\_uri](#input\_client\_default\_redirect\_uri) | The default redirect URI. Must be in the list of callback URLs | `string` | `""` | no |
| <a name="input_client_explicit_auth_flows"></a> [client\_explicit\_auth\_flows](#input\_client\_explicit\_auth\_flows) | List of authentication flows (ADMIN\_NO\_SRP\_AUTH, CUSTOM\_AUTH\_FLOW\_ONLY, USER\_PASSWORD\_AUTH) | `list(string)` | `[]` | no |
| <a name="input_client_generate_secret"></a> [client\_generate\_secret](#input\_client\_generate\_secret) | Should an application secret be generated | `bool` | `true` | no |
| <a name="input_client_id_token_validity"></a> [client\_id\_token\_validity](#input\_client\_id\_token\_validity) | Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. Must be between 5 minutes and 1 day. Cannot be greater than refresh token expiration. This value will be overridden if you have entered a value in `token_validity_units`. | `number` | `60` | no |
| <a name="input_client_logout_urls"></a> [client\_logout\_urls](#input\_client\_logout\_urls) | List of allowed logout URLs for the identity providers | `list(string)` | `[]` | no |
| <a name="input_client_name"></a> [client\_name](#input\_client\_name) | The name of the application client | `string` | `null` | no |
| <a name="input_client_prevent_user_existence_errors"></a> [client\_prevent\_user\_existence\_errors](#input\_client\_prevent\_user\_existence\_errors) | Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the user pool. When set to ENABLED and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to LEGACY, those APIs will return a UserNotFoundException exception if the user does not exist in the user pool. | `string` | `null` | no |
| <a name="input_client_read_attributes"></a> [client\_read\_attributes](#input\_client\_read\_attributes) | List of user pool attributes the application client can read from | `list(string)` | `[]` | no |
| <a name="input_client_refresh_token_validity"></a> [client\_refresh\_token\_validity](#input\_client\_refresh\_token\_validity) | The time limit in days refresh tokens are valid for. Must be between 60 minutes and 3650 days. This value will be overridden if you have entered a value in `token_validity_units` | `number` | `30` | no |
| <a name="input_client_supported_identity_providers"></a> [client\_supported\_identity\_providers](#input\_client\_supported\_identity\_providers) | List of provider names for the identity providers that are supported on this client | `list(string)` | `[]` | no |
| <a name="input_client_token_validity_units"></a> [client\_token\_validity\_units](#input\_client\_token\_validity\_units) | Configuration block for units in which the validity times are represented in. Valid values for the following arguments are: `seconds`, `minutes`, `hours` or `days`. | `any` | <pre>{<br>  "access_token": "minutes",<br>  "id_token": "minutes",<br>  "refresh_token": "days"<br>}</pre> | no |
| <a name="input_client_write_attributes"></a> [client\_write\_attributes](#input\_client\_write\_attributes) | List of user pool attributes the application client can write to | `list(string)` | `[]` | no |
| <a name="input_clients"></a> [clients](#input\_clients) | User Pool clients configuration | `any` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | (Optional) When active, DeletionProtection prevents accidental deletion of your user pool. Before you can delete a user pool that you have protected against deletion, you must deactivate this feature. Valid values are ACTIVE and INACTIVE, Default value is INACTIVE. | `string` | `"INACTIVE"` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_device_configuration"></a> [device\_configuration](#input\_device\_configuration) | The configuration for the user pool's device tracking | `map(any)` | `{}` | no |
| <a name="input_device_configuration_challenge_required_on_new_device"></a> [device\_configuration\_challenge\_required\_on\_new\_device](#input\_device\_configuration\_challenge\_required\_on\_new\_device) | Indicates whether a challenge is required on a new device. Only applicable to a new device | `bool` | `false` | no |
| <a name="input_device_configuration_device_only_remembered_on_user_prompt"></a> [device\_configuration\_device\_only\_remembered\_on\_user\_prompt](#input\_device\_configuration\_device\_only\_remembered\_on\_user\_prompt) | If true, a device is only remembered on user prompt | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Cognito User Pool domain | `string` | `null` | no |
| <a name="input_domain_certificate_arn"></a> [domain\_certificate\_arn](#input\_domain\_certificate\_arn) | The ARN of an ISSUED ACM certificate in `us-east-1` for a custom domain | `string` | `null` | no |
| <a name="input_email_configuration"></a> [email\_configuration](#input\_email\_configuration) | Email configuration | `map(any)` | `{}` | no |
| <a name="input_email_configuration_email_sending_account"></a> [email\_configuration\_email\_sending\_account](#input\_email\_configuration\_email\_sending\_account) | Instruct Cognito to either use its built-in functionality or Amazon SES to send out emails. Allowed values: `COGNITO_DEFAULT` or `DEVELOPER` | `string` | `"COGNITO_DEFAULT"` | no |
| <a name="input_email_configuration_from_email_address"></a> [email\_configuration\_from\_email\_address](#input\_email\_configuration\_from\_email\_address) | Sender’s email address or sender’s display name with their email address (e.g. `john@example.com`, `John Smith <john@example.com>` or `"John Smith Ph.D." <john@example.com>)`. Escaped double quotes are required around display names that contain certain characters as specified in RFC 5322 | `string` | `null` | no |
| <a name="input_email_configuration_reply_to_email_address"></a> [email\_configuration\_reply\_to\_email\_address](#input\_email\_configuration\_reply\_to\_email\_address) | The REPLY-TO email address | `string` | `""` | no |
| <a name="input_email_configuration_source_arn"></a> [email\_configuration\_source\_arn](#input\_email\_configuration\_source\_arn) | The ARN of the email configuration source | `string` | `""` | no |
| <a name="input_email_verification_message"></a> [email\_verification\_message](#input\_email\_verification\_message) | A string representing the email verification message | `string` | `null` | no |
| <a name="input_email_verification_subject"></a> [email\_verification\_subject](#input\_email\_verification\_subject) | A string representing the email verification subject | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_identity_providers"></a> [identity\_providers](#input\_identity\_providers) | Cognito Identity Providers configuration | `list(any)` | `[]` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_lambda_config"></a> [lambda\_config](#input\_lambda\_config) | Configuration for the AWS Lambda triggers associated with the User Pool | `any` | `null` | no |
| <a name="input_lambda_config_create_auth_challenge"></a> [lambda\_config\_create\_auth\_challenge](#input\_lambda\_config\_create\_auth\_challenge) | The ARN of the lambda creating an authentication challenge | `string` | `""` | no |
| <a name="input_lambda_config_custom_email_sender"></a> [lambda\_config\_custom\_email\_sender](#input\_lambda\_config\_custom\_email\_sender) | A custom email sender AWS Lambda trigger | `map(any)` | `{}` | no |
| <a name="input_lambda_config_custom_message"></a> [lambda\_config\_custom\_message](#input\_lambda\_config\_custom\_message) | AWS Lambda trigger custom message | `string` | `""` | no |
| <a name="input_lambda_config_custom_sms_sender"></a> [lambda\_config\_custom\_sms\_sender](#input\_lambda\_config\_custom\_sms\_sender) | A custom SMS sender AWS Lambda trigger | `map(any)` | `{}` | no |
| <a name="input_lambda_config_define_auth_challenge"></a> [lambda\_config\_define\_auth\_challenge](#input\_lambda\_config\_define\_auth\_challenge) | Authentication challenge | `string` | `""` | no |
| <a name="input_lambda_config_kms_key_id"></a> [lambda\_config\_kms\_key\_id](#input\_lambda\_config\_kms\_key\_id) | The Amazon Resource Name of Key Management Service Customer master keys. Amazon Cognito uses the key to encrypt codes and temporary passwords sent to CustomEmailSender and CustomSMSSender. | `string` | `null` | no |
| <a name="input_lambda_config_post_authentication"></a> [lambda\_config\_post\_authentication](#input\_lambda\_config\_post\_authentication) | A post-authentication AWS Lambda trigger | `string` | `""` | no |
| <a name="input_lambda_config_post_confirmation"></a> [lambda\_config\_post\_confirmation](#input\_lambda\_config\_post\_confirmation) | A post-confirmation AWS Lambda trigger | `string` | `""` | no |
| <a name="input_lambda_config_pre_authentication"></a> [lambda\_config\_pre\_authentication](#input\_lambda\_config\_pre\_authentication) | A pre-authentication AWS Lambda trigger | `string` | `""` | no |
| <a name="input_lambda_config_pre_sign_up"></a> [lambda\_config\_pre\_sign\_up](#input\_lambda\_config\_pre\_sign\_up) | A pre-registration AWS Lambda trigger | `string` | `""` | no |
| <a name="input_lambda_config_pre_token_generation"></a> [lambda\_config\_pre\_token\_generation](#input\_lambda\_config\_pre\_token\_generation) | Allow to customize identity token claims before token generation | `string` | `""` | no |
| <a name="input_lambda_config_user_migration"></a> [lambda\_config\_user\_migration](#input\_lambda\_config\_user\_migration) | The user migration Lambda config type | `string` | `""` | no |
| <a name="input_lambda_config_verify_auth_challenge_response"></a> [lambda\_config\_verify\_auth\_challenge\_response](#input\_lambda\_config\_verify\_auth\_challenge\_response) | Verifies the authentication challenge response | `string` | `""` | no |
| <a name="input_mfa_configuration"></a> [mfa\_configuration](#input\_mfa\_configuration) | Multi-factor authentication configuration. Must be one of the following values (ON, OFF, OPTIONAL) | `string` | `"OFF"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_number_schemas"></a> [number\_schemas](#input\_number\_schemas) | A container with the number schema attributes of a user pool. Maximum of 50 attributes | `list(any)` | `[]` | no |
| <a name="input_password_policy"></a> [password\_policy](#input\_password\_policy) | User Pool password policy configuration | <pre>object({<br>    minimum_length                   = number,<br>    require_lowercase                = bool,<br>    require_numbers                  = bool,<br>    require_symbols                  = bool,<br>    require_uppercase                = bool,<br>    temporary_password_validity_days = number<br>  })</pre> | `null` | no |
| <a name="input_password_policy_minimum_length"></a> [password\_policy\_minimum\_length](#input\_password\_policy\_minimum\_length) | The minimum password length | `number` | `8` | no |
| <a name="input_password_policy_require_lowercase"></a> [password\_policy\_require\_lowercase](#input\_password\_policy\_require\_lowercase) | Whether you have required users to use at least one lowercase letter in their password | `bool` | `true` | no |
| <a name="input_password_policy_require_numbers"></a> [password\_policy\_require\_numbers](#input\_password\_policy\_require\_numbers) | Whether you have required users to use at least one number in their password | `bool` | `true` | no |
| <a name="input_password_policy_require_symbols"></a> [password\_policy\_require\_symbols](#input\_password\_policy\_require\_symbols) | Whether you have required users to use at least one symbol in their password | `bool` | `true` | no |
| <a name="input_password_policy_require_uppercase"></a> [password\_policy\_require\_uppercase](#input\_password\_policy\_require\_uppercase) | Whether you have required users to use at least one uppercase letter in their password | `bool` | `true` | no |
| <a name="input_password_policy_temporary_password_validity_days"></a> [password\_policy\_temporary\_password\_validity\_days](#input\_password\_policy\_temporary\_password\_validity\_days) | Password policy temporary password validity\_days | `number` | `7` | no |
| <a name="input_recovery_mechanisms"></a> [recovery\_mechanisms](#input\_recovery\_mechanisms) | List of account recovery options | `list(any)` | `[]` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_resource_server_identifier"></a> [resource\_server\_identifier](#input\_resource\_server\_identifier) | Resource server identifier | `string` | `null` | no |
| <a name="input_resource_server_name"></a> [resource\_server\_name](#input\_resource\_server\_name) | Resource server name | `string` | `null` | no |
| <a name="input_resource_server_scope_description"></a> [resource\_server\_scope\_description](#input\_resource\_server\_scope\_description) | Resource server scope description | `string` | `null` | no |
| <a name="input_resource_server_scope_name"></a> [resource\_server\_scope\_name](#input\_resource\_server\_scope\_name) | Resource server scope name | `string` | `null` | no |
| <a name="input_resource_servers"></a> [resource\_servers](#input\_resource\_servers) | Resource servers configuration | `list(any)` | `[]` | no |
| <a name="input_schemas"></a> [schemas](#input\_schemas) | A container with the schema attributes of a User Pool. Maximum of 50 attributes | `list(any)` | `[]` | no |
| <a name="input_sms_authentication_message"></a> [sms\_authentication\_message](#input\_sms\_authentication\_message) | A string representing the SMS authentication message | `string` | `null` | no |
| <a name="input_sms_configuration"></a> [sms\_configuration](#input\_sms\_configuration) | SMS configuration | `map(any)` | `{}` | no |
| <a name="input_sms_configuration_external_id"></a> [sms\_configuration\_external\_id](#input\_sms\_configuration\_external\_id) | The external ID used in IAM role trust relationships | `string` | `""` | no |
| <a name="input_sms_configuration_sns_caller_arn"></a> [sms\_configuration\_sns\_caller\_arn](#input\_sms\_configuration\_sns\_caller\_arn) | The ARN of the Amazon SNS caller. This is usually the IAM role that you've given Cognito permission to assume | `string` | `""` | no |
| <a name="input_sms_verification_message"></a> [sms\_verification\_message](#input\_sms\_verification\_message) | A string representing the SMS verification message | `string` | `null` | no |
| <a name="input_software_token_mfa_configuration"></a> [software\_token\_mfa\_configuration](#input\_software\_token\_mfa\_configuration) | Configuration block for software token MFA. `mfa_configuration` must also be enabled for this to work | `map(any)` | `{}` | no |
| <a name="input_software_token_mfa_configuration_enabled"></a> [software\_token\_mfa\_configuration\_enabled](#input\_software\_token\_mfa\_configuration\_enabled) | If `true`, and if `mfa_configuration` is also enabled, multi-factor authentication by software TOTP generator will be enabled | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_string_schemas"></a> [string\_schemas](#input\_string\_schemas) | A container with the string schema attributes of a user pool. Maximum of 50 attributes | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_temporary_password_validity_days"></a> [temporary\_password\_validity\_days](#input\_temporary\_password\_validity\_days) | The user account expiration limit, in days, after which the account is no longer usable | `number` | `7` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_user_group_description"></a> [user\_group\_description](#input\_user\_group\_description) | The description of the user group | `string` | `null` | no |
| <a name="input_user_group_name"></a> [user\_group\_name](#input\_user\_group\_name) | The name of the user group | `string` | `null` | no |
| <a name="input_user_group_precedence"></a> [user\_group\_precedence](#input\_user\_group\_precedence) | The precedence of the user group | `number` | `null` | no |
| <a name="input_user_group_role_arn"></a> [user\_group\_role\_arn](#input\_user\_group\_role\_arn) | The ARN of the IAM role to be associated with the user group | `string` | `null` | no |
| <a name="input_user_groups"></a> [user\_groups](#input\_user\_groups) | User groups configuration | `list(any)` | `[]` | no |
| <a name="input_user_pool_add_ons"></a> [user\_pool\_add\_ons](#input\_user\_pool\_add\_ons) | Configuration block for user pool add-ons to enable user pool advanced security mode features | `map(any)` | `{}` | no |
| <a name="input_user_pool_add_ons_advanced_security_mode"></a> [user\_pool\_add\_ons\_advanced\_security\_mode](#input\_user\_pool\_add\_ons\_advanced\_security\_mode) | The mode for advanced security, must be one of `OFF`, `AUDIT` or `ENFORCED` | `string` | `null` | no |
| <a name="input_user_pool_name"></a> [user\_pool\_name](#input\_user\_pool\_name) | User pool name. If not provided, the name will be generated from the context | `string` | `null` | no |
| <a name="input_username_attributes"></a> [username\_attributes](#input\_username\_attributes) | Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with `alias_attributes` | `list(string)` | `null` | no |
| <a name="input_username_configuration"></a> [username\_configuration](#input\_username\_configuration) | The Username Configuration. Setting `case_sensitive` specifies whether username case sensitivity will be applied for all users in the user pool through Cognito APIs | `map(any)` | `{}` | no |
| <a name="input_verification_message_template"></a> [verification\_message\_template](#input\_verification\_message\_template) | The verification message templates configuration | `map(any)` | `{}` | no |
| <a name="input_verification_message_template_default_email_option"></a> [verification\_message\_template\_default\_email\_option](#input\_verification\_message\_template\_default\_email\_option) | The default email option. Must be either `CONFIRM_WITH_CODE` or `CONFIRM_WITH_LINK`. Defaults to `CONFIRM_WITH_CODE` | `string` | `null` | no |
| <a name="input_verification_message_template_email_message_by_link"></a> [verification\_message\_template\_email\_message\_by\_link](#input\_verification\_message\_template\_email\_message\_by\_link) | The email message template for sending a confirmation link to the user, it must contain the `{##Click Here##}` placeholder | `string` | `null` | no |
| <a name="input_verification_message_template_email_subject_by_link"></a> [verification\_message\_template\_email\_subject\_by\_link](#input\_verification\_message\_template\_email\_subject\_by\_link) | The subject line for the email message template for sending a confirmation link to the user | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the User Pool |
| <a name="output_client_ids"></a> [client\_ids](#output\_client\_ids) | The ids of the User Pool clients |
| <a name="output_client_ids_map"></a> [client\_ids\_map](#output\_client\_ids\_map) | The IDs map of the User Pool clients |
| <a name="output_client_secrets"></a> [client\_secrets](#output\_client\_secrets) | The client secrets of the User Pool clients |
| <a name="output_client_secrets_map"></a> [client\_secrets\_map](#output\_client\_secrets\_map) | The client secrets map of the User Pool clients |
| <a name="output_creation_date"></a> [creation\_date](#output\_creation\_date) | The date the User Pool was created |
| <a name="output_domain_app_version"></a> [domain\_app\_version](#output\_domain\_app\_version) | The app version for the domain |
| <a name="output_domain_aws_account_id"></a> [domain\_aws\_account\_id](#output\_domain\_aws\_account\_id) | The AWS account ID for the User Pool domain |
| <a name="output_domain_cloudfront_distribution_arn"></a> [domain\_cloudfront\_distribution\_arn](#output\_domain\_cloudfront\_distribution\_arn) | The ARN of the CloudFront distribution for the domain |
| <a name="output_domain_s3_bucket"></a> [domain\_s3\_bucket](#output\_domain\_s3\_bucket) | The S3 bucket where the static files for the domain are stored |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The endpoint name of the User Pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx\_yyyyy |
| <a name="output_id"></a> [id](#output\_id) | The ID of the User Pool |
| <a name="output_last_modified_date"></a> [last\_modified\_date](#output\_last\_modified\_date) | The date the User Pool was last modified |
| <a name="output_resource_servers_scope_identifiers"></a> [resource\_servers\_scope\_identifiers](#output\_resource\_servers\_scope\_identifiers) | A list of all scopes configured in the format identifier/scope\_name |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/cognito) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
