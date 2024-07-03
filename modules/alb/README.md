# Component: `alb`

This component is responsible for provisioning a generic Application Load Balancer. It depends on the `vpc` and
`dns-delegated` components.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    alb:
      vars:
        https_ssl_policy: ELBSecurityPolicy-FS-1-2-Res-2020-10
        health_check_path: /api/healthz
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0.0), version: >= 1.0.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`local`](https://registry.terraform.io/modules/local/>= 2.1), version: >= 2.1

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`acm` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`alb` | 1.11.1 | [`cloudposse/alb/aws`](https://registry.terraform.io/modules/cloudposse/alb/aws/1.11.1) | n/a
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
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
  <dt>`access_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable access_logs<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`access_logs_prefix` (`string`) <i>optional</i></dt>
  <dd>
    The S3 log bucket prefix<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`access_logs_s3_bucket_id` (`string`) <i>optional</i></dt>
  <dd>
    An external S3 Bucket name to store access logs in. If specified, no logging bucket will be created.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`acm_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Atmos `acm` component name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"acm"`
  </dd>
  <dt>`alb_access_logs_s3_bucket_force_destroy` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean that indicates all objects should be deleted from the ALB access logs S3 bucket so that the bucket can be destroyed without error<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`cross_zone_load_balancing_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable cross zone load balancing<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`deletion_protection_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable deletion protection for ALB<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`deregistration_delay` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time to wait in seconds before changing the state of a deregistering target to unused<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `15`
  </dd>
  <dt>`dns_acm_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If `true`, use the ACM ARN created by the given `dns-delegated` component. Otherwise, use the ACM ARN created by the given `acm` component.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`dns_delegated_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Atmos `dns-delegated` component name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"dns-delegated"`
  </dd>
  <dt>`dns_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    `dns-delegated` component environment name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`health_check_healthy_threshold` (`number`) <i>optional</i></dt>
  <dd>
    The number of consecutive health checks successes required before considering an unhealthy target healthy<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `2`
  </dd>
  <dt>`health_check_interval` (`number`) <i>optional</i></dt>
  <dd>
    The duration in seconds in between health checks<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `15`
  </dd>
  <dt>`health_check_matcher` (`string`) <i>optional</i></dt>
  <dd>
    The HTTP response codes to indicate a healthy check<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"200-399"`
  </dd>
  <dt>`health_check_path` (`string`) <i>optional</i></dt>
  <dd>
    The destination for the health check request<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"/"`
  </dd>
  <dt>`health_check_port` (`string`) <i>optional</i></dt>
  <dd>
    The port to use for the healthcheck<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"traffic-port"`
  </dd>
  <dt>`health_check_timeout` (`number`) <i>optional</i></dt>
  <dd>
    The amount of time to wait in seconds before failing a health check request<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `10`
  </dd>
  <dt>`health_check_unhealthy_threshold` (`number`) <i>optional</i></dt>
  <dd>
    The number of consecutive health check failures required before considering the target unhealthy<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `2`
  </dd>
  <dt>`http2_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable HTTP/2<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`http_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable HTTP listener<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`http_ingress_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDR blocks to allow in HTTP security group<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "0.0.0.0/0"
    ]
    ```
    
  </dd>
  <dt>`http_ingress_prefix_list_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of prefix list IDs for allowing access to HTTP ingress security group<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`http_port` (`number`) <i>optional</i></dt>
  <dd>
    The port for the HTTP listener<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `80`
  </dd>
  <dt>`http_redirect` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable HTTP redirect to HTTPS<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`https_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to enable/disable HTTPS listener<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`https_ingress_cidr_blocks` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of CIDR blocks to allow in HTTPS security group<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "0.0.0.0/0"
    ]
    ```
    
  </dd>
  <dt>`https_ingress_prefix_list_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of prefix list IDs for allowing access to HTTPS ingress security group<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`https_port` (`number`) <i>optional</i></dt>
  <dd>
    The port for the HTTPS listener<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `443`
  </dd>
  <dt>`https_ssl_policy` (`string`) <i>optional</i></dt>
  <dd>
    The name of the SSL Policy for the listener<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ELBSecurityPolicy-TLS13-1-2-2021-06"`
  </dd>
  <dt>`idle_timeout` (`number`) <i>optional</i></dt>
  <dd>
    The time in seconds that the connection is allowed to be idle<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `60`
  </dd>
  <dt>`internal` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean flag to determine whether the ALB should be internal<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`ip_address_type` (`string`) <i>optional</i></dt>
  <dd>
    The type of IP addresses used by the subnets for your load balancer. The possible values are `ipv4` and `dualstack`.<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ipv4"`
  </dd>
  <dt>`lifecycle_rule_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    A boolean that indicates whether the s3 log bucket lifecycle rule should be enabled.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`stickiness` <i>optional</i></dt>
  <dd>
    Target group sticky configuration<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    cookie_duration = number
    enabled         = bool
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`target_group_name` (`string`) <i>optional</i></dt>
  <dd>
    The name for the default target group, uses a module label name if left empty<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`target_group_port` (`number`) <i>optional</i></dt>
  <dd>
    The port for the default target group<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `80`
  </dd>
  <dt>`target_group_protocol` (`string`) <i>optional</i></dt>
  <dd>
    The protocol for the default target group HTTP or HTTPS<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"HTTP"`
  </dd>
  <dt>`target_group_target_type` (`string`) <i>optional</i></dt>
  <dd>
    The type (`instance`, `ip` or `lambda`) of targets that can be registered with the target group<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ip"`
  </dd>
  <dt>`vpc_component_name` (`string`) <i>optional</i></dt>
  <dd>
    Atmos `vpc` component name<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"vpc"`
  </dd></dl>


### Outputs

<dl>
  <dt>`access_logs_bucket_id`</dt>
  <dd>
    The S3 bucket ID for access logs<br/>
  </dd>
  <dt>`alb_arn`</dt>
  <dd>
    The ARN of the ALB<br/>
  </dd>
  <dt>`alb_arn_suffix`</dt>
  <dd>
    The ARN suffix of the ALB<br/>
  </dd>
  <dt>`alb_dns_name`</dt>
  <dd>
    DNS name of ALB<br/>
  </dd>
  <dt>`alb_name`</dt>
  <dd>
    The ARN suffix of the ALB<br/>
  </dd>
  <dt>`alb_zone_id`</dt>
  <dd>
    The ID of the zone which ALB is provisioned<br/>
  </dd>
  <dt>`default_target_group_arn`</dt>
  <dd>
    The default target group ARN<br/>
  </dd>
  <dt>`http_listener_arn`</dt>
  <dd>
    The ARN of the HTTP forwarding listener<br/>
  </dd>
  <dt>`http_redirect_listener_arn`</dt>
  <dd>
    The ARN of the HTTP to HTTPS redirect listener<br/>
  </dd>
  <dt>`https_listener_arn`</dt>
  <dd>
    The ARN of the HTTPS listener<br/>
  </dd>
  <dt>`listener_arns`</dt>
  <dd>
    A list of all the listener ARNs<br/>
  </dd>
  <dt>`security_group_id`</dt>
  <dd>
    The security group ID of the ALB<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/alb) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
