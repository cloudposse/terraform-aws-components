# Component: `strongdm`

This component provisions [strongDM](https://www.strongdm.com/) gateway, relay and roles

## Usage

**Stack Level**: Regional

Use this in the catalog or use these variables to overwrite the catalog values.

```yaml
components:
  terraform:
    strong-dm:
      vars:
        enabled: true
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 0.13.0), version: >= 0.13.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`helm`](https://registry.terraform.io/modules/helm/>= 2.2.0), version: >= 2.2.0
- [`sdm`](https://registry.terraform.io/modules/sdm/>= 1.0.19), version: >= 1.0.19

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 3.0
- `aws`, version: >= 3.0
- `helm`, version: >= 2.2.0
- `sdm`, version: >= 1.0.19

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`iam_roles_network` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.24.1 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.gateway_tokens`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.relay_tokens`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`aws_ssm_parameter.ssh_admin_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)
  - [`helm_release.cleanup`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
  - [`helm_release.gateway`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
  - [`helm_release.node`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
  - [`helm_release.relay`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)
  - [`sdm_node.gateway`](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/node) (resource)
  - [`sdm_node.relay`](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/node) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.api_access_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.api_secret_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.ssh_admin_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Additional attributes (e.g. `1`)<br/>
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
      "enabled": true,
      "environment": null,
      "id_length_limit": null,
      "label_key_case": null,
      "label_order": [],
      "label_value_case": null,
      "name": null,
      "namespace": null,
      "regex_replace_chars": null,
      "stage": null,
      "tags": {}
    }
    ```
    
  </dd>
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
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
    Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters (minimum 6).<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for default, which is `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_key_case` (`string`) <i>optional</i></dt>
  <dd>
    The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br/>
    Possible values: `lower`, `title`, `upper`.<br/>
    Default value: `title`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The naming order of the id output and Name tag.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 5 elements, but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`label_value_case` (`string`) <i>optional</i></dt>
  <dd>
    The letter case of output label values (also used in `tags` and `id`).<br/>
    Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
    Default value: `lower`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    Solution name, e.g. 'app' or 'jenkins'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
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
  <dt>`ssm_account` (`string`) <i>required</i></dt>
  <dd>
    Account (stage) housing SSM parameters<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`ssm_region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region housing SSM parameters<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`create_roles` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to create roles (should only be set in one account)<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`dns_zone` (`string`) <i>optional</i></dt>
  <dd>
    DNS zone (e.g. example.com) into which to install the web host.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`gateway_count` (`number`) <i>optional</i></dt>
  <dd>
    Number of gateways to provision<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `2`
  </dd>
  <dt>`install_gateway` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to install a pair of gateways<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`install_relay` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to install a pair of relays<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`kms_alias_name` (`string`) <i>optional</i></dt>
  <dd>
    AWS KMS alias used for encryption/decryption default is alias used in SSM<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"alias/aws/ssm"`
  </dd>
  <dt>`kubernetes_namespace` (`string`) <i>optional</i></dt>
  <dd>
    The Kubernetes namespace to install the release into. Defaults to `default`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`register_nodes` (`bool`) <i>optional</i></dt>
  <dd>
    Set `true` to register nodes as SSH targets<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`relay_count` (`number`) <i>optional</i></dt>
  <dd>
    Number of relays to provision<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `2`
  </dd></dl>


<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://github.com/spotinst/spotinst-kubernetes-helm-charts
- https://docs.spot.io/ocean/tutorials/spot-kubernetes-controller/
