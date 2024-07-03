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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`amplify_app` | 0.2.1 | [`cloudposse/amplify-app/aws`](https://registry.terraform.io/modules/cloudposse/amplify-app/aws/0.2.1) | n/a
`certificate_verification_dns_record` | 0.12.3 | [`cloudposse/route53-cluster-hostname/aws`](https://registry.terraform.io/modules/cloudposse/route53-cluster-hostname/aws/0.12.3) | Create the SSL certificate validation record
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`subdomains_dns_record` | 0.12.3 | [`cloudposse/route53-cluster-hostname/aws`](https://registry.terraform.io/modules/cloudposse/route53-cluster-hostname/aws/0.12.3) | Create DNS records for the subdomains
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.github_pat`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

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
  <dt>`auto_branch_creation_config` <i>optional</i></dt>
  <dd>
    The automated branch creation configuration for the Amplify app<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    basic_auth_credentials        = optional(string)
    build_spec                    = optional(string)
    enable_auto_build             = optional(bool)
    enable_basic_auth             = optional(bool)
    enable_performance_mode       = optional(bool)
    enable_pull_request_preview   = optional(bool)
    environment_variables         = optional(map(string))
    framework                     = optional(string)
    pull_request_environment_name = optional(string)
    stage                         = optional(string)
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`auto_branch_creation_patterns` (`list(string)`) <i>optional</i></dt>
  <dd>
    The automated branch creation glob patterns for the Amplify app<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`basic_auth_credentials` (`string`) <i>optional</i></dt>
  <dd>
    The credentials for basic authorization for the Amplify app<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`build_spec` (`string`) <i>optional</i></dt>
  <dd>
    The [build specification](https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html) (build spec) for the Amplify app.<br/>
    If not provided then it will use the `amplify.yml` at the root of your project / branch.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`certificate_verification_dns_record_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to create DNS records for SSL certificate validation.<br/>
    If using the DNS zone from `dns-delegated`, the SSL certificate is already validated, and this variable must be set to `false`.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`custom_rules` <i>optional</i></dt>
  <dd>
    The custom rules to apply to the Amplify App<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    condition = optional(string)
    source    = string
    status    = optional(string)
    target    = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`description` (`string`) <i>optional</i></dt>
  <dd>
    The description for the Amplify app<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`dns_delegated_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The component name of `dns-delegated`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dns-delegated"`
  </dd>
  <dt>`dns_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The environment name of `dns-delegated`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`domain_config` <i>optional</i></dt>
  <dd>
    Amplify custom domain configuration<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    domain_name            = optional(string)
    enable_auto_sub_domain = optional(bool, false)
    wait_for_verification  = optional(bool, false)
    sub_domain = list(object({
      branch_name = string
      prefix      = string
    }))
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`enable_auto_branch_creation` (`bool`) <i>optional</i></dt>
  <dd>
    Enables automated branch creation for the Amplify app<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`enable_basic_auth` (`bool`) <i>optional</i></dt>
  <dd>
    Enables basic authorization for the Amplify app.<br/>
    This will apply to all branches that are part of this app.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`enable_branch_auto_build` (`bool`) <i>optional</i></dt>
  <dd>
    Enables auto-building of branches for the Amplify App<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`enable_branch_auto_deletion` (`bool`) <i>optional</i></dt>
  <dd>
    Automatically disconnects a branch in the Amplify Console when you delete a branch from your Git repository<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`environment_variables` (`map(string)`) <i>optional</i></dt>
  <dd>
    The environment variables for the Amplify app<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`environments` <i>optional</i></dt>
  <dd>
    The configuration of the environments for the Amplify App<br/>
    <br/>
    **Type:** 

    ```hcl
    map(object({
    branch_name                   = optional(string)
    backend_enabled               = optional(bool, false)
    environment_name              = optional(string)
    deployment_artifacts          = optional(string)
    stack_name                    = optional(string)
    display_name                  = optional(string)
    description                   = optional(string)
    enable_auto_build             = optional(bool)
    enable_basic_auth             = optional(bool)
    enable_notification           = optional(bool)
    enable_performance_mode       = optional(bool)
    enable_pull_request_preview   = optional(bool)
    environment_variables         = optional(map(string))
    framework                     = optional(string)
    pull_request_environment_name = optional(string)
    stage                         = optional(string)
    ttl                           = optional(number)
    webhook_enabled               = optional(bool, false)
  }))
    ```
    
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`github_personal_access_token_secret_path` (`string`) <i>optional</i></dt>
  <dd>
    Path to the GitHub personal access token in AWS Parameter Store<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/amplify/github_personal_access_token"`
  </dd>
  <dt>`iam_service_role_actions` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of IAM policy actions for the AWS Identity and Access Management (IAM) service role for the Amplify app.<br/>
    If not provided, the default set of actions will be used for the role if the variable `iam_service_role_enabled` is set to `true`.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`iam_service_role_arn` (`list(string)`) <i>optional</i></dt>
  <dd>
    The AWS Identity and Access Management (IAM) service role for the Amplify app.<br/>
    If not provided, a new role will be created if the variable `iam_service_role_enabled` is set to `true`.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`iam_service_role_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to create the IAM service role for the Amplify app<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`oauth_token` (`string`) <i>optional</i></dt>
  <dd>
    The OAuth token for a third-party source control system for the Amplify app.<br/>
    The OAuth token is used to create a webhook and a read-only deploy key.<br/>
    The OAuth token is not stored.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`platform` (`string`) <i>optional</i></dt>
  <dd>
    The platform or framework for the Amplify app<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"WEB"`
  </dd>
  <dt>`repository` (`string`) <i>optional</i></dt>
  <dd>
    The repository for the Amplify app<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`subdomains_dns_records_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to create DNS records for the Amplify app custom subdomains<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    Amplify App ARN <br/>
  </dd>
  <dt>`backend_environments`</dt>
  <dd>
    Created backend environments<br/>
  </dd>
  <dt>`branch_names`</dt>
  <dd>
    The names of the created Amplify branches<br/>
  </dd>
  <dt>`default_domain`</dt>
  <dd>
    Amplify App domain (non-custom)<br/>
  </dd>
  <dt>`domain_association_arn`</dt>
  <dd>
    ARN of the domain association<br/>
  </dd>
  <dt>`domain_association_certificate_verification_dns_record`</dt>
  <dd>
    The DNS record for certificate verification<br/>
  </dd>
  <dt>`name`</dt>
  <dd>
    Amplify App name<br/>
  </dd>
  <dt>`sub_domains`</dt>
  <dd>
    DNS records and the verified status for the subdomains<br/>
  </dd>
  <dt>`webhooks`</dt>
  <dd>
    Created webhooks<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
