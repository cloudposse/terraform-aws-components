# Component: `sftp`

This component is responsible for provisioning SFTP Endpoints.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    sftp:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `awsutils` | >= 0.11.0 |
| `local` | >= 2.0 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`s3_context` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`security_group` | 1.0.1 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/1.0.1) | n/a
`sftp` | 1.2.0 | [`cloudposse/transfer-sftp/aws`](https://registry.terraform.io/modules/cloudposse/transfer-sftp/aws/1.2.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_route53_zone.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)
  - [`aws_s3_bucket.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) (data source)

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
> ### `hosted_zone_suffix` (`string`) <i>required</i>
>
>
> The hosted zone name suffix. The stage name will be prefixed to this suffix.<br/>
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


> ### `region` (`string`) <i>required</i>
>
>
> VPN Endpoints are region-specific. This identifies the region. AWS Region<br/>
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


> ### `s3_bucket_context` (`any`) <i>required</i>
>
>
> The s3 bucket context map of inputs. The same null label inputs can be provided. Provide the `name` to find the s3 bucket using a data source.<br/>
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
>   `any`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    ``
>   </dd>
> </dl>
>
> </details>



### Optional Variables
> ### `address_allocation_ids` (`list(string)`) <i>optional</i>
>
>
> A list of address allocation IDs that are required to attach an Elastic IP address to your SFTP server's endpoint. This property can only be used when endpoint_type is set to VPC.<br/>
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


> ### `domain` (`string`) <i>optional</i>
>
>
> Where your files are stored. S3 or EFS<br/>
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
>    `"S3"`
>   </dd>
> </dl>
>
> </details>


> ### `domain_name` (`string`) <i>optional</i>
>
>
> Domain to use when connecting to the SFTP endpoint<br/>
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


> ### `eip_enabled` (`bool`) <i>optional</i>
>
>
> Whether to provision and attach an Elastic IP to be used as the SFTP endpoint. An EIP will be provisioned per subnet.<br/>
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


> ### `force_destroy` (`bool`) <i>optional</i>
>
>
> Forces the AWS Transfer Server to be destroyed<br/>
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


> ### `restricted_home` (`bool`) <i>optional</i>
>
>
> Restricts SFTP users so they only have access to their home directories.<br/>
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


> ### `security_group_rules` (`list(any)`) <i>optional</i>
>
>
> A list of Security Group rule objects to add to the created security group.<br/>
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
>   `list(any)`
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>    ```hcl
>>
>    [
>
>      {
>
>        "cidr_blocks": [
>
>          "0.0.0.0/0"
>
>        ],
>
>        "from_port": 22,
>
>        "protocol": "tcp",
>
>        "to_port": 22,
>
>        "type": "ingress"
>
>      }
>
>    ]
>
>    ```
>    
>   </dd>
> </dl>
>
> </details>


> ### `security_policy_name` (`string`) <i>optional</i>
>
>
> Specifies the name of the security policy that is attached to the server. Possible values are TransferSecurityPolicy-2018-11, TransferSecurityPolicy-2020-06, and TransferSecurityPolicy-FIPS-2020-06. Default value is: TransferSecurityPolicy-2018-11.<br/>
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
>    `"TransferSecurityPolicy-2018-11"`
>   </dd>
> </dl>
>
> </details>


> ### `sftp_users` (`any`) <i>optional</i>
>
>
> List of SFTP usernames and public keys<br/>
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


> ### `vpc_endpoint_id` (`string`) <i>optional</i>
>
>
> The ID of the VPC endpoint. This property can only be used when endpoint_type is set to VPC_ENDPOINT<br/>
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


> ### `vpc_security_group_ids` (`list(string)`) <i>optional</i>
>
>
> A list of security groups IDs that are available to attach to your server's endpoint. If no security groups are specified, the VPC's default security groups are automatically assigned to your endpoint. This property can only be used when endpoint_type is set to VPC.<br/>
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



### Outputs

<dl>
  <dt><code>sftp</code></dt>
  <dd>
    The SFTP module outputs<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-transfer-sftp](https://github.com/cloudposse/terraform-aws-transfer-sftp) - Cloud Posse's
  upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
