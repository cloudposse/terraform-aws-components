# Component: `spacelift-worker-pool`

This component is responsible for provisioning Spacelift worker pools.

**NOTE**: By default, the autoscaling group is set to 0 instances. Sign into the target account and manually update the count.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    spacelift-worker-pool:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        ec2_instance_type: r5n.large
        ecr_account_name: corp
        spacelift_api_endpoint: https://<GITHUBORG>.app.spacelift.io
        spacelift_ami_id: ami-xxxyyyzzz
        spacelift_runner_image: <ACCOUNTID>.dkr.ecr.<REGION>.amazonaws.com/<INFRA_IMAGE>:latest
```

## Configuration

### Docker Image on ECR

Build and tag a Docker image for this repository and push to ECR. Ensure the account where this component is deployed has read-only access to the ECR repository.

### API Key

Prior to deployment, the API key must exist in SSM.

To generate the key, please follow [these instructions](https://docs.spacelift.io/integrations/api#api-key-management). Once generated, write the API key ID and secret to the SSM key store at the following locations within the same AWS account and region where the Spacelift worker pool will reside.

| Key     | SSM Path                | Type           |
|---------|-------------------------|----------------|
| API Key | `/spacelift/key_id`     | `SecureString` |
| API ID  | `/spacelift/key_secret` | `SecureString` |

_HINT_: The API key ID is displayed as an upper-case, 16-character alphanumeric value next to the key name in the API key list.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 0.14.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) | ~> 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_spacelift"></a> [spacelift](#provider\_spacelift) | ~> 1.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_account_map"></a> [account\_map](#module\_account\_map) | cloudposse/stack-config/yaml//modules/remote-state | 0.13.0 |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | cloudposse/stack-config/yaml//modules/remote-state | 0.14.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_spacelift_ec2_workerpool"></a> [spacelift\_ec2\_workerpool](#module\_spacelift\_ec2\_workerpool) | spacelift.io/spacelift-io/spacelift-workerpool-on-ec2/aws | 1.0.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.24.1 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 0.13.0 |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role_policy.spacelift_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_security_group.spacelift](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |

| spacelift_worker_pool.primary | resource |
| [aws_iam_policy_document.spacelift_role_policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_ssm_parameter.spacelift_key_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.spacelift_key_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_map_environment_name"></a> [account\_map\_environment\_name](#input\_account\_map\_environment\_name) | The name of the environment where `account_map` is provisioned | `string` | `"gbl"` | no |
| <a name="input_account_map_stage_name"></a> [account\_map\_stage\_name](#input\_account\_map\_stage\_name) | The name of the stage where `account_map` is provisioned | `string` | `"root"` | no |
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_ec2_instance_type"></a> [ec2\_instance\_type](#input\_ec2\_instance\_type) | EC2 instance type to use for workers | `string` | `"t3.micro"` | no |
| <a name="input_ecr_account_name"></a> [ecr\_account\_name](#input\_ecr\_account\_name) | Name of the AWS account that contains the ECR infrastructure repo | `string` | n/a | yes |
| <a name="input_ecr_repo_name"></a> [ecr\_repo\_name](#input\_ecr\_repo\_name) | Name of the ECR repo containing the infrastructure image | `string` | n/a | yes |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_import_profile_name"></a> [import\_profile\_name](#input\_import\_profile\_name) | AWS Profile name to use when importing a resource | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_spacelift_ami_id"></a> [spacelift\_ami\_id](#input\_spacelift\_ami\_id) | AMI id of Spacelift worker pool image | `string` | n/a | yes |
| <a name="input_spacelift_api_endpoint"></a> [spacelift\_api\_endpoint](#input\_spacelift\_api\_endpoint) | The Spacelift API endpoint URL (e.g. https://example.app.spacelift.io) | `string` | n/a | yes |
| <a name="input_spacelift_runner_image"></a> [spacelift\_runner\_image](#input\_spacelift\_runner\_image) | Location of ECR image to use for Spacelift | `string` | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_spacelift_role_policy_id"></a> [spacelift\_role\_policy\_id](#output\_spacelift\_role\_policy\_id) | n/a |
| <a name="output_spacelift_role_policy_name"></a> [spacelift\_role\_policy\_name](#output\_spacelift\_role\_policy\_name) | n/a |
| <a name="output_worker_pool_id"></a> [worker\_pool\_id](#output\_worker\_pool\_id) | n/a |
| <a name="output_worker_pool_name"></a> [worker\_pool\_name](#output\_worker\_pool\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [cloudposse/terraform-spacelift-cloud-infrastructure-automation](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation) - Cloud Posse's related upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
