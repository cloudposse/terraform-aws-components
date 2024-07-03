# Component: `aws-waf-acl`

This component is responsible for provisioning an AWS Web Application Firewall (WAF) with an associated managed rule
group.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    waf:
      vars:
        enabled: true
        name: waf
        acl_name: default
        default_action: allow
        description: Default web ACL
        visibility_config:
          cloudwatch_metrics_enabled: false
          metric_name: "default"
          sampled_requests_enabled: false
        managed_rule_group_statement_rules:
          - name: "OWASP-10"
            # Rules are processed in order based on the value of priority, lowest number first
            priority: 1

            statement:
              name: AWSManagedRulesCommonRuleSet
              vendor_name: AWS

            visibility_config:
              # Defines and enables Amazon CloudWatch metrics and web request sample collection.
              cloudwatch_metrics_enabled: false
              metric_name: "OWASP-10"
              sampled_requests_enabled: false
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.3.0), version: >= 1.3.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 5.0), version: >= 5.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 5.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`association_resource_components` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`aws_waf` | 1.3.0 | [`cloudposse/waf/aws`](https://registry.terraform.io/modules/cloudposse/waf/aws/1.3.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`log_destination_components` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.acl_arn`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)

### Data Sources

The following data sources are used by this module:


### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
  ### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  
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
</dl>

---


  ### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


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
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `number`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


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
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `set(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "default"
  ]
  ```
  
  </dd>
</dl>

---


  ### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `map(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


</details>

### Required Inputs
  ### `acl_name` (`string`) <i>required</i>


Friendly name of the ACL. The ACL ARN will be stored in SSM under {ssm_path_prefix}/{acl_name}/arn<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---


  ### `region` (`string`) <i>required</i>


AWS Region<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---


  ### `visibility_config` <i>required</i>


Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
cloudwatch_metrics_enabled:<br/>
  Whether the associated resource sends metrics to CloudWatch.<br/>
metric_name:<br/>
  A friendly name of the CloudWatch metric.<br/>
sampled_requests_enabled:<br/>
  Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  object({
    cloudwatch_metrics_enabled = bool
    metric_name                = string
    sampled_requests_enabled   = bool
  })
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

---



### Optional Inputs
  ### `association_resource_arns` (`list(string)`) <i>optional</i>


A list of ARNs of the resources to associate with the web ACL.<br/>
This must be an ARN of an Application Load Balancer, Amazon API Gateway stage, or AWS AppSync.<br/>
<br/>
Do not use this variable to associate a Cloudfront Distribution.<br/>
Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.<br/>
For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `association_resource_component_selectors` <i>optional</i>


A list of Atmos component selectors to get from the remote state and associate their ARNs with the web ACL.<br/>
The components must be Application Load Balancers, Amazon API Gateway stages, or AWS AppSync.<br/>
<br/>
component:<br/>
  Atmos component name<br/>
component_arn_output:<br/>
  The component output that defines the component ARN<br/>
<br/>
Set `tenant`, `environment` and `stage` if the components are in different OUs, regions or accounts.<br/>
<br/>
Do not use this variable to select a Cloudfront Distribution component.<br/>
Instead, you should use the `web_acl_id` property on the `cloudfront_distribution` resource.<br/>
For more details, refer to https://docs.aws.amazon.com/waf/latest/APIReference/API_AssociateWebACL.html<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    component            = string
    namespace            = optional(string, null)
    tenant               = optional(string, null)
    environment          = optional(string, null)
    stage                = optional(string, null)
    component_arn_output = string
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `byte_match_statement_rules` <i>optional</i>


A rule statement that defines a string match search for AWS WAF to apply to web requests.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  positional_constraint:<br/>
    Area within the portion of a web request that you want AWS WAF to search for search_string. Valid values include the following: EXACTLY, STARTS_WITH, ENDS_WITH, CONTAINS, CONTAINS_WORD.<br/>
  search_string<br/>
    String value that you want AWS WAF to search for. AWS WAF searches only in the part of web requests that you designate for inspection in field_to_match.<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `custom_response_body` <i>optional</i>


Defines custom response bodies that can be referenced by custom_response actions.<br/>
The map keys are used as the `key` attribute which is a unique key identifying the custom response body.<br/>
content:<br/>
  Payload of the custom response.<br/>
  The response body can be plain text, HTML or JSON and cannot exceed 4KB in size.<br/>
content_type:<br/>
  Content Type of Response Body.<br/>
  Valid values are `TEXT_PLAIN`, `TEXT_HTML`, or `APPLICATION_JSON`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(object({
    content      = string
    content_type = string
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `default_action` (`string`) <i>optional</i>


Specifies that AWS WAF should allow requests by default. Possible values: `allow`, `block`.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"block"`
  </dd>
</dl>

---


  ### `default_block_response` (`string`) <i>optional</i>


A HTTP response code that is sent when default action is used. Only takes effect if default_action is set to `block`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `description` (`string`) <i>optional</i>


A friendly description of the WebACL.<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"Managed by Terraform"`
  </dd>
</dl>

---


  ### `geo_allowlist_statement_rules` <i>optional</i>


A rule statement used to identify a list of allowed countries which should not be blocked by the WAF.<br/>
<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  country_codes:<br/>
    A list of two-character country codes.<br/>
  forwarded_ip_config:<br/>
    fallback_behavior:<br/>
      The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
      Possible values: `MATCH`, `NO_MATCH`<br/>
    header_name:<br/>
      The name of the HTTP header to use for the IP address.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `geo_match_statement_rules` <i>optional</i>


A rule statement used to identify web requests based on country of origin.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  country_codes:<br/>
    A list of two-character country codes.<br/>
  forwarded_ip_config:<br/>
    fallback_behavior:<br/>
      The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
      Possible values: `MATCH`, `NO_MATCH`<br/>
    header_name:<br/>
      The name of the HTTP header to use for the IP address.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `ip_set_reference_statement_rules` <i>optional</i>


A rule statement used to detect web requests coming from particular IP addresses or address ranges.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  arn:<br/>
    The ARN of the IP Set that this statement references.<br/>
  ip_set:<br/>
    Defines a new IP Set<br/>
<br/>
    description:<br/>
      A friendly description of the IP Set<br/>
    addresses:<br/>
      Contains an array of strings that specifies zero or more IP addresses or blocks of IP addresses.<br/>
      All addresses must be specified using Classless Inter-Domain Routing (CIDR) notation.<br/>
    ip_address_version:<br/>
      Specify `IPV4` or `IPV6`<br/>
  ip_set_forwarded_ip_config:<br/>
    fallback_behavior:<br/>
      The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
      Possible values: `MATCH`, `NO_MATCH`<br/>
    header_name:<br/>
      The name of the HTTP header to use for the IP address.<br/>
    position:<br/>
      The position in the header to search for the IP address.<br/>
      Possible values include: `FIRST`, `LAST`, or `ANY`.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `log_destination_component_selectors` <i>optional</i>


A list of Atmos component selectors to get from the remote state and associate their names/ARNs with the WAF logs.<br/>
The components must be Amazon Kinesis Data Firehose, CloudWatch Log Group, or S3 bucket.<br/>
<br/>
component:<br/>
  Atmos component name<br/>
component_output:<br/>
  The component output that defines the component name or ARN<br/>
<br/>
Set `tenant`, `environment` and `stage` if the components are in different OUs, regions or accounts.<br/>
<br/>
Note: data firehose, log group, or bucket name must be prefixed with `aws-waf-logs-`,<br/>
e.g. `aws-waf-logs-example-firehose`, `aws-waf-logs-example-log-group`, or `aws-waf-logs-example-bucket`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    component        = string
    namespace        = optional(string, null)
    tenant           = optional(string, null)
    environment      = optional(string, null)
    stage            = optional(string, null)
    component_output = string
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `log_destination_configs` (`list(string)`) <i>optional</i>


A list of resource names/ARNs to associate Amazon Kinesis Data Firehose, Cloudwatch Log log group, or S3 bucket with the WAF logs.<br/>
Note: data firehose, log group, or bucket name must be prefixed with `aws-waf-logs-`,<br/>
e.g. `aws-waf-logs-example-firehose`, `aws-waf-logs-example-log-group`, or `aws-waf-logs-example-bucket`.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

---


  ### `logging_filter` <i>optional</i>


A configuration block that specifies which web requests are kept in the logs and which are dropped.<br/>
You can filter on the rule action and on the web request labels that were applied by matching rules during web ACL evaluation.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  object({
    default_behavior = string
    filter = list(object({
      behavior    = string
      requirement = string
      condition = list(object({
        action_condition = optional(object({
          action = string
        }), null)
        label_name_condition = optional(object({
          label_name = string
        }), null)
      }))
    }))
  })
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `managed_rule_group_statement_rules` <i>optional</i>


A rule statement used to run the rules that are defined in a managed rule group.<br/>
<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
override_action:<br/>
  The override action to apply to the rules in a rule group.<br/>
  Possible values: `count`, `none`<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  name:<br/>
    The name of the managed rule group.<br/>
  vendor_name:<br/>
    The name of the managed rule group vendor.<br/>
  version:<br/>
    The version of the managed rule group.<br/>
    You can set `Version_1.0` or `Version_1.1` etc. If you want to use the default version, do not set anything.<br/>
  rule_action_override:<br/>
    Action settings to use in the place of the rule actions that are configured inside the rule group.<br/>
    You specify one override for each rule whose action you want to change.<br/>
  managed_rule_group_configs:<br/>
    Additional information that's used by a managed rule group. Only one rule attribute is allowed in each config.<br/>
    Refer to https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-list.html for more details.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name            = string
    priority        = number
    override_action = optional(string)
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement = object({
      name        = string
      vendor_name = string
      version     = optional(string)
      rule_action_override = optional(map(object({
        action = string
        custom_request_handling = optional(object({
          insert_header = object({
            name  = string
            value = string
          })
        }), null)
        custom_response = optional(object({
          response_code = string
          response_header = optional(object({
            name  = string
            value = string
          }), null)
        }), null)
      })), null)
      managed_rule_group_configs = optional(list(object({
        aws_managed_rules_bot_control_rule_set = optional(object({
          inspection_level = string
        }), null)
        aws_managed_rules_atp_rule_set = optional(object({
          enable_regex_in_path = optional(bool)
          login_path           = string
          request_inspection = optional(object({
            payload_type = string
            password_field = object({
              identifier = string
            })
            username_field = object({
              identifier = string
            })
          }), null)
          response_inspection = optional(object({
            body_contains = optional(object({
              success_strings = list(string)
              failure_strings = list(string)
            }), null)
            header = optional(object({
              name           = string
              success_values = list(string)
              failure_values = list(string)
            }), null)
            json = optional(object({

              identifier      = string
              success_strings = list(string)
              failure_strings = list(string)
            }), null)
            status_code = optional(object({
              success_codes = list(string)
              failure_codes = list(string)
            }), null)
          }), null)
        }), null)
      })), null)
    })
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `rate_based_statement_rules` <i>optional</i>


A rate-based rule tracks the rate of requests for each originating IP address,<br/>
and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  aggregate_key_type:<br/>
     Setting that indicates how to aggregate the request counts.<br/>
     Possible values include: `FORWARDED_IP` or `IP`<br/>
  limit:<br/>
    The limit on requests per 5-minute period for a single originating IP address.<br/>
  forwarded_ip_config:<br/>
    fallback_behavior:<br/>
      The match status to assign to the web request if the request doesn't have a valid IP address in the specified position.<br/>
      Possible values: `MATCH`, `NO_MATCH`<br/>
    header_name:<br/>
      The name of the HTTP header to use for the IP address.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `redacted_fields` <i>optional</i>


The parts of the request that you want to keep out of the logs.<br/>
You can only specify one of the following: `method`, `query_string`, `single_header`, or `uri_path`<br/>
<br/>
method:<br/>
  Whether to enable redaction of the HTTP method.<br/>
  The method indicates the type of operation that the request is asking the origin to perform.<br/>
uri_path:<br/>
  Whether to enable redaction of the URI path.<br/>
  This is the part of a web request that identifies a resource.<br/>
query_string:<br/>
  Whether to enable redaction of the query string.<br/>
  This is the part of a URL that appears after a `?` character, if any.<br/>
single_header:<br/>
  The list of names of the query headers to redact.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  map(object({
    method        = optional(bool, false)
    uri_path      = optional(bool, false)
    query_string  = optional(bool, false)
    single_header = optional(list(string), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `{}`
  </dd>
</dl>

---


  ### `regex_match_statement_rules` <i>optional</i>


A rule statement used to search web request components for a match against a single regular expression.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  regex_string:<br/>
     String representing the regular expression. Minimum of 1 and maximum of 512 characters.<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl.html#field_to_match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection. At least one required.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `regex_pattern_set_reference_statement_rules` <i>optional</i>


A rule statement used to search web request components for matches with regular expressions.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  arn:<br/>
     The Amazon Resource Name (ARN) of the Regex Pattern Set that this statement references.<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `rule_group_reference_statement_rules` <i>optional</i>


A rule statement used to run the rules that are defined in an WAFv2 Rule Group.<br/>
<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
override_action:<br/>
  The override action to apply to the rules in a rule group.<br/>
  Possible values: `count`, `none`<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  arn:<br/>
    The ARN of the `aws_wafv2_rule_group` resource.<br/>
  rule_action_override:<br/>
    Action settings to use in the place of the rule actions that are configured inside the rule group.<br/>
    You specify one override for each rule whose action you want to change.<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name            = string
    priority        = number
    override_action = optional(string)
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement = object({
      arn = string
      rule_action_override = optional(map(object({
        action = string
        custom_request_handling = optional(object({
          insert_header = object({
            name  = string
            value = string
          })
        }), null)
        custom_response = optional(object({
          response_code = string
          response_header = optional(object({
            name  = string
            value = string
          }), null)
        }), null)
      })), null)
    })
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `scope` (`string`) <i>optional</i>


Specifies whether this is for an AWS CloudFront distribution or for a regional application.<br/>
Possible values are `CLOUDFRONT` or `REGIONAL`.<br/>
To work with CloudFront, you must also specify the region us-east-1 (N. Virginia) on the AWS provider.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"REGIONAL"`
  </dd>
</dl>

---


  ### `size_constraint_statement_rules` <i>optional</i>


A rule statement that uses a comparison operator to compare a number of bytes against the size of a request component.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  comparison_operator:<br/>
     The operator to use to compare the request part to the size setting.<br/>
     Possible values: `EQ`, `NE`, `LE`, `LT`, `GE`, or `GT`.<br/>
  size:<br/>
    The size, in bytes, to compare to the request part, after any transformations.<br/>
    Valid values are integers between `0` and `21474836480`, inclusive.<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `sqli_match_statement_rules` <i>optional</i>


An SQL injection match condition identifies the part of web requests,<br/>
such as the URI or the query string, that you want AWS WAF to inspect.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
statement:<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `ssm_path_prefix` (`string`) <i>optional</i>


SSM path prefix (with leading but not trailing slash) under which to store all WAF info<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"/waf"`
  </dd>
</dl>

---


  ### `token_domains` (`list(string)`) <i>optional</i>


Specifies the domains that AWS WAF should accept in a web request token.<br/>
This enables the use of tokens across multiple protected websites.<br/>
When AWS WAF provides a token, it uses the domain of the AWS resource that the web ACL is protecting.<br/>
If you don't specify a list of token domains, AWS WAF accepts tokens only for the domain of the protected resource.<br/>
With a token domain list, AWS WAF accepts the resource's host domain plus all domains in the token domain list,<br/>
including their prefixed subdomains.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---


  ### `xss_match_statement_rules` <i>optional</i>


A rule statement that defines a cross-site scripting (XSS) match search for AWS WAF to apply to web requests.<br/>
<br/>
action:<br/>
  The action that AWS WAF should take on a web request when it matches the rule's statement.<br/>
name:<br/>
  A friendly name of the rule.<br/>
priority:<br/>
  If you define more than one Rule in a WebACL,<br/>
  AWS WAF evaluates each request against the rules in order based on the value of priority.<br/>
  AWS WAF processes rules with lower priority first.<br/>
<br/>
captcha_config:<br/>
 Specifies how AWS WAF should handle CAPTCHA evaluations.<br/>
<br/>
 immunity_time_property:<br/>
   Defines custom immunity time.<br/>
<br/>
   immunity_time:<br/>
   The amount of time, in seconds, that a CAPTCHA or challenge timestamp is considered valid by AWS WAF. The default setting is 300.<br/>
<br/>
rule_label:<br/>
   A List of labels to apply to web requests that match the rule match statement<br/>
<br/>
statement:<br/>
  field_to_match:<br/>
    The part of a web request that you want AWS WAF to inspect.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#field-to-match<br/>
  text_transformation:<br/>
    Text transformations eliminate some of the unusual formatting that attackers use in web requests in an effort to bypass detection.<br/>
    See https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl#text-transformation<br/>
<br/>
visibility_config:<br/>
  Defines and enables Amazon CloudWatch metrics and web request sample collection.<br/>
<br/>
  cloudwatch_metrics_enabled:<br/>
    Whether the associated resource sends metrics to CloudWatch.<br/>
  metric_name:<br/>
    A friendly name of the CloudWatch metric.<br/>
  sampled_requests_enabled:<br/>
    Whether AWS WAF should store a sampling of the web requests that match the rules.<br/>
<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    name     = string
    priority = number
    action   = string
    captcha_config = optional(object({
      immunity_time_property = object({
        immunity_time = number
      })
    }), null)
    rule_label = optional(list(string), null)
    statement  = any
    visibility_config = optional(object({
      cloudwatch_metrics_enabled = optional(bool)
      metric_name                = string
      sampled_requests_enabled   = optional(bool)
    }), null)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `null`
  </dd>
</dl>

---



### Outputs

<dl>
  <dt>`arn`</dt>
  <dd>
    The ARN of the WAF WebACL.<br/>
  </dd>
  <dt>`id`</dt>
  <dd>
    The ID of the WAF WebACL.<br/>
  </dd>
  <dt>`logging_config_id`</dt>
  <dd>
    The ARN of the WAFv2 Web ACL logging configuration.<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/waf) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
