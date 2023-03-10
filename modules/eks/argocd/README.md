# Component: `argocd`

This component is responsible for provisioning [Argo CD](https://argoproj.github.io/cd/).

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

> :warning::warning::warning: Initial install needs run `deploy` two times because first run will create ArgoCD CRDs
> and second run will finish ArgoCD configuration. :warning::warning::warning:

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    argocd:
      settings:
        spacelift:
          workspace_enabled: true
          depends_on:
            - argocd-applicationset
            - tenant-gbl-corp-argocd-depoy-non-prod
      vars:
        enabled: true
        alb_group_name: argocd
        alb_name: argocd
        alb_logs_prefix: argocd
        certificate_issuer: selfsigning-issuer
        github_organization: MyOrg
        oidc_enabled: false
        saml_enabled: true
        ssm_store_account: corp
        ssm_store_account_region: us-west-2
        saml_admin_role: ArgoCD-non-prod-admin
        saml_readonly_role: ArgoCD-non-prod-observer
        argocd_repo_name: argocd-deploy-non-prod
        chart_values: {}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.config_secrets"></a> [aws.config\_secrets](#provider\_aws.config\_secrets) | >= 4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | cloudposse/helm-release/aws | 0.3.0 |
| <a name="module_argocd_apps"></a> [argocd\_apps](#module\_argocd\_apps) | cloudposse/helm-release/aws | 0.3.0 |
| <a name="module_argocd_repo"></a> [argocd\_repo](#module\_argocd\_repo) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_dns_gbl_delegated"></a> [dns\_gbl\_delegated](#module\_dns\_gbl\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_config_secrets"></a> [iam\_roles\_config\_secrets](#module\_iam\_roles\_config\_secrets) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_saml_sso_providers"></a> [saml\_sso\_providers](#module\_saml\_sso\_providers) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.kubernetes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_eks_cluster_auth.kubernetes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_ssm_parameter.github_deploy_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.oidc_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.oidc_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameters_by_path.argocd_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) | data source |
| [kubernetes_resources.crd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Toggles Admin user creation the deployed chart | `bool` | `false` | no |
| <a name="input_alb_group_name"></a> [alb\_group\_name](#input\_alb\_group\_name) | A name used in annotations to reuse an ALB (e.g. `argocd`) or to generate a new one | `string` | `null` | no |
| <a name="input_alb_logs_bucket"></a> [alb\_logs\_bucket](#input\_alb\_logs\_bucket) | The name of the bucket for ALB access logs. The bucket must have policy allowing the ELB logging principal | `string` | `""` | no |
| <a name="input_alb_logs_prefix"></a> [alb\_logs\_prefix](#input\_alb\_logs\_prefix) | `alb_logs_bucket` s3 bucket prefix | `string` | `""` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The name of the ALB (e.g. `argocd`) provisioned by `alb-controller`. Works together with `var.alb_group_name` | `string` | `null` | no |
| <a name="input_argo_enable_workflows_auth"></a> [argo\_enable\_workflows\_auth](#input\_argo\_enable\_workflows\_auth) | Allow argo-workflows to use Dex instance for SAML auth | `bool` | `false` | no |
| <a name="input_argo_workflows_name"></a> [argo\_workflows\_name](#input\_argo\_workflows\_name) | Name of argo-workflows instance | `string` | `"argo-workflows"` | no |
| <a name="input_argocd_apps_chart"></a> [argocd\_apps\_chart](#input\_argocd\_apps\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | `"argocd-apps"` | no |
| <a name="input_argocd_apps_chart_description"></a> [argocd\_apps\_chart\_description](#input\_argocd\_apps\_chart\_description) | Set release description attribute (visible in the history). | `string` | `"A Helm chart for managing additional Argo CD Applications and Projects"` | no |
| <a name="input_argocd_apps_chart_repository"></a> [argocd\_apps\_chart\_repository](#input\_argocd\_apps\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | `"https://argoproj.github.io/argo-helm"` | no |
| <a name="input_argocd_apps_chart_version"></a> [argocd\_apps\_chart\_version](#input\_argocd\_apps\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `"0.0.3"` | no |
| <a name="input_argocd_apps_enabled"></a> [argocd\_apps\_enabled](#input\_argocd\_apps\_enabled) | Enable argocd apps | `bool` | `true` | no |
| <a name="input_argocd_create_namespaces"></a> [argocd\_create\_namespaces](#input\_argocd\_create\_namespaces) | ArgoCD create namespaces policy | `bool` | `false` | no |
| <a name="input_argocd_rbac_default_policy"></a> [argocd\_rbac\_default\_policy](#input\_argocd\_rbac\_default\_policy) | Default ArgoCD RBAC default role.<br><br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#basic-built-in-roles for more information. | `string` | `"role:readonly"` | no |
| <a name="input_argocd_rbac_groups"></a> [argocd\_rbac\_groups](#input\_argocd\_rbac\_groups) | List of ArgoCD Group Role Assignment strings to be added to the argocd-rbac configmap policy.csv item.<br>e.g.<br>[<br>  {<br>    group: idp-group-name,<br>    role: argocd-role-name<br>  },<br>]<br>becomes: `g, idp-group-name, role:argocd-role-name`<br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information. | <pre>list(object({<br>    group = string,<br>    role  = string<br>  }))</pre> | `[]` | no |
| <a name="input_argocd_rbac_policies"></a> [argocd\_rbac\_policies](#input\_argocd\_rbac\_policies) | List of ArgoCD RBAC Permission strings to be added to the argocd-rbac configmap policy.csv item.<br><br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information. | `list(string)` | `[]` | no |
| <a name="input_argocd_repositories"></a> [argocd\_repositories](#input\_argocd\_repositories) | Map of objects defining an `argocd_repo` to configure.  The key is the name of the ArgoCD repository. | <pre>map(object({<br>    environment = string # The environment where the `argocd_repo` component is deployed.<br>    stage       = string # The stage where the `argocd_repo` component is deployed.<br>    tenant      = string # The tenant where the `argocd_repo` component is deployed.<br>  }))</pre> | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_certificate_issuer"></a> [certificate\_issuer](#input\_certificate\_issuer) | Certificate manager cluster issuer | `string` | `"letsencrypt-staging"` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | `"argo-cd"` | no |
| <a name="input_chart_description"></a> [chart\_description](#input\_chart\_description) | Set release description attribute (visible in the history). | `string` | `null` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | `"https://argoproj.github.io/argo-helm"` | no |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `"5.19.12"` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails. | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_datadog_notifications_enabled"></a> [datadog\_notifications\_enabled](#input\_datadog\_notifications\_enabled) | Whether or not to notify Datadog of deployments via the Datadog Events API. | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_forecastle_enabled"></a> [forecastle\_enabled](#input\_forecastle\_enabled) | Toggles Forecastle integration in the deployed chart | `bool` | `false` | no |
| <a name="input_github_notifications_enabled"></a> [github\_notifications\_enabled](#input\_github\_notifications\_enabled) | Whether or not to enable GitHub deployment and commit status notifications. | `bool` | `false` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub Organization | `string` | n/a | yes |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `true` | no |
| <a name="input_host"></a> [host](#input\_host) | Host name to use for ingress and ALB | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_import_role_arn"></a> [import\_role\_arn](#input\_import\_role\_arn) | IAM Role ARN to use when importing a resource | `string` | `null` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes kube config file | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | The namespace to install the release into. | `string` | `"argocd"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_notifications_default_triggers"></a> [notifications\_default\_triggers](#input\_notifications\_default\_triggers) | Default notification Triggers to configure.<br><br>See: https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/triggers/#default-triggers<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/790438efebf423c2d56cb4b93471f4adb3fcd448/charts/argo-cd/values.yaml#L2841) | `map(list(string))` | `{}` | no |
| <a name="input_notifications_notifiers"></a> [notifications\_notifiers](#input\_notifications\_notifiers) | Notification Triggers to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352) | <pre>object({<br>    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")<br>    service_github = optional(object({<br>      appID          = optional(number)<br>      installationID = optional(number)<br>      privateKey     = optional(string)<br>    }))<br>  })</pre> | `{}` | no |
| <a name="input_notifications_templates"></a> [notifications\_templates](#input\_notifications\_templates) | Notification Templates to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/templates/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158) | <pre>map(object({<br>    message = string<br>    alertmanager = optional(object({<br>      labels       = map(string)<br>      annotations  = map(string)<br>      generatorURL = string<br>    }))<br>    github = optional(object({<br>      status = object({<br>        state     = string<br>        label     = string<br>        targetURL = string<br>      })<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_notifications_triggers"></a> [notifications\_triggers](#input\_notifications\_triggers) | Notification Triggers to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352) | <pre>map(list(<br>    object({<br>      oncePer = optional(string)<br>      send    = list(string)<br>      when    = string<br>    })<br>  ))</pre> | `{}` | no |
| <a name="input_oidc_enabled"></a> [oidc\_enabled](#input\_oidc\_enabled) | Toggles OIDC integration in the deployed chart | `bool` | `false` | no |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | OIDC issuer URL | `string` | `""` | no |
| <a name="input_oidc_name"></a> [oidc\_name](#input\_oidc\_name) | Name of the OIDC resource | `string` | `""` | no |
| <a name="input_oidc_rbac_scopes"></a> [oidc\_rbac\_scopes](#input\_oidc\_rbac\_scopes) | OIDC RBAC scopes to request | `string` | `"[argocd_realm_access]"` | no |
| <a name="input_oidc_requested_scopes"></a> [oidc\_requested\_scopes](#input\_oidc\_requested\_scopes) | Set of OIDC scopes to request | `string` | `"[\"openid\", \"profile\", \"email\", \"groups\"]"` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Enable Service Account for pods. | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | The cpu and memory of the deployment's limits and requests. | <pre>object({<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_saml_enabled"></a> [saml\_enabled](#input\_saml\_enabled) | Toggles SAML integration in the deployed chart | `bool` | `false` | no |
| <a name="input_saml_okta_app_name"></a> [saml\_okta\_app\_name](#input\_saml\_okta\_app\_name) | Name of the Okta SAML Integration | `string` | `"ArgoCD"` | no |
| <a name="input_saml_rbac_scopes"></a> [saml\_rbac\_scopes](#input\_saml\_rbac\_scopes) | SAML RBAC scopes to request | `string` | `"[email,groups]"` | no |
| <a name="input_saml_sso_providers"></a> [saml\_sso\_providers](#input\_saml\_sso\_providers) | SAML SSO providers components | <pre>map(object({<br>    component = string<br>  }))</pre> | `{}` | no |
| <a name="input_slack_notifications_enabled"></a> [slack\_notifications\_enabled](#input\_slack\_notifications\_enabled) | Whether or not to enable Slack notifications. | `bool` | `false` | no |
| <a name="input_slack_notifications_icon"></a> [slack\_notifications\_icon](#input\_slack\_notifications\_icon) | URI of custom image to use as the Slack notifications icon. | `string` | `null` | no |
| <a name="input_slack_notifications_username"></a> [slack\_notifications\_username](#input\_slack\_notifications\_username) | Custom username to use for Slack notifications. | `string` | `null` | no |
| <a name="input_ssm_oidc_client_id"></a> [ssm\_oidc\_client\_id](#input\_ssm\_oidc\_client\_id) | The SSM Parameter Store path for the ID of the IdP client | `string` | `"/argocd/oidc/client_id"` | no |
| <a name="input_ssm_oidc_client_secret"></a> [ssm\_oidc\_client\_secret](#input\_ssm\_oidc\_client\_secret) | The SSM Parameter Store path for the secret of the IdP client | `string` | `"/argocd/oidc/client_secret"` | no |
| <a name="input_ssm_store_account"></a> [ssm\_store\_account](#input\_ssm\_store\_account) | Account storing SSM parameters | `string` | n/a | yes |
| <a name="input_ssm_store_account_region"></a> [ssm\_store\_account\_region](#input\_ssm\_store\_account\_region) | AWS region storing SSM parameters | `string` | n/a | yes |
| <a name="input_ssm_store_account_tenant"></a> [ssm\_store\_account\_tenant](#input\_ssm\_store\_account\_tenant) | Tenant of the account storing SSM parameters.<br><br>If the tenant label is not used, leave this as null. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `300` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed release |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [Argo CD](https://argoproj.github.io/cd/)
- [Argo CD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [Argo Helm Chart](https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
