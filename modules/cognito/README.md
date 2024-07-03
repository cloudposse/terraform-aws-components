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

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.8.0), version: >= 4.8.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.8.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_cognito_identity_provider.identity_provider`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_identity_provider) (resource)
  - [`aws_cognito_resource_server.resource`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_resource_server) (resource)
  - [`aws_cognito_user_group.main`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) (resource)
  - [`aws_cognito_user_pool.pool`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) (resource)
  - [`aws_cognito_user_pool_client.client`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) (resource)
  - [`aws_cognito_user_pool_domain.domain`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) (resource)

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
    AWS region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`admin_create_user_config` (`map(any)`) <i>optional</i></dt>
  <dd>
    The configuration for AdminCreateUser requests<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`admin_create_user_config_allow_admin_create_user_only` (`bool`) <i>optional</i></dt>
  <dd>
    Set to `true` if only the administrator is allowed to create user profiles. Set to `false` if users can sign themselves up via an app<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`admin_create_user_config_email_message` (`string`) <i>optional</i></dt>
  <dd>
    The message template for email messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"{username}, your temporary password is `{####}`"`
  </dd>
  <dt>`admin_create_user_config_email_subject` (`string`) <i>optional</i></dt>
  <dd>
    The subject line for email messages<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"Your verification code"`
  </dd>
  <dt>`admin_create_user_config_sms_message` (`string`) <i>optional</i></dt>
  <dd>
    The message template for SMS messages. Must contain `{username}` and `{####}` placeholders, for username and temporary password, respectively<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"Your username is {username} and temporary password is `{####}`"`
  </dd>
  <dt>`alias_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Attributes supported as an alias for this user pool. Possible values: phone_number, email, or preferred_username. Conflicts with `username_attributes`<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`auto_verified_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    The attributes to be auto-verified. Possible values: email, phone_number<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_access_token_validity` (`number`) <i>optional</i></dt>
  <dd>
    Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used. This value will be overridden if you have entered a value in `token_validity_units`.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `60`
  </dd>
  <dt>`client_allowed_oauth_flows` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of allowed OAuth flows (code, implicit, client_credentials)<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_allowed_oauth_flows_user_pool_client` (`bool`) <i>optional</i></dt>
  <dd>
    Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`client_allowed_oauth_scopes` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin)<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_callback_urls` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of allowed callback URLs for the identity providers<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_default_redirect_uri` (`string`) <i>optional</i></dt>
  <dd>
    The default redirect URI. Must be in the list of callback URLs<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`client_explicit_auth_flows` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH)<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_generate_secret` (`bool`) <i>optional</i></dt>
  <dd>
    Should an application secret be generated<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`client_id_token_validity` (`number`) <i>optional</i></dt>
  <dd>
    Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. Must be between 5 minutes and 1 day. Cannot be greater than refresh token expiration. This value will be overridden if you have entered a value in `token_validity_units`.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `60`
  </dd>
  <dt>`client_logout_urls` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of allowed logout URLs for the identity providers<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the application client<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`client_prevent_user_existence_errors` (`string`) <i>optional</i></dt>
  <dd>
    Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the user pool. When set to ENABLED and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to LEGACY, those APIs will return a UserNotFoundException exception if the user does not exist in the user pool.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`client_read_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of user pool attributes the application client can read from<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_refresh_token_validity` (`number`) <i>optional</i></dt>
  <dd>
    The time limit in days refresh tokens are valid for. Must be between 60 minutes and 3650 days. This value will be overridden if you have entered a value in `token_validity_units`<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `30`
  </dd>
  <dt>`client_supported_identity_providers` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of provider names for the identity providers that are supported on this client<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`client_token_validity_units` (`any`) <i>optional</i></dt>
  <dd>
    Configuration block for units in which the validity times are represented in. Valid values for the following arguments are: `seconds`, `minutes`, `hours` or `days`.<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** 
    ```hcl
    {
      "access_token": "minutes",
      "id_token": "minutes",
      "refresh_token": "days"
    }
    ```
    
  </dd>
  <dt>`client_write_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of user pool attributes the application client can write to<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`clients` (`any`) <i>optional</i></dt>
  <dd>
    User Pool clients configuration<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`deletion_protection` (`string`) <i>optional</i></dt>
  <dd>
    (Optional) When active, DeletionProtection prevents accidental deletion of your user pool. Before you can delete a user pool that you have protected against deletion, you must deactivate this feature. Valid values are ACTIVE and INACTIVE, Default value is INACTIVE.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"INACTIVE"`
  </dd>
  <dt>`device_configuration` (`map(any)`) <i>optional</i></dt>
  <dd>
    The configuration for the user pool's device tracking<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`device_configuration_challenge_required_on_new_device` (`bool`) <i>optional</i></dt>
  <dd>
    Indicates whether a challenge is required on a new device. Only applicable to a new device<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`device_configuration_device_only_remembered_on_user_prompt` (`bool`) <i>optional</i></dt>
  <dd>
    If true, a device is only remembered on user prompt<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`domain` (`string`) <i>optional</i></dt>
  <dd>
    Cognito User Pool domain<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`domain_certificate_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of an ISSUED ACM certificate in `us-east-1` for a custom domain<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`email_configuration` (`map(any)`) <i>optional</i></dt>
  <dd>
    Email configuration<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`email_configuration_email_sending_account` (`string`) <i>optional</i></dt>
  <dd>
    Instruct Cognito to either use its built-in functionality or Amazon SES to send out emails. Allowed values: `COGNITO_DEFAULT` or `DEVELOPER`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"COGNITO_DEFAULT"`
  </dd>
  <dt>`email_configuration_from_email_address` (`string`) <i>optional</i></dt>
  <dd>
    Sender’s email address or sender’s display name with their email address (e.g. `john@example.com`, `John Smith <john@example.com>` or `"John Smith Ph.D." <john@example.com>)`. Escaped double quotes are required around display names that contain certain characters as specified in RFC 5322<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`email_configuration_reply_to_email_address` (`string`) <i>optional</i></dt>
  <dd>
    The REPLY-TO email address<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`email_configuration_source_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the email configuration source<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`email_verification_message` (`string`) <i>optional</i></dt>
  <dd>
    A string representing the email verification message<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`email_verification_subject` (`string`) <i>optional</i></dt>
  <dd>
    A string representing the email verification subject<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`identity_providers` (`list(any)`) <i>optional</i></dt>
  <dd>
    Cognito Identity Providers configuration<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`lambda_config` (`any`) <i>optional</i></dt>
  <dd>
    Configuration for the AWS Lambda triggers associated with the User Pool<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`lambda_config_create_auth_challenge` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the lambda creating an authentication challenge<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_custom_email_sender` (`map(any)`) <i>optional</i></dt>
  <dd>
    A custom email sender AWS Lambda trigger<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`lambda_config_custom_message` (`string`) <i>optional</i></dt>
  <dd>
    AWS Lambda trigger custom message<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_custom_sms_sender` (`map(any)`) <i>optional</i></dt>
  <dd>
    A custom SMS sender AWS Lambda trigger<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`lambda_config_define_auth_challenge` (`string`) <i>optional</i></dt>
  <dd>
    Authentication challenge<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_kms_key_id` (`string`) <i>optional</i></dt>
  <dd>
    The Amazon Resource Name of Key Management Service Customer master keys. Amazon Cognito uses the key to encrypt codes and temporary passwords sent to CustomEmailSender and CustomSMSSender.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`lambda_config_post_authentication` (`string`) <i>optional</i></dt>
  <dd>
    A post-authentication AWS Lambda trigger<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_post_confirmation` (`string`) <i>optional</i></dt>
  <dd>
    A post-confirmation AWS Lambda trigger<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_pre_authentication` (`string`) <i>optional</i></dt>
  <dd>
    A pre-authentication AWS Lambda trigger<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_pre_sign_up` (`string`) <i>optional</i></dt>
  <dd>
    A pre-registration AWS Lambda trigger<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_pre_token_generation` (`string`) <i>optional</i></dt>
  <dd>
    Allow to customize identity token claims before token generation<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_user_migration` (`string`) <i>optional</i></dt>
  <dd>
    The user migration Lambda config type<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`lambda_config_verify_auth_challenge_response` (`string`) <i>optional</i></dt>
  <dd>
    Verifies the authentication challenge response<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`mfa_configuration` (`string`) <i>optional</i></dt>
  <dd>
    Multi-factor authentication configuration. Must be one of the following values (ON, OFF, OPTIONAL)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"OFF"`
  </dd>
  <dt>`number_schemas` (`list(any)`) <i>optional</i></dt>
  <dd>
    A container with the number schema attributes of a user pool. Maximum of 50 attributes<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`password_policy` <i>optional</i></dt>
  <dd>
    User Pool password policy configuration<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    minimum_length                   = number,
    require_lowercase                = bool,
    require_numbers                  = bool,
    require_symbols                  = bool,
    require_uppercase                = bool,
    temporary_password_validity_days = number
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`password_policy_minimum_length` (`number`) <i>optional</i></dt>
  <dd>
    The minimum password length<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `8`
  </dd>
  <dt>`password_policy_require_lowercase` (`bool`) <i>optional</i></dt>
  <dd>
    Whether you have required users to use at least one lowercase letter in their password<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`password_policy_require_numbers` (`bool`) <i>optional</i></dt>
  <dd>
    Whether you have required users to use at least one number in their password<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`password_policy_require_symbols` (`bool`) <i>optional</i></dt>
  <dd>
    Whether you have required users to use at least one symbol in their password<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`password_policy_require_uppercase` (`bool`) <i>optional</i></dt>
  <dd>
    Whether you have required users to use at least one uppercase letter in their password<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`password_policy_temporary_password_validity_days` (`number`) <i>optional</i></dt>
  <dd>
    Password policy temporary password validity_days<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `7`
  </dd>
  <dt>`recovery_mechanisms` (`list(any)`) <i>optional</i></dt>
  <dd>
    List of account recovery options<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`resource_server_identifier` (`string`) <i>optional</i></dt>
  <dd>
    Resource server identifier<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`resource_server_name` (`string`) <i>optional</i></dt>
  <dd>
    Resource server name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`resource_server_scope_description` (`string`) <i>optional</i></dt>
  <dd>
    Resource server scope description<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`resource_server_scope_name` (`string`) <i>optional</i></dt>
  <dd>
    Resource server scope name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`resource_servers` (`list(any)`) <i>optional</i></dt>
  <dd>
    Resource servers configuration<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`schemas` (`list(any)`) <i>optional</i></dt>
  <dd>
    A container with the schema attributes of a User Pool. Maximum of 50 attributes<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`sms_authentication_message` (`string`) <i>optional</i></dt>
  <dd>
    A string representing the SMS authentication message<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`sms_configuration` (`map(any)`) <i>optional</i></dt>
  <dd>
    SMS configuration<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`sms_configuration_external_id` (`string`) <i>optional</i></dt>
  <dd>
    The external ID used in IAM role trust relationships<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`sms_configuration_sns_caller_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the Amazon SNS caller. This is usually the IAM role that you've given Cognito permission to assume<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`sms_verification_message` (`string`) <i>optional</i></dt>
  <dd>
    A string representing the SMS verification message<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`software_token_mfa_configuration` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for software token MFA. `mfa_configuration` must also be enabled for this to work<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`software_token_mfa_configuration_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, and if `mfa_configuration` is also enabled, multi-factor authentication by software TOTP generator will be enabled<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`string_schemas` (`list(any)`) <i>optional</i></dt>
  <dd>
    A container with the string schema attributes of a user pool. Maximum of 50 attributes<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`temporary_password_validity_days` (`number`) <i>optional</i></dt>
  <dd>
    The user account expiration limit, in days, after which the account is no longer usable<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `7`
  </dd>
  <dt>`user_group_description` (`string`) <i>optional</i></dt>
  <dd>
    The description of the user group<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`user_group_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the user group<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`user_group_precedence` (`number`) <i>optional</i></dt>
  <dd>
    The precedence of the user group<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`user_group_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the IAM role to be associated with the user group<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`user_groups` (`list(any)`) <i>optional</i></dt>
  <dd>
    User groups configuration<br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`user_pool_add_ons` (`map(any)`) <i>optional</i></dt>
  <dd>
    Configuration block for user pool add-ons to enable user pool advanced security mode features<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`user_pool_add_ons_advanced_security_mode` (`string`) <i>optional</i></dt>
  <dd>
    The mode for advanced security, must be one of `OFF`, `AUDIT` or `ENFORCED`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`user_pool_name` (`string`) <i>optional</i></dt>
  <dd>
    User pool name. If not provided, the name will be generated from the context<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`username_attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Specifies whether email addresses or phone numbers can be specified as usernames when a user signs up. Conflicts with `alias_attributes`<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`username_configuration` (`map(any)`) <i>optional</i></dt>
  <dd>
    The Username Configuration. Setting `case_sensitive` specifies whether username case sensitivity will be applied for all users in the user pool through Cognito APIs<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`verification_message_template` (`map(any)`) <i>optional</i></dt>
  <dd>
    The verification message templates configuration<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`verification_message_template_default_email_option` (`string`) <i>optional</i></dt>
  <dd>
    The default email option. Must be either `CONFIRM_WITH_CODE` or `CONFIRM_WITH_LINK`. Defaults to `CONFIRM_WITH_CODE`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`verification_message_template_email_message_by_link` (`string`) <i>optional</i></dt>
  <dd>
    The email message template for sending a confirmation link to the user, it must contain the `{##Click Here##}` placeholder<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`verification_message_template_email_subject_by_link` (`string`) <i>optional</i></dt>
  <dd>
    The subject line for the email message template for sending a confirmation link to the user<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    The ARN of the User Pool<br/>
  </dd>
  <dt>`client_ids`</dt>
  <dd>
    The ids of the User Pool clients<br/>
  </dd>
  <dt>`client_ids_map`</dt>
  <dd>
    The IDs map of the User Pool clients<br/>
  </dd>
  <dt>`client_secrets`</dt>
  <dd>
     The client secrets of the User Pool clients<br/>
  </dd>
  <dt>`client_secrets_map`</dt>
  <dd>
    The client secrets map of the User Pool clients<br/>
  </dd>
  <dt>`creation_date`</dt>
  <dd>
    The date the User Pool was created<br/>
  </dd>
  <dt>`domain_app_version`</dt>
  <dd>
    The app version for the domain<br/>
  </dd>
  <dt>`domain_aws_account_id`</dt>
  <dd>
    The AWS account ID for the User Pool domain<br/>
  </dd>
  <dt>`domain_cloudfront_distribution_arn`</dt>
  <dd>
    The ARN of the CloudFront distribution for the domain<br/>
  </dd>
  <dt>`domain_s3_bucket`</dt>
  <dd>
    The S3 bucket where the static files for the domain are stored<br/>
  </dd>
  <dt>`endpoint`</dt>
  <dd>
    The endpoint name of the User Pool. Example format: cognito-idp.REGION.amazonaws.com/xxxx_yyyyy<br/>
  </dd>
  <dt>`id`</dt>
  <dd>
    The ID of the User Pool<br/>
  </dd>
  <dt>`last_modified_date`</dt>
  <dd>
    The date the User Pool was last modified<br/>
  </dd>
  <dt>`resource_servers_scope_identifiers`</dt>
  <dd>
     A list of all scopes configured in the format identifier/scope_name<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/cognito) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
