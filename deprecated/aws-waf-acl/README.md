# Component: `aws-waf-acl`

This component is responsible for provisioning an AWS Web Application Firewall (WAF) with an associated managed rule group.


## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    aws-waf-acl:
      vars:
        enabled: true
        acl_name: default
        default_action: allow
        description: Default web ACL
        managed_rule_group_statement_rules:
        - name: "OWASP-10"
          # Rules are processed in order based on the value of priority, lowest number first
          priority: 1

          statement:
            name:  AWSManagedRulesCommonRuleSet
            vendor_name: AWS

          visibility_config:
            # Defines and enables Amazon CloudWatch metrics and web request sample collection.
            cloudwatch_metrics_enabled: false
            metric_name: "OWASP-10"
            sampled_requests_enabled: false
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 0.14.9 |
| `aws` | >= 3.36 |
| `external` | >= 2.1 |
| `local` | >= 2.1 |
| `template` | >= 2.2 |
| `utils` | >= 0.3 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 3.36 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`aws_waf` | 0.0.1 | [`cloudposse/waf/aws`](https://registry.terraform.io/modules/cloudposse/waf/aws/0.0.1) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.24.1 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.24.1) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.acl_arn`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)(main.tf#30)

### Data Sources

The following data sources are used by this module:


### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
> ### `additional_tag_map` (`map(string)`) <i>optional</i>
>
>
> Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>
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
> Additional attributes (e.g. `1`)<br/>
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
>      "name": null,
>
>      "namespace": null,
>
>      "regex_replace_chars": null,
>
>      "stage": null,
>
>      "tags": {}
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
> Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
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
> Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>
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
> Set to `null` for default, which is `0`.<br/>
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
> The letter case of label keys (`tag` names) (i.e. `name`, `namespace`, `environment`, `stage`, `attributes`) to use in `tags`.<br/>
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
> The naming order of the id output and Name tag.<br/>
>
> Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
>
> You can omit any of the 5 elements, but at least one must be present.<br/>
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
> The letter case of output label values (also used in `tags` and `id`).<br/>
>
> Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
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


> ### `name` (`string`) <i>optional</i>
>
>
> Solution name, e.g. 'app' or 'jenkins'<br/>
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
> Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>
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
> Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
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
> Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>
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
> Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>
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



</details>

### Required Variables
> ### `acl_name` (`string`) <i>required</i>
>
>
> Friendly name of the ACL. The ACL ARN will be stored in SSM under {ssm_path_prefix}/{acl_name}/arn<br/>
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
> AWS Region<br/>
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



### Optional Variables
> ### `association_resource_arns` (`list(string)`) <i>optional</i>
>
>
> A list of ARNs of the resources to associate with the web ACL.<br/>
>
> This must be an ARN of an Application Load Balancer or an Amazon API Gateway stage.<br/>
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


> ### `byte_match_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement that defines a string match search for AWS WAF to apply to web requests.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   field_to_match:<br/>
>
>     The part of a web request that you want AWS WAF to inspect.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
>
>   text_transformation:<br/>
>
>     Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `default_action` (`string`) <i>optional</i>
>
>
> Specifies that AWS WAF should allow requests by default. Possible values: `allow`, `block`.<br/>
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
>    `"block"`
>   </dd>
> </dl>
>
> </details>


> ### `description` (`string`) <i>optional</i>
>
>
> A friendly description of the WebACL.<br/>
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
>    `"Managed by Terraform"`
>   </dd>
> </dl>
>
> </details>


> ### `geo_match_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement used to identify web requests based on country of origin.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   country_codes:<br/>
>
>     A list of two-character country codes.<br/>
>
>   forwarded_ip_config:<br/>
>
>     fallback_behavior:<br/>
>
>       The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
>
>       Possible values: `MATCH`, `NO_MATCH`<br/>
>
>     header_name:<br/>
>
>       The name of the HTTP header to use for the IP address.<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `ip_set_reference_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement used to detect web requests coming from particular IP addresses or address ranges.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   arn:<br/>
>
>     The ARN of the IP Set that this statement references.<br/>
>
>   ip_set_forwarded_ip_config:<br/>
>
>     fallback_behavior:<br/>
>
>       The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
>
>       Possible values: `MATCH`, `NO_MATCH`<br/>
>
>     header_name:<br/>
>
>       The name of the HTTP header to use for the IP address.<br/>
>
>     position:<br/>
>
>       The position in the header to search for the IP address.<br/>
>
>       Possible values include: `FIRST`, `LAST`, or `ANY`.<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `log_destination_configs` (`list(string)`) <i>optional</i>
>
>
> The Amazon Kinesis Data Firehose ARNs.<br/>
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


> ### `managed_rule_group_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement used to run the rules that are defined in a managed rule group.<br/>
>
> <br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> override_action:<br/>
>
>   The override action to apply to the rules in a rule group.<br/>
>
>   Possible values: `count`, `none`<br/>
>
> <br/>
>
> statement:<br/>
>
>   name:<br/>
>
>     The name of the managed rule group.<br/>
>
>   vendor_name:<br/>
>
>     The name of the managed rule group vendor.<br/>
>
>   excluded_rule:<br/>
>
>     The list of names of the rules to exclude.<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `rate_based_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rate-based rule tracks the rate of requests for each originating IP address,<br/>
>
> and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   aggregate_key_type:<br/>
>
>      Setting that indicates how to aggregate the request counts.<br/>
>
>      Possible values include: `FORWARDED_IP` or `IP`<br/>
>
>   limit:<br/>
>
>     The limit on requests per 5-minute period for a single originating IP address.<br/>
>
>   forwarded_ip_config:<br/>
>
>     fallback_behavior:<br/>
>
>       The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
>
>       Possible values: `MATCH`, `NO_MATCH`<br/>
>
>     header_name:<br/>
>
>       The name of the HTTP header to use for the IP address.<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `redacted_fields` <i>optional</i>
>
>
> The parts of the request that you want to keep out of the logs.<br/>
>
> <br/>
>
> method_enabled:<br/>
>
>   Whether to enable redaction of the HTTP method.<br/>
>
>   The method indicates the type of operation that the request is asking the origin to perform.<br/>
>
> uri_path_enabled:<br/>
>
>   Whether to enable redaction of the URI path.<br/>
>
>   This is the part of a web request that identifies a resource.<br/>
>
> query_string_enabled:<br/>
>
>   Whether to enable redaction of the query string.<br/>
>
>   This is the part of a URL that appears after a `?` character, if any.<br/>
>
> single_header:<br/>
>
>   The list of names of the query headers to redact.<br/>
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
>   
>
>   ```hcl
>   object({
    method_enabled       = bool,
    uri_path_enabled     = bool,
    query_string_enabled = bool,
    single_header        = list(string)
  })
>   ```
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `regex_pattern_set_reference_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement used to search web request components for matches with regular expressions.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   arn:<br/>
>
>      The Amazon Resource Name (ARN) of the Regex Pattern Set that this statement references.<br/>
>
>   field_to_match:<br/>
>
>     The part of a web request that you want AWS WAF to inspect.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
>
>   text_transformation:<br/>
>
>     Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `rule_group_reference_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement used to run the rules that are defined in an WAFv2 Rule Group.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> override_action:<br/>
>
>   The override action to apply to the rules in a rule group.<br/>
>
>   Possible values: `count`, `none`<br/>
>
> <br/>
>
> statement:<br/>
>
>   arn:<br/>
>
>     The ARN of the `aws_wafv2_rule_group` resource.<br/>
>
>   excluded_rule:<br/>
>
>     The list of names of the rules to exclude.<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `scope` (`string`) <i>optional</i>
>
>
> Specifies whether this is for an AWS CloudFront distribution or for a regional application.<br/>
>
> Possible values are `CLOUDFRONT` or `REGIONAL`.<br/>
>
> To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider.<br/>
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
>    `"REGIONAL"`
>   </dd>
> </dl>
>
> </details>


> ### `size_constraint_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement that uses a comparison operator to compare a number of bytes against the size of a request component.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   comparison_operator:<br/>
>
>      The operator to use to compare the request part to the size setting.<br/>
>
>      Possible values: `EQ`, `NE`, `LE`, `LT`, `GE`, or `GT`.<br/>
>
>   size:<br/>
>
>     The size, in bytes, to compare to the request part, after any transformations.<br/>
>
>     Valid values are integers between `0` and `21474836480`, inclusive.<br/>
>
>   field_to_match:<br/>
>
>     The part of a web request that you want AWS WAF to inspect.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
>
>   text_transformation:<br/>
>
>     Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `sqli_match_statement_rules` (`list(any)`) <i>optional</i>
>
>
> An SQL injection match condition identifies the part of web requests,<br/>
>
> such as the URI or the query string, that you want AWS WAF to inspect.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> statement:<br/>
>
>   field_to_match:<br/>
>
>     The part of a web request that you want AWS WAF to inspect.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
>
>   text_transformation:<br/>
>
>     Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>


> ### `ssm_path_prefix` (`string`) <i>optional</i>
>
>
> SSM path prefix (with leading but not trailing slash) under which to store all WAF info<br/>
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
>    `"/waf"`
>   </dd>
> </dl>
>
> </details>


> ### `visibility_config` (`map(string)`) <i>optional</i>
>
>
> Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
> cloudwatch_metrics_enabled:<br/>
>
>   Whether the associated resource sends metrics to CloudWatch.<br/>
>
> metric_name:<br/>
>
>   A friendly name of the CloudWatch metric.<br/>
>
> sampled_requests_enabled:<br/>
>
>   Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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


> ### `xss_match_statement_rules` (`list(any)`) <i>optional</i>
>
>
> A rule statement that defines a cross-site scripting (XSS) match search for AWS WAF to apply to web requests.<br/>
>
> <br/>
>
> action:<br/>
>
>   The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
>
> name:<br/>
>
>   A friendly name of the rule.<br/>
>
> priority:<br/>
>
>   If you define more than one Rule in a WebACL,<br/>
>
>   AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
>
>   AWS WAF processes rules with lower priority first.<br/>
>
> <br/>
>
> xss_match_statement:<br/>
>
>   field_to_match:<br/>
>
>     The part of a web request that you want AWS WAF to inspect.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
>
>   text_transformation:<br/>
>
>     Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
>
>     See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
>
> <br/>
>
> visibility_config:<br/>
>
>   Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
>
> <br/>
>
>   cloudwatch_metrics_enabled:<br/>
>
>     Whether the associated resource sends metrics to CloudWatch.<br/>
>
>   metric_name:<br/>
>
>     A friendly name of the CloudWatch metric.<br/>
>
>   sampled_requests_enabled:<br/>
>
>     Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
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
>    `null`
>   </dd>
> </dl>
>
> </details>



### Outputs

<dl>
  <dt><code>acl</code></dt>
  <dd>
    Information about the created WAF ACL<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/ecr) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
