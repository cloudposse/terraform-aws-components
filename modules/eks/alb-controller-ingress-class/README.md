# Component: `eks/alb-controller-ingress-class`

This component deploys a Kubernetes `IngressClass` resource for the AWS Load Balancer Controller. This is not often
needed, as the default IngressClass deployed by the `eks/alb-controller` component is sufficient for most use cases, and
when it is not, a service can deploy its own IngressClass. This is for the rare case where you want to deploy an
additional IngressClass deploying an additional ALB that you nevertheless want to be shared by some services, with none
of them explicitly owning it.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    eks/alb-controller-ingress-class:
      vars:
        class_name: special
        group: special
        ip_address_type: ipv4
        scheme: internet-facing
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0
- [`helm`](https://registry.terraform.io/modules/helm/>= 2.0), version: >= 2.0
- [`kubernetes`](https://registry.terraform.io/modules/kubernetes/>= 2.14.0, != 2.21.0), version: >= 2.14.0, != 2.21.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0
- `kubernetes`, version: >= 2.14.0, != 2.21.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`kubernetes_ingress_class_v1.default`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_class_v1) (resource)
  - [`kubernetes_manifest.alb_controller_class_params`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/manifest) (resource)

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
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region.<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`additional_tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags to apply to the ingress load balancer.<br/>
    <br/>
    **Type:** `map(string)`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`class_name` (`string`) <i>optional</i></dt>
  <dd>
    Class name for default ingress<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"default"`
  </dd>
  <dt>`eks_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the eks component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"eks/cluster"`
  </dd>
  <dt>`group` (`string`) <i>optional</i></dt>
  <dd>
    Group name for default ingress<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"common"`
  </dd>
  <dt>`helm_manifest_experiment_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`ip_address_type` (`string`) <i>optional</i></dt>
  <dd>
    IP address type for default ingress, one of `ipv4` or `dualstack`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dualstack"`
  </dd>
  <dt>`is_default` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to make this the default IngressClass. There should only be one default per cluster.<br/>
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
  <dt>`load_balancer_attributes` (`list(object({ key = string, value = string }))`) <i>optional</i></dt>
  <dd>
    A list of load balancer attributes to apply to the default ingress load balancer.<br/>
    See [Load Balancer Attributes](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/application-load-balancers.html#load-balancer-attributes).<br/>
    <br/>
    <br/>
    **Type:** `list(object({ key = string, value = string }))`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`scheme` (`string`) <i>optional</i></dt>
  <dd>
    Scheme for default ingress, one of `internet-facing` or `internal`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"internet-facing"`
  </dd></dl>


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [alb-controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller) - Helm Chart
- [alb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) - AWS Load Balancer Controller

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
