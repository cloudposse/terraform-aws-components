# Component: `eks/prometheus-scraper`

This component provisions the an Amazon Managed collector or scraper to connect Amazon Managed Prometheus (AMP) with an
EKS cluster.

A common use case for Amazon Managed Service for Prometheus is to monitor Kubernetes clusters managed by Amazon Elastic
Kubernetes Service (Amazon EKS). Kubernetes clusters, and many applications that run within Amazon EKS, automatically
export their metrics for Prometheus-compatible scrapers to access.

Amazon Managed Service for Prometheus provides a fully managed, agentless scraper, or collector, that automatically
discovers and pulls Prometheus-compatible metrics. You don't have to manage, install, patch, or maintain agents or
scrapers. An Amazon Managed Service for Prometheus collector provides reliable, stable, highly available, automatically
scaled collection of metrics for your Amazon EKS cluster. Amazon Managed Service for Prometheus managed collectors work
with Amazon EKS clusters, including EC2 and Fargate.

An Amazon Managed Service for Prometheus collector creates an Elastic Network Interface (ENI) per subnet specified when
creating the scraper. The collector scrapes the metrics through these ENIs, and uses remote_write to push the data to
your Amazon Managed Service for Prometheus workspace using a VPC endpoint. The scraped data never travels on the public
internet.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    eks/prometheus-scraper:
      vars:
        enabled: true
        name: prometheus-scraper
        # This refers to the `managed-prometheus/workspace` Terraform component,
        # but the component name can be whatever you choose to name the stack component
        prometheus_component_name: prometheus
```

### Authenticating with EKS

In order for this managed collector to authenticate with the EKS cluster, update auth map after deploying.

Note the `scraper_role_arn` and `clusterrole_username` outputs and set them to `rolearn` and `username` respectively
with the `map_additional_iam_roles` input for `eks/cluster`.

```yaml
components:
  terraform:
    eks/cluster:
      vars:
        map_additional_iam_roles:
          # this role is used to grant the Prometheus scraper access to this cluster. See eks/prometheus-scraper
          - rolearn: "arn:aws:iam::111111111111:role/AWSServiceRoleForAmazonPrometheusScraper_111111111111111"
            username: "acme-plat-ue2-sandbox-prometheus-scraper"
            groups: []
```

Then reapply the given cluster component.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `helm` | >= 2.0 |
| `kubernetes` | >= 2.7.1, != 2.21.0 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`prometheus` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`scraper_access` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_prometheus_scraper.this`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_scraper) (resource)(main.tf#18)

### Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
> ### `additional_tag_map` (`map(string)`) <i>optional</i>
>
>
> Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
>
> This is for some rare cases where resources want additional configuration of tags<br/>
>
> and therefore take a list of maps with tag key, value, and additional configuration.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `map(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `attributes` (`list(string)`) <i>optional</i>
>
>
> ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
>
> in the order they appear in the list. New attributes are appended to the<br/>
>
> end of the list. The elements of the list are joined by the `delimiter`<br/>
>
> and treated as a single ID element.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `[]`
>   </dd>
> </dl>
>
> </details>


> ### `context` (`any`) <i>optional</i>
>
>
> Single object for setting entire context at once.<br/>
>
> See description of individual variables for details.<br/>
>
> Leave string and numeric variables as `null` to use default value.<br/>
>
> Individual variable settings (non-null) override settings in context object,<br/>
>
> except for attributes, tags, and additional_tag_map, which are merged.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>    ```hcl
>>
>    {
>
>      "additional_tag_map": {},
>
>      "attributes": [],
>
>      "delimiter": null,
>
>      "descriptor_formats": {},
>
>      "enabled": true,
>
>      "environment": null,
>
>      "id_length_limit": null,
>
>      "label_key_case": null,
>
>      "label_order": [],
>
>      "label_value_case": null,
>
>      "labels_as_tags": [
>
>        "unset"
>
>      ],
>
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {},
>
>      "tenant": null
>
>    }
>
>    ```
>    
>   </dd>
> </dl>
>
> </details>


> ### `delimiter` (`string`) <i>optional</i>
>
>
> Delimiter to be used between ID elements.<br/>
>
> Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `descriptor_formats` (`any`) <i>optional</i>
>
>
> Describe additional descriptors to be output in the `descriptors` output map.<br/>
>
> Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
>
> `{<br/>
>
>    format = string<br/>
>
>    labels = list(string)<br/>
>
> }`<br/>
>
> (Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
>
> `format` is a Terraform format string to be passed to the `format()` function.<br/>
>
> `labels` is a list of labels, in order, to pass to `format()` function.<br/>
>
> Label values will be normalized before being passed to `format()` so they will be<br/>
>
> identical to how they appear in `id`.<br/>
>
> Default is `{}` (`descriptors` output will be empty).<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `enabled` (`bool`) <i>optional</i>
>
>
> Set to false to prevent the module from creating any resources<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `environment` (`string`) <i>optional</i>
>
>
> ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `id_length_limit` (`number`) <i>optional</i>
>
>
> Limit `id` to this many characters (minimum 6).<br/>
>
> Set to `0` for unlimited length.<br/>
>
> Set to `null` for keep the existing setting, which defaults to `0`.<br/>
>
> Does not affect `id_full`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `number`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_key_case` (`string`) <i>optional</i>
>
>
> Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
>
> Does not affect keys of tags passed in via the `tags` input.<br/>
>
> Possible values: `lower`, `title`, `upper`.<br/>
>
> Default value: `title`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_order` (`list(string)`) <i>optional</i>
>
>
> The order in which the labels (ID elements) appear in the `id`.<br/>
>
> Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
>
> You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `list(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `label_value_case` (`string`) <i>optional</i>
>
>
> Controls the letter case of ID elements (labels) as included in `id`,<br/>
>
> set as tag values, and output by this module individually.<br/>
>
> Does not affect values of tags passed in via the `tags` input.<br/>
>
> Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
>
> Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
>
> Default value: `lower`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `labels_as_tags` (`set(string)`) <i>optional</i>
>
>
> Set of labels (ID elements) to include as tags in the `tags` output.<br/>
>
> Default is to include all labels.<br/>
>
> Tags with empty values will not be included in the `tags` output.<br/>
>
> Set to `[]` to suppress all generated tags.<br/>
>
> **Notes:**<br/>
>
>   The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
>
>   Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
>
>   changed in later chained modules. Attempts to change it will be silently ignored.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `set(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>    ```hcl
>>
>    [
>
>      "default"
>
>    ]
>
>    ```
>    
>   </dd>
> </dl>
>
> </details>


> ### `name` (`string`) <i>optional</i>
>
>
> ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
>
> This is the only ID element not also included as a `tag`.<br/>
>
> The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `namespace` (`string`) <i>optional</i>
>
>
> ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `regex_replace_chars` (`string`) <i>optional</i>
>
>
> Terraform regular expression (regex) string.<br/>
>
> Characters matching the regex will be removed from the ID elements.<br/>
>
> If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `stage` (`string`) <i>optional</i>
>
>
> ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `tags` (`map(string)`) <i>optional</i>
>
>
> Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
>
> Neither the tag keys nor the tag values will be modified by this module.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `map(string)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `tenant` (`string`) <i>optional</i>
>
>
> ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>



</details>

### Required Variables
> ### `region` (`string`) <i>required</i>
>
>
> AWS Region<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    ``
>   </dd>
> </dl>
>
> </details>



### Optional Variables
> ### `atomic` (`bool`) <i>optional</i>
>
>
> If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used.<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>


> ### `chart_description` (`string`) <i>optional</i>
>
>
> Set release description attribute (visible in the history).<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"AWS Managed Prometheus (AMP) scrapper roles and role bindings"`
>   </dd>
> </dl>
>
> </details>


> ### `chart_values` (`any`) <i>optional</i>
>
>
> Additional values to yamlencode as `helm_release` values.<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `{}`
>   </dd>
> </dl>
>
> </details>


> ### `cleanup_on_fail` (`bool`) <i>optional</i>
>
>
> Allow deletion of new resources created in this upgrade when upgrade fails.<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>


> ### `create_namespace` (`bool`) <i>optional</i>
>
>
> Create the Kubernetes namespace if it does not yet exist<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>


> ### `eks_component_name` (`string`) <i>optional</i>
>
>
> The name of the eks component<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"eks/cluster"`
>   </dd>
> </dl>
>
> </details>


> ### `eks_scrape_configuration` (`string`) <i>optional</i>
>
>
> Scrape configuration for the agentless scraper that will installed with EKS integrations<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"global:\n  scrape_interval: 30s\nscrape_configs:\n  # pod metrics\n  - job_name: pod_exporter\n    kubernetes_sd_configs:\n      - role: pod\n  # container metrics\n  - job_name: cadvisor\n    scheme: https\n    authorization:\n      credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n    kubernetes_sd_configs:\n      - role: node\n    relabel_configs:\n      - action: labelmap\n        regex: __meta_kubernetes_node_label_(.+)\n      - replacement: kubernetes.default.svc:443\n        target_label: __address__\n      - source_labels: [__meta_kubernetes_node_name]\n        regex: (.+)\n        target_label: __metrics_path__\n        replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor\n  # apiserver metrics\n  - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token\n    job_name: kubernetes-apiservers\n    kubernetes_sd_configs:\n    - role: endpoints\n    relabel_configs:\n    - action: keep\n      regex: default;kubernetes;https\n      source_labels:\n      - __meta_kubernetes_namespace\n      - __meta_kubernetes_service_name\n      - __meta_kubernetes_endpoint_port_name\n    scheme: https\n  # kube proxy metrics\n  - job_name: kube-proxy\n    honor_labels: true\n    kubernetes_sd_configs:\n    - role: pod\n    relabel_configs:\n    - action: keep\n      source_labels:\n      - __meta_kubernetes_namespace\n      - __meta_kubernetes_pod_name\n      separator: '/'\n      regex: 'kube-system/kube-proxy.+'\n    - source_labels:\n      - __address__\n      action: replace\n      target_label: __address__\n      regex: (.+?)(\\\\:\\\\d+)?\n      replacement: $1:10249\n"`
>   </dd>
> </dl>
>
> </details>


> ### `helm_manifest_experiment_enabled` (`bool`) <i>optional</i>
>
>
> Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `false`
>   </dd>
> </dl>
>
> </details>


> ### `kube_data_auth_enabled` (`bool`) <i>optional</i>
>
>
> If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br/>
>
> Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `false`
>   </dd>
> </dl>
>
> </details>


> ### `kube_exec_auth_aws_profile` (`string`) <i>optional</i>
>
>
> The AWS config profile for `aws eks get-token` to use<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `""`
>   </dd>
> </dl>
>
> </details>


> ### `kube_exec_auth_aws_profile_enabled` (`bool`) <i>optional</i>
>
>
> If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `false`
>   </dd>
> </dl>
>
> </details>


> ### `kube_exec_auth_enabled` (`bool`) <i>optional</i>
>
>
> If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br/>
>
> Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.<br/>
>
> <br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>


> ### `kube_exec_auth_role_arn` (`string`) <i>optional</i>
>
>
> The role ARN for `aws eks get-token` to use<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `""`
>   </dd>
> </dl>
>
> </details>


> ### `kube_exec_auth_role_arn_enabled` (`bool`) <i>optional</i>
>
>
> If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>


> ### `kubeconfig_context` (`string`) <i>optional</i>
>
>
> Context to choose from the Kubernetes kube config file<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `""`
>   </dd>
> </dl>
>
> </details>


> ### `kubeconfig_exec_auth_api_version` (`string`) <i>optional</i>
>
>
> The Kubernetes API version of the credentials returned by the `exec` auth plugin<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"client.authentication.k8s.io/v1beta1"`
>   </dd>
> </dl>
>
> </details>


> ### `kubeconfig_file` (`string`) <i>optional</i>
>
>
> The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `""`
>   </dd>
> </dl>
>
> </details>


> ### `kubeconfig_file_enabled` (`bool`) <i>optional</i>
>
>
> If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `false`
>   </dd>
> </dl>
>
> </details>


> ### `kubernetes_namespace` (`string`) <i>optional</i>
>
>
> Kubernetes namespace to install the release into<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"kube-system"`
>   </dd>
> </dl>
>
> </details>


> ### `prometheus_component_name` (`string`) <i>optional</i>
>
>
> The name of the Amazon Managed Prometheus workspace component<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"managed-prometheus/workspace"`
>   </dd>
> </dl>
>
> </details>


> ### `timeout` (`number`) <i>optional</i>
>
>
> Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `number`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `300`
>   </dd>
> </dl>
>
> </details>


> ### `verify` (`bool`) <i>optional</i>
>
>
> Verify the package before installing it. Helm uses a provenance file to verify the integrity of the chart; this must be hosted alongside the chart<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `false`
>   </dd>
> </dl>
>
> </details>


> ### `vpc_component_name` (`string`) <i>optional</i>
>
>
> The name of the vpc component<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `string`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `"vpc"`
>   </dd>
> </dl>
>
> </details>


> ### `wait` (`bool`) <i>optional</i>
>
>
> Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`.<br/>
>
>
> <details>
> <summary>Click to expand</summary>
>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   `bool`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `true`
>   </dd>
> </dl>
>
> </details>



### Outputs

<dl>
  <dt><code>clusterrole_username</code></dt>
  <dd>
    The username of the ClusterRole used to give the scraper in-cluster permissions<br/>
  </dd>
  <dt><code>scraper_role_arn</code></dt>
  <dd>
    The Amazon Resource Name (ARN) of the IAM role that provides permissions for the scraper to discover, collect, and produce metrics<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/prometheus-scraper) -
  Cloud Posse's upstream component
- [AMP Collector Documentation](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-collector-how-to.html#AMP-collector-eks-setup)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)