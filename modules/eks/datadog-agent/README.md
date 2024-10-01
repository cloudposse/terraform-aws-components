---
tags:
  - component/eks/datadog-agent
  - layer/datadog
  - provider/aws
  - provider/helm
  - provider/datadog
---

# Component: `eks/datadog-agent`

This component installs the `datadog-agent` for EKS clusters.

## Usage

**Stack Level**: Regional

Use this in the catalog as default values.

```yaml
components:
  terraform:
    datadog-agent:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        eks_component_name: eks/cluster
        name: "datadog"
        description: "Datadog Kubernetes Agent"
        kubernetes_namespace: "monitoring"
        create_namespace: true
        repository: "https://helm.datadoghq.com"
        chart: "datadog"
        chart_version: "3.29.2"
        timeout: 1200
        wait: true
        atomic: true
        cleanup_on_fail: true
        cluster_checks_enabled: false
        helm_manifest_experiment_enabled: false
        secrets_store_type: SSM
        tags:
          team: sre
          service: datadog-agent
          app: monitoring
        # datadog-agent shouldn't be deployed to the Fargate nodes
        values:
          agents:
            affinity:
              nodeAffinity:
                requiredDuringSchedulingIgnoredDuringExecution:
                  nodeSelectorTerms:
                    - matchExpressions:
                        - key: eks.amazonaws.com/compute-type
                          operator: NotIn
                          values:
                            - fargate
          datadog:
            env:
              - name: DD_EC2_PREFER_IMDSV2 # this merges ec2 instances and the node in the hostmap section
                value: "true"
```

Deploy this to a particular environment such as dev, prod, etc.

This will add cluster checks to a specific environment.

```yaml
components:
  terraform:
    datadog-agent:
      vars:
        # Order affects merge order. Later takes priority. We append lists though.
        datadog_cluster_check_config_paths:
          - catalog/cluster-checks/defaults/*.yaml
          - catalog/cluster-checks/dev/*.yaml
        datadog_cluster_check_config_parameters: {}
        # add additional tags to all data coming in from this agent.
        datadog_tags:
          - "env:dev"
          - "region:us-west-2"
          - "stage:dev"
```

## Cluster Checks

Cluster Checks are configurations that allow us to setup external URLs to be monitored. They can be configured through
the datadog agent or annotations on kubernetes services.

Cluster Checks are similar to synthetics checks, they are not as indepth, but significantly cheaper. Use Cluster Checks
when you need a simple health check beyond the kubernetes pod health check.

Public addresses that test endpoints must use the agent configuration, whereas service addresses internal to the cluster
can be tested by annotations.

### Adding Cluster Checks

Cluster Checks can be enabled or disabled via the `cluster_checks_enabled` variable. We recommend this be set to true.

New Cluster Checks can be added to defaults to be applied in every account. Alternatively they can be placed in an
individual stage folder which will be applied to individual stages. This is controlled by the
`datadog_cluster_check_config_parameters` variable, which determines the paths of yaml files to look for cluster checks
per stage.

Once they are added, and properly configured, the new checks show up in the network monitor creation under `ssl` and
`Http`

**Please note:** the yaml file name doesn't matter, but the root key inside which is `something.yaml` does matter. this
is following
[datadog's docs](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/?tab=helm#configuration-from-static-configuration-files)
for `<integration name>.yaml`.

#### Sample Yaml

> [!WARNING]
>
> The key of a filename must match datadog docs, which is `<INTEGRATION_NAME>.yaml` >
> [Datadog Cluster Checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/?tab=helm#configuration-from-static-configuration-files)

Cluster Checks **can** be used for external URL testing (loadbalancer endpoints), whereas annotations **must** be used
for kubernetes services.

```
http_check.yaml:
  cluster_check: true
  init_config:
  instances:
    - name: "[${stage}] Echo Server"
      url: "https://echo.${stage}.uw2.acme.com"
    - name: "[${stage}] Portal"
      url: "https://portal.${stage}.uw2.acme.com"
    - name: "[${stage}] ArgoCD"
      url: "https://argocd.${stage}.uw2.acme.com"

```

### Monitoring Cluster Checks

Using Cloudposse's `datadog-monitor` component. The following yaml snippet will monitor all HTTP Cluster Checks, this
can be added to each stage (usually via a defaults folder).

```yaml
https-checks:
  name: "(Network Check) ${stage} - HTTPS Check"
  type: service check
  query: |
    "http.can_connect".over("stage:${stage}").by("instance").last(2).count_by_status()
  message: |
    HTTPS Check failed on <code>{{instance.name}}</code>
      in Stage: <code>{{stage.name}}</code>
  escalation_message: ""
  tags:
    managed-by: Terraform
  notify_no_data: false
  notify_audit: false
  require_full_window: true
  enable_logs_sample: false
  force_delete: true
  include_tags: true
  locked: false
  renotify_interval: 0
  timeout_h: 0
  evaluation_delay: 0
  new_host_delay: 0
  new_group_delay: 0
  no_data_timeframe: 2
  threshold_windows: {}
  thresholds:
    critical: 1
    warning: 1
    ok: 1
```

## References

- https://github.com/DataDog/helm-charts/tree/main/charts/datadog
- https://github.com/DataDog/helm-charts/blob/main/charts/datadog/values.yaml
- https://github.com/DataDog/helm-charts/blob/main/examples/datadog/agent_basic_values.yaml
- https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release
- https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/?tab=helm

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.7 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.14.0, != 2.21.0 |
| <a name="requirement_utils"></a> [utils](#requirement\_utils) | >= 1.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_datadog_agent"></a> [datadog\_agent](#module\_datadog\_agent) | cloudposse/helm-release/aws | 0.10.0 |
| <a name="module_datadog_cluster_check_yaml_config"></a> [datadog\_cluster\_check\_yaml\_config](#module\_datadog\_cluster\_check\_yaml\_config) | cloudposse/config/yaml | 1.0.2 |
| <a name="module_datadog_configuration"></a> [datadog\_configuration](#module\_datadog\_configuration) | ../../datadog-configuration/modules/datadog_keys | n/a |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_values_merge"></a> [values\_merge](#module\_values\_merge) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended | `string` | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `true` | no |
| <a name="input_cluster_checks_enabled"></a> [cluster\_checks\_enabled](#input\_cluster\_checks\_enabled) | Enable Cluster Checks for the Datadog Agent | `bool` | `false` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the Kubernetes namespace if it does not yet exist | `bool` | `true` | no |
| <a name="input_datadog_cluster_check_auto_added_tags"></a> [datadog\_cluster\_check\_auto\_added\_tags](#input\_datadog\_cluster\_check\_auto\_added\_tags) | List of tags to add to Datadog Cluster Check | `list(string)` | <pre>[<br>  "stage",<br>  "environment"<br>]</pre> | no |
| <a name="input_datadog_cluster_check_config_parameters"></a> [datadog\_cluster\_check\_config\_parameters](#input\_datadog\_cluster\_check\_config\_parameters) | Map of parameters to Datadog Cluster Check configurations | `map(any)` | `{}` | no |
| <a name="input_datadog_cluster_check_config_paths"></a> [datadog\_cluster\_check\_config\_paths](#input\_datadog\_cluster\_check\_config\_paths) | List of paths to Datadog Cluster Check configurations | `list(string)` | `[]` | no |
| <a name="input_datadog_tags"></a> [datadog\_tags](#input\_datadog\_tags) | List of static tags to attach to every metric, event and service check collected by the agent | `set(string)` | `[]` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_description"></a> [description](#input\_description) | Release description attribute (visible in the history) | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the EKS component. Used to get the remote state | `string` | `"eks/eks"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes config file.<br>If supplied, `kubeconfig_context_format` will be ignored. | `string` | `""` | no |
| <a name="input_kubeconfig_context_format"></a> [kubeconfig\_context\_format](#input\_kubeconfig\_context\_format) | A format string to use for creating the `kubectl` context name when<br>`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br>Must include a single `%s` which will be replaced with the cluster name. | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | Kubernetes namespace to install the release into | `string` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_repository"></a> [repository](#input\_repository) | Repository URL where to locate the requested chart | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `null` | no |
| <a name="input_values"></a> [values](#input\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_verify"></a> [verify](#input\_verify) | Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart | `bool` | `false` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true` | `bool` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_checks"></a> [cluster\_checks](#output\_cluster\_checks) | Cluster Checks for the cluster |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed release |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- Datadog's [Kubernetes Agent documentation](https://docs.datadoghq.com/containers/kubernetes/)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/datadog-agent) -
  Cloud Posse's upstream component
