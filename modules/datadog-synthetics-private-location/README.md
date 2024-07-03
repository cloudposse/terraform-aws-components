# Component: `datadog-synthetics-private-location`

This component provisions a Datadog synthetics private location on Datadog and a private location agent on EKS cluster.

Private locations allow you to monitor internal-facing applications or any private URLs that are not accessible from the
public internet.

## Usage

**Stack Level**: Regional

Use this in the catalog or use these variables to overwrite the catalog values.

```yaml
components:
  terraform:
    datadog-synthetics-private-location:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: "datadog-synthetics-private-location"
        description: "Datadog Synthetics Private Location Agent"
        kubernetes_namespace: "monitoring"
        create_namespace: true
        # https://github.com/DataDog/helm-charts/tree/main/charts/synthetics-private-location
        repository: "https://helm.datadoghq.com"
        chart: "synthetics-private-location"
        chart_version: "0.15.15"
        timeout: 180
        wait: true
        atomic: true
        cleanup_on_fail: true
```

## Synthetics Private Location Config

```shell
docker run --rm datadog/synthetics-private-location-worker --help
```

```
The Datadog Synthetics Private Location Worker runs tests on privately accessible websites and brings results to Datadog

Access keys:
      --accessKey        Access Key for Datadog API authentication  [string]
      --secretAccessKey  Secret Access Key for Datadog API authentication  [string]
      --datadogApiKey    Datadog API key to send browser tests artifacts (e.g. screenshots)  [string]
      --privateKey       Private Key used to decrypt test configurations  [array]
      --publicKey        Public Key used by Datadog to encrypt test results. Composed of --publicKey.pem and --publicKey.fingerprint

Worker configuration:
      --site                      Datadog site (datadoghq.com, us3.datadoghq.com, datadoghq.eu or ddog-gov.com)  [string] [required] [default: "datadoghq.com"]
      --concurrency               Maximum number of tests executed in parallel  [number] [default: 10]
      --maxNumberMessagesToFetch  Maximum number of tests that can be fetched at the same time  [number] [default: 10]
      --proxyDatadog              Proxy URL used to send requests to Datadog  [string] [default: none]
      --dumpConfig                Display non-secret worker configuration parameters  [boolean]
      --enableStatusProbes        Enable the probes system for Kubernetes  [boolean] [default: false]
      --statusProbesPort          The port for the probes server to listen on  [number] [default: 8080]
      --config                    Path to JSON config file  [default: "/etc/datadog/synthetics-check-runner.json"]

Tests configuration:
      --maxTimeout            Maximum test execution duration, in milliseconds  [number] [default: 60000]
      --proxyTestRequests     Proxy URL used to send test requests  [string] [default: none]
      --proxyIgnoreSSLErrors  Discard SSL errors when using a proxy  [boolean] [default: false]
      --dnsUseHost            Use local DNS config for API tests and HTTP steps in browser tests (currently ["192.168.65.5"])  [boolean] [default: true]
      --dnsServer             DNS server IPs used in given order for API tests and HTTP steps in browser tests (--dnsServer="1.0.0.1" --dnsServer="9.9.9.9") and after local DNS config, if --dnsUseHost is present  [array] [default: ["8.8.8.8","1.1.1.1"]]

Network filtering:
      --allowedIPRanges               Grant access to IP ranges (has precedence over --blockedIPRanges)  [default: none]
      --blockedIPRanges               Deny access to IP ranges (e.g. --blockedIPRanges.4="127.0.0.0/8" --blockedIPRanges.6="::1/128")  [default: none]
      --enableDefaultBlockedIpRanges  Deny access to all reserved IP ranges, except for those explicitly set in --allowedIPRanges  [boolean] [default: false]
      --allowedDomainNames            Grant access to domain names for API tests (has precedence over --blockedDomainNames, e.g. --allowedDomainNames="*.example.com")  [array] [default: none]
      --blockedDomainNames            Deny access to domain names for API tests (e.g. --blockedDomainNames="example.org" --blockedDomainNames="*.com")  [array] [default: none]

Options:
      --enableIPv6  Use IPv6 to perform tests. (Warning: IPv6 in Docker is only supported with Linux host)  [boolean] [default: false]
      --version     Show version number  [boolean]
  -f, --logFormat   Format log output  [choices: "pretty", "pretty-compact", "json"] [default: "pretty"]
  -h, --help        Show help  [boolean]

Volumes:
    /etc/datadog/certs/  .pem certificates present in this directory will be imported and trusted as certificate authorities for API and browser tests

Environment variables:
    Command options can also be set via environment variables (DATADOG_API_KEY="...", DATADOG_WORKER_CONCURRENCY="15", DATADOG_DNS_USE_HOST="true")
    For options that accept multiple arguments, JSON string array notation should be used (DATADOG_TESTS_DNS_SERVER='["8.8.8.8", "1.1.1.1"]')

    Supported environment variables:
        DATADOG_ACCESS_KEY,
        DATADOG_API_KEY,
        DATADOG_PRIVATE_KEY,
        DATADOG_PUBLIC_KEY_FINGERPRINT,
        DATADOG_PUBLIC_KEY_PEM,
        DATADOG_SECRET_ACCESS_KEY,
        DATADOG_SITE,
        DATADOG_WORKER_CONCURRENCY,
        DATADOG_WORKER_LOG_FORMAT,
        DATADOG_WORKER_MAX_NUMBER_MESSAGES_TO_FETCH,
        DATADOG_WORKER_PROXY,
        DATADOG_TESTS_DNS_SERVER,
        DATADOG_TESTS_DNS_USE_HOST,
        DATADOG_TESTS_PROXY,
        DATADOG_TESTS_PROXY_IGNORE_SSL_ERRORS,
        DATADOG_TESTS_TIMEOUT,
        DATADOG_ALLOWED_IP_RANGES_4,
        DATADOG_ALLOWED_IP_RANGES_6,
        DATADOG_BLOCKED_IP_RANGES_4,
        DATADOG_BLOCKED_IP_RANGES_6,
        DATADOG_ENABLE_DEFAULT_WINDOWS_FIREWALL_RULES,
        DATADOG_ALLOWED_DOMAIN_NAMES,
        DATADOG_BLOCKED_DOMAIN_NAMES,
        DATADOG_WORKER_ENABLE_STATUS_PROBES,
        DATADOG_WORKER_STATUS_PROBES_PORT
```

## References

- https://docs.datadoghq.com/synthetics/private_locations
- https://docs.datadoghq.com/synthetics/private_locations/configuration/
- https://github.com/DataDog/helm-charts/tree/main/charts/synthetics-private-location
- https://github.com/DataDog/helm-charts/blob/main/charts/synthetics-private-location/values.yaml

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`datadog`](https://registry.terraform.io/modules/datadog/>= 3.3.0), version: >= 3.3.0
- [`helm`](https://registry.terraform.io/modules/helm/>= 2.3.0), version: >= 2.3.0
- [`kubernetes`](https://registry.terraform.io/modules/kubernetes/>= 2.14.0, != 2.21.0), version: >= 2.14.0, != 2.21.0
- [`local`](https://registry.terraform.io/modules/local/>= 1.3), version: >= 1.3
- [`template`](https://registry.terraform.io/modules/template/>= 2.0), version: >= 2.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.0
- `datadog`, version: >= 3.3.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`datadog_configuration` | latest | [`../datadog-configuration/modules/datadog_keys`](https://registry.terraform.io/modules/../datadog-configuration/modules/datadog_keys/) | n/a
`datadog_synthetics_private_location` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`datadog_synthetics_private_location.this`](https://registry.terraform.io/providers/datadog/datadog/latest/docs/resources/synthetics_private_location) (resource)

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
  <dt>`create_namespace` (`bool`) <i>optional</i></dt>
  <dd>
    Create the Kubernetes namespace if it does not yet exist<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
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
    The name of the eks component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"eks/cluster"`
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
  <dt>`private_location_tags` (`set(string)`) <i>optional</i></dt>
  <dd>
    List of static tags to associate with the synthetics private location<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
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
  <dt>`metadata`</dt>
  <dd>
    Block status of the deployed release<br/>
  </dd>
  <dt>`synthetics_private_location_id`</dt>
  <dd>
    Synthetics private location ID<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://docs.datadoghq.com/getting_started/synthetics/private_location
- https://docs.datadoghq.com/synthetics/private_locations/configuration
- https://registry.terraform.io/providers/DataDog/datadog/latest/docs/resources/synthetics_private_location
- https://github.com/DataDog/helm-charts/tree/main/charts/synthetics-private-location
