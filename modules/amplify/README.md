---
tags:
  - component/amplify
  - layer/unassigned
  - provider/aws
---

# Component: `amplify`

This component is responsible for provisioning AWS Amplify apps, backend environments, branches, domain associations,
and webhooks.

## Usage

**Stack Level**: Regional

Here's an example for how to use this component:

```yaml
# stacks/catalog/amplify/defaults.yaml
components:
  terraform:
    amplify/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        # https://docs.aws.amazon.com/amplify/latest/userguide/setting-up-GitHub-access.html
        github_personal_access_token_secret_path: "/amplify/github_personal_access_token"
        platform: "WEB"
        enable_auto_branch_creation: false
        enable_basic_auth: false
        enable_branch_auto_build: true
        enable_branch_auto_deletion: false
        iam_service_role_enabled: false
        environment_variables: {}
        dns_delegated_component_name: "dns-delegated"
        dns_delegated_environment_name: "gbl"
```

```yaml
# stacks/catalog/amplify/example.yaml
import:
  - catalog/amplify/defaults

components:
  terraform:
    amplify/example:
      metadata:
        # Point to the Terraform component
        component: amplify
      inherits:
        # Inherit the default settings
        - amplify/defaults
      vars:
        name: "example"
        description: "example Amplify App"
        repository: "https://github.com/cloudposse/amplify-test2"
        platform: "WEB_COMPUTE"
        enable_auto_branch_creation: false
        enable_basic_auth: false
        enable_branch_auto_build: true
        enable_branch_auto_deletion: false
        iam_service_role_enabled: true
        # https://docs.aws.amazon.com/amplify/latest/userguide/ssr-CloudWatch-logs.html
        iam_service_role_actions:
          - "logs:CreateLogStream"
          - "logs:CreateLogGroup"
          - "logs:DescribeLogGroups"
          - "logs:PutLogEvents"
        custom_rules: []
        auto_branch_creation_patterns: []
        environment_variables:
          NEXT_PRIVATE_STANDALONE: false
          NEXT_PUBLIC_TEST: test
          _LIVE_UPDATES: '[{"pkg":"node","type":"nvm","version":"16"},{"pkg":"next-version","type":"internal","version":"13.1.1"}]'
        environments:
          main:
            branch_name: "main"
            enable_auto_build: true
            backend_enabled: false
            enable_performance_mode: false
            enable_pull_request_preview: false
            framework: "Next.js - SSR"
            stage: "PRODUCTION"
            environment_variables: {}
          develop:
            branch_name: "develop"
            enable_auto_build: true
            backend_enabled: false
            enable_performance_mode: false
            enable_pull_request_preview: false
            framework: "Next.js - SSR"
            stage: "DEVELOPMENT"
            environment_variables: {}
        domain_config:
          enable_auto_sub_domain: false
          wait_for_verification: false
          sub_domain:
            - branch_name: "main"
              prefix: "example-prod"
            - branch_name: "develop"
              prefix: "example-dev"
        subdomains_dns_records_enabled: true
        certificate_verification_dns_record_enabled: false
```

The `amplify/example` YAML configuration defines an Amplify app in AWS. The app is set up to use the `Next.js` framework
with SSR (server-side rendering) and is linked to the GitHub repository "https://github.com/cloudposse/amplify-test2".

The app is set up to have two environments: `main` and `develop`. Each environment has different configuration settings,
such as the branch name, framework, and stage. The `main` environment is set up for production, while the `develop`
environments is set up for development.

The app is also configured to have custom subdomains for each environment, with prefixes such as `example-prod` and
`example-dev`. The subdomains are configured to use DNS records, which are enabled through the
`subdomains_dns_records_enabled` variable.

The app also has an IAM service role configured with specific IAM actions, and environment variables set up for each
environment. Additionally, the app is configured to use the Atmos Spacelift workspace, as indicated by the
`workspace_enabled: true` setting.

The `amplify/example` Atmos component extends the `amplify/defaults` component.

The `amplify/example` configuration is imported into the `stacks/mixins/stage/dev.yaml` stack config file to be
provisioned in the `dev` account.

```yaml
# stacks/mixins/stage/dev.yaml
import:
  - catalog/amplify/example
```

You can execute the following command to provision the Amplify app using Atmos:

```shell
atmos terraform apply amplify/example -s <stack>
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_amplify_app"></a> [amplify\_app](#module\_amplify\_app) | cloudposse/amplify-app/aws | 0.2.1 |
| <a name="module_certificate_verification_dns_record"></a> [certificate\_verification\_dns\_record](#module\_certificate\_verification\_dns\_record) | cloudposse/route53-cluster-hostname/aws | 0.12.3 |
| <a name="module_dns_delegated"></a> [dns\_delegated](#module\_dns\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_subdomains_dns_record"></a> [subdomains\_dns\_record](#module\_subdomains\_dns\_record) | cloudposse/route53-cluster-hostname/aws | 0.12.3 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.github_pat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_auto_branch_creation_config"></a> [auto\_branch\_creation\_config](#input\_auto\_branch\_creation\_config) | The automated branch creation configuration for the Amplify app | <pre>object({<br>    basic_auth_credentials        = optional(string)<br>    build_spec                    = optional(string)<br>    enable_auto_build             = optional(bool)<br>    enable_basic_auth             = optional(bool)<br>    enable_performance_mode       = optional(bool)<br>    enable_pull_request_preview   = optional(bool)<br>    environment_variables         = optional(map(string))<br>    framework                     = optional(string)<br>    pull_request_environment_name = optional(string)<br>    stage                         = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_auto_branch_creation_patterns"></a> [auto\_branch\_creation\_patterns](#input\_auto\_branch\_creation\_patterns) | The automated branch creation glob patterns for the Amplify app | `list(string)` | `[]` | no |
| <a name="input_basic_auth_credentials"></a> [basic\_auth\_credentials](#input\_basic\_auth\_credentials) | The credentials for basic authorization for the Amplify app | `string` | `null` | no |
| <a name="input_build_spec"></a> [build\_spec](#input\_build\_spec) | The [build specification](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html) (build spec) for the Amplify app.<br>If not provided then it will use the `amplify.yml` at the root of your project / branch. | `string` | `null` | no |
| <a name="input_certificate_verification_dns_record_enabled"></a> [certificate\_verification\_dns\_record\_enabled](#input\_certificate\_verification\_dns\_record\_enabled) | Whether or not to create DNS records for SSL certificate validation.<br>If using the DNS zone from `dns-delegated`, the SSL certificate is already validated, and this variable must be set to `false`. | `bool` | `false` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_custom_rules"></a> [custom\_rules](#input\_custom\_rules) | The custom rules to apply to the Amplify App | <pre>list(object({<br>    condition = optional(string)<br>    source    = string<br>    status    = optional(string)<br>    target    = string<br>  }))</pre> | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description for the Amplify app | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_delegated_component_name"></a> [dns\_delegated\_component\_name](#input\_dns\_delegated\_component\_name) | The component name of `dns-delegated` | `string` | `"dns-delegated"` | no |
| <a name="input_dns_delegated_environment_name"></a> [dns\_delegated\_environment\_name](#input\_dns\_delegated\_environment\_name) | The environment name of `dns-delegated` | `string` | `"gbl"` | no |
| <a name="input_domain_config"></a> [domain\_config](#input\_domain\_config) | Amplify custom domain configuration | <pre>object({<br>    domain_name            = optional(string)<br>    enable_auto_sub_domain = optional(bool, false)<br>    wait_for_verification  = optional(bool, false)<br>    sub_domain = list(object({<br>      branch_name = string<br>      prefix      = string<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_enable_auto_branch_creation"></a> [enable\_auto\_branch\_creation](#input\_enable\_auto\_branch\_creation) | Enables automated branch creation for the Amplify app | `bool` | `false` | no |
| <a name="input_enable_basic_auth"></a> [enable\_basic\_auth](#input\_enable\_basic\_auth) | Enables basic authorization for the Amplify app.<br>This will apply to all branches that are part of this app. | `bool` | `false` | no |
| <a name="input_enable_branch_auto_build"></a> [enable\_branch\_auto\_build](#input\_enable\_branch\_auto\_build) | Enables auto-building of branches for the Amplify App | `bool` | `true` | no |
| <a name="input_enable_branch_auto_deletion"></a> [enable\_branch\_auto\_deletion](#input\_enable\_branch\_auto\_deletion) | Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository | `bool` | `false` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | The environment variables for the Amplify app | `map(string)` | `{}` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | The configuration of the environments for the Amplify App | <pre>map(object({<br>    branch_name                   = optional(string)<br>    backend_enabled               = optional(bool, false)<br>    environment_name              = optional(string)<br>    deployment_artifacts          = optional(string)<br>    stack_name                    = optional(string)<br>    display_name                  = optional(string)<br>    description                   = optional(string)<br>    enable_auto_build             = optional(bool)<br>    enable_basic_auth             = optional(bool)<br>    enable_notification           = optional(bool)<br>    enable_performance_mode       = optional(bool)<br>    enable_pull_request_preview   = optional(bool)<br>    environment_variables         = optional(map(string))<br>    framework                     = optional(string)<br>    pull_request_environment_name = optional(string)<br>    stage                         = optional(string)<br>    ttl                           = optional(number)<br>    webhook_enabled               = optional(bool, false)<br>  }))</pre> | `{}` | no |
| <a name="input_github_personal_access_token_secret_path"></a> [github\_personal\_access\_token\_secret\_path](#input\_github\_personal\_access\_token\_secret\_path) | Path to the GitHub personal access token in AWS Parameter Store | `string` | `"/amplify/github_personal_access_token"` | no |
| <a name="input_iam_service_role_actions"></a> [iam\_service\_role\_actions](#input\_iam\_service\_role\_actions) | List of IAM policy actions for the AWS Identity and Access Management (IAM) service role for the Amplify app.<br>If not provided, the default set of actions will be used for the role if the variable `iam_service_role_enabled` is set to `true`. | `list(string)` | `[]` | no |
| <a name="input_iam_service_role_arn"></a> [iam\_service\_role\_arn](#input\_iam\_service\_role\_arn) | The AWS Identity and Access Management (IAM) service role for the Amplify app.<br>If not provided, a new role will be created if the variable `iam_service_role_enabled` is set to `true`. | `list(string)` | `[]` | no |
| <a name="input_iam_service_role_enabled"></a> [iam\_service\_role\_enabled](#input\_iam\_service\_role\_enabled) | Flag to create the IAM service role for the Amplify app | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_oauth_token"></a> [oauth\_token](#input\_oauth\_token) | The OAuth token for a third-party source control system for the Amplify app.<br>The OAuth token is used to create a webhook and a read-only deploy key.<br>The OAuth token is not stored. | `string` | `null` | no |
| <a name="input_platform"></a> [platform](#input\_platform) | The platform or framework for the Amplify app | `string` | `"WEB"` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | The repository for the Amplify app | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_subdomains_dns_records_enabled"></a> [subdomains\_dns\_records\_enabled](#input\_subdomains\_dns\_records\_enabled) | Whether or not to create DNS records for the Amplify app custom subdomains | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amplify App ARN |
| <a name="output_backend_environments"></a> [backend\_environments](#output\_backend\_environments) | Created backend environments |
| <a name="output_branch_names"></a> [branch\_names](#output\_branch\_names) | The names of the created Amplify branches |
| <a name="output_default_domain"></a> [default\_domain](#output\_default\_domain) | Amplify App domain (non-custom) |
| <a name="output_domain_association_arn"></a> [domain\_association\_arn](#output\_domain\_association\_arn) | ARN of the domain association |
| <a name="output_domain_association_certificate_verification_dns_record"></a> [domain\_association\_certificate\_verification\_dns\_record](#output\_domain\_association\_certificate\_verification\_dns\_record) | The DNS record for certificate verification |
| <a name="output_name"></a> [name](#output\_name) | Amplify App name |
| <a name="output_sub_domains"></a> [sub\_domains](#output\_sub\_domains) | DNS records and the verified status for the subdomains |
| <a name="output_webhooks"></a> [webhooks](#output\_webhooks) | Created webhooks |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
