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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | ![>= 0.13.0](https://img.shields.io/badge/>=_0.13.0-success.svg?style=for-the-badge) |
| `aws` | ![>= 3.0](https://img.shields.io/badge/>=_3.0-success.svg?style=for-the-badge) |
| `helm` | ![>= 2.2.0](https://img.shields.io/badge/>=_2.2.0-success.svg?style=for-the-badge) |
| `sdm` | ![>= 1.0.19](https://img.shields.io/badge/>=_1.0.19-success.svg?style=for-the-badge) |


## Providers

| Provider | Version |
| --- | --- |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | ![>= 3.0](https://img.shields.io/badge/>=_3.0-success.svg?style=for-the-badge) |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | ![>= 3.0](https://img.shields.io/badge/>=_3.0-success.svg?style=for-the-badge) |
| [`helm`](https://registry.terraform.io/providers/helm/latest) | ![>= 2.2.0](https://img.shields.io/badge/>=_2.2.0-success.svg?style=for-the-badge) |
| [`sdm`](https://registry.terraform.io/providers/sdm/latest) | ![>= 1.0.19](https://img.shields.io/badge/>=_1.0.19-success.svg?style=for-the-badge) |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | [![latest](https://img.shields.io/badge/latest-success.svg?style=for-the-badge)](../account-map/modules/iam-roles) | [`../account-map/modules/iam-roles`](../account-map/modules/iam-roles) | n/a
`iam_roles_network` | [![latest](https://img.shields.io/badge/latest-success.svg?style=for-the-badge)](../account-map/modules/iam-roles) | [`../account-map/modules/iam-roles`](../account-map/modules/iam-roles) | n/a
`this` | [![0.24.1](https://img.shields.io/badge/0.24.1-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a


## Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.gateway_tokens`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(main.tf#50)
  - [`aws_ssm_parameter.relay_tokens`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(main.tf#60)
  - [`aws_ssm_parameter.ssh_admin_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(main.tf#70)
  - [`helm_release.cleanup`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)(helm.tf#67)
  - [`helm_release.gateway`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)(helm.tf#1)
  - [`helm_release.node`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)(helm.tf#40)
  - [`helm_release.relay`](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) (resource)(helm.tf#23)
  - [`sdm_node.gateway`](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/node) (resource)(main.tf#29)
  - [`sdm_node.relay`](https://registry.terraform.io/providers/strongdm/sdm/latest/docs/resources/node) (resource)(main.tf#43)

## Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.api_access_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.api_secret_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.ssh_admin_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)



## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `ssm_account` (`string`) <i>required</i>


Account (stage) housing SSM parameters<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `ssm_region` (`string`) <i>required</i>


AWS Region housing SSM parameters<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `create_roles` (`bool`) <i>optional</i>


Set `true` to create roles (should only be set in one account)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `dns_zone` (`string`) <i>optional</i>


DNS zone (e.g. example.com) into which to install the web host.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `gateway_count` (`number`) <i>optional</i>


Number of gateways to provision<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>2</code>
>   </dd>
> </dl>
>


### `install_gateway` (`bool`) <i>optional</i>


Set `true` to install a pair of gateways<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `install_relay` (`bool`) <i>optional</i>


Set `true` to install a pair of relays<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `kms_alias_name` (`string`) <i>optional</i>


AWS KMS alias used for encryption/decryption default is alias used in SSM<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"alias/aws/ssm"</code>
>   </dd>
> </dl>
>


### `kubernetes_namespace` (`string`) <i>optional</i>


The Kubernetes namespace to install the release into. Defaults to `default`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `register_nodes` (`bool`) <i>optional</i>


Set `true` to register nodes as SSH targets<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `relay_count` (`number`) <i>optional</i>


Number of relays to provision<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>2</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


Additional attributes (e.g. `1`)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {}
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for default, which is `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The naming order of the id output and Name tag.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 5 elements, but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


The letter case of output label values (also used in `tags` and `id`).<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


Solution name, e.g. 'app' or 'jenkins'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://github.com/spotinst/spotinst-kubernetes-helm-charts
- https://docs.spot.io/ocean/tutorials/spot-kubernetes-controller/
