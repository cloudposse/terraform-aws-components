---
tags:
  - component/argocd-repo
  - layer/software-delivery
  - provider/aws
  - provider/github
---

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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.3 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 6.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_store_write"></a> [store\_write](#module\_store\_write) | cloudposse/ssm-parameter-store/aws | 0.11.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [github_branch_default.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_default) | resource |
| [github_branch_protection.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/branch_protection) | resource |
| [github_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository) | resource |
| [github_repository_deploy_key.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_deploy_key) | resource |
| [github_repository_file.application_set](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.codeowners_file](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.gitignore](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.pull_request_template](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_repository_file.readme](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_file) | resource |
| [github_team_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/team_repository) | resource |
| [tls_private_key.default](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ssm_parameter.github_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [github_repository.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/repository) | data source |
| [github_team.default](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/team) | data source |
| [github_user.automation_user](https://registry.terraform.io/providers/integrations/github/latest/docs/data-sources/user) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_repo"></a> [create\_repo](#input\_create\_repo) | Whether or not to create the repository or use an existing one | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | The description of the repository | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Environments to populate `applicationset.yaml` files and repository deploy keys (for ArgoCD) for.<br><br>`auto-sync` determines whether or not the ArgoCD application will be automatically synced.<br><br>`ignore-differences` determines whether or not the ArgoCD application will ignore the number of<br>replicas in the deployment. Read more on ignore differences here:<br>https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/#respect-ignore-difference-configs<br><br>Example:<pre>tenant: plat<br>environment: use1<br>stage: sandbox<br>auto-sync: true<br>ignore-differences:<br>  - group: apps<br>    kind: Deployment<br>    json-pointers:<br>      - /spec/replicas</pre> | <pre>list(object({<br>    tenant      = optional(string, null)<br>    environment = string<br>    stage       = string<br>    attributes  = optional(list(string), [])<br>    auto-sync   = bool<br>    ignore-differences = optional(list(object({<br>      group         = string,<br>      kind          = string,<br>      json-pointers = list(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/` | `string` | `null` | no |
| <a name="input_github_codeowner_teams"></a> [github\_codeowner\_teams](#input\_github\_codeowner\_teams) | List of teams to use when populating the CODEOWNERS file.<br><br>For example: `["@ACME/cloud-admins", "@ACME/cloud-developers"]`. | `list(string)` | n/a | yes |
| <a name="input_github_default_notifications_enabled"></a> [github\_default\_notifications\_enabled](#input\_github\_default\_notifications\_enabled) | Enable default GitHub commit statuses notifications (required for CD sync mode) | `string` | `true` | no |
| <a name="input_github_notifications"></a> [github\_notifications](#input\_github\_notifications) | ArgoCD notification annotations for subscribing to GitHub.<br><br>    The default value given uses the same notification template names as defined in the `eks/argocd` component. If want to add additional notifications, include any existing notifications from this list that you want to keep in addition. | `list(string)` | <pre>[<br>  "notifications.argoproj.io/subscribe.on-deploy-started.app-repo-github-commit-status: \"\"",<br>  "notifications.argoproj.io/subscribe.on-deploy-started.argocd-repo-github-commit-status: \"\"",<br>  "notifications.argoproj.io/subscribe.on-deploy-succeeded.app-repo-github-commit-status: \"\"",<br>  "notifications.argoproj.io/subscribe.on-deploy-succeeded.argocd-repo-github-commit-status: \"\"",<br>  "notifications.argoproj.io/subscribe.on-deploy-failed.app-repo-github-commit-status: \"\"",<br>  "notifications.argoproj.io/subscribe.on-deploy-failed.argocd-repo-github-commit-status: \"\""<br>]</pre> | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub Organization | `string` | n/a | yes |
| <a name="input_github_token_override"></a> [github\_token\_override](#input\_github\_token\_override) | Use the value of this variable as the GitHub token instead of reading it from SSM | `string` | `null` | no |
| <a name="input_github_user"></a> [github\_user](#input\_github\_user) | Github user | `string` | n/a | yes |
| <a name="input_github_user_email"></a> [github\_user\_email](#input\_github\_user\_email) | Github user email | `string` | n/a | yes |
| <a name="input_gitignore_entries"></a> [gitignore\_entries](#input\_gitignore\_entries) | List of .gitignore entries to use when populating the .gitignore file.<br><br>For example: `[".idea/", ".vscode/"]`. | `list(string)` | n/a | yes |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_manifest_kubernetes_namespace"></a> [manifest\_kubernetes\_namespace](#input\_manifest\_kubernetes\_namespace) | The namespace used for the ArgoCD application | `string` | `"argocd"` | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_permissions"></a> [permissions](#input\_permissions) | A list of Repository Permission objects used to configure the team permissions of the repository<br><br>`team_slug` should be the name of the team without the `@{org}` e.g. `@cloudposse/team` => `team`<br>`permission` is just one of the available values listed below | <pre>list(object({<br>    team_slug  = string,<br>    permission = string<br>  }))</pre> | `[]` | no |
| <a name="input_push_restrictions_enabled"></a> [push\_restrictions\_enabled](#input\_push\_restrictions\_enabled) | Enforce who can push to the main branch | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_required_pull_request_reviews"></a> [required\_pull\_request\_reviews](#input\_required\_pull\_request\_reviews) | Enforce restrictions for pull request reviews | `bool` | `true` | no |
| <a name="input_slack_notifications_channel"></a> [slack\_notifications\_channel](#input\_slack\_notifications\_channel) | If given, the Slack channel to for deployment notifications. | `string` | `""` | no |
| <a name="input_ssm_github_api_key"></a> [ssm\_github\_api\_key](#input\_ssm\_github\_api\_key) | SSM path to the GitHub API key | `string` | `"/argocd/github/api_key"` | no |
| <a name="input_ssm_github_deploy_key_format"></a> [ssm\_github\_deploy\_key\_format](#input\_ssm\_github\_deploy\_key\_format) | Format string of the SSM parameter path to which the deploy keys will be written to (%s will be replaced with the environment name) | `string` | `"/argocd/deploy_keys/%s"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_keys_ssm_path_format"></a> [deploy\_keys\_ssm\_path\_format](#output\_deploy\_keys\_ssm\_path\_format) | SSM Parameter Store path format for the repository's deploy keys |
| <a name="output_deploy_keys_ssm_paths"></a> [deploy\_keys\_ssm\_paths](#output\_deploy\_keys\_ssm\_paths) | SSM Parameter Store paths for the repository's deploy keys |
| <a name="output_repository"></a> [repository](#output\_repository) | Repository name |
| <a name="output_repository_default_branch"></a> [repository\_default\_branch](#output\_repository\_default\_branch) | Repository default branch |
| <a name="output_repository_description"></a> [repository\_description](#output\_repository\_description) | Repository description |
| <a name="output_repository_git_clone_url"></a> [repository\_git\_clone\_url](#output\_repository\_git\_clone\_url) | Repository git clone URL |
| <a name="output_repository_ssh_clone_url"></a> [repository\_ssh\_clone\_url](#output\_repository\_ssh\_clone\_url) | Repository SSH clone URL |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | Repository URL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/argocd-repo) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
