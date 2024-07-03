# Component: `argocd-repo`

This component is responsible for creating and managing an ArgoCD desired state repository.

## Usage

**Stack Level**: Regional

The following are example snippets of how to use this component:

```yaml
# stacks/argocd/repo/default.yaml
components:
  terraform:
    argocd-repo:
      vars:
        enabled: true
        github_user: ci-acme
        github_user_email: ci@acme.com
        github_organization: ACME
        github_codeowner_teams:
          - "@ACME/cloud-admins"
          - "@ACME/cloud-posse"
        # the team must be present in the org where the repository lives
        # team_slug is the name of the team without the org
        # e.g. `@cloudposse/engineering` is just `engineering`
        permissions:
          - team_slug: admins
            permission: admin
          - team_slug: bots
            permission: admin
          - team_slug: engineering
            permission: push
```

```yaml
# stacks/argocd/repo/non-prod.yaml
import:
  - catalog/argocd/repo/defaults

components:
  terraform:
    argocd-deploy-non-prod:
      component: argocd-repo
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        name: argocd-deploy-non-prod
        description: "ArgoCD desired state repository (Non-production) for ACME applications"
        environments:
          - tenant: mgmt
            environment: uw2
            stage: sandbox
```

```yaml
# stacks/mgmt-gbl-corp.yaml
import:
---
- catalog/argocd/repo/non-prod
```

If the repository already exists, it will need to be imported (replace names of IAM profile var file accordingly):

```bash
$ export TF_VAR_github_token_override=[REDACTED]
$ atmos terraform varfile argocd-deploy-non-prod -s mgmt-gbl-corp
$ cd components/terraform/argocd-repo
$ terraform import -var "import_profile_name=eg-mgmt-gbl-corp-admin" -var-file="mgmt-gbl-corp-argocd-deploy-non-prod.terraform.tfvars.json" "github_repository.default[0]" argocd-deploy-non-prod
$ atmos terraform varfile argocd-deploy-non-prod -s mgmt-gbl-corp
$ cd components/terraform/argocd-repo
$ terraform import -var "import_profile_name=eg-mgmt-gbl-corp-admin" -var-file="mgmt-gbl-corp-argocd-deploy-non-prod.terraform.tfvars.json" "github_branch.default[0]" argocd-deploy-non-prod:main
$ cd components/terraform/argocd-repo
$ terraform import -var "import_profile_name=eg-mgmt-gbl-corp-admin" -var-file="mgmt-gbl-corp-argocd-deploy-non-prod.terraform.tfvars.json" "github_branch_default.default[0]" argocd-deploy-non-prod
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`github`](https://registry.terraform.io/modules/github/>= 4.0), version: >= 4.0
- [`random`](https://registry.terraform.io/modules/random/>= 2.3), version: >= 2.3
- [`tls`](https://registry.terraform.io/modules/tls/>= 3.0), version: >= 3.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0
- `github`, version: >= 4.0
- `tls`, version: >= 3.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`store_write` | 0.11.0 | [`cloudposse/ssm-parameter-store/aws`](https://registry.terraform.io/modules/cloudposse/ssm-parameter-store/aws/0.11.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`github_branch_default.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) (resource)
  - [`github_branch_protection.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) (resource)
  - [`github_repository.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) (resource)
  - [`github_repository_deploy_key.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) (resource)
  - [`github_repository_file.application_set`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
  - [`github_repository_file.codeowners_file`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
  - [`github_repository_file.gitignore`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
  - [`github_repository_file.pull_request_template`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
  - [`github_repository_file.readme`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) (resource)
  - [`github_team_repository.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) (resource)
  - [`tls_private_key.default`](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.github_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`github_repository.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) (data source)
  - [`github_team.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) (data source)
  - [`github_user.automation_user`](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) (data source)

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
  <dt>`github_codeowner_teams` (`list(string)`) <i>required</i></dt>
  <dd>
    List of teams to use when populating the CODEOWNERS file.<br/>
    <br/>
    For example: `["@ACME/cloud-admins", "@ACME/cloud-developers"]`.<br/>
    <br/>

    **Type:** `list(string)`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`github_organization` (`string`) <i>required</i></dt>
  <dd>
    GitHub Organization<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`github_user` (`string`) <i>required</i></dt>
  <dd>
    Github user<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`github_user_email` (`string`) <i>required</i></dt>
  <dd>
    Github user email<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`gitignore_entries` (`list(string)`) <i>required</i></dt>
  <dd>
    List of .gitignore entries to use when populating the .gitignore file.<br/>
    <br/>
    For example: `[".idea/", ".vscode/"]`.<br/>
    <br/>

    **Type:** `list(string)`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`create_repo` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to create the repository or use an existing one<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`description` (`string`) <i>optional</i></dt>
  <dd>
    The description of the repository<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`environments` <i>optional</i></dt>
  <dd>
    Environments to populate `applicationset.yaml` files and repository deploy keys (for ArgoCD) for.<br/>
    <br/>
    `auto-sync` determines whether or not the ArgoCD application will be automatically synced.<br/>
    <br/>
    `ignore-differences` determines whether or not the ArgoCD application will ignore the number of<br/>
    replicas in the deployment. Read more on ignore differences here:<br/>
    https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs<br/>
    <br/>
    Example:<br/>
    ```<br/>
    tenant: plat<br/>
    environment: use1<br/>
    stage: sandbox<br/>
    auto-sync: true<br/>
    ignore-differences:<br/>
      - group: apps<br/>
        kind: Deployment<br/>
        json-pointers:<br/>
          - /spec/replicas<br/>
    ```<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    tenant      = optional(string, null)
    environment = string
    stage       = string
    attributes  = optional(list(string), [])
    auto-sync   = bool
    ignore-differences = optional(list(object({
      group         = string,
      kind          = string,
      json-pointers = list(string)
    })), [])
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`github_base_url` (`string`) <i>optional</i></dt>
  <dd>
    This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`github_default_notifications_enabled` (`string`) <i>optional</i></dt>
  <dd>
    Enable default GitHub commit statuses notifications (required for CD sync mode)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`github_notifications` (`list(string)`) <i>optional</i></dt>
  <dd>
        ArgoCD notification annotations for subscribing to GitHub.<br/>
    <br/>
        The default value given uses the same notification template names as defined in the `eks/argocd` component. If want to add additional notifications, include any existing notifications from this list that you want to keep in addition.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "notifications.argoproj.io/subscribe.on-deploy-started.app-repo-github-commit-status: \"\"",
      "notifications.argoproj.io/subscribe.on-deploy-started.argocd-repo-github-commit-status: \"\"",
      "notifications.argoproj.io/subscribe.on-deploy-succeded.app-repo-github-commit-status: \"\"",
      "notifications.argoproj.io/subscribe.on-deploy-succeded.argocd-repo-github-commit-status: \"\"",
      "notifications.argoproj.io/subscribe.on-deploy-failed.app-repo-github-commit-status: \"\"",
      "notifications.argoproj.io/subscribe.on-deploy-failed.argocd-repo-github-commit-status: \"\""
    ]
    ```
    
  </dd>
  <dt>`github_token_override` (`string`) <i>optional</i></dt>
  <dd>
    Use the value of this variable as the GitHub token instead of reading it from SSM<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`manifest_kubernetes_namespace` (`string`) <i>optional</i></dt>
  <dd>
    The namespace used for the ArgoCD application<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"argocd"`
  </dd>
  <dt>`permissions` <i>optional</i></dt>
  <dd>
    A list of Repository Permission objects used to configure the team permissions of the repository<br/>
    <br/>
    `team_slug` should be the name of the team without the `@{org}` e.g. `@cloudposse/team` => `team`<br/>
    `permission` is just one of the available values listed below<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    team_slug  = string,
    permission = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`push_restrictions_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enforce who can push to the main branch<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`required_pull_request_reviews` (`bool`) <i>optional</i></dt>
  <dd>
    Enforce restrictions for pull request reviews<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`slack_notifications_channel` (`string`) <i>optional</i></dt>
  <dd>
    If given, the Slack channel to for deployment notifications.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`ssm_github_api_key` (`string`) <i>optional</i></dt>
  <dd>
    SSM path to the GitHub API key<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/argocd/github/api_key"`
  </dd>
  <dt>`ssm_github_deploy_key_format` (`string`) <i>optional</i></dt>
  <dd>
    Format string of the SSM parameter path to which the deploy keys will be written to (%s will be replaced with the environment name)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/argocd/deploy_keys/%s"`
  </dd></dl>


### Outputs

<dl>
  <dt>`deploy_keys_ssm_path_format`</dt>
  <dd>
    SSM Parameter Store path format for the repository's deploy keys<br/>
  </dd>
  <dt>`deploy_keys_ssm_paths`</dt>
  <dd>
    SSM Parameter Store paths for the repository's deploy keys<br/>
  </dd>
  <dt>`repository`</dt>
  <dd>
    Repository name<br/>
  </dd>
  <dt>`repository_default_branch`</dt>
  <dd>
    Repository default branch<br/>
  </dd>
  <dt>`repository_description`</dt>
  <dd>
    Repository description<br/>
  </dd>
  <dt>`repository_git_clone_url`</dt>
  <dd>
    Repository git clone URL<br/>
  </dd>
  <dt>`repository_ssh_clone_url`</dt>
  <dd>
    Repository SSH clone URL<br/>
  </dd>
  <dt>`repository_url`</dt>
  <dd>
    Repository URL<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/argocd-repo) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
