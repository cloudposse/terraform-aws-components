---
tags:
  - component/ec2-client-vpn
  - layer/network
  - provider/aws
---

# Component: `ec2-client-vpn`

This component is responsible for provisioning VPN Client Endpoints.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component. This component should only be applied once as the resources it
creates are regional. This is typically done via the corp stack (e.g. `uw2-corp.yaml`). This is because a vpc endpoint
requires a vpc and the network stack does not have a vpc.

```yaml
components:
  terraform:
    ec2-client-vpn:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        client_cidr: 10.100.0.0/10
        logging_stream_name: client_vpn
        logging_enabled: true
        retention_in_days: 7
        organization_name: acme
        split_tunnel: true
        availability_zones:
          - us-west-2a
          - us-west-2b
          - us-west-2c
        associated_security_group_ids: []
        additional_routes:
          - destination_cidr_block: 0.0.0.0/0
            description: Internet Route
        authorization_rules:
          - name: Internet Rule
            authorize_all_groups: true
            description: Allows routing to the internet"
            target_network_cidr: 0.0.0.0/0
```

## Deploying

NOTE: This module uses the `aws_ec2_client_vpn_route` resource which throws an error if too many API calls come from a
single host. Ignore this error and repeat the terraform command. It usually takes 3 deploys (or destroys) to complete.

Error on create (See issue https://github.com/hashicorp/terraform-provider-aws/issues/19750)

```
ConcurrentMutationLimitExceeded: Cannot initiate another change for this endpoint at this time. Please try again later.
```

Error on destroy (See issue https://github.com/hashicorp/terraform-provider-aws/issues/16645)

```
timeout while waiting for resource to be gone (last state: 'deleting', timeout: 1m0s)
```

## Testing

NOTE: The `GoogleIDPMetadata-cloudposse.com.xml` in this repo is equivalent to the one in the `sso` component and is
used for testing. This component can only specify a single SAML document. The customer SAML xml should be placed in this
directory side-by-side the CloudPosse SAML xml.

Prior to testing, the component needs to be deployed and the AWS client app needs to be setup by the IdP admin otherwise
the following steps will result in an error similar to `app_not_configured_for_user`.

1. Deploy the component in a regional account with a VPC like `ue2-corp`.
1. Copy the contents of `client_configuration` into a file called `client_configuration.ovpn`
1. Download AWS client VPN `brew install --cask aws-vpn-client`
1. Launch the VPN
1. File > Manage Profiles to open the Manage Profiles window
1. Click Add Profile to open the Add Profile window
1. Set the display name e.g. `<tenant>-<environment>-<stage>`
1. Click the folder icon and find the file that was saved in a previous step
1. Click Add Profile to save the profile
1. Click Done to close to Manage Profiles window
1. Under "Ready to connect.", choose the profile, and click Connect

A browser will launch and allow you to connect to the VPN.

1.  Make a note of where this component is deployed
1.  Ensure that the resource to connect to is in a VPC that is connected by the transit gateway
1.  Ensure that the resource to connect to contains a security group with a rule that allows ingress from where the
    client vpn is deployed (e.g. `ue2-corp`)
1.  Use `nmap` to test if the port is `open`. If the port is `filtered` then it's not open.

```console
nmap -p <PORT> <HOST>
```

Successful tests have been seen with MSK and RDS.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_awsutils"></a> [awsutils](#requirement\_awsutils) | >= 0.11.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2_client_vpn"></a> [ec2\_client\_vpn](#module\_ec2\_client\_vpn) | cloudposse/ec2-client-vpn/aws | 0.14.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_associated_security_group_ids"></a> [associated\_security\_group\_ids](#input\_associated\_security\_group\_ids) | List of security groups to attach to the client vpn network associations | `list(string)` | `[]` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_authentication_type"></a> [authentication\_type](#input\_authentication\_type) | One of `certificate-authentication` or `federated-authentication` | `string` | `"certificate-authentication"` | no |
| <a name="input_authorization_rules"></a> [authorization\_rules](#input\_authorization\_rules) | List of objects describing the authorization rules for the Client VPN. Each Target Network CIDR range given will be used to create an additional route attached to the Client VPN endpoint with the same Description. | <pre>list(object({<br>    name                 = string<br>    access_group_id      = string<br>    authorize_all_groups = bool<br>    description          = string<br>    target_network_cidr  = string<br>  }))</pre> | n/a | yes |
| <a name="input_ca_common_name"></a> [ca\_common\_name](#input\_ca\_common\_name) | Unique Common Name for CA self-signed certificate | `string` | `null` | no |
| <a name="input_client_cidr"></a> [client\_cidr](#input\_client\_cidr) | Network CIDR to use for clients | `string` | n/a | yes |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the VPC that is to be associated with Client VPN endpoint is used as the DNS server. | `list(string)` | `[]` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_export_client_certificate"></a> [export\_client\_certificate](#input\_export\_client\_certificate) | Flag to determine whether to export the client certificate with the VPN configuration | `bool` | `true` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Enables or disables Client VPN Cloudwatch logging. | `bool` | `false` | no |
| <a name="input_logging_stream_name"></a> [logging\_stream\_name](#input\_logging\_stream\_name) | Names of stream used for logging | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_organization_name"></a> [organization\_name](#input\_organization\_name) | Name of organization to use in private certificate | `string` | n/a | yes |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | VPN Endpoints are region-specific. This identifies the region. AWS Region | `string` | n/a | yes |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Number of days you want to retain log events in the log group | `number` | `30` | no |
| <a name="input_root_common_name"></a> [root\_common\_name](#input\_root\_common\_name) | Unique Common Name for Root self-signed certificate | `string` | `null` | no |
| <a name="input_saml_metadata_document"></a> [saml\_metadata\_document](#input\_saml\_metadata\_document) | Optional SAML metadata document. Must include this or `saml_provider_arn` | `string` | `null` | no |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn) | Optional SAML provider ARN. Must include this or `saml_metadata_document` | `string` | `null` | no |
| <a name="input_server_common_name"></a> [server\_common\_name](#input\_server\_common\_name) | Unique Common Name for Server self-signed certificate | `string` | `null` | no |
| <a name="input_split_tunnel"></a> [split\_tunnel](#input\_split\_tunnel) | Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false. | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | VPN Client Configuration file (.ovpn) contents that can be imported into AWS client vpn |
| <a name="output_full_client_configuration"></a> [full\_client\_configuration](#output\_full\_client\_configuration) | Client configuration including client certificate and private key for mutual authentication |
| <a name="output_vpn_endpoint_arn"></a> [vpn\_endpoint\_arn](#output\_vpn\_endpoint\_arn) | The ARN of the Client VPN Endpoint Connection. |
| <a name="output_vpn_endpoint_dns_name"></a> [vpn\_endpoint\_dns\_name](#output\_vpn\_endpoint\_dns\_name) | The DNS Name of the Client VPN Endpoint Connection. |
| <a name="output_vpn_endpoint_id"></a> [vpn\_endpoint\_id](#output\_vpn\_endpoint\_id) | The ID of the Client VPN Endpoint Connection. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-ec2-client-vpn](https://github.com/cloudposse/terraform-aws-ec2-client-vpn) - Cloud Posse's
  upstream component
- [cloudposse/awsutils](https://github.com/cloudposse/terraform-provider-awsutils) - Cloud Posse's awsutils provider

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
