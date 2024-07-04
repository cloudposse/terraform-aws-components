# Component: `network-firewall`

This component is responsible for provisioning [AWS Network Firewall](https://aws.amazon.com/network-firewal) resources,
including Network Firewall, firewall policy, rule groups, and logging configuration.

## Usage

**Stack Level**: Regional

Example of a Network Firewall with stateful 5-tuple rules:

:::info

The "5-tuple" means the five items (columns) that each rule (row, or tuple) in a firewall policy uses to define whether
to block or allow traffic: source and destination IP, source and destination port, and protocol.

Refer to
[Standard stateful rule groups in AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-rule-groups-basic.html)
for more details.

:::

```yaml
components:
  terraform:
    network-firewall:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: network-firewall
        # The name of a VPC component where the Network Firewall is provisioned
        vpc_component_name: vpc
        firewall_subnet_name: "firewall"
        stateful_default_actions:
          - "aws:alert_strict"
        stateless_default_actions:
          - "aws:forward_to_sfe"
        stateless_fragment_default_actions:
          - "aws:forward_to_sfe"
        stateless_custom_actions: []
        delete_protection: false
        firewall_policy_change_protection: false
        subnet_change_protection: false
        logging_config: []
        rule_group_config:
          stateful-packet-inspection:
            capacity: 50
            name: stateful-packet-inspection
            description: "Stateful inspection of packets"
            type: "STATEFUL"
            rule_group:
              stateful_rule_options:
                rule_order: "STRICT_ORDER"
              rules_source:
                stateful_rule:
                  - action: "DROP"
                    header:
                      destination: "124.1.1.24/32"
                      destination_port: 53
                      direction: "ANY"
                      protocol: "TCP"
                      source: "1.2.3.4/32"
                      source_port: 53
                    rule_option:
                      keyword: "sid:1"
                  - action: "PASS"
                    header:
                      destination: "ANY"
                      destination_port: "ANY"
                      direction: "ANY"
                      protocol: "TCP"
                      source: "10.10.192.0/19"
                      source_port: "ANY"
                    rule_option:
                      keyword: "sid:2"
                  - action: "PASS"
                    header:
                      destination: "ANY"
                      destination_port: "ANY"
                      direction: "ANY"
                      protocol: "TCP"
                      source: "10.10.224.0/19"
                      source_port: "ANY"
                    rule_option:
                      keyword: "sid:3"
```

Example of a Network Firewall with [Suricata](https://suricata.readthedocs.io/en/suricata-6.0.0/rules/) rules:

:::info

For [Suricata](https://suricata.io/) rule group type, you provide match and action settings in a string, in a Suricata
compatible specification. The specification fully defines what the stateful rules engine looks for in a traffic flow and
the action to take on the packets in a flow that matches the inspection criteria.

Refer to
[Suricata compatible rule strings in AWS Network Firewall](https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-rule-groups-suricata.html)
for more details.

:::

```yaml
components:
  terraform:
    network-firewall:
      metadata:
        component: "network-firewall"
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        name: "network-firewall"

        # The name of a VPC component where the Network Firewall is provisioned
        vpc_component_name: "vpc"
        firewall_subnet_name: "firewall"

        delete_protection: false
        firewall_policy_change_protection: false
        subnet_change_protection: false

        # Logging config
        logging_enabled: true
        flow_logs_bucket_component_name: "network-firewall-logs-bucket-flow"
        alert_logs_bucket_component_name: "network-firewall-logs-bucket-alert"

        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateless-default-actions.html
        # https://docs.aws.amazon.com/network-firewall/latest/APIReference/API_FirewallPolicy.html
        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/rule-action.html#rule-action-stateless
        stateless_default_actions:
          - "aws:forward_to_sfe"
        stateless_fragment_default_actions:
          - "aws:forward_to_sfe"
        stateless_custom_actions: []

        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-rule-evaluation-order.html#suricata-strict-rule-evaluation-order.html
        # https://github.com/aws-samples/aws-network-firewall-strict-rule-ordering-terraform
        policy_stateful_engine_options_rule_order: "STRICT_ORDER"

        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-default-actions.html
        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-rule-evaluation-order.html#suricata-default-rule-evaluation-order
        # https://docs.aws.amazon.com/network-firewall/latest/APIReference/API_FirewallPolicy.html
        stateful_default_actions:
          - "aws:alert_established"
        #  - "aws:alert_strict"
        #  - "aws:drop_established"
        #  - "aws:drop_strict"

        # https://docs.aws.amazon.com/network-firewall/latest/developerguide/rule-groups.html
        rule_group_config:
          stateful-inspection:
            # https://docs.aws.amazon.com/network-firewall/latest/developerguide/rule-group-managing.html#nwfw-rule-group-capacity
            # For stateful rules, `capacity` means the max number of rules in the rule group
            capacity: 1000
            name: "stateful-inspection"
            description: "Stateful inspection of packets"
            type: "STATEFUL"

            rule_group:
              rule_variables:
                port_sets: []
                ip_sets:
                  - key: "CIDR_1"
                    definition:
                      - "10.10.0.0/11"
                  - key: "CIDR_2"
                    definition:
                      - "10.11.0.0/11"
                  - key: "SCANNER"
                    definition:
                      - "10.12.48.186/32"
                  # bad actors
                  - key: "BLOCKED_LIST"
                    definition:
                      - "193.142.146.35/32"
                      - "69.40.195.236/32"
                      - "125.17.153.207/32"
                      - "185.220.101.4/32"
                      - "195.219.212.151/32"
                      - "162.247.72.199/32"
                      - "147.185.254.17/32"
                      - "179.60.147.101/32"
                      - "157.230.244.66/32"
                      - "192.99.4.116/32"
                      - "62.102.148.69/32"
                      - "185.129.62.62/32"

              stateful_rule_options:
                # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-rule-evaluation-order.html#suricata-strict-rule-evaluation-order.html
                # All the stateful rule groups are provided to the rule engine as Suricata compatible strings
                # Suricata can evaluate stateful rule groups by using the default rule group ordering method,
                # or you can set an exact order using the strict ordering method.
                # The settings for your rule groups must match the settings for the firewall policy that they belong to.
                # With strict ordering, the rule groups are evaluated by order of priority, starting from the lowest number,
                # and the rules in each rule group are processed in the order in which they're defined.
                rule_order: "STRICT_ORDER"

              # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-how-to-provide-rules.html
              rules_source:
                # Suricata rules for the rule group
                # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-examples.html
                # https://docs.aws.amazon.com/network-firewall/latest/developerguide/suricata-rule-evaluation-order.html
                # https://github.com/aws-samples/aws-network-firewall-terraform/blob/main/firewall.tf#L66
                # https://docs.aws.amazon.com/network-firewall/latest/developerguide/stateful-rule-groups-suricata.html
                # https://coralogix.com/blog/writing-effective-suricata-rules-for-the-sta/
                # https://suricata.readthedocs.io/en/suricata-6.0.10/rules/intro.html
                # https://suricata.readthedocs.io/en/suricata-6.0.0/rules/header-keywords.html
                # https://docs.aws.amazon.com/network-firewall/latest/developerguide/rule-action.html
                #
                # With Strict evaluation order, the rules in each rule group are processed in the order in which they're defined
                #
                # Pass – Discontinue inspection of the matching packet and permit it to go to its intended destination
                #
                # Drop or Alert – Evaluate the packet against all rules with drop or alert action settings.
                # If the firewall has alert logging configured, send a message to the firewall's alert logs for each matching rule.
                # The first log entry for the packet will be for the first rule that matched the packet.
                # After all rules have been evaluated, handle the packet according to the action setting in the first rule that matched the packet.
                # If the first rule has a drop action, block the packet. If it has an alert action, continue evaluation.
                #
                # Reject – Drop traffic that matches the conditions of the stateful rule and send a TCP reset packet back to sender of the packet.
                # A TCP reset packet is a packet with no payload and a RST bit contained in the TCP header flags.
                # Reject is available only for TCP traffic. This option doesn't support FTP and IMAP protocols.
                rules_string: |
                  alert ip $BLOCKED_LIST any <> any any ( msg:"Alert on blocked traffic"; sid:100; rev:1; )
                  drop ip $BLOCKED_LIST any <> any any ( msg:"Blocked blocked traffic"; sid:200; rev:1; )

                  pass ip $SCANNER any -> any any ( msg: "Allow scanner"; sid:300; rev:1; )

                  alert ip $CIDR_1 any -> $CIDR_2 any ( msg:"Alert on CIDR_1 to CIDR_2 traffic"; sid:400; rev:1; )
                  drop ip $CIDR_1 any -> $CIDR_2 any ( msg:"Blocked CIDR_1 to CIDR_2 traffic"; sid:410; rev:1; )

                  pass ip any any <> any any ( msg: "Allow general traffic"; sid:10000; rev:1; )
```

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |




### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`alert_logs_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`flow_logs_bucket` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`network_firewall` | 0.3.2 | [`cloudposse/network-firewall/aws`](https://registry.terraform.io/modules/cloudposse/network-firewall/aws/0.3.2) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`vpc` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a




### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

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

<details>
<summary>Click to expand</summary>

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

</details

---


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

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

<details>
<summary>Click to expand</summary>

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

</details

---


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

<details>
<summary>Click to expand</summary>

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

</details

---



</details>

### Required Inputs
### `region` (`string`) <i>required</i>


AWS Region<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `rule_group_config` (`any`) <i>required</i>


Rule group configuration. Refer to [networkfirewall_rule_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) for configuration details<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>Yes</dd>
  <dt>Type</dt>
  <dd>
  `any`
  </dd>
  <dt>Default value</dt>
  <dd>
  ``
  </dd>
</dl>

</details

---


### `vpc_component_name` (`string`) <i>required</i>


The name of a VPC component where the Network Firewall is provisioned<br/>

<details>
<summary>Click to expand</summary>

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

</details

---



### Optional Inputs
### `alert_logs_bucket_component_name` (`string`) <i>optional</i>


Alert logs bucket component name<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `delete_protection` (`bool`) <i>optional</i>


A boolean flag indicating whether it is possible to delete the firewall<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

</details

---


### `firewall_policy_change_protection` (`bool`) <i>optional</i>


A boolean flag indicating whether it is possible to change the associated firewall policy<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

</details

---


### `firewall_subnet_name` (`string`) <i>optional</i>


Firewall subnet name<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"firewall"`
  </dd>
</dl>

</details

---


### `flow_logs_bucket_component_name` (`string`) <i>optional</i>


Flow logs bucket component name<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `logging_enabled` (`bool`) <i>optional</i>


Flag to enable/disable Network Firewall Flow and Alert Logs<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

</details

---


### `network_firewall_description` (`string`) <i>optional</i>


AWS Network Firewall description. If not provided, the Network Firewall name will be used<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `network_firewall_name` (`string`) <i>optional</i>


Friendly name to give the Network Firewall. If not provided, the name will be derived from the context.<br/>
Changing the name will cause the Firewall to be deleted and recreated.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `network_firewall_policy_name` (`string`) <i>optional</i>


Friendly name to give the Network Firewall policy. If not provided, the name will be derived from the context.<br/>
Changing the name will cause the policy to be deleted and recreated.<br/>
<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `policy_stateful_engine_options_rule_order` (`string`) <i>optional</i>


Indicates how to manage the order of stateful rule evaluation for the policy. Valid values: DEFAULT_ACTION_ORDER, STRICT_ORDER<br/>

<details>
<summary>Click to expand</summary>

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

</details

---


### `stateful_default_actions` (`list(string)`) <i>optional</i>


Default stateful actions<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "aws:alert_strict"
  ]
  ```
  
  </dd>
</dl>

</details

---


### `stateless_custom_actions` <i>optional</i>


Set of configuration blocks describing the custom action definitions that are available for use in the firewall policy's `stateless_default_actions`<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  

  ```hcl
  list(object({
    action_name = string
    dimensions  = list(string)
  }))
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  `[]`
  </dd>
</dl>

</details

---


### `stateless_default_actions` (`list(string)`) <i>optional</i>


Default stateless actions<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "aws:forward_to_sfe"
  ]
  ```
  
  </dd>
</dl>

</details

---


### `stateless_fragment_default_actions` (`list(string)`) <i>optional</i>


Default stateless actions for fragmented packets<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `list(string)`
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  [
    "aws:forward_to_sfe"
  ]
  ```
  
  </dd>
</dl>

</details

---


### `subnet_change_protection` (`bool`) <i>optional</i>


A boolean flag indicating whether it is possible to change the associated subnet(s)<br/>

<details>
<summary>Click to expand</summary>

<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `false`
  </dd>
</dl>

</details

---



### Outputs

<dl>
  <dt><code>az_subnet_endpoint_stats</code></dt>
  <dd>
    List of objects with each object having three items: AZ, subnet ID, VPC endpoint ID<br/>
  </dd>
  <dt><code>network_firewall_arn</code></dt>
  <dd>
    Network Firewall ARN<br/>
  </dd>
  <dt><code>network_firewall_name</code></dt>
  <dd>
    Network Firewall name<br/>
  </dd>
  <dt><code>network_firewall_policy_arn</code></dt>
  <dd>
    Network Firewall policy ARN<br/>
  </dd>
  <dt><code>network_firewall_policy_name</code></dt>
  <dd>
    Network Firewall policy name<br/>
  </dd>
  <dt><code>network_firewall_status</code></dt>
  <dd>
    Nested list of information about the current status of the Network Firewall<br/>
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
- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/TODO) -
  Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
