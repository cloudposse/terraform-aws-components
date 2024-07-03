# Component: `eks-iam`

This component is responsible for provisioning specific [IAM roles for Kubernetes Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html). IAM roles are created for the following Kubernetes projects:

1. [aws-load-balancer-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller)
1. [cluster-proportional-autoscaler](https://github.com/kubernetes-sigs/cluster-proportional-autoscaler)
1. [cert-manager](https://cert-manager.io/docs/configuration/acme/dns01/route53/)
1. [external-dns](https://github.com/kubernetes-sigs/external-dns)

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    eks-iam:
      vars:
        standard_service_accounts:
          - "alb-controller",
          - "external-dns"
          - "cert-manager"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## Reference

### Version Requirements

- [`terraform`](https://registry.terraform.io/modules/terraform/>= 0.13.0), version: >= 0.13.0
- [`aws`](https://registry.terraform.io/modules/aws/>= 3.0), version: >= 3.0
- [`local`](https://registry.terraform.io/modules/local/>= 1.3), version: >= 1.3
- [`template`](https://registry.terraform.io/modules/template/>= 2.2), version: >= 2.2

https://registry.terraform.io/modules/cloudposse/stack-config/yaml//remote-state

### Providers

- `aws`, version: >= 3.0
- `terraform`

### Modules

Name | Version | Source | Description
--- | --- | --- | ---
`alb-controller` | latest | [`./modules/service-account`](https://registry.terraform.io/modules/./modules/service-account/) | n/a
`autoscaler` | latest | [`./modules/service-account`](https://registry.terraform.io/modules/./modules/service-account/) | n/a
`cert-manager` | latest | [`./modules/service-account`](https://registry.terraform.io/modules/./modules/service-account/) | n/a
`external-dns` | latest | [`./modules/service-account`](https://registry.terraform.io/modules/./modules/service-account/) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | tags/0.21.0 | [`git::https://github.com/cloudposse/terraform-null-label.git`](https://registry.terraform.io/modules/git::https:/github.com/cloudposse/terraform-null-label.git/tags/0.21.0) | n/a


### Resources

The following resources are used by this module:


### Data Sources

The following data sources are used by this module:

  - [`aws_iam_policy_document.autoscaler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.cert_manager`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.external_dns`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_kms_alias.ssm`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_alias) (data source)
  - [`terraform_remote_state.account_map`](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)
  - [`terraform_remote_state.dns_delegated`](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)
  - [`terraform_remote_state.dns_gbl_delegated`](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)
  - [`terraform_remote_state.eks`](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) (data source)

### Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern.

<dl>
  <dt>`additional_tag_map` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags for appending to tags_as_list_of_maps. Not added to `tags`.<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
  </dd>
  <dt>`attributes` (`list(string)`) <i>optional</i></dt>
  <dd>
    Additional attributes (e.g. `1`)<br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `[]`
  </dd>
  <dt>`context` <i>optional</i></dt>
  <dd>
    Single object for setting entire context at once.<br/>
    See description of individual variables for details.<br/>
    Leave string and numeric variables as `null` to use default value.<br/>
    Individual variable settings (non-null) override settings in context object,<br/>
    except for attributes, tags, and additional_tag_map, which are merged.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** 

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
    <br/>
    
    **Default value:** 
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
  <dt>`delimiter` (`string`) <i>optional</i></dt>
  <dd>
    Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br/>
    Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
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
    Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`id_length_limit` (`number`) <i>optional</i></dt>
  <dd>
    Limit `id` to this many characters.<br/>
    Set to `0` for unlimited length.<br/>
    Set to `null` for default, which is `0`.<br/>
    Does not affect `id_full`.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `number`
    **Default value:** `null`
  </dd>
  <dt>`label_order` (`list(string)`) <i>optional</i></dt>
  <dd>
    The naming order of the id output and Name tag.<br/>
    Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
    You can omit any of the 5 elements, but at least one must be present.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `list(string)`
    **Default value:** `null`
  </dd>
  <dt>`name` (`string`) <i>optional</i></dt>
  <dd>
    Solution name, e.g. 'app' or 'jenkins'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`namespace` (`string`) <i>optional</i></dt>
  <dd>
    Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`regex_replace_chars` (`string`) <i>optional</i></dt>
  <dd>
    Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br/>
    If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
    <br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`stage` (`string`) <i>optional</i></dt>
  <dd>
    Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release'<br/>
    **Required:** No<br/>
    **Type:** `string`
    **Default value:** `null`
  </dd>
  <dt>`tags` (`map(string)`) <i>optional</i></dt>
  <dd>
    Additional tags (e.g. `map('BusinessUnit','XYZ')`<br/>
    **Required:** No<br/>
    **Type:** `map(string)`
    **Default value:** `{}`
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
  <dt>`standard_service_accounts` (`list(string)`) <i>required</i></dt>
  <dd>
    List of standard service accounts expected to be enabled everywhere<br/>

    **Type:** `list(string)`
    <br/>
    **Default value:** ``

  </dd>
</dl>

### Optional Inputs

<dl>
  <dt>`account_map_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`account_map_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage where `account_map` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`dns_gbl_delegated_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment where global `dns_delegated` is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`kms_alias_name` (`string`) <i>optional</i></dt>
  <dd>
    AWS KMS alias used for encryption/decryption of SSM parameters default is alias used in SSM<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"alias/aws/ssm"`
  </dd>
  <dt>`optional_service_accounts` (`list(string)`) <i>optional</i></dt>
  <dd>
    List of optional service accounts to enable<br/>
    <br/>
    **Type:** `list(string)`
    <br/>
    **Default value:** `[]`
  </dd>
  <dt>`tfstate_account_id` (`string`) <i>optional</i></dt>
  <dd>
    The ID of the account where the Terraform remote state backend is provisioned<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`tfstate_assume_role` (`bool`) <i>optional</i></dt>
  <dd>
    Set to false to use the caller's role to access the Terraform remote state<br/>
    <br/>
    **Type:** `bool`
    <br/>
    **Default value:** `true`
  </dd>
  <dt>`tfstate_bucket_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment for Terraform state bucket<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`tfstate_bucket_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage for Terraform state bucket<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd>
  <dt>`tfstate_existing_role_arn` (`string`) <i>optional</i></dt>
  <dd>
    The ARN of the existing IAM Role to access the Terraform remote state. If not provided and `remote_state_assume_role` is `true`, a role will be constructed from `remote_state_role_arn_template`<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `""`
  </dd>
  <dt>`tfstate_role_arn_template` (`string`) <i>optional</i></dt>
  <dd>
    IAM Role ARN template for accessing the Terraform remote state<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"arn:aws:iam::%s:role/%s-%s-%s-%s"`
  </dd>
  <dt>`tfstate_role_environment_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the environment for Terraform state IAM role<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"gbl"`
  </dd>
  <dt>`tfstate_role_name` (`string`) <i>optional</i></dt>
  <dd>
    IAM Role name for accessing the Terraform remote state<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"terraform"`
  </dd>
  <dt>`tfstate_role_stage_name` (`string`) <i>optional</i></dt>
  <dd>
    The name of the stage for Terraform state IAM role<br/>
    <br/>
    **Type:** `string`
    <br/>
    **Default value:** `"root"`
  </dd></dl>


### Outputs

<dl>
  <dt>`service_accounts`</dt>
  <dd>
    n/a<br/>
  </dd>
</dl>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->


## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/eks-iam) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
