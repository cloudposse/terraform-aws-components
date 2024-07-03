# Component: `dns-primary`

This component is responsible for provisioning the primary DNS zones into an AWS account. By convention, we typically
provision the primary DNS zones in the `dns` account. The primary account for branded zones (e.g. `example.com`),
however, would be in the `prod` account, while staging zone (e.g. `example.qa`) might be in the `staging` account.

The zones from the primary DNS zone are then expected to be delegated to other accounts via
[the `dns-delegated` component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-delegated).
Additionally, external records can be created on the primary DNS zones via the `record_config` variable.

## Architecture

### Summary

The `dns` account gets a single `dns-primary` component deployed. Every other account that needs DNS entries gets a
single `dns-delegated` component, chaining off the domains in the `dns` account. Optionally, accounts can have a single
`dns-primary` component of their own, to have apex domains (which Cloud Posse calls "vanity domains"). Typically, these
domains are configured with CNAME (or apex alias) records to point to service domain entries.

### Details

The purpose of the `dns` account is to host root domains shared by several accounts (with each account being delegated
its own subdomain) and to be the owner of domain registrations purchased from Amazon.

The purpose of the `dns-primary` component is to provision AWS Route53 zones for the root domains. These zones, once
provisioned, must be manually configured into the Domain Name Registrar's records as name servers. A single component
can provision multiple domains and, optionally, associated ACM (SSL) certificates in a single account.

Cloud Posse's architecture expects root domains shared by several accounts to be provisioned in the `dns` account with
`dns-primary` and delegated to other accounts using the `dns-delegated` component, with each account getting its own
subdomain corresponding to a Route 53 zone in the delegated account. Cloud Posse's architecture requires at least one
such domain, called "the service domain", be provisioned. The service domain is not customer facing, and is provisioned
to allow fully automated construction of host names without any concerns about how they look. Although they are not
secret, the public will never see them.

Root domains used by a single account are provisioned with the `dns-primary` component directly in that account. Cloud
Posse calls these "vanity domains". These can be whatever the marketing or PR or other stakeholders want to be.

After a domain is provisioned in the `dns` account, the `dns-delegated` component can provision one or more subdomains
for each account, and, optionally, associated ACM certificates. For the service domain, Cloud Posse recommends using the
account name as the delegated subdomain (either directly, e.g. "plat-dev", or as multiple subdomains, e.g. "dev.plat")
because that allows `dns-delegated` to automatically provision any required host name in that zone.

There is no automated support for `dns-primary` to provision root domains outside of the `dns` account that are to be
shared by multiple accounts, and such usage is not recommended. If you must, `dns-primary` can provision a subdomain of
a root domain that is provisioned in another account (not `dns`). In this case, the delegation of the subdomain must be
done manually by entering the name servers into the parent domain's records (instead of in the Registrar's records).

The architecture does not support other configurations, or non-standard component names.

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. This component should only be applied once as the DNS zones it
creates are global. This is typically done via the DNS stack (e.g. `gbl-dns.yaml`).

```yaml
components:
  terraform:
    dns-primary:
      vars:
        domain_names:
          - example.net
        record_config:
          - root_zone: example.net
            name: ""
            type: A
            ttl: 60
            records:
              - 53.229.170.215
          # using a period at the end of a name
          - root_zone: example.net
            name: www.
            type: CNAME
            ttl: 60
            records:
              - example.net
          # using numbers as name requires quotes
          - root_zone: example.net
            name: "123456."
            type: CNAME
            ttl: 60
            records:
              - example.net
          # strings that are very long, this could be a DKIM key
          - root_zone: example.net
            name: service._domainkey.
            type: CNAME
            ttl: 60
            records:
              - !!str |-
                YourVeryLongStringGoesHere
```

:::info Use the [acm](https://docs.cloudposse.com/components/library/aws/acm) component for more advanced certificate
requirements.

:::

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
`acm` | 0.16.3 | [`cloudposse/acm-request-certificate/aws`](https://registry.terraform.io/modules/cloudposse/acm-request-certificate/aws/0.16.3) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_route53_record.aliasrec`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
  - [`aws_route53_record.dnsrec`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
  - [`aws_route53_record.soa`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)
  - [`aws_route53_zone.root`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) (resource)

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
  <dt>`alias_record_config` <i>optional</i></dt>
  <dd>
    DNS Alias Record config<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    root_zone              = string
    name                   = string
    type                   = string
    zone_id                = string
    record                 = string
    evaluate_target_health = bool
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`dns_soa_config` (`string`) <i>optional</i></dt>
  <dd>
    Root domain name DNS SOA record:<br/>
    - awsdns-hostmaster.amazon.com. ; AWS default value for administrator email address<br/>
    - 1 ; serial number, not used by AWS<br/>
    - 7200 ; refresh time in seconds for secondary DNS servers to refreh SOA record<br/>
    - 900 ; retry time in seconds for secondary DNS servers to retry failed SOA record update<br/>
    - 1209600 ; expire time in seconds (1209600 is 2 weeks) for secondary DNS servers to remove SOA record if they cannot refresh it<br/>
    - 60 ; nxdomain TTL, or time in seconds for secondary DNS servers to cache negative responses<br/>
    See [SOA Record Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) for more information.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60"`
  </dd>
  <dt>`domain_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    Root domain name list, e.g. `["example.net"]`<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`record_config` <i>optional</i></dt>
  <dd>
    DNS Record config<br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    root_zone = string
    name      = string
    type      = string
    ttl       = string
    records   = list(string)
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`request_acm_certificate` (`bool`) <i>optional</i></dt>
  <dd>
    Whether or not to request an ACM certificate for each domain<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`acms`</dt>
  <dd>
    ACM certificates for domains<br/>
  </dd>
  <dt>`zones`</dt>
  <dd>
    DNS zones<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-primary) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
