# Component: `route53-resolver-dns-firewall`

This component is responsible for provisioning
[Route 53 Resolver DNS Firewall](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-dns-firewall.html)
resources, including Route 53 Resolver DNS Firewall, domain lists, firewall rule groups, firewall rules, and logging
configuration.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
# stacks/catalog/route53-resolver-dns-firewall/defaults.yaml
components:
  terraform:
    route53-resolver-dns-firewall/defaults:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        firewall_fail_open: "ENABLED"
        query_log_enabled: true
        logs_bucket_component_name: "route53-resolver-dns-firewall-logs-bucket"
        domains_config:
          allowed-domains:
            # Concat the lists of domains passed in the `domains` field and loaded from the file `domains_file`
            # The file is in the `components/terraform/route53-resolver-dns-firewall/config` folder
            domains_file: "config/allowed_domains.txt"
            domains: []
          blocked-domains:
            # Concat the lists of domains passed in the `domains` field and loaded from the file `domains_file`
            # The file is in the `components/terraform/route53-resolver-dns-firewall/config` folder
            domains_file: "config/blocked_domains.txt"
            domains: []
        rule_groups_config:
          blocked-and-allowed-domains:
            # 'priority' must be between 100 and 9900 exclusive
            priority: 101
            rules:
              allowed-domains:
                firewall_domain_list_name: "allowed-domains"
                # 'priority' must be between 100 and 9900 exclusive
                priority: 101
                action: "ALLOW"
              blocked-domains:
                firewall_domain_list_name: "blocked-domains"
                # 'priority' must be between 100 and 9900 exclusive
                priority: 200
                action: "BLOCK"
                block_response: "NXDOMAIN"
```

```yaml
# stacks/mixins/stage/dev.yaml
import:
  - catalog/route53-resolver-dns-firewall/defaults

components:
  terraform:
    route53-resolver-dns-firewall/example:
      metadata:
        component: route53-resolver-dns-firewall
        inherits:
          - route53-resolver-dns-firewall/defaults
      vars:
        name: route53-dns-firewall-example
        vpc_component_name: vpc
```

Execute the following command to provision the `route53-resolver-dns-firewall/example` component using Atmos:

```shell
atmos terraform apply route53-resolver-dns-firewall/example -s <stack>
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.9.0), version: >= 4.9.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`logs_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`route53_resolver_dns_firewall` | 0.2.1 | [`cloudposse/route53-resolver-dns-firewall/aws`](https://registry.terraform.io/modules/cloudposse/route53-resolver-dns-firewall/aws/0.2.1) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a




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
  <dt>`domains_config` <i>required</i></dt>
  <dd>
    Map of Route 53 Resolver DNS Firewall domain configurations<br/>

    **Type:** 

    ```hcl
    map(object({
    domains      = optional(list(string))
    domains_file = optional(string)
  }))
    ```
    
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`rule_groups_config` <i>required</i></dt>
  <dd>
    Rule groups and rules configuration<br/>

    **Type:** 

    ```hcl
    map(object({
    priority            = number
    mutation_protection = optional(string)
    # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_resolver_firewall_rule
    rules = map(object({
      action                    = string
      priority                  = number
      block_override_dns_type   = optional(string)
      block_override_domain     = optional(string)
      block_override_ttl        = optional(number)
      block_response            = optional(string)
      firewall_domain_list_name = string
    }))
  }))
    ```
    
    <br/>
    **Default value:** ``

  </dd>
  <dt>`vpc_component_name` (`string`) <i>required</i></dt>
  <dd>
    The name of a VPC component where the Network Firewall is provisioned<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`firewall_fail_open` (`string`) <i>optional</i></dt>
  <dd>
    Determines how Route 53 Resolver handles queries during failures, for example when all traffic that is sent to DNS Firewall fails to receive a reply.<br/>
    By default, fail open is disabled, which means the failure mode is closed.<br/>
    This approach favors security over availability. DNS Firewall blocks queries that it is unable to evaluate properly.<br/>
    If you enable this option, the failure mode is open. This approach favors availability over security.<br/>
    In this case, DNS Firewall allows queries to proceed if it is unable to properly evaluate them.<br/>
    Valid values: ENABLED, DISABLED.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ENABLED"`
  </dd>
  <dt>`logs_bucket_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Flow logs bucket component name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`query_log_config_name` (`string`) <i>optional</i></dt>
  <dd>
    Route 53 Resolver query log config name. If omitted, the name will be generated by concatenating the ID from the context with the VPC ID<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`query_log_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable Route 53 Resolver query logging<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`domains`</dt>
  <dd>
    Route 53 Resolver DNS Firewall domain configurations<br/>
  </dd>
  <dt>`query_log_config`</dt>
  <dd>
    Route 53 Resolver query logging configuration<br/>
  </dd>
  <dt>`rule_group_associations`</dt>
  <dd>
    Route 53 Resolver DNS Firewall rule group associations<br/>
  </dd>
  <dt>`rule_groups`</dt>
  <dd>
    Route 53 Resolver DNS Firewall rule groups<br/>
  </dd>
  <dt>`rules`</dt>
  <dd>
    Route 53 Resolver DNS Firewall rules<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [Deploy centralized traffic filtering using AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deploy-centralized-traffic-filtering-using-aws-network-firewall)
- [AWS Network Firewall – New Managed Firewall Service in VPC](https://aws.amazon.com/blogs/aws/aws-network-firewall-new-managed-firewall-service-in-vpc)
- [Deployment models for AWS Network Firewall](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall)
- [Deployment models for AWS Network Firewall with VPC routing enhancements](https://aws.amazon.com/blogs/networking-and-content-delivery/deployment-models-for-aws-network-firewall-with-vpc-routing-enhancements)
- [Inspection Deployment Models with AWS Network Firewall](https://d1.awsstatic.com/architecture-diagrams/ArchitectureDiagrams/inspection-deployment-models-with-AWS-network-firewall-ra.pdf)
- [How to deploy AWS Network Firewall by using AWS Firewall Manager](https://aws.amazon.com/blogs/security/how-to-deploy-aws-network-firewall-by-using-aws-firewall-manager)
- [A Deep Dive into AWS Transit Gateway](https://www.youtube.com/watch?v=a55Iud-66q0)
- [Appliance in a shared services VPC](https://docs.aws.amazon.com/vpc/latest/tgw/transit-gateway-appliance-scenario.html)
- [Quotas on Route 53 Resolver DNS Firewall](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/DNSLimitations.html#limits-api-entities-resolver)
- [Unified bad hosts](https://github.com/StevenBlack/hosts)
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/TODO) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
