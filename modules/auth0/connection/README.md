# Component: `auth0/connection`

Auth 0 Connection component. [Auth0](https://auth0.com/docs/) is a third-party service that provides authentication and
authorization as a service. It is typically used to to authenticate users.

An Auth0 connection is a bridge between Auth0 and an identity provider (IdP) that allows your application to
authenticate users. Auth0 supports many types of connections, including social identity providers such as Google,
Facebook, and Twitter, enterprise identity providers such as Microsoft Azure AD, and passwordless authentication methods
such as email and SMS.

## Usage

Before deploying this component, you need to deploy the `auth0/tenant` component. This components with authenticate with
the [Auth0 Terraform provider](https://registry.terraform.io/providers/auth0/auth0/latest/) using the Auth0 tenant's
client ID and client secret configured with the `auth0/tenant` component.

**Stack Level**: Global

Here's an example snippet for how to use this component.

```yaml
# stacks/catalog/auth0/connection.yaml
components:
  terraform:
    auth0/connection:
      vars:
        enabled: true
        name: "auth0"

        # These must all be specified for the connection to be created
        strategy: "email"
        connection_name: "email"
        options_name: "email"

        email_from: "{{`{{ application.name }}`}} <root@auth0.com>"
        email_subject: "Welcome to {{`{{ application.name }}`}}"
        syntax: "liquid"

        auth_params:
          scope: "openid profile"
          response_type: "code"

        totp:
          time_step: 895
          length: 6

        template_file: "templates/email.html"

        # Stage-specific configuration
        auth0_app_connections:
          - stage: sandbox
          - stage: dev
          - stage: staging
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_auth0"></a> [auth0](#requirement\_auth0) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_auth0"></a> [auth0](#provider\_auth0) | >= 1.0.0 |
| <a name="provider_aws.auth0_provider"></a> [aws.auth0\_provider](#provider\_aws.auth0\_provider) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_auth0_apps"></a> [auth0\_apps](#module\_auth0\_apps) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_auth0_ssm_parameters"></a> [auth0\_ssm\_parameters](#module\_auth0\_ssm\_parameters) | cloudposse/ssm-parameter-store/aws | 0.13.0 |
| <a name="module_auth0_tenant"></a> [auth0\_tenant](#module\_auth0\_tenant) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_auth0_provider"></a> [iam\_roles\_auth0\_provider](#module\_iam\_roles\_auth0\_provider) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [auth0_connection.this](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/connection) | resource |
| [auth0_connection_clients.this](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/connection_clients) | resource |
| [aws_ssm_parameter.auth0_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.auth0_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.auth0_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auth0_app_connections"></a> [auth0\_app\_connections](#input\_auth0\_app\_connections) | The list of Auth0 apps to add to this connection | <pre>list(object({<br>    component   = optional(string, "auth0/app")<br>    environment = optional(string, "")<br>    stage       = optional(string, "")<br>    tenant      = optional(string, "")<br>  }))</pre> | `[]` | no |
| <a name="input_auth0_debug"></a> [auth0\_debug](#input\_auth0\_debug) | Enable debug mode for the Auth0 provider | `bool` | `true` | no |
| <a name="input_auth0_tenant_component_name"></a> [auth0\_tenant\_component\_name](#input\_auth0\_tenant\_component\_name) | The name of the component | `string` | `"auth0/tenant"` | no |
| <a name="input_auth0_tenant_environment_name"></a> [auth0\_tenant\_environment\_name](#input\_auth0\_tenant\_environment\_name) | The name of the environment where the Auth0 tenant component is deployed. Defaults to the environment of the current stack. | `string` | `""` | no |
| <a name="input_auth0_tenant_stage_name"></a> [auth0\_tenant\_stage\_name](#input\_auth0\_tenant\_stage\_name) | The name of the stage where the Auth0 tenant component is deployed. Defaults to the stage of the current stack. | `string` | `""` | no |
| <a name="input_auth0_tenant_tenant_name"></a> [auth0\_tenant\_tenant\_name](#input\_auth0\_tenant\_tenant\_name) | The name of the tenant where the Auth0 tenant component is deployed. Yes this is a bit redundant, since Auth0 also calls this resource a tenant. Defaults to the tenant of the current stack. | `string` | `""` | no |
| <a name="input_auth_params"></a> [auth\_params](#input\_auth\_params) | Query string parameters to be included as part of the generated passwordless email link. | <pre>object({<br>    scope         = optional(string, null)<br>    response_type = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_brute_force_protection"></a> [brute\_force\_protection](#input\_brute\_force\_protection) | Indicates whether to enable brute force protection, which will limit the number of signups and failed logins from a suspicious IP address. | `bool` | `true` | no |
| <a name="input_connection_name"></a> [connection\_name](#input\_connection\_name) | The name of the connection | `string` | `""` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_auth0_ssm_parameters_enabled"></a> [create\_auth0\_ssm\_parameters\_enabled](#input\_create\_auth0\_ssm\_parameters\_enabled) | Whether or not to create a duplicate of the AWS SSM parameter for the Auth0 domain, client ID, and client secret in this account. | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_disable_signup"></a> [disable\_signup](#input\_disable\_signup) | Indicates whether to allow user sign-ups to your application. | `bool` | `false` | no |
| <a name="input_email_from"></a> [email\_from](#input\_email\_from) | When using an email strategy, the address to use as the sender | `string` | `null` | no |
| <a name="input_email_subject"></a> [email\_subject](#input\_email\_subject) | When using an email strategy, the subject of the email | `string` | `null` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_non_persistent_attrs"></a> [non\_persistent\_attrs](#input\_non\_persistent\_attrs) | If there are user fields that should not be stored in Auth0 databases due to privacy reasons, you can add them to the DenyList here. | `list(string)` | `[]` | no |
| <a name="input_options_name"></a> [options\_name](#input\_options\_name) | The name of the connection options. Required for the email strategy. | `string` | `""` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_set_user_root_attributes"></a> [set\_user\_root\_attributes](#input\_set\_user\_root\_attributes) | Determines whether to sync user profile attributes at each login or only on the first login. Options include: `on_each_login`, `on_first_login`. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_strategy"></a> [strategy](#input\_strategy) | The strategy to use for the connection | `string` | `"auth0"` | no |
| <a name="input_syntax"></a> [syntax](#input\_syntax) | The syntax of the template body | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_template"></a> [template](#input\_template) | The template to use for the connection. If not provided, the `template_file` variable must be set. | `string` | `""` | no |
| <a name="input_template_file"></a> [template\_file](#input\_template\_file) | The path to the template file. If not provided, the `template` variable must be set. | `string` | `""` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_totp"></a> [totp](#input\_totp) | The TOTP settings for the connection | <pre>object({<br>    time_step = optional(number, 900)<br>    length    = optional(number, 6)<br>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth0_connection_id"></a> [auth0\_connection\_id](#output\_auth0\_connection\_id) | The Auth0 Connection ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/auth0/connection) -
  Cloud Posse's upstream component
- [Auth0 Terraform Provider](https://registry.terraform.io/providers/auth0/auth0/latest/)
- [Auth0 Documentation](https://auth0.com/docs/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
