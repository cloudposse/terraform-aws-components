# Component: `zscaler`

This component is responsible for provisioning ZScaler Private Access Connector instances on Amazon Linux 2 AMIs.

Prior to provisioning this component, it is required that a SecureString SSM Parameter containing the ZScaler App
Connector Provisioning Key is populated in each account corresponding to the regional stack the component is deployed
to, with the name of the SSM Parameter matching the value of `var.zscaler_key`.

This parameter should be populated using `chamber`, which is included in the geodesic image:

```
chamber write zscaler key <value>
```

Where `<value>` is the ZScaler App Connector Provisioning Key. For more information on how to generate this key, see:
[ZScaler documentation on Configuring App Connectors](https://help.zscaler.com/zpa/configuring-connectors).

## Usage

**Stack Level**: Regional

The typical stack configuration for this component is as follows:

```yaml
components:
  terraform:
    zscaler:
      vars:
        zscaler_count: 2
```

Preferably, regional stack configurations can be kept _DRY_ by importing `catalog/zscaler` via the `imports` list at the
top of the configuration.

```
import:
  ...
  - catalog/zscaler
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 0.13.0), version: >= 0.13.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`null`](https://registry.terraform.io/modules/null/>= 3.0), version: >= 3.0
- [`random`](https://registry.terraform.io/modules/random/>= 3.0), version: >= 3.0
- [`template`](https://registry.terraform.io/modules/template/>= 2.2), version: >= 2.2
- [`utils`](https://registry.terraform.io/modules/utils/>= 1.10.0), version: >= 1.10.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 3.0
- `template`, version: >= 2.2

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`ec2_zscaler` | 0.32.2 | [`cloudposse/ec2-instance/aws`](https://registry.terraform.io/modules/cloudposse/ec2-instance/aws/0.32.2) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.24.1 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a


### Resources

The following resources are used by this module:

  - [`aws_iam_role_policy_attachment.ssm_core`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ami.amazon_linux_2`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
  - [`aws_ssm_parameter.zscaler_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`template_file.userdata`](https://registry.terraform.io/providers/cloudposse/template/latest/docs/data-sources/file) (data source)

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
    AWS region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`ami_owner` (`string`) <i>optional</i></dt>
  <dd>
    The owner of the AMI used for the ZScaler EC2 instances.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"amazon"`
  </dd>
  <dt>`ami_regex` (`string`) <i>optional</i></dt>
  <dd>
    The regex used to match the latest AMI to be used for the ZScaler EC2 instances.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"^amzn2-ami-hvm.*"`
  </dd>
  <dt>`aws_ssm_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Set true to install the AWS SSM agent on each EC2 instances.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`instance_type` (`string`) <i>optional</i></dt>
  <dd>
    The instance family to use for the ZScaler EC2 instances.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"m5n.large"`
  </dd>
  <dt>`secrets_store_type` (`string`) <i>optional</i></dt>
  <dd>
    Secret store type for Zscaler provisioning keys. Valid values: `SSM`, `ASM` (but `ASM` not currently supported)<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"SSM"`
  </dd>
  <dt>`security_group_rules` (`list(any)`) <i>optional</i></dt>
  <dd>
    A list of maps of Security Group rules.<br/>
    The values of map is fully complated with `aws_security_group_rule` resource.<br/>
    To get more info see [security_group_rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule).<br/>
    <br/>
    <br/>
    **Type:** `list(any)`
    <br/>
    **Default value:** 
    ```hcl
    [
      {
        "cidr_blocks": [
          "0.0.0.0/0"
        ],
        "from_port": 0,
        "protocol": "-1",
        "to_port": 65535,
        "type": "egress"
      }
    ]
    ```
    
  </dd>
  <dt>`zscaler_count` (`number`) <i>optional</i></dt>
  <dd>
    The number of Zscaler instances.<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`zscaler_key` (`string`) <i>optional</i></dt>
  <dd>
    SSM key (without leading `/`) for the Zscaler provisioning key secret.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"zscaler/key"`
  </dd></dl>


### Outputs

<dl>
  <dt>`instance_id`</dt>
  <dd>
    Instance ID<br/>
  </dd>
  <dt>`private_ip`</dt>
  <dd>
    Private IP of the instance<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/zscaler) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
