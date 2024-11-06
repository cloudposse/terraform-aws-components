---
tags:
  - component/dns-delegated
  - layer/network
  - provider/aws
---

# Component: `dns-delegated`

This component is responsible for provisioning a DNS zone which manages subdomains delegated from a DNS zone in the primary DNS
account. The primary DNS zone is expected to already be provisioned via
[the `dns-primary` component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-primary).

If you are deploying a root zone (e.g `example.com`) rather than a subdomain delegated from a root zone (e.g `prod.example.com`),
and only a single account needs to manage or update the zone you are deploying, then you should use `dns-primary` instead to deploy 
that root zone into the target account. See 
[Why not use dns-delegated for all vanity domains?](https://docs.cloudposse.com/layers/network/faq/#why-not-use-dns-delegated-for-all-vanity-domains)
for more details on that.

This component also provisions a wildcard ACM certificate for the given subdomain.

This component should only be deployed globally, which is to say once per account. See 
[Why should the dns-delegated component be deployed globally rather than regionally?](https://docs.cloudposse.com/layers/network/faq/#why-should-the-dns-delegated-component-be-deployed-globally-rather-than-regionally)
for details on why. 

Note that once you delegate a subdomain (e.g. `prod.example.com`) to an account, that 
account can deploy multiple levels of sub-subdomains (e.g. `api.use1.prod.example.com`) without further configuration,
although you will need to create additional TLS certificates, as the wildcard in a wildcard TLS certificate
only matches a single level. You can use [our `acm` component](https://github.com/cloudposse/terraform-aws-components/tree/readme-global-only/modules/acm)
for that.

## Usage

**Stack Level**: Global


Here's an example snippet for how to use this component. Use this component in global stacks for any
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
        #    - 7200 ; refresh time in seconds for secondary DNS servers to refresh SOA record
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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |
| <a name="provider_aws.primary"></a> [aws.primary](#provider\_aws.primary) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm"></a> [acm](#module\_acm) | cloudposse/acm-request-certificate/aws | 0.17.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_private_ca"></a> [private\_ca](#module\_private\_ca) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_utils"></a> [utils](#module\_utils) | cloudposse/utils/aws | 1.3.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

| Name | Type |
|------|------|
| [aws_route53_record.root_ns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.soa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_route53_zone_association.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone_association) | resource |
| [aws_shield_protection.shield_protection](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) | resource |
| [aws_ssm_parameter.acm_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_route53_zone.root_zone](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_aws_shield_protection_enabled"></a> [aws\_shield\_protection\_enabled](#input\_aws\_shield\_protection\_enabled) | Enable or disable AWS Shield Advanced protection for Route53 Zones. If set to 'true', a subscription to AWS Shield Advanced must exist in this account. | `bool` | `false` | no |
| <a name="input_certificate_authority_component_key"></a> [certificate\_authority\_component\_key](#input\_certificate\_authority\_component\_key) | Use this component key e.g. `root` or `mgmt` to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_component_name"></a> [certificate\_authority\_component\_name](#input\_certificate\_authority\_component\_name) | Use this component name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_enabled"></a> [certificate\_authority\_enabled](#input\_certificate\_authority\_enabled) | Whether to use the certificate authority or not | `bool` | `false` | no |
| <a name="input_certificate_authority_environment_name"></a> [certificate\_authority\_environment\_name](#input\_certificate\_authority\_environment\_name) | Use this environment name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_certificate_authority_stage_name"></a> [certificate\_authority\_stage\_name](#input\_certificate\_authority\_stage\_name) | Use this stage name to read from the remote state to get the certificate\_authority\_arn if using an authority type of SUBORDINATE | `string` | `null` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_private_zone_enabled"></a> [dns\_private\_zone\_enabled](#input\_dns\_private\_zone\_enabled) | Whether to set the zone to public or private | `bool` | `false` | no |
| <a name="input_dns_soa_config"></a> [dns\_soa\_config](#input\_dns\_soa\_config) | Root domain name DNS SOA record:<br>- awsdns-hostmaster.amazon.com. ; AWS default value for administrator email address<br>- 1 ; serial number, not used by AWS<br>- 7200 ; refresh time in seconds for secondary DNS servers to refresh SOA record<br>- 900 ; retry time in seconds for secondary DNS servers to retry failed SOA record update<br>- 1209600 ; expire time in seconds (1209600 is 2 weeks) for secondary DNS servers to remove SOA record if they cannot refresh it<br>- 60 ; nxdomain TTL, or time in seconds for secondary DNS servers to cache negative responses<br>See [SOA Record Documentation](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/SOA-NSrecords.html) for more information. | `string` | `"awsdns-hostmaster.amazon.com. 1 7200 900 1209600 60"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_request_acm_certificate"></a> [request\_acm\_certificate](#input\_request\_acm\_certificate) | Whether or not to create an ACM certificate | `bool` | `true` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_primary_environment_name"></a> [vpc\_primary\_environment\_name](#input\_vpc\_primary\_environment\_name) | The name of the environment where primary VPC is deployed | `string` | `null` | no |
| <a name="input_vpc_region_abbreviation_type"></a> [vpc\_region\_abbreviation\_type](#input\_vpc\_region\_abbreviation\_type) | Type of VPC abbreviation (either `fixed` or `short`) to use in names. See https://github.com/cloudposse/terraform-aws-utils for details. | `string` | `"fixed"` | no |
| <a name="input_vpc_secondary_environment_names"></a> [vpc\_secondary\_environment\_names](#input\_vpc\_secondary\_environment\_names) | The names of the environments where secondary VPCs are deployed | `list(string)` | `[]` | no |
| <a name="input_zone_config"></a> [zone\_config](#input\_zone\_config) | Zone config | <pre>list(object({<br>    subdomain = string<br>    zone_name = string<br>  }))</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acm_ssm_parameter"></a> [acm\_ssm\_parameter](#output\_acm\_ssm\_parameter) | The SSM parameter for the ACM cert. |
| <a name="output_certificate"></a> [certificate](#output\_certificate) | The ACM certificate information. |
| <a name="output_default_dns_zone_id"></a> [default\_dns\_zone\_id](#output\_default\_dns\_zone\_id) | Default root DNS zone ID for the cluster |
| <a name="output_default_domain_name"></a> [default\_domain\_name](#output\_default\_domain\_name) | Default root domain name (e.g. dev.example.net) for the cluster |
| <a name="output_route53_hosted_zone_protections"></a> [route53\_hosted\_zone\_protections](#output\_route53\_hosted\_zone\_protections) | List of AWS Shield Advanced Protections for Route53 Hosted Zones. |
| <a name="output_zones"></a> [zones](#output\_zones) | Subdomain and zone config |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-delegated) -
  Cloud Posse's upstream component
- [The `dns-primary` component](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/dns-primary).
- [The `acm` component](https://github.com/cloudposse/terraform-aws-components/tree/readme-global-only/modules/acm)
component for that.
- [Why not use dns-delegated for all vanity domains?](https://docs.cloudposse.com/layers/network/faq/#why-not-use-dns-delegated-for-all-vanity-domains)
- [Why should the dns-delegated component be deployed globally rather than regionally?](https://docs.cloudposse.com/layers/network/faq/#why-should-the-dns-delegated-component-be-deployed-globally-rather-than-regionally)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
