# Component: `opsgenie`

Terraform component to provision [Opsgenie resources](https://registry.terraform.io/providers/opsgenie/opsgenie/latest/docs).

## Usage

**Stack Level**: Global

Here's an example snippet for how to use this component. For more information use these resources:

1. See the [detailed usage](./detailed-usage.md) documentation for the full breakdown in usage.
1. View the [Cloud Posse opsgenie module's example configuration](https://github.com/cloudposse/terraform-opsgenie-incident-management/tree/master/examples/config/resources) for a more complete example.

```yaml
components:
  terraform:
    opsgenie:
      vars:
        teams:
        - name: acme
          description: Global Team for Acme Co.
          members:
            username: opsgenie-test@cloudposse.com
            role: admin
        - name: acme.dev
          description: Acme Dev Team
          delete_default_resources: true
          members:
            username: opsgenie-test@cloudposse.com
            role: admin
        - name: acme.dev.some-service
          description: "repo: https://github.com/acme/some-service;owner:David Lightman @David Lightman"
          ignore_members: true
          delete_default_resources: true
          members:
            username: opsgenie-test@cloudposse.com
            role: admin

        alert_policies:
        - name: "prioritize-env-prod-critical-alerts"
          owner_team_name: acme.dev
          tags:
            - "ManagedBy:terraform"
          filter:
            type: match-all-conditions
            conditions:
              - field: source
                operation: matches
                expected_value: ".*prod.acme.*"
              - field: tags
                operation: contains
                expected_value: "severity:critical"
          priority: P1

        escalations:
        - name: acme.dev.some-service-escalation
          description: "repo: https://github.com/acme/some-service;owner:David Lightman @David Lightman"
          owner_team_name: acme.dev
          rule:
            condition: if-not-acked
            notify_type: default
            delay: 0
            recipients:
            - type: team
              team_name: acme.dev.some-service

        api_integrations:
        - name: acme-dev-opsgenie-sns-integration
          type: AmazonSns
          owner_team_name: acme.dev
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 0.12), version: >= 0.12
- [`aws`](https://registry.terraform.io/modules/aws/>= 2.0), version: >= 2.0
- [`local`](https://registry.terraform.io/modules/local/>= 1.3), version: >= 1.3
- [`opsgenie`](https://registry.terraform.io/modules/opsgenie/>= 0.5.0), version: >= 0.5.0
- [`template`](https://registry.terraform.io/modules/template/>= 2.0), version: >= 2.0

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 2.0

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`opsgenie_config` | 0.9.0 | [`git::https://github.com/cloudposse/terraform-opsgenie-incident-management.git//modules/config`](https://registry.terraform.io/modules/git::https:/github.com/cloudposse/terraform-opsgenie-incident-management.git//modules/config/0.9.0) | n/a
`this` | tags/0.21.0 | [`git::https://github.com/cloudposse/terraform-null-label.git`](https://registry.terraform.io/modules/git::https:/github.com/cloudposse/terraform-null-label.git/tags/0.21.0) | n/a


### Resources

The following resources are used by this module:

  - [`aws_ssm_parameter.opsgenie_datadog_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) (resource)

### Data Sources

The following data sources are used by this module:

  - [`aws_ssm_parameter.opsgenie_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>
  ### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>
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


Additional attributes (e.g. `1`)<br/>
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


  ### `context` <i>optional</i>


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
  

  ```hcl
  object({
    enabled             = bool
    namespace           = string
    environment         = string
    stage               = string
    name                = string
    delimiter           = string
    attributes          = list(string)
    tags                = map(string)
    additional_tag_map  = map(string)
    regex_replace_chars = string
    label_order         = list(string)
    id_length_limit     = number
  })
  ```
  
  </dd>
  <dt>Default value</dt>
  <dd>
  
  ```hcl
  {
    "additional_tag_map": {},
    "attributes": [],
    "delimiter": null,
    "enabled": true,
    "environment": null,
    "id_length_limit": null,
    "label_order": [],
    "name": null,
    "namespace": null,
    "regex_replace_chars": null,
    "stage": null,
    "tags": {}
  }
  ```
  
  </dd>
</dl>

---


  ### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
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


Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>
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


Limit `id` to this many characters.<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for default, which is `0`.<br/>
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


  ### `label_order` (`list(string)`) <i>optional</i>


The naming order of the id output and Name tag.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 5 elements, but at least one must be present.<br/>
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


  ### `name` (`string`) <i>optional</i>


Solution name, e.g. 'app' or 'jenkins'<br/>
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


Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>
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


Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
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


Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>
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


Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>
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


</details>

### Required Inputs
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



### Optional Inputs
  ### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>
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


  ### `kms_key_arn` (`string`) <i>optional</i>


AWS KMS key used for writing to SSM<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"alias/aws/ssm"`
  </dd>
</dl>

---


  ### `ssm_parameter_name_format` (`string`) <i>optional</i>


SSM parameter name format<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"/%s/%s"`
  </dd>
</dl>

---


  ### `ssm_path` (`string`) <i>optional</i>


SSM path<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"opsgenie"`
  </dd>
</dl>

---


  ### `tfstate_account_id` (`string`) <i>optional</i>


The ID of the account where the Terraform remote state backend is provisioned<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `tfstate_assume_role` (`bool`) <i>optional</i>


Set to false to use the caller's role to access the Terraform remote state<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `bool`
  </dd>
  <dt>Default value</dt>
  <dd>
  `true`
  </dd>
</dl>

---


  ### `tfstate_bucket_environment_name` (`string`) <i>optional</i>


The name of the environment for Terraform state bucket<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `tfstate_bucket_stage_name` (`string`) <i>optional</i>


The name of the stage for Terraform state bucket<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"root"`
  </dd>
</dl>

---


  ### `tfstate_existing_role_arn` (`string`) <i>optional</i>


The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template`<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `""`
  </dd>
</dl>

---


  ### `tfstate_role_arn_template` (`string`) <i>optional</i>


IAM Role ARN template for accessing the Terraform remote state<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"arn:aws:iam::%s:role/%s-%s-%s-%s"`
  </dd>
</dl>

---


  ### `tfstate_role_environment_name` (`string`) <i>optional</i>


The name of the environment for Terraform state IAM role<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"gbl"`
  </dd>
</dl>

---


  ### `tfstate_role_name` (`string`) <i>optional</i>


IAM Role name for accessing the Terraform remote state<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"terraform"`
  </dd>
</dl>

---


  ### `tfstate_role_stage_name` (`string`) <i>optional</i>


The name of the stage for Terraform state IAM role<br/>
<dl>
  <dt>Required</dt>
  <dd>No</dd>
  <dt>Type</dt>
  <dd>
  `string`
  </dd>
  <dt>Default value</dt>
  <dd>
  `"root"`
  </dd>
</dl>

---



### Outputs

<dl>
  <dt>`alert_policies`</dt>
  <dd>
    Alert policies<br/>
  </dd>
  <dt>`api_integrations`</dt>
  <dd>
    API integrations<br/>
  </dd>
  <dt>`escalations`</dt>
  <dd>
    Escalations<br/>
  </dd>
  <dt>`existing_users`</dt>
  <dd>
    Existing Users<br/>
  </dd>
  <dt>`notification_policies`</dt>
  <dd>
    Notification policies<br/>
  </dd>
  <dt>`service_incident_rule_ids`</dt>
  <dd>
    Service Incident Rule IDs<br/>
  </dd>
  <dt>`services`</dt>
  <dd>
    Services<br/>
  </dd>
  <dt>`team_routing_rules`</dt>
  <dd>
    Team routing rules<br/>
  </dd>
  <dt>`teams`</dt>
  <dd>
    Teams<br/>
  </dd>
  <dt>`users`</dt>
  <dd>
    Users<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
  * [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/opsgenie) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
