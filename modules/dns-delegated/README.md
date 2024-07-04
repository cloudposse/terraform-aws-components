# Component: `dns-delegated`

This component is responsible for provisioning a DNS zone which delegates nameservers to the DNS zone in the primary DNS
account. The primary DNS zone is expected to already be provisioned via
[the `dns-primary` component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-primary).

This component also provisions a wildcard ACM certificate for the given subdomain.

## Usage

**Stack Level**: Global or Regional

Here's an example snippet for how to use this component. Use this component in global or regional stacks for any
accounts where you host services that need DNS records on a given subdomain (e.g. delegated zone) of the root domain
(e.g. primary zone).

Public Hosted Zone `devplatform.example.net` will be created and `example.net` HZ in the dns primary account will
contain a record delegating DNS to the new HZ

This will create an ACM record

```yaml
components:
  terraform:
    dns-delegated:
      vars:
        zone_config:
          - subdomain: devplatform
            zone_name: example.net
        request_acm_certificate: true
        dns_private_zone_enabled: false
        #  dns_soa_config configures the SOA record for the zone::
        #    - awsdns-hostmaster.amazon.com. ; AWS default value for administrator email address
        #    - 1 ; serial number, not used by AWS
        #    - 7200 ; refresh time in seconds for secondary DNS servers to refreh SOA record
        #    - 900 ; retry time in seconds for secondary DNS servers to retry failed SOA record update
        #    - 1209600 ; expire time in seconds (1209600 is 2 weeks) for secondary DNS servers to remove SOA record if they cannot refresh it
        #    - 60 ; nxdomain TTL, or time in seconds for secondary DNS servers to cache negative responses
        #    See [SOA Record Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) for more information.
        dns_soa_config: "awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60"
```

Private Hosted Zone `devplatform.example.net` will be created and `example.net` HZ in the dns primary account will
contain a record delegating DNS to the new HZ

This will create an ACM record using a Private CA

```yaml
components:
  terraform:
    dns-delegated:
      vars:
        zone_config:
          - subdomain: devplatform
            zone_name: example.net
        request_acm_certificate: true
        dns_private_zone_enabled: true
        vpc_region_abbreviation_type: short
        vpc_primary_environment_name: use2
        certificate_authority_component_name: private-ca-subordinate
        certificate_authority_stage_name: pca
        certificate_authority_environment_name: use2
        certificate_authority_component_key: subordinate
```

### Limitations

Switching a hosted zone from public to private can cause issues because the provider will try to do an update instead of
a ForceNew.

See: https://github.com/hashicorp/terraform-provider-aws/issues/7614

It's not possible to toggle between public and private so if switching from public to private and downtime is
acceptable, delete the records of the hosted zone, delete the hosted zone, destroy the terraform component, and deploy
with the new settings.

NOTE: With each of these workarounds, you may have an issue connecting to the service specific provider e.g. for
`auroro-postgres` you may get an error of the host set to `localhost` on the `postgresql` provider resulting in an
error. To get around this, dump the endpoint using `atmos terraform show`, hardcode the `host` input on the provider,
and re-run the apply.

#### Workaround if downtime is fine

1. Delete anything using ACMs connected to previous hosted zones
1. Delete ACMs
1. Delete entries in public hosted zone
1. Delete hosted zone
1. Use atmos to destroy `dns-delegated` to remove the public hosted zone
1. Use atmos to deploy `dns-delegated` for the private hosted zone
1. Move aurora-postgres, msk, external-dns, echo-server, etc to the new hosted zone by re-deploying

#### Workaround if downtime is not fine

1. Create a new virtual component of `dns-delegated` with the correct private inputs (see above)
1. Deploy the new dns-delegated-private component
1. Move aurora-postgres, msk, external-dns, echo-server, etc to the new hosted zone by re-deploying

## Caveats

- Do not create a delegation for subdomain of a domain in a zone for which that zone is not authoritative for the
  subdomain (usually because you already delegated a parent subdomain). Though Amazon Route 53 will allow you to, you
  should not do it. For historic reasons, Route 53 Public DNS allows customers to create two NS delegations within a
  hosted zone which creates a conflict (and can return either set to resolvers depending on the query).

For example, in a single hosted zone with the domain name `example.com`, it is possible to create two NS delegations
which are parent and child of each other as follows:

```
a.example.com. 172800 IN NS ns-1084.awsdns-07.org.
a.example.com. 172800 IN NS ns-634.awsdns-15.net.
a.example.com. 172800 IN NS ns-1831.awsdns-36.co.uk.
a.example.com. 172800 IN NS ns-190.awsdns-23.com.

b.a.example.com. 172800 IN NS ns-1178.awsdns-19.org.
b.a.example.com. 172800 IN NS ns-614.awsdns-12.net.
b.a.example.com. 172800 IN NS ns-1575.awsdns-04.co.uk.
b.a.example.com. 172800 IN NS ns-338.awsdns-42.com.
```

This configuration creates two discrete possible resolution paths.

1. If a resolver directly queries the `example.com` nameservers for `c.b.a.example.com`, it will receive the second set
   of nameservers.

2. If a resolver queries `example.com` for `a.example.com`, it will receive the first set of nameservers.

If the resolver then proceeds to query the `a.example.com` nameservers for `c.b.a.example.com`, the response is driven
by the contents of the `a.example.com` zone, which may be different than the results returned by the `b.a.example.com`
nameservers. `c.b.a.example.com` may not have an entry in the `a.example.com` nameservers, resulting in an error
(`NXDOMAIN`) being returned.

From 15th May 2020, Route 53 Resolver has been enabling a modern DNS resolver standard called "QName Minimization"[*].
This change causes the resolver to more strictly use recursion path [2] described above where path [1] was common
before. [*] [https://tools.ietf.org/html/rfc7816](https://tools.ietf.org/html/rfc7816)

As of January 2022, you can observe the different query strategies in use by Google DNS at `8.8.8.8` (strategy 1) and
Cloudflare DNS at `1.1.1.1` (strategy 2). You should verify that both DNS servers resolve your host records properly.

Takeaway

1. In order to ensure DNS resolution is consistent no matter the resolver, it is important to always create NS
   delegations only authoritative zones.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `aws` | >= 4.9.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`acm` | 0.17.0 | [`cloudposse/acm-request-certificate/aws`](https://registry.terraform.io/modules/cloudposse/acm-request-certificate/aws/0.17.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`private_ca` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 1.3.0 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/1.3.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_route53_record.root_ns`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)(main.tf#104)
  - [`aws_route53_record.soa`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)(main.tf#82)
  - [`aws_route53_zone.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) (resource)(main.tf#17)
  - [`aws_route53_zone.private`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) (resource)(main.tf#27)
  - [`aws_route53_zone_association.secondary`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) (resource)(main.tf#61)
  - [`aws_shield_protection.shield_protection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) (resource)(main.tf#73)
  - [`aws_ssm_parameter.acm_arn`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(acm.tf#36)

## Data Sources

The following data sources are used by this module:

  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)
  - [`aws_route53_zone.root_zone`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) (data source)

## Required Variables
### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `zone_config` <i>required</i>


Zone config<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   list(object({
    subdomain = string
    zone_name = string
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `aws_shield_protection_enabled` (`bool`) <i>optional</i>


Enable or disable AWS Shield Advanced protection for Route53 Zones. If set to 'true', a subscription to AWS Shield Advanced must exist in this account.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `certificate_authority_component_key` (`string`) <i>optional</i>


Use this component key e.g. `root` or `mgmt` to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `certificate_authority_component_name` (`string`) <i>optional</i>


Use this component name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `certificate_authority_enabled` (`bool`) <i>optional</i>


Whether to use the certificate authority or not<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `certificate_authority_environment_name` (`string`) <i>optional</i>


Use this environment name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `certificate_authority_stage_name` (`string`) <i>optional</i>


Use this stage name to read from the remote state to get the certificate_authority_arn if using an authority type of SUBORDINATE<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `dns_private_zone_enabled` (`bool`) <i>optional</i>


Whether to set the zone to public or private<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `dns_soa_config` (`string`) <i>optional</i>


Root domain name DNS SOA record:<br/>
- awsdns-hostmaster.amazon.com. ; AWS default value for administrator email address<br/>
- 1 ; serial number, not used by AWS<br/>
- 7200 ; refresh time in seconds for secondary DNS servers to refreh SOA record<br/>
- 900 ; retry time in seconds for secondary DNS servers to retry failed SOA record update<br/>
- 1209600 ; expire time in seconds (1209600 is 2 weeks) for secondary DNS servers to remove SOA record if they cannot refresh it<br/>
- 60 ; nxdomain TTL, or time in seconds for secondary DNS servers to cache negative responses<br/>
See [SOA Record Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) for more information.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60"</code>
>   </dd>
> </dl>
>


### `request_acm_certificate` (`bool`) <i>optional</i>


Whether or not to create an ACM certificate<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `vpc_primary_environment_name` (`string`) <i>optional</i>


The name of the environment where primary VPC is deployed<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `vpc_region_abbreviation_type` (`string`) <i>optional</i>


Type of VPC abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"fixed"</code>
>   </dd>
> </dl>
>


### `vpc_secondary_environment_names` (`list(string)`) <i>optional</i>


The names of the environments where secondary VPCs are deployed<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
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
>    
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


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

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
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
>    
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>

## Outputs

<dl>
  <dt><code>acm_ssm_parameter</code></dt>
  <dd>
    The SSM parameter for the ACM cert.<br/>

  </dd>
  <dt><code>certificate</code></dt>
  <dd>
    The ACM certificate information.<br/>

  </dd>
  <dt><code>default_dns_zone_id</code></dt>
  <dd>
    Default root DNS zone ID for the cluster<br/>

  </dd>
  <dt><code>default_domain_name</code></dt>
  <dd>
    Default root domain name (e.g. dev.example.net) for the cluster<br/>

  </dd>
  <dt><code>route53_hosted_zone_protections</code></dt>
  <dd>
    List of AWS Shield Advanced Protections for Route53 Hosted Zones.<br/>

  </dd>
  <dt><code>zones</code></dt>
  <dd>
    Subdomain and zone config<br/>

  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-delegated) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
