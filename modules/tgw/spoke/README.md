# Component: `tgw/spoke`

This component is responsible for provisioning [AWS Transit Gateway](https://aws.amazon.com/transit-gateway) attachments
to connect VPCs in a `spoke` account to different accounts through a central `hub`.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to configure and use this component:

stacks/catalog/tgw/spoke.yaml

```yaml
components:
  terraform:
    tgw/spoke-defaults:
      metadata:
        type: abstract
        component: tgw/spoke
      vars:
        enabled: true
        name: tgw-spoke
        tags:
          Team: sre
          Service: tgw-spoke
        expose_eks_sg: false
        tgw_hub_tenant_name: core
        tgw_hub_environment_name: ue1

    tgw/spoke:
      metadata:
        inherits:
          - tgw/spoke-defaults
      vars:
        # This is what THIS spoke is allowed to connect to.
        # since this is deployed to each plat account (dev->prod),
        # we allow connections to network and auto.
        connections:
          - account:
              tenant: core
              stage: network
            # Set this value if the vpc component has a different name in this account
            vpc_component_names:
              - vpc-dev
          - account:
              tenant: core
              stage: auto
```

stacks/ue2/dev.yaml

```yaml
import:
  - catalog/tgw/spoke

components:
  terraform:
    tgw/spoke:
      vars:
        # use when there is not an EKS cluster in the stack
        expose_eks_sg: false
        # override default connections
        connections:
          - account:
              tenant: core
              stage: network
            vpc_component_names:
              - vpc-dev
          - account:
              tenant: core
              stage: auto
          - account:
              tenant: plat
              stage: dev
            eks_component_names:
              - eks/cluster
          - account:
              tenant: plat
              stage: qa
            eks_component_names:
              - eks/cluster
```

To provision the attachments for a spoke account:

```sh
atmos terraform plan tgw/spoke -s <tenant>-<environment>-<stage>
atmos terraform apply tgw/spoke -s <tenant>-<environment>-<stage>
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.1), version: >= 4.1

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.1
- `aws`, version: >= 4.1

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`cross_region_hub_connector` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`tgw_hub` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`tgw_hub_role` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`tgw_hub_routes` | 0.10.0 | [`cloudposse/transit-gateway/aws`](https://registry.terraform.io/modules/cloudposse/transit-gateway/aws/0.10.0) | n/a
`tgw_spoke_vpc_attachment` | latest | [`./modules/standard_vpc_attachment`](https://registry.terraform.io/modules/./modules/standard_vpc_attachment/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_route.back_route`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)
  - [`aws_route.default_route`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) (resource)

### Data Sources

The following data sources are used by this module:


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
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`connections` <i>optional</i></dt>
  <dd>
    A list of objects to define each TGW connections.<br/>
    <br/>
    By default, each connection will look for only the default `vpc` component.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    account = object({
      stage       = string
      environment = optional(string, "")
      tenant      = optional(string, "")
    })
    vpc_component_names = optional(list(string), ["vpc"])
    eks_component_names = optional(list(string), [])
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`cross_region_hub_connector_components` (`map(object({ component = string, environment = string }))`) <i>optional</i></dt>
  <dd>
    A map of cross-region hub connector components that provide this spoke with the appropriate Transit Gateway attachments IDs.<br/>
    - The key should be the environment that the remote VPC is located in.<br/>
    - The component is the name of the compoent in the remote region (e.g. `tgw/cross-region-hub-connector`)<br/>
    - The environment is the region that the cross-region-hub-connector is deployed in.<br/>
    e.g. the following would configure a component called `tgw/cross-region-hub-connector/use1` that is deployed in the<br/>
    If use2 is the primary region, the following would be its configuration:<br/>
    use1:<br/>
      component: "tgw/cross-region-hub-connector"<br/>
      environment: "use1" (the remote region)<br/>
    and in the alternate region, the following would be its configuration:<br/>
    use2:<br/>
      component: "tgw/cross-region-hub-connector"<br/>
      environment: "use1" (our own region)<br/>
    <br/>
    <br/>
    **Type:** `map(object({ component = string, environment = string }))`
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`default_route_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable default routing via transit gateway, requires also nat gateway and instance to be disabled in vpc component. Default is disabled.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`default_route_outgoing_account_name` (`string`) <i>optional</i></dt>
  <dd>
    The account name which is used for outgoing traffic, when using the transit gateway as default route.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`expose_eks_sg` (`bool`) <i>optional</i></dt>
  <dd>
    Set true to allow EKS clusters to accept traffic from source accounts<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`own_eks_component_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    The name of the eks components in the owning account.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`own_vpc_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the vpc component in the owning account. Defaults to "vpc"<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"vpc"`
  </dd>
  <dt>`peered_region` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` if this region is not the primary region<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`static_routes` <i>optional</i></dt>
  <dd>
    A list of static routes to add to the transit gateway, pointing at this VPC as a destination.<br/>
    <br/>
    **Type:** 

    ```hcl
    set(object({
    blackhole              = bool
    destination_cidr_block = string
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`static_tgw_routes` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of static routes to add to the local routing table with the transit gateway as a destination.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`tgw_hub_component_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the transit-gateway component<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"tgw/hub"`
  </dd>
  <dt>`tgw_hub_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage where `tgw/hub` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"network"`
  </dd>
  <dt>`tgw_hub_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the tenant where `tgw/hub` is provisioned.<br/>
    <br/>
    If the `tenant` label is not used, leave this as `null`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd></dl>


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/tgw) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
