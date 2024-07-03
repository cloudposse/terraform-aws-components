# Component: `vpc`

This component is responsible for provisioning a VPC and corresponding Subnets. Additionally, VPC Flow Logs can
optionally be enabled for auditing purposes. See the existing VPC configuration documentation for the provisioned
subnets.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
# catalog/vpc/defaults or catalog/vpc
components:
  terraform:
    vpc/defaults:
      metadata:
        type: abstract
        component: vpc
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: vpc
        availability_zones:
          - "a"
          - "b"
          - "c"
        nat_gateway_enabled: true
        nat_instance_enabled: false
        max_subnet_count: 3
        vpc_flow_logs_enabled: true
        vpc_flow_logs_bucket_environment_name: <environment>
        vpc_flow_logs_bucket_stage_name: audit
        vpc_flow_logs_traffic_type: "ALL"
        subnet_type_tag_key: "example.net/subnet/type"
        assign_generated_ipv6_cidr_block: true
```

```yaml
import:
  - catalog/vpc

components:
  terraform:
    vpc:
      metadata:
        component: vpc
        inherits:
          - vpc/defaults
      vars:
        ipv4_primary_cidr_block: "10.111.0.0/18"
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
`endpoint_security_groups` | 2.2.0 | [`cloudposse/security-group/aws`](https://registry.terraform.io/modules/cloudposse/security-group/aws/2.2.0) | We could create a security group per endpoint, but until we are ready to customize them by service, it is just a waste of resources. We use a single security group for all endpoints. Security groups can be updated without recreating the endpoint or interrupting service, so this is an easy change to make later.
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`subnets` | 2.4.2 | [`cloudposse/dynamic-subnets/aws`](https://registry.terraform.io/modules/cloudposse/dynamic-subnets/aws/2.4.2) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`utils` | 1.3.0 | [`cloudposse/utils/aws`](https://registry.terraform.io/modules/cloudposse/utils/aws/1.3.0) | n/a
`vpc` | 2.1.0 | [`cloudposse/vpc/aws`](https://registry.terraform.io/modules/cloudposse/vpc/aws/2.1.0) | n/a
`vpc_endpoints` | 2.1.0 | [`cloudposse/vpc/aws//modules/vpc-endpoints`](https://registry.terraform.io/modules/cloudposse/vpc/aws/modules/vpc-endpoints/2.1.0) | n/a
`vpc_flow_logs_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_flow_log.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) (resource)
  - [`aws_shield_protection.nat_eip_shield_protection`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/shield_protection) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_eip.eip`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eip) (data source)

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
  <dt>`subnet_type_tag_key` (`string`) <i>required</i></dt>
  <dd>
    Key for subnet type tag to provide information about the type of subnets, e.g. `cpco/subnet/type=private` or `cpcp/subnet/type=public`<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`assign_generated_ipv6_cidr_block` (`bool`) <i>optional</i></dt>
  <dd>
    When `true`, assign AWS generated IPv6 CIDR block to the VPC.  Conflicts with `ipv6_ipam_pool_id`.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`availability_zone_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of Availability Zones IDs where subnets will be created. Overrides `availability_zones`.<br/>
    Can be the full name, e.g. `use1-az1`, or just the part after the AZ ID region code, e.g. `-az1`,<br/>
    to allow reusable values across regions. Consider contention for resources and spot pricing in each AZ when selecting.<br/>
    Useful in some regions when using only some AZs and you want to use the same ones across multiple accounts.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`availability_zones` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of Availability Zones (AZs) where subnets will be created. Ignored when `availability_zone_ids` is set.<br/>
    Can be the full name, e.g. `us-east-1a`, or just the part after the region, e.g. `a` to allow reusable values across regions.<br/>
    The order of zones in the list ***must be stable*** or else Terraform will continually make changes.<br/>
    If no AZs are specified, then `max_subnet_count` AZs will be selected in alphabetical order.<br/>
    If `max_subnet_count > 0` and `length(var.availability_zones) > max_subnet_count`, the list<br/>
    will be truncated. We recommend setting `availability_zones` and `max_subnet_count` explicitly as constant<br/>
    (not computed) values for predictability, consistency, and stability.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`gateway_vpc_endpoints` (`set(string)`) <i>optional</i></dt>
  <dd>
    A list of Gateway VPC Endpoints to provision into the VPC. Only valid values are "dynamodb" and "s3".<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`interface_vpc_endpoints` (`set(string)`) <i>optional</i></dt>
  <dd>
    A list of Interface VPC Endpoints to provision into the VPC.<br/>
    <br/>
    **Type:** `set(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`ipv4_additional_cidr_block_associations` <i>optional</i></dt>
  <dd>
    IPv4 CIDR blocks to assign to the VPC.<br/>
    `ipv4_cidr_block` can be set explicitly, or set to `null` with the CIDR block derived from `ipv4_ipam_pool_id` using `ipv4_netmask_length`.<br/>
    Map keys must be known at `plan` time, and are only used to track changes.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    map(object({
    ipv4_cidr_block     = string
    ipv4_ipam_pool_id   = string
    ipv4_netmask_length = number
  }))
    ```
    
    <br/>
    **Default value:** `{}`
  </dd>
  <dt>`ipv4_cidr_block_association_timeouts` <i>optional</i></dt>
  <dd>
    Timeouts (in `go` duration format) for creating and destroying IPv4 CIDR block associations<br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    create = string
    delete = string
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ipv4_cidrs` <i>optional</i></dt>
  <dd>
    Lists of CIDRs to assign to subnets. Order of CIDRs in the lists must not change over time.<br/>
    Lists may contain more CIDRs than needed.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    list(object({
    private = list(string)
    public  = list(string)
  }))
    ```
    
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`ipv4_primary_cidr_block` (`string`) <i>optional</i></dt>
  <dd>
    The primary IPv4 CIDR block for the VPC.<br/>
    Either `ipv4_primary_cidr_block` or `ipv4_primary_cidr_block_association` must be set, but not both.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`ipv4_primary_cidr_block_association` <i>optional</i></dt>
  <dd>
    Configuration of the VPC's primary IPv4 CIDR block via IPAM. Conflicts with `ipv4_primary_cidr_block`.<br/>
    One of `ipv4_primary_cidr_block` or `ipv4_primary_cidr_block_association` must be set.<br/>
    Additional CIDR blocks can be set via `ipv4_additional_cidr_block_associations`.<br/>
    <br/>
    <br/>
    **Type:** 

    ```hcl
    object({
    ipv4_ipam_pool_id   = string
    ipv4_netmask_length = number
  })
    ```
    
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`map_public_ip_on_launch` (`bool`) <i>optional</i></dt>
  <dd>
    Instances launched into a public subnet should be assigned a public IP address<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`max_subnet_count` (`number`) <i>optional</i></dt>
  <dd>
    Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availability zone (in `region_availability_zones` variable) within the region<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `0`
  </dd>
  <dt>`nat_eip_aws_shield_protection_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable or disable AWS Shield Advanced protection for NAT EIPs. If set to 'true', a subscription to AWS Shield Advanced must exist in this account.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`nat_gateway_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable NAT gateways<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`nat_instance_ami_id` (`list(string)`) <i>optional</i></dt>
  <dd>
    A list optionally containing the ID of the AMI to use for the NAT instance.<br/>
    If the list is empty (the default), the latest official AWS NAT instance AMI<br/>
    will be used. NOTE: The Official NAT instance AMI is being phased out and<br/>
    does not support NAT64. Use of a NAT gateway is recommended instead.<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`nat_instance_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to enable/disable NAT instances<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`nat_instance_type` (`string`) <i>optional</i></dt>
  <dd>
    NAT Instance type<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"t3.micro"`
  </dd>
  <dt>`public_subnets_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    If false, do not create public subnets.<br/>
    Since NAT gateways and instances must be created in public subnets, these will also not be created when `false`.<br/>
    <br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`subnets_per_az_count` (`number`) <i>optional</i></dt>
  <dd>
    The number of subnet of each type (public or private) to provision per Availability Zone.<br/>
    <br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `1`
  </dd>
  <dt>`subnets_per_az_names` (`list(string)`) <i>optional</i></dt>
  <dd>
    The subnet names of each type (public or private) to provision per Availability Zone.<br/>
    This variable is optional.<br/>
    If a list of names is provided, the list items will be used as keys in the outputs `named_private_subnets_map`, `named_public_subnets_map`,<br/>
    `named_private_route_table_ids_map` and `named_public_route_table_ids_map`<br/>
    <br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** 
    ```hcl
    [
      "common"
    ]
    ```
    
  </dd>
  <dt>`vpc_flow_logs_bucket_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where the VPC Flow Logs bucket is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`vpc_flow_logs_bucket_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The stage (account) name where the VPC Flow Logs bucket is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`vpc_flow_logs_bucket_tenant_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the tenant where the VPC Flow Logs bucket is provisioned.<br/>
    <br/>
    If the `tenant` label is not used, leave this as `null`.<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`vpc_flow_logs_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enable or disable the VPC Flow Logs<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`vpc_flow_logs_log_destination_type` (`string`) <i>optional</i></dt>
  <dd>
    The type of the logging destination. Valid values: `cloud-watch-logs`, `s3`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"s3"`
  </dd>
  <dt>`vpc_flow_logs_traffic_type` (`string`) <i>optional</i></dt>
  <dd>
    The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"ALL"`
  </dd></dl>


### Outputs

<dl>
  <dt>`availability_zones`</dt>
  <dd>
    List of Availability Zones where subnets were created<br/>
  </dd>
  <dt>`az_private_subnets_map`</dt>
  <dd>
    Map of AZ names to list of private subnet IDs in the AZs<br/>
  </dd>
  <dt>`az_public_subnets_map`</dt>
  <dd>
    Map of AZ names to list of public subnet IDs in the AZs<br/>
  </dd>
  <dt>`interface_vpc_endpoints`</dt>
  <dd>
    List of Interface VPC Endpoints in this VPC.<br/>
  </dd>
  <dt>`max_subnet_count`</dt>
  <dd>
    Maximum allowed number of subnets before all subnet CIDRs need to be recomputed<br/>
  </dd>
  <dt>`nat_eip_protections`</dt>
  <dd>
    List of AWS Shield Advanced Protections for NAT Elastic IPs.<br/>
  </dd>
  <dt>`nat_gateway_ids`</dt>
  <dd>
    NAT Gateway IDs<br/>
  </dd>
  <dt>`nat_gateway_public_ips`</dt>
  <dd>
    NAT Gateway public IPs<br/>
  </dd>
  <dt>`nat_instance_ids`</dt>
  <dd>
    NAT Instance IDs<br/>
  </dd>
  <dt>`private_route_table_ids`</dt>
  <dd>
    Private subnet route table IDs<br/>
  </dd>
  <dt>`private_subnet_cidrs`</dt>
  <dd>
    Private subnet CIDRs<br/>
  </dd>
  <dt>`private_subnet_ids`</dt>
  <dd>
    Private subnet IDs<br/>
  </dd>
  <dt>`public_route_table_ids`</dt>
  <dd>
    Public subnet route table IDs<br/>
  </dd>
  <dt>`public_subnet_cidrs`</dt>
  <dd>
    Public subnet CIDRs<br/>
  </dd>
  <dt>`public_subnet_ids`</dt>
  <dd>
    Public subnet IDs<br/>
  </dd>
  <dt>`route_tables`</dt>
  <dd>
    Route tables info map<br/>
  </dd>
  <dt>`subnets`</dt>
  <dd>
    Subnets info map<br/>
  </dd>
  <dt>`vpc`</dt>
  <dd>
    VPC info map<br/>
  </dd>
  <dt>`vpc_cidr`</dt>
  <dd>
    VPC CIDR<br/>
  </dd>
  <dt>`vpc_default_network_acl_id`</dt>
  <dd>
    The ID of the network ACL created by default on VPC creation<br/>
  </dd>
  <dt>`vpc_default_security_group_id`</dt>
  <dd>
    The ID of the security group created by default on VPC creation<br/>
  </dd>
  <dt>`vpc_id`</dt>
  <dd>
    VPC ID<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/vpc) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
