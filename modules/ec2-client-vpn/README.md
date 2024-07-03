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

        nmap -p <PORT> <HOST>

Successful tests have been seen with MSK and RDS.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 1.0), version: >= 1.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 4.0), version: >= 4.0
- [`awsutils`](https://registry.terraform.io/modules/awsutils/>= 0.11.0), version: >= 0.11.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state



### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`ec2_client_vpn` | 0.14.0 | [`cloudposse/ec2-client-vpn/aws`](https://registry.terraform.io/modules/cloudposse/ec2-client-vpn/aws/0.14.0) | n/a
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
  <dt>`authorization_rules` <i>required</i></dt>
  <dd>
    List of objects describing the authorization rules for the Client VPN. Each Target Network CIDR range given will be used to create an additional route attached to the Client VPN endpoint with the same Description.<br/>

    **Type:** 

    ```hcl
    list(object({
    name                 = string
    access_group_id      = string
    authorize_all_groups = bool
    description          = string
    target_network_cidr  = string
  }))
    ```
    
    <br/>
    **Default value:** ``

  </dd>
  <dt>`client_cidr` (`string`) <i>required</i></dt>
  <dd>
    Network CIDR to use for clients<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`logging_stream_name` (`string`) <i>required</i></dt>
  <dd>
    Names of stream used for logging<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`organization_name` (`string`) <i>required</i></dt>
  <dd>
    Name of organization to use in private certificate<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
  <dt>`region` (`string`) <i>required</i></dt>
  <dd>
    VPN Endpoints are region-specific. This identifies the region. AWS Region<br/>

    **Type:** `string`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`associated_security_group_ids` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of security groups to attach to the client vpn network associations<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`authentication_type` (`string`) <i>optional</i></dt>
  <dd>
    One of `certificate-authentication` or `federated-authentication`<br/>
    <br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"certificate-authentication"`
  </dd>
  <dt>`ca_common_name` (`string`) <i>optional</i></dt>
  <dd>
    Unique Common Name for CA self-signed certificate<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`dns_servers` (`list(string)`) <i>optional</i></dt>
  <dd>
    Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers. If no DNS server is specified, the DNS address of the VPC that is to be associated with Client VPN endpoint is used as the DNS server.<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`export_client_certificate` (`bool`) <i>optional</i></dt>
  <dd>
    Flag to determine whether to export the client certificate with the VPN configuration<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`logging_enabled` (`bool`) <i>optional</i></dt>
  <dd>
    Enables or disables Client VPN Cloudwatch logging.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd>
  <dt>`retention_in_days` (`number`) <i>optional</i></dt>
  <dd>
    Number of days you want to retain log events in the log group<br/>
    <br/>
    **Type:** `number`
    <br/>
    **Default value:** `30`
  </dd>
  <dt>`root_common_name` (`string`) <i>optional</i></dt>
  <dd>
    Unique Common Name for Root self-signed certificate<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`saml_metadata_document` (`string`) <i>optional</i></dt>
  <dd>
    Optional SAML metadata document. Must include this or `saml_provider_arn`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`saml_provider_arn` (`string`) <i>optional</i></dt>
  <dd>
    Optional SAML provider ARN. Must include this or `saml_metadata_document`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`server_common_name` (`string`) <i>optional</i></dt>
  <dd>
    Unique Common Name for Server self-signed certificate<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `null`
  </dd>
  <dt>`split_tunnel` (`bool`) <i>optional</i></dt>
  <dd>
    Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false.<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `false`
  </dd></dl>


### Outputs

<dl>
  <dt>`client_configuration`</dt>
  <dd>
    VPN Client Configuration file (.ovpn) contents that can be imported into AWS client vpn<br/>
  </dd>
  <dt>`full_client_configuration`</dt>
  <dd>
    Client configuration including client certificate and private key for mutual authentication<br/>
  </dd>
  <dt>`vpn_endpoint_arn`</dt>
  <dd>
    The ARN of the Client VPN Endpoint Connection.<br/>
  </dd>
  <dt>`vpn_endpoint_dns_name`</dt>
  <dd>
    The DNS Name of the Client VPN Endpoint Connection.<br/>
  </dd>
  <dt>`vpn_endpoint_id`</dt>
  <dd>
    The ID of the Client VPN Endpoint Connection.<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-ec2-client-vpn](https://github.com/cloudposse/terraform-aws-ec2-client-vpn) - Cloud Posse's
  upstream component
- [cloudposse/awsutils](https://github.com/cloudposse/terraform-provider-awsutils) - Cloud Posse's awsutils provider

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
