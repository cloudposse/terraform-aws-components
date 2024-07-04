# Component: `ecs`

This component is responsible for provisioning an ECS Cluster and associated load balancer.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

The following will create

- ecs cluster
- load balancer with an ACM cert placed on example.com
- r53 record on all \*.example.com which will point to the load balancer

```yaml
components:
  terraform:
    ecs:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        name: ecs
        enabled: true
        acm_certificate_domain: example.com
        route53_record_name: "*"
        # Create records will be created in each zone
        zone_names:
          - example.com
        capacity_providers_fargate: true
        capacity_providers_fargate_spot: true
        capacity_providers_ec2:
          default:
            instance_type: t3.medium
            max_size: 2

        alb_configuration:
          public:
            internal_enabled: false
            # resolves to *.public-platform.<environment>.<stage>.<tenant>.<domain>.<tld>
            route53_record_name: "*.public-platform"
            additional_certs:
              - "my-vanity-domain.com"
          private:
            internal_enabled: true
            route53_record_name: "*.private-platform"
            additional_certs:
              - "my-vanity-domain.com"
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.0 |


### Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |


### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`alb` | 1.11.1 | [`cloudposse/alb/aws`](https://registry.terraform.io/modules/cloudposse/alb/aws/1.11.1) | n/a
`cluster` | 0.4.1 | [`cloudposse/ecs-cluster/aws`](https://registry.terraform.io/modules/cloudposse/ecs-cluster/aws/0.4.1) | n/a
`dns_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`target_group_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | This is used due to the short limit on target group names i.e. 32 characters
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_lb_listener_certificate.additional_certs`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) (resource)(main.tf#241)
  - [`aws_route53_record.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) (resource)(main.tf#146)
  - [`aws_security_group.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)(main.tf#33)
  - [`aws_security_group_rule.egress`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)(main.tf#60)
  - [`aws_security_group_rule.ingress_cidr`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)(main.tf#40)
  - [`aws_security_group_rule.ingress_security_groups`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)(main.tf#50)

### Data Sources

The following data sources are used by this module:

  - [`aws_acm_certificate.additional_certs`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) (data source)
  - [`aws_acm_certificate.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) (data source)
---
### Required Variables
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



---
### Optional Variables
### `acm_certificate_domain` (`string`) <i>optional</i>


Domain to get the ACM cert to use on the ALB.<br/>

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


### `acm_certificate_domain_suffix` (`string`) <i>optional</i>


Domain suffix to use with dns delegated HZ to get the ACM cert to use on the ALB<br/>

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


### `alb_configuration` (`map(any)`) <i>optional</i>


Map of multiple ALB configurations.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(any)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `alb_ingress_cidr_blocks_http` (`list(string)`) <i>optional</i>


List of CIDR blocks allowed to access environment over HTTP<br/>

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
>    
>
>    ```hcl
>>
>    [
>
>      "0.0.0.0/0"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `alb_ingress_cidr_blocks_https` (`list(string)`) <i>optional</i>


List of CIDR blocks allowed to access environment over HTTPS<br/>

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
>    
>
>    ```hcl
>>
>    [
>
>      "0.0.0.0/0"
>
>    ]
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `allowed_cidr_blocks` (`list(string)`) <i>optional</i>


List of CIDR blocks to be allowed to connect to the ECS cluster<br/>

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


### `allowed_security_groups` (`list(string)`) <i>optional</i>


List of Security Group IDs to be allowed to connect to the ECS cluster<br/>

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


### `capacity_providers_ec2` <i>optional</i>


EC2 autoscale groups capacity providers<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    instance_type                        = string
    max_size                             = number
    security_group_ids                   = optional(list(string), [])
    min_size                             = optional(number, 0)
    image_id                             = optional(string)
    instance_initiated_shutdown_behavior = optional(string, "terminate")
    key_name                             = optional(string, "")
    user_data                            = optional(string, "")
    enable_monitoring                    = optional(bool, true)
    instance_warmup_period               = optional(number, 300)
    maximum_scaling_step_size            = optional(number, 1)
    minimum_scaling_step_size            = optional(number, 1)
    target_capacity_utilization          = optional(number, 100)
    ebs_optimized                        = optional(bool, false)
    block_device_mappings = optional(list(object({
      device_name  = string
      no_device    = bool
      virtual_name = string
      ebs = object({
        delete_on_termination = bool
        encrypted             = bool
        iops                  = number
        kms_key_id            = string
        snapshot_id           = string
        volume_size           = number
        volume_type           = string
      })
    })), [])
    instance_market_options = optional(object({
      market_type = string
      spot_options = object({
        block_duration_minutes         = number
        instance_interruption_behavior = string
        max_price                      = number
        spot_instance_type             = string
        valid_until                    = string
      })
    }))
    instance_refresh = optional(object({
      strategy = string
      preferences = optional(object({
        instance_warmup        = optional(number, null)
        min_healthy_percentage = optional(number, null)
        skip_matching          = optional(bool, null)
        auto_rollback          = optional(bool, null)
      }), null)
      triggers = optional(list(string), [])
    }))
    mixed_instances_policy = optional(object({
      instances_distribution = object({
        on_demand_allocation_strategy            = string
        on_demand_base_capacity                  = number
        on_demand_percentage_above_base_capacity = number
        spot_allocation_strategy                 = string
        spot_instance_pools                      = number
        spot_max_price                           = string
      })
      }), {
      instances_distribution = null
    })
    placement = optional(object({
      affinity          = string
      availability_zone = string
      group_name        = string
      host_id           = string
      tenancy           = string
    }))
    credit_specification = optional(object({
      cpu_credits = string
    }))
    elastic_gpu_specifications = optional(object({
      type = string
    }))
    disable_api_termination   = optional(bool, false)
    default_cooldown          = optional(number, 300)
    health_check_grace_period = optional(number, 300)
    force_delete              = optional(bool, false)
    termination_policies      = optional(list(string), ["Default"])
    suspended_processes       = optional(list(string), [])
    placement_group           = optional(string, "")
    metrics_granularity       = optional(string, "1Minute")
    enabled_metrics = optional(list(string), [
      "GroupMinSize",
      "GroupMaxSize",
      "GroupDesiredCapacity",
      "GroupInServiceInstances",
      "GroupPendingInstances",
      "GroupStandbyInstances",
      "GroupTerminatingInstances",
      "GroupTotalInstances",
      "GroupInServiceCapacity",
      "GroupPendingCapacity",
      "GroupStandbyCapacity",
      "GroupTerminatingCapacity",
      "GroupTotalCapacity",
      "WarmPoolDesiredCapacity",
      "WarmPoolWarmedCapacity",
      "WarmPoolPendingCapacity",
      "WarmPoolTerminatingCapacity",
      "WarmPoolTotalCapacity",
      "GroupAndWarmPoolDesiredCapacity",
      "GroupAndWarmPoolTotalCapacity",
    ])
    wait_for_capacity_timeout            = optional(string, "10m")
    service_linked_role_arn              = optional(string, "")
    metadata_http_endpoint_enabled       = optional(bool, true)
    metadata_http_put_response_hop_limit = optional(number, 2)
    metadata_http_tokens_required        = optional(bool, true)
    metadata_http_protocol_ipv6_enabled  = optional(bool, false)
    tag_specifications_resource_types    = optional(set(string), ["instance", "volume"])
    max_instance_lifetime                = optional(number, null)
    capacity_rebalance                   = optional(bool, false)
    warm_pool = optional(object({
      pool_state                  = string
      min_size                    = number
      max_group_prepared_capacity = number
    }))
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `capacity_providers_fargate` (`bool`) <i>optional</i>


Use FARGATE capacity provider<br/>

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


### `capacity_providers_fargate_spot` (`bool`) <i>optional</i>


Use FARGATE_SPOT capacity provider<br/>

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


### `container_insights_enabled` (`bool`) <i>optional</i>


Whether or not to enable container insights<br/>

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


### `dns_delegated_component_name` (`string`) <i>optional</i>


Use this component name to read from the remote state to get the dns_delegated zone ID<br/>

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
>    <code>"dns-delegated"</code>
>   </dd>
> </dl>
>


### `dns_delegated_environment_name` (`string`) <i>optional</i>


Use this environment name to read from the remote state to get the dns_delegated zone ID<br/>

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
>    <code>"gbl"</code>
>   </dd>
> </dl>
>


### `dns_delegated_stage_name` (`string`) <i>optional</i>


Use this stage name to read from the remote state to get the dns_delegated zone ID<br/>

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


### `internal_enabled` (`bool`) <i>optional</i>


Whether to create an internal load balancer for services in this cluster<br/>

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


### `maintenance_page_path` (`string`) <i>optional</i>


The path from this directory to the text/html page to use as the maintenance page. Must be within 1024 characters<br/>

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
>    <code>"templates/503_example.html"</code>
>   </dd>
> </dl>
>


### `route53_enabled` (`bool`) <i>optional</i>


Whether or not to create a route53 record for the ALB<br/>

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


### `route53_record_name` (`string`) <i>optional</i>


The route53 record name<br/>

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
>    <code>"*"</code>
>   </dd>
> </dl>
>



---
### Context Variables

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

### Outputs

<dl>
  <dt><code>alb</code></dt>
  <dd>
    ALB outputs<br/>

  </dd>
  <dt><code>cluster_arn</code></dt>
  <dd>
    ECS cluster ARN<br/>

  </dd>
  <dt><code>cluster_name</code></dt>
  <dd>
    ECS Cluster Name<br/>

  </dd>
  <dt><code>private_subnet_ids</code></dt>
  <dd>
    Private subnet ids<br/>

  </dd>
  <dt><code>public_subnet_ids</code></dt>
  <dd>
    Public subnet ids<br/>

  </dd>
  <dt><code>records</code></dt>
  <dd>
    Record names<br/>

  </dd>
  <dt><code>security_group_id</code></dt>
  <dd>
    Security group id<br/>

  </dd>
  <dt><code>vpc_id</code></dt>
  <dd>
    VPC ID<br/>

  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/ecs) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
