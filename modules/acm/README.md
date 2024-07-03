# Component: `acm`

This component is responsible for requesting an ACM certificate for a domain and adding a CNAME record to the DNS zone
to complete certificate validation.

The ACM component is to manage an unlimited number of certificates, predominantly for vanity domains. While the
[dns-primary](https://docs.cloudposse.com/components/library/aws/dns-primary) component has the ability to generate ACM
certificates, it is very opinionated and can only manage one zone. In reality, companies have many branded domains
associated with a load balancer, so we need to be able to generate more complicated certificates.

We have, as a convenience, the ability to create an ACM certificate as part of creating a DNS zone, whether primary or
delegated. That convenience is limited to creating `example.com` and `*.example.com` when creating a zone for
`example.com`. For example, Acme has delegated `acct.acme.com` and in addition to `*.acct.acme.com` needed an ACM
certificate for `*.usw2.acct.acme.com`, so we use the ACM component to provision that, rather than extend the DNS
primary or delegated components to take a list of additional certificates. Both are different views on the Single
Responsibility Principle.

## Usage

**Stack Level**: Global or Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    acm:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        domain_name: acme.com
        process_domain_validation_options: false
        validation_method: DNS
        # NOTE: The following subject alternative name is automatically added by the module.
        #       Additional entries can be added by providing this input.
        # subject_alternative_names:
        #   - "*.acme.com"
```

ACM using a private CA

```yaml
components:
  terraform:
    acm:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        domain_name: acme.com
        process_domain_validation_options: false
        dns_private_zone_enabled: true
        certificate_authority_component_name: private-ca-subordinate
        certificate_authority_stage_name: pca
        certificate_authority_environment_name: use2
        certificate_authority_component_key: subordinate
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 4.9.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`acm` | 0.16.3 | [`cloudposse/acm-request-certificate/aws`](https://registry.terraform.io/modules/cloudposse/acm-request-certificate/aws/0.16.3) | https://github.com/cloudposse/terraform-aws-acm-request-certificate
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`private_ca` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.acm_arn`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_route53_zone.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)

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
  <dt>`certificate_authority_component_key` (`string`) <i>optional</i></dt>
  <dd>
    Use this component key e.g. `root` or `mgmt` to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`certificate_authority_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this component name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`certificate_authority_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to use the certificate authority or not<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`certificate_authority_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this environment name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`certificate_authority_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this stage name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`dns_delegated_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this component name to read from the remote state to get the dns_delegated zone ID<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dns-delegated"`
  </dd>
  <dt>`dns_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this environment name to read from the remote state to get the dns_delegated zone ID<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`dns_delegated_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    Use this stage name to read from the remote state to get the dns_delegated zone ID<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`dns_private_zone_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Whether to set the zone to public or private<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`domain_name` (`string`) <i>optional</i></dt>
  <dd>
    Root domain name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`domain_name_prefix` (`string`) <i>optional</i></dt>
  <dd>
    Root domain name prefix to use with DNS delegated remote state<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`process_domain_validation_options` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable processing of the record to add to the DNS zone to complete certificate validation<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`subject_alternative_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of domains that should be SANs in the issued certificate<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`subject_alternative_names_prefixes` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list of domain prefixes to use with DNS delegated remote state that should be SANs in the issued certificate<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`validation_method` (`string`) <i>optional</i></dt>
  <dd>
    Method to use for validation, DNS or EMAIL<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"DNS"`
  </dd>
  <dt>`zone_name` (`string`) <i>optional</i></dt>
  <dd>
    Name of the zone in which to place the DNS validation records to validate the certificate.<br/>
    Typically a domain name. Default of `""` actually defaults to `domain_name`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd></dl>


### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    The ARN of the certificate<br/>
  </dd>
  <dt>`domain_name`</dt>
  <dd>
    Certificate domain name<br/>
  </dd>
  <dt>`domain_validation_options`</dt>
  <dd>
    CNAME records that are added to the DNS zone to complete certificate validation<br/>
  </dd>
  <dt>`id`</dt>
  <dd>
    The ID of the certificate<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/acm) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
