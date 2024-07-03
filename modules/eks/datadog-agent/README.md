# Component: `datadog-agent`

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
[datadogs docs](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/?tab=helm#configuration-from-static-configuration-files)
for `<integration name>.yaml`.

#### Sample Yaml

:::caution The key of a filename must match datadog docs, which is `<INTEGRATION_NAME>.yaml`
[Datadog Cluster Checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/?tab=helm#configuration-from-static-configuration-files)
:::

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


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`helm`](https://registry.terraform.io/modules/helm/>= 2.7), version: >= 2.7
- [`kubernetes`](https://registry.terraform.io/modules/kubernetes/>= 2.14.0, != 2.21.0), version: >= 2.14.0, != 2.21.0
- [`utils`](https://registry.terraform.io/modules/utils/>= 1.10.0), version: >= 1.10.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`datadog_agent` | 0.10.0 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.0) | n/a
`datadog_cluster_check_yaml_config` | 1.0.2 | [`cloudposse/config/yaml`](https://registry.terraform.io/modules/cloudposse/config/yaml/1.0.2) | n/a
`datadog_configuration` | latest | [`../../datadog-configuration/modules/datadog_keys`](https://registry.terraform.io/modules/../../datadog-configuration/modules/datadog_keys/) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`values_merge` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)

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
  <dt>`chart` (`string`) <i>required</i></dt>
  <dd>
    Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`kubernetes_namespace` (`string`) <i>required</i></dt>
  <dd>
    Kubernetes namespace to install the release into<br/>

    **Type:** `string`
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
  <dt>`atomic` (`bool`) <i>optional</i></dt>
  <dd>
    If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`chart_version` (`string`) <i>optional</i></dt>
  <dd>
    Specify the exact chart version to install. If this is not specified, the latest version is installed<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`cleanup_on_fail` (`bool`) <i>optional</i></dt>
  <dd>
    Allow deletion of new resources created in this upgrade when upgrade fails<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`cluster_checks_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable Cluster Checks for the Datadog Agent<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`create_namespace` (`bool`) <i>optional</i></dt>
  <dd>
    Create the Kubernetes namespace if it does not yet exist<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`datadog_cluster_check_auto_added_tags` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of tags to add to Datadog Cluster Check<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "stage",
      "environment"
    ]
    ```
    
  </dd>
  <dt>`datadog_cluster_check_config_parameters` (`map(any)`) <i>optional</i></dt>
  <dd>
    Map of parameters to Datadog Cluster Check configurations<br/>
    <br/>
    **Type:** `map(any)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`datadog_cluster_check_config_paths` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of paths to Datadog Cluster Check configurations<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`datadog_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    List of static tags to attach to every metric, event and service check collected by the agent<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`description` (`string`) <i>optional</i></dt>
  <dd>
    Release description attribute (visible in the history)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`eks_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the EKS component. Used to get the remote state<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"eks/eks"`
  </dd>
  <dt>`helm_manifest_experiment_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`kube_data_auth_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br/>
    Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`kube_exec_auth_aws_profile` (`string`) <i>optional</i></dt>
  <dd>
    The AWS config profile for `aws eks get-token` to use<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kube_exec_auth_aws_profile_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`kube_exec_auth_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br/>
    Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`kube_exec_auth_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    The role ARN for `aws eks get-token` to use<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kube_exec_auth_role_arn_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`kubeconfig_context` (`string`) <i>optional</i></dt>
  <dd>
    Context to choose from the Kubernetes config file.<br/>
    If supplied, `kubeconfig_context_format` will be ignored.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kubeconfig_context_format` (`string`) <i>optional</i></dt>
  <dd>
    A format string to use for creating the `kubectl` context name when<br/>
    `kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br/>
    Must include a single `%s` which will be replaced with the cluster name.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kubeconfig_exec_auth_api_version` (`string`) <i>optional</i></dt>
  <dd>
    The Kubernetes API version of the credentials returned by the `exec` auth plugin<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"client.authentication.k8s.io/v1beta1"`
  </dd>
  <dt>`kubeconfig_file` (`string`) <i>optional</i></dt>
  <dd>
    The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`kubeconfig_file_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`repository` (`string`) <i>optional</i></dt>
  <dd>
    Repository URL where to locate the requested chart<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`timeout` (`number`) <i>optional</i></dt>
  <dd>
    Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`values` (`any`) <i>optional</i></dt>
  <dd>
    Additional values to yamlencode as `helm_release` values.<br/>
    <br/>
    **Type:** `any`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`verify` (`bool`) <i>optional</i></dt>
  <dd>
    Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`wait` (`bool`) <i>optional</i></dt>
  <dd>
    Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `null`
  </dd></dl>


### Outputs

<dl>
  <dt>`cluster_checks`</dt>
  <dd>
    Cluster Checks for the cluster<br/>
  </dd>
  <dt>`metadata`</dt>
  <dd>
    Block status of the deployed release<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- Datadog's [Kubernetes Agent documentation](https://docs.datadoghq.com/containers/kubernetes/)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/datadog-agent) -
  Cloud Posse's upstream component
