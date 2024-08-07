# Component: `auth0/tenant`

This component configures an [Auth0](https://auth0.com/docs/) tenant. This component is used to configure authentication
for the Terraform provider for Auth0 and to configure the Auth0 tenant itself.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component.

```yaml
# catalog/auth0/tenant.yaml
components:
  terraform:
    auth0/tenant:
      vars:
        enabled: true
        name: auth0
        support_email: "tech@acme.com"
        support_url: "https://acme.com"
```

### Auth0 Tenant Creation

Chicken before the egg...

The Auth0 tenant must exist before we can manage it with Terraform. In order to create the Auth0 application used by the
[Auth0 Terraform provider](https://registry.terraform.io/providers/auth0/auth0/latest/), we must first create the Auth0
tenant. Then once we have the Auth0 provider configured, we can import the tenant into Terraform. However, the tenant is
not a resource identifiable by an ID within the Auth0 Management API! We can nevertheless import it using a random
string. On first run, we import the existing tenant using a random string. It does not matter what this value is.
Terraform will use the same tenant as the Auth0 application for the Terraform Auth0 Provider.

Create the Auth0 tenant now using the Auth0 Management API or the Auth0 Dashboard following
[the Auth0 create tenants documentation](https://auth0.com/docs/get-started/auth0-overview/create-tenants).

### Provider Pre-requisites

Once the Auth0 tenant is created or you've been given access to an existing tenant, you can configure the Auth0 provider
in Terraform. Follow the
[Auth0 provider documentation](https://registry.terraform.io/providers/auth0/auth0/latest/docs/guides/quickstart) to
create a Machine to Machine application.

> [!TIP]
>
> #### Machine to Machine App Name
>
> Use the Context Label format for the machine name for consistency. For example, `acme-plat-gbl-prod-auth0-provider`.

After creating the Machine to Machine application, add the app's domain, client ID, and client secret to AWS Systems
Manager Parameter Store in the same account and region as this component deployment. The path for the parameters are
defined by the component deployment's Null Label context ID as follows:

```hcl
auth0_domain_ssm_path        = "/${module.this.id}/domain"
auth0_client_id_ssm_path     = "/${module.this.id}/client_id"
auth0_client_secret_ssm_path = "/${module.this.id}/client_secret"
```

For example, if we're deploying `auth0/tenant` into `plat-gbl-prod` and my default region is `us-west-2`, then I would
add the following parameters to the `plat-prod` account in `us-west-2`:

```
/acme-plat-gbl-prod-auth0/domain
/acme-plat-gbl-prod-auth0/client_id
/acme-plat-gbl-prod-auth0/client_secret
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_dns_gbl_delegated"></a> [dns\_gbl\_delegated](#module\_dns\_gbl\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [auth0_custom_domain.this](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/custom_domain) | resource |
| [auth0_custom_domain_verification.this](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/custom_domain_verification) | resource |
| [auth0_tenant.this](https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/tenant) | resource |
| [aws_route53_record.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_ssm_parameter.auth0_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.auth0_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.auth0_domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allowed_logout_urls"></a> [allowed\_logout\_urls](#input\_allowed\_logout\_urls) | The URLs that Auth0 can redirect to after logout. | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auth0_debug"></a> [auth0\_debug](#input\_auth0\_debug) | Enable debug mode for the Auth0 provider | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_default_redirection_uri"></a> [default\_redirection\_uri](#input\_default\_redirection\_uri) | The default redirection URI. | `string` | `""` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_disable_clickjack_protection_headers"></a> [disable\_clickjack\_protection\_headers](#input\_disable\_clickjack\_protection\_headers) | Whether to disable clickjack protection headers. | `bool` | `true` | no |
| <a name="input_disable_fields_map_fix"></a> [disable\_fields\_map\_fix](#input\_disable\_fields\_map\_fix) | Whether to disable fields map fix. | `bool` | `false` | no |
| <a name="input_disable_management_api_sms_obfuscation"></a> [disable\_management\_api\_sms\_obfuscation](#input\_disable\_management\_api\_sms\_obfuscation) | Whether to disable management API SMS obfuscation. | `bool` | `false` | no |
| <a name="input_enable_public_signup_user_exists_error"></a> [enable\_public\_signup\_user\_exists\_error](#input\_enable\_public\_signup\_user\_exists\_error) | Whether to enable public signup user exists error. | `bool` | `true` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_enabled_locales"></a> [enabled\_locales](#input\_enabled\_locales) | The enabled locales. | `list(string)` | <pre>[<br>  "en"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_friendly_name"></a> [friendly\_name](#input\_friendly\_name) | The friendly name of the Auth0 tenant. If not provided, the module context ID will be used. | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_idle_session_lifetime"></a> [idle\_session\_lifetime](#input\_idle\_session\_lifetime) | The idle session lifetime in hours. | `number` | `72` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_no_disclose_enterprise_connections"></a> [no\_disclose\_enterprise\_connections](#input\_no\_disclose\_enterprise\_connections) | Whether to disclose enterprise connections. | `bool` | `false` | no |
| <a name="input_oidc_logout_prompt_enabled"></a> [oidc\_logout\_prompt\_enabled](#input\_oidc\_logout\_prompt\_enabled) | Whether the OIDC logout prompt is enabled. | `bool` | `false` | no |
| <a name="input_picture_url"></a> [picture\_url](#input\_picture\_url) | The URL of the picture to be displayed in the Auth0 Universal Login page. | `string` | `"https://cloudposse.com/wp-content/uploads/2017/07/CloudPosse2-TRANSAPRENT.png"` | no |
| <a name="input_provider_ssm_base_path"></a> [provider\_ssm\_base\_path](#input\_provider\_ssm\_base\_path) | The base path for the SSM parameters. If not defined, this is set to the module context ID. This is also required when `var.enabled` is set to `false` | `string` | `""` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_sandbox_version"></a> [sandbox\_version](#input\_sandbox\_version) | The sandbox version. | `string` | `"18"` | no |
| <a name="input_session_cookie_mode"></a> [session\_cookie\_mode](#input\_session\_cookie\_mode) | The session cookie mode. | `string` | `"persistent"` | no |
| <a name="input_session_lifetime"></a> [session\_lifetime](#input\_session\_lifetime) | The session lifetime in hours. | `number` | `168` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_support_email"></a> [support\_email](#input\_support\_email) | The email address to be displayed in the Auth0 Universal Login page. | `string` | n/a | yes |
| <a name="input_support_url"></a> [support\_url](#input\_support\_url) | The URL to be displayed in the Auth0 Universal Login page. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_use_scope_descriptions_for_consent"></a> [use\_scope\_descriptions\_for\_consent](#input\_use\_scope\_descriptions\_for\_consent) | Whether to use scope descriptions for consent. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_auth0_domain"></a> [auth0\_domain](#output\_auth0\_domain) | The Auth0 custom domain |
| <a name="output_client_id_ssm_path"></a> [client\_id\_ssm\_path](#output\_client\_id\_ssm\_path) | The SSM parameter path for the Auth0 client ID |
| <a name="output_client_secret_ssm_path"></a> [client\_secret\_ssm\_path](#output\_client\_secret\_ssm\_path) | The SSM parameter path for the Auth0 client secret |
| <a name="output_domain_ssm_path"></a> [domain\_ssm\_path](#output\_domain\_ssm\_path) | The SSM parameter path for the Auth0 domain |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/auth0) -
  Cloud Posse's upstream component
- [Auth0 Terraform Provider](https://registry.terraform.io/providers/auth0/auth0/latest/)
- [Auth0 Documentation](https://auth0.com/docs/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
