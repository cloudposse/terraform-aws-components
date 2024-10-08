---
tags:
  - component/site-to-site-vpn
  - layer/network
  - provider/aws
---

# Component: `site-to-site-vpn`

This component provisions a [Site-To-Site VPN](https://aws.amazon.com/vpn/site-to-site-vpn/) with a target AWS VPC on
one side of the tunnel. The other (customer) side can be any VPN gateway endpoint, e.g. a hardware device, other cloud
VPN, etc.

AWS Site-to-Site VPN is a fully-managed service that creates a secure connection between your data center or branch
office and your AWS resources using IP Security (IPSec) tunnels. When using Site-to-Site VPN, you can connect to both
your Amazon Virtual Private Clouds (VPC) and AWS Transit Gateway, and two tunnels per connection are used for increased
redundancy.

The component provisions the following resources:

- AWS Virtual Private Gateway (a representation of the AWS side of the tunnel)

- AWS Customer Gateway (a representation of the other (remote) side of the tunnel). It requires:

  - The gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN)
  - `/32` IP of the VPN endpoint

- AWS Site-To-Site VPN connection. It creates two VPN tunnels for redundancy and requires:

  - The IP CIDR ranges on each side of the tunnel
  - Pre-shared Keys for each tunnel (can be auto-generated if not provided and saved into SSM Parameter Store)
  - (Optional) IP CIDR ranges to be used inside each VPN tunnel

- Route table entries to direct the appropriate traffic from the local VPC to the other side of the tunnel

## Post-tunnel creation requirements

Once the site-to-site VPN resources are deployed, you need to send the VPN configuration from AWS side to the
administrator of the remote side of the VPN connection. To do this:

1. Determine the infrastructure that will be used for the remote side, specifically:

- Vendor
- Platform
- Software Version
- IKE version

1. Log into the target AWS account
1. Go to the "VPC" console
1. On the left navigation manu, go to `Virtual Private Network` > `Site-to-Site VPN Connections`
1. Select the VPN connection that was created via this component
1. On the top right, click the `Download Configuration` button
1. Enter the information you obtained and click `Download`
1. Send the configuration file to the administrator of the remote side of the tunnel

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    site-to-site-vpn:
      metadata:
        component: site-to-site-vpn
      vars:
        enabled: true
        name: "site-to-site-vpn"
        vpc_component_name: vpc
        customer_gateway_bgp_asn: 65000
        customer_gateway_ip_address: 20.200.30.0
        vpn_gateway_amazon_side_asn: 64512
        vpn_connection_static_routes_only: true
        vpn_connection_tunnel1_inside_cidr: 169.254.20.0/30
        vpn_connection_tunnel2_inside_cidr: 169.254.21.0/30
        vpn_connection_local_ipv4_network_cidr: 10.100.128.0/24
        vpn_connection_remote_ipv4_network_cidr: 10.10.80.0/24
        vpn_connection_static_routes_destinations:
          - 10.100.128.0/24
        vpn_connection_tunnel1_startup_action: add
        vpn_connection_tunnel2_startup_action: add
        transit_gateway_enabled: false
        vpn_connection_tunnel1_cloudwatch_log_enabled: false
        vpn_connection_tunnel2_cloudwatch_log_enabled: false
        preshared_key_enabled: true
        ssm_enabled: true
        ssm_path_prefix: "/site-to-site-vpn"
```

## Amazon side Autonomous System Number (ASN)

The variable `vpn_gateway_amazon_side_asn` (Amazon side Autonomous System Number) is not strictly required when creating
an AWS VPN Gateway. If you do not specify Amazon side ASN during the creation of the VPN Gateway, AWS will automatically
assign a default ASN (which is 7224 for the Amazon side of the VPN).

However, specifying Amazon side ASN can be important if you need to integrate the VPN with an on-premises network that
uses Border Gateway Protocol (BGP) and you want to avoid ASN conflicts or require a specific ASN for routing policies.

If your use case involves BGP peering, and you need a specific ASN for the Amazon side, then you should explicitly set
the `vpn_gateway_amazon_side_asn`. Otherwise, it can be omitted (set to `null`), and AWS will handle it automatically.

## Provisioning

Provision the `site-to-site-vpn` component by executing the following commands:

```sh
atmos terraform plan site-to-site-vpn -s <stack>
atmos terraform apply site-to-site-vpn -s <stack>
```

## References

- https://aws.amazon.com/vpn/site-to-site-vpn
- https://docs.aws.amazon.com/vpn/latest/s2svpn/VPC_VPN.html
- https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_VpnTunnelOptionsSpecification.html

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_vpn_connection"></a> [vpn\_connection](#module\_vpn\_connection) | cloudposse/vpn-connection/aws | 1.3.1 |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.tunnel1_preshared_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.tunnel2_preshared_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_password.tunnel1_preshared_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.tunnel2_preshared_key](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_customer_gateway_bgp_asn"></a> [customer\_gateway\_bgp\_asn](#input\_customer\_gateway\_bgp\_asn) | The Customer Gateway's Border Gateway Protocol (BGP) Autonomous System Number (ASN) | `number` | n/a | yes |
| <a name="input_customer_gateway_ip_address"></a> [customer\_gateway\_ip\_address](#input\_customer\_gateway\_ip\_address) | The IPv4 address for the Customer Gateway device's outside interface. Set to `null` to not create the Customer Gateway | `string` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_existing_transit_gateway_id"></a> [existing\_transit\_gateway\_id](#input\_existing\_transit\_gateway\_id) | Existing Transit Gateway ID. If provided, the module will not create a Virtual Private Gateway but instead will use the transit\_gateway. For setting up transit gateway we can use the cloudposse/transit-gateway/aws module and pass the output transit\_gateway\_id to this variable | `string` | `""` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_preshared_key_enabled"></a> [preshared\_key\_enabled](#input\_preshared\_key\_enabled) | Flag to enable adding the preshared keys to the VPN connection | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_ssm_enabled"></a> [ssm\_enabled](#input\_ssm\_enabled) | Flag to enable saving the `tunnel1_preshared_key` and `tunnel2_preshared_key` in the SSM Parameter Store | `bool` | `false` | no |
| <a name="input_ssm_path_prefix"></a> [ssm\_path\_prefix](#input\_ssm\_path\_prefix) | SSM Key path prefix for the associated SSM parameters | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_transit_gateway_enabled"></a> [transit\_gateway\_enabled](#input\_transit\_gateway\_enabled) | Set to true to enable VPN connection to transit gateway and then pass in the existing\_transit\_gateway\_id | `bool` | `false` | no |
| <a name="input_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#input\_transit\_gateway\_route\_table\_id) | The ID of the route table for the transit gateway that you want to associate + propagate the VPN connection's TGW attachment | `string` | `null` | no |
| <a name="input_transit_gateway_routes"></a> [transit\_gateway\_routes](#input\_transit\_gateway\_routes) | A map of transit gateway routes to create on the given TGW route table (via `transit_gateway_route_table_id`) for the created VPN Attachment. Use the key in the map to describe the route | <pre>map(object({<br/>    blackhole              = optional(bool, false)<br/>    destination_cidr_block = string<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | Atmos VPC component name | `string` | `"vpc"` | no |
| <a name="input_vpn_connection_local_ipv4_network_cidr"></a> [vpn\_connection\_local\_ipv4\_network\_cidr](#input\_vpn\_connection\_local\_ipv4\_network\_cidr) | The IPv4 CIDR on the Customer Gateway (on-premises) side of the VPN connection | `string` | `"0.0.0.0/0"` | no |
| <a name="input_vpn_connection_log_retention_in_days"></a> [vpn\_connection\_log\_retention\_in\_days](#input\_vpn\_connection\_log\_retention\_in\_days) | Specifies the number of days you want to retain log events | `number` | `30` | no |
| <a name="input_vpn_connection_remote_ipv4_network_cidr"></a> [vpn\_connection\_remote\_ipv4\_network\_cidr](#input\_vpn\_connection\_remote\_ipv4\_network\_cidr) | The IPv4 CIDR on the AWS side of the VPN connection | `string` | `"0.0.0.0/0"` | no |
| <a name="input_vpn_connection_static_routes_destinations"></a> [vpn\_connection\_static\_routes\_destinations](#input\_vpn\_connection\_static\_routes\_destinations) | List of CIDR blocks to be used as destination for static routes. Routes to destinations will be propagated to the VPC route tables | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_static_routes_only"></a> [vpn\_connection\_static\_routes\_only](#input\_vpn\_connection\_static\_routes\_only) | If set to `true`, the VPN connection will use static routes exclusively. Static routes must be used for devices that don't support BGP | `bool` | `false` | no |
| <a name="input_vpn_connection_tunnel1_cloudwatch_log_enabled"></a> [vpn\_connection\_tunnel1\_cloudwatch\_log\_enabled](#input\_vpn\_connection\_tunnel1\_cloudwatch\_log\_enabled) | Enable or disable VPN tunnel logging feature for the tunnel | `bool` | `false` | no |
| <a name="input_vpn_connection_tunnel1_cloudwatch_log_output_format"></a> [vpn\_connection\_tunnel1\_cloudwatch\_log\_output\_format](#input\_vpn\_connection\_tunnel1\_cloudwatch\_log\_output\_format) | Set log format for the tunnel. Default format is json. Possible values are `json` and `text` | `string` | `"json"` | no |
| <a name="input_vpn_connection_tunnel1_dpd_timeout_action"></a> [vpn\_connection\_tunnel1\_dpd\_timeout\_action](#input\_vpn\_connection\_tunnel1\_dpd\_timeout\_action) | The action to take after DPD timeout occurs for the first VPN tunnel. Specify restart to restart the IKE initiation. Specify `clear` to end the IKE session. Valid values are `clear` \| `none` \| `restart` | `string` | `"clear"` | no |
| <a name="input_vpn_connection_tunnel1_ike_versions"></a> [vpn\_connection\_tunnel1\_ike\_versions](#input\_vpn\_connection\_tunnel1\_ike\_versions) | The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 \| ikev2 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_inside_cidr"></a> [vpn\_connection\_tunnel1\_inside\_cidr](#input\_vpn\_connection\_tunnel1\_inside\_cidr) | The CIDR block of the inside IP addresses for the first VPN tunnel | `string` | `null` | no |
| <a name="input_vpn_connection_tunnel1_phase1_dh_group_numbers"></a> [vpn\_connection\_tunnel1\_phase1\_dh\_group\_numbers](#input\_vpn\_connection\_tunnel1\_phase1\_dh\_group\_numbers) | List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are 2 \| 5 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_phase1_encryption_algorithms"></a> [vpn\_connection\_tunnel1\_phase1\_encryption\_algorithms](#input\_vpn\_connection\_tunnel1\_phase1\_encryption\_algorithms) | List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_phase1_integrity_algorithms"></a> [vpn\_connection\_tunnel1\_phase1\_integrity\_algorithms](#input\_vpn\_connection\_tunnel1\_phase1\_integrity\_algorithms) | One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_phase2_dh_group_numbers"></a> [vpn\_connection\_tunnel1\_phase2\_dh\_group\_numbers](#input\_vpn\_connection\_tunnel1\_phase2\_dh\_group\_numbers) | List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are 2 \| 5 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_phase2_encryption_algorithms"></a> [vpn\_connection\_tunnel1\_phase2\_encryption\_algorithms](#input\_vpn\_connection\_tunnel1\_phase2\_encryption\_algorithms) | List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_phase2_integrity_algorithms"></a> [vpn\_connection\_tunnel1\_phase2\_integrity\_algorithms](#input\_vpn\_connection\_tunnel1\_phase2\_integrity\_algorithms) | One or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel1_preshared_key"></a> [vpn\_connection\_tunnel1\_preshared\_key](#input\_vpn\_connection\_tunnel1\_preshared\_key) | The preshared key of the first VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero. Allowed characters are alphanumeric characters, periods(.) and underscores(\_) | `string` | `null` | no |
| <a name="input_vpn_connection_tunnel1_startup_action"></a> [vpn\_connection\_tunnel1\_startup\_action](#input\_vpn\_connection\_tunnel1\_startup\_action) | The action to take when the establishing the tunnel for the first VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify `start` for AWS to initiate the IKE negotiation. Valid values are `add` \| `start` | `string` | `"add"` | no |
| <a name="input_vpn_connection_tunnel2_cloudwatch_log_enabled"></a> [vpn\_connection\_tunnel2\_cloudwatch\_log\_enabled](#input\_vpn\_connection\_tunnel2\_cloudwatch\_log\_enabled) | Enable or disable VPN tunnel logging feature for the tunnel | `bool` | `false` | no |
| <a name="input_vpn_connection_tunnel2_cloudwatch_log_output_format"></a> [vpn\_connection\_tunnel2\_cloudwatch\_log\_output\_format](#input\_vpn\_connection\_tunnel2\_cloudwatch\_log\_output\_format) | Set log format for the tunnel. Default format is json. Possible values are `json` and `text` | `string` | `"json"` | no |
| <a name="input_vpn_connection_tunnel2_dpd_timeout_action"></a> [vpn\_connection\_tunnel2\_dpd\_timeout\_action](#input\_vpn\_connection\_tunnel2\_dpd\_timeout\_action) | The action to take after DPD timeout occurs for the second VPN tunnel. Specify restart to restart the IKE initiation. Specify clear to end the IKE session. Valid values are `clear` \| `none` \| `restart` | `string` | `"clear"` | no |
| <a name="input_vpn_connection_tunnel2_ike_versions"></a> [vpn\_connection\_tunnel2\_ike\_versions](#input\_vpn\_connection\_tunnel2\_ike\_versions) | The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 \| ikev2 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_inside_cidr"></a> [vpn\_connection\_tunnel2\_inside\_cidr](#input\_vpn\_connection\_tunnel2\_inside\_cidr) | The CIDR block of the inside IP addresses for the second VPN tunnel | `string` | `null` | no |
| <a name="input_vpn_connection_tunnel2_phase1_dh_group_numbers"></a> [vpn\_connection\_tunnel2\_phase1\_dh\_group\_numbers](#input\_vpn\_connection\_tunnel2\_phase1\_dh\_group\_numbers) | List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are 2 \| 5 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_phase1_encryption_algorithms"></a> [vpn\_connection\_tunnel2\_phase1\_encryption\_algorithms](#input\_vpn\_connection\_tunnel2\_phase1\_encryption\_algorithms) | List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_phase1_integrity_algorithms"></a> [vpn\_connection\_tunnel2\_phase1\_integrity\_algorithms](#input\_vpn\_connection\_tunnel2\_phase1\_integrity\_algorithms) | One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_phase2_dh_group_numbers"></a> [vpn\_connection\_tunnel2\_phase2\_dh\_group\_numbers](#input\_vpn\_connection\_tunnel2\_phase2\_dh\_group\_numbers) | List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are 2 \| 5 \| 14 \| 15 \| 16 \| 17 \| 18 \| 19 \| 20 \| 21 \| 22 \| 23 \| 24 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_phase2_encryption_algorithms"></a> [vpn\_connection\_tunnel2\_phase2\_encryption\_algorithms](#input\_vpn\_connection\_tunnel2\_phase2\_encryption\_algorithms) | List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 \| AES256 \| AES128-GCM-16 \| AES256-GCM-16 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_phase2_integrity_algorithms"></a> [vpn\_connection\_tunnel2\_phase2\_integrity\_algorithms](#input\_vpn\_connection\_tunnel2\_phase2\_integrity\_algorithms) | One or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 \| SHA2-256 \| SHA2-384 \| SHA2-512 | `list(string)` | `[]` | no |
| <a name="input_vpn_connection_tunnel2_preshared_key"></a> [vpn\_connection\_tunnel2\_preshared\_key](#input\_vpn\_connection\_tunnel2\_preshared\_key) | The preshared key of the second VPN tunnel. The preshared key must be between 8 and 64 characters in length and cannot start with zero. Allowed characters are alphanumeric characters, periods(.) and underscores(\_) | `string` | `null` | no |
| <a name="input_vpn_connection_tunnel2_startup_action"></a> [vpn\_connection\_tunnel2\_startup\_action](#input\_vpn\_connection\_tunnel2\_startup\_action) | The action to take when the establishing the tunnel for the second VPN connection. By default, your customer gateway device must initiate the IKE negotiation and bring up the tunnel. Specify `start` for AWS to initiate the IKE negotiation. Valid values are `add` \| `start` | `string` | `"add"` | no |
| <a name="input_vpn_gateway_amazon_side_asn"></a> [vpn\_gateway\_amazon\_side\_asn](#input\_vpn\_gateway\_amazon\_side\_asn) | The Autonomous System Number (ASN) for the Amazon side of the VPN Gateway. If you don't specify an ASN, the Virtual Private Gateway is created with the default ASN | `number` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_customer_gateway_id"></a> [customer\_gateway\_id](#output\_customer\_gateway\_id) | Customer Gateway ID |
| <a name="output_vpn_connection_customer_gateway_configuration"></a> [vpn\_connection\_customer\_gateway\_configuration](#output\_vpn\_connection\_customer\_gateway\_configuration) | The configuration information for the VPN connection's Customer Gateway (in the native XML format) |
| <a name="output_vpn_connection_id"></a> [vpn\_connection\_id](#output\_vpn\_connection\_id) | VPN Connection ID |
| <a name="output_vpn_connection_tunnel1_address"></a> [vpn\_connection\_tunnel1\_address](#output\_vpn\_connection\_tunnel1\_address) | The public IP address of the first VPN tunnel |
| <a name="output_vpn_connection_tunnel1_cgw_inside_address"></a> [vpn\_connection\_tunnel1\_cgw\_inside\_address](#output\_vpn\_connection\_tunnel1\_cgw\_inside\_address) | The RFC 6890 link-local address of the first VPN tunnel (Customer Gateway side) |
| <a name="output_vpn_connection_tunnel1_vgw_inside_address"></a> [vpn\_connection\_tunnel1\_vgw\_inside\_address](#output\_vpn\_connection\_tunnel1\_vgw\_inside\_address) | The RFC 6890 link-local address of the first VPN tunnel (Virtual Private Gateway side) |
| <a name="output_vpn_connection_tunnel2_address"></a> [vpn\_connection\_tunnel2\_address](#output\_vpn\_connection\_tunnel2\_address) | The public IP address of the second VPN tunnel |
| <a name="output_vpn_connection_tunnel2_cgw_inside_address"></a> [vpn\_connection\_tunnel2\_cgw\_inside\_address](#output\_vpn\_connection\_tunnel2\_cgw\_inside\_address) | The RFC 6890 link-local address of the second VPN tunnel (Customer Gateway side) |
| <a name="output_vpn_connection_tunnel2_vgw_inside_address"></a> [vpn\_connection\_tunnel2\_vgw\_inside\_address](#output\_vpn\_connection\_tunnel2\_vgw\_inside\_address) | The RFC 6890 link-local address of the second VPN tunnel (Virtual Private Gateway side) |
| <a name="output_vpn_gateway_id"></a> [vpn\_gateway\_id](#output\_vpn\_gateway\_id) | Virtual Private Gateway ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/site-to-site-vpn) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
