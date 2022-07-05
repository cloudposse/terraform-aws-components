# Component: `spacelift`

This component is responsible for provisioning Spacelift stacks.

## Design

Design is documented in these places:

- https://github.com/cloudposse/infra-live/pull/100
- https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/pull/103
- https://github.com/cloudposse/infra-live/pull/109

## Usage

This component runs on Spacelift directly. It is configured to run with `atmos` and state is stored in S3. See [Spacelift Overview](docs/spacelift-overview.md).

```yaml
components:
  terraform:
    spacelift-defaults:
      metadata:
        type: abstract
        component: spacelift
      settings:
        spacelift:
          workspace_enabled: true
          administrative: true
          autodeploy: true
          before_init:
            - spacelift-configure-paths
            - spacelift-write-vars
            - spacelift-tf-workspace
          component_root: components/terraform/spacelift
          description: Spacelift Administrative stack
          stack_destructor_enabled: false
          terraform_version: 1.1.9
          worker_pool_name: acme-ue2-auto-spacelift-worker-pool
          repository: infrastructure
          labels:
            - admin
      vars:
        # This is to locally apply the stack
        external_execution: true
        # This should match the version set in the Dockerfile
        terraform_version: "1.1.9"
        terraform_version_map:
          "1.1.9": "1.1.9"
        # additional defaults
        infracost_enabled: true
        runner_image: 1234567890.dkr.ecr.us-east-2.amazonaws.com/org/infrastructure
        administrative_stack_drift_detection_enabled: true
        administrative_trigger_policy_enabled: true
        git_repository: infrastructure
        worker_pool_name_id_map:
          acme-core-ue2-auto-spacelift-worker-pool: 01F...
        autodeploy: false
        stack_config_path_template: stacks/%s.yaml
        spacelift_component_path: components/terraform
        administrative_stack_drift_detection_reconcile: true
        administrative_stack_drift_detection_schedule:
          - 0 4 * * *
        drift_detection_enabled: true
        drift_detection_reconcile: true
        drift_detection_schedule:
          - 0 4 * * *
        aws_role_enabled: false
        stack_destructor_enabled: false
        before_init:
          - spacelift-configure-paths
          - spacelift-write-vars
          - spacelift-tf-workspace

    # Manages policies, admin stacks, and core OU accounts
    spacelift:
      metadata:
        component: spacelift
        inherits:
          - spacelift-defaults
      vars:
        enabled: true
        # Use context_filters to split up admin stack management
        # context_filters:
        #   stages:
        #     - artifacts
        #     - audit
        #     - auto
        #     - corp
        #     - dns
        #     - identity
        #     - marketplace
        #     - network
        #     - public
        #     - security
        # These are the policies created from https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/tree/master/catalog/policies
        # Make sure to remove the .rego suffix
        policies_available:
          - git_push.proposed-run
          - git_push.tracked-run
          - plan.default
          - trigger.dependencies
          - trigger.retries
          # This is the global admin policy
          - trigger.administrative
        # These are the policies added to each spacelift stack created by this admin stack
        policies_enabled:
          - git_push.proposed-run
          - git_push.tracked-run
          - plan.default
          - trigger.dependencies
```

## Prerequisites

### GitHub Integration

1. The GitHub owner will need to sign up for a [free trial of Spacelift](https://spacelift.io/free-trial.html)
1. Once an account is created take note of the URL - usually its `https://<GITHUBORG>.app.spacelift.io/`
1. Create a Login Policy

   - Click on Policies then Add Policy
   - Use the following policy and replace `GITHUBORG` with the GitHub Organization slug and DEV with the GitHub id for the Dev setting up the Spacelift module.

   ```rego
   package spacelift

   # See https://docs.spacelift.io/concepts/policy/login-policy for implementation details.
   # Note: Login policies don't affect GitHub organization or SSO admins.
   # Note 2: Enabling SSO requires that all users have an IdP (G Suite) account, so we'll just use
   #          GitHub authentication in the meantime while working with external collaborators.
   # Map session input data to human friendly variables to use in policy evaluation

   username	:= input.session.login
   member_of   := input.session.teams # Input is friendly name, e.g. "SRE" not "sre" or "@GITHUBORG/sre"
   GITHUBORG   := input.session.member # Is this user a member of the CUSTOMER GitHub org?

   # Define GitHub usernames of non org external collaborators with admin vs. user access
   admin_collaborators := { "DEV" }
   user_collaborators  := { "GITHUBORG" } # Using GITHUBORG as a placeholder to avoid empty set

   # Grant admin access to GITHUBORG org members in the CloudPosse group
   admin {
     GITHUBORG
     member_of[_] == "CloudPosse"
   }

   # Grant admin access to non-GITHUBORG org accounts in the admin_collaborators set
   admin {
     # not GITHUBORG
     admin_collaborators[username]
   }

   # Grant user access to GITHUBORG org members in the Developers group
   # allow {
   # 	GITHUBORG
   # 	member_of[_] == "Developers"
   # }

   # Grant user access to non-GITHUBORG org accounts in the user_collaborators set
   allow {
     not GITHUBORG
     user_collaborators[username]
   }

   # Deny access to any non-GITHUBORG org accounts who aren't defined in external collaborators sets
   deny {
     not GITHUBORG
     not user_collaborators[username]
     not admin_collaborators[username]
   }
   ```

## Spacelift Layout

[Runtime configuration](https://docs.spacelift.io/concepts/configuration/runtime-configuration) is an optional piece of setup that is applied to individual runs instead of being global to the stack. It's defined in `.spacelift/config.yml` YAML file at the root of your repository.

### Create Spacelift helper scripts

[/rootfs/usr/local/bin/spacelift-tf-workspace](/rootfs/usr/local/bin/spacelift-tf-workspace) manages selecting or creating a terraform workspace; similar to how `atmos` manages workspaces during a Terraform run.

[/rootfs/usr/local/bin/spacelift-write-vars](/rootfs/usr/local/bin/spacelift-write-vars) writes the component config using `atmos` to the `spacelift.auto.tfvars.json` file.

**NOTE**: make sure they are all executable:

```bash
chmod +x rootfs/usr/local/bin/spacelift*
```

## Building Spacelift Resources

### Build a Spacelift AMI (Optional)

**NOTE**: This won't be necessary for Kubernetes implementations once Spacelift adds support for Kubernetes worker pools.

**NOTE**: This is not needed if the [official AMI](https://github.com/spacelift-io/spacelift-worker-image/releases) already exists in the desired region and there aren't any customizations to the AMI.

1. Clone the following GitHub repository: `git clone git@github.com:spacelift-io/spacelift-worker-image.git`
1. Run the packer script

    ```bash
    packer build \
      -var='region=us-east-2' \
      -var='ami_regions=null' \
      -var='ami_groups=null' \
      spacelift.pkr.hcl
    ```

Since the `spacelift-worker-pool` component uses a data source to retrieve the AMI, we do not need to copy this AMI id over

### Deploy the [`spacelift-worker-pool`](../spacelift-worker-pool) Component

See [`spacelift-worker-pool` README](../spacelift-worker-pool/README.md) for the configuration and deployment needs.

### Update the `spacelift` catalog

1. `runner_image` = ECR location and tag of new Docker container
1. `git_repository` = Name of `infrastructure` repository
1. `git_branch` = Name of main/master branch
1. `worker_pool_id` = Output of running `spacelift-worker-pool` component

### Manually update Autoscaling Group settings

You will need to login to the account where Spacelift is deployed to and manually update the ASG to spin up an instance. This is set to 0 by default

### Deploy the admin stack

Set these inputs locally

```
export SPACELIFT_API_KEY_ENDPOINT=
export SPACELIFT_API_KEY_ID=
export SPACELIFT_API_KEY_SECRET=
```

The name of the spacelift stack resource will be different depending on the name of the component and the root atmos stack. This would be the command if the root atmos stack is `core-gbl-auto` and the spacelift component is `spacelift`.

```
atmos terraform apply spacelift --stack core-gbl-auto -target 'module.spacelift.module.stacks["core-gbl-auto-spacelift"]'
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_spacelift"></a> [spacelift](#requirement\_spacelift) | >= 0.1.2 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_spacelift"></a> [spacelift](#module\_spacelift) | cloudposse/cloud-infrastructure-automation/spacelift | 0.49.4 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_administrative_stack_drift_detection_enabled"></a> [administrative\_stack\_drift\_detection\_enabled](#input\_administrative\_stack\_drift\_detection\_enabled) | Flag to enable/disable administrative stack drift detection | `bool` | `true` | no |
| <a name="input_administrative_stack_drift_detection_reconcile"></a> [administrative\_stack\_drift\_detection\_reconcile](#input\_administrative\_stack\_drift\_detection\_reconcile) | Flag to enable/disable administrative stack drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift | `bool` | `true` | no |
| <a name="input_administrative_stack_drift_detection_schedule"></a> [administrative\_stack\_drift\_detection\_schedule](#input\_administrative\_stack\_drift\_detection\_schedule) | List of cron expressions to schedule drift detection for the administrative stack | `list(string)` | <pre>[<br>  "0 4 * * *"<br>]</pre> | no |
| <a name="input_administrative_trigger_policy_enabled"></a> [administrative\_trigger\_policy\_enabled](#input\_administrative\_trigger\_policy\_enabled) | Flag to enable/disable the global administrative trigger policy | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_autodeploy"></a> [autodeploy](#input\_autodeploy) | Default autodeploy value for all stacks created by this project | `bool` | n/a | yes |
| <a name="input_aws_role_arn"></a> [aws\_role\_arn](#input\_aws\_role\_arn) | ARN of the AWS IAM role to assume and put its temporary credentials in the runtime environment | `string` | `null` | no |
| <a name="input_aws_role_enabled"></a> [aws\_role\_enabled](#input\_aws\_role\_enabled) | Flag to enable/disable Spacelift to use AWS STS to assume the supplied IAM role and put its temporary credentials in the runtime environment | `bool` | `false` | no |
| <a name="input_aws_role_external_id"></a> [aws\_role\_external\_id](#input\_aws\_role\_external\_id) | Custom external ID (works only for private workers). See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-user_externalid.html for more details | `string` | `null` | no |
| <a name="input_aws_role_generate_credentials_in_worker"></a> [aws\_role\_generate\_credentials\_in\_worker](#input\_aws\_role\_generate\_credentials\_in\_worker) | Flag to enable/disable generating AWS credentials in the private worker after assuming the supplied IAM role | `bool` | `true` | no |
| <a name="input_before_init"></a> [before\_init](#input\_before\_init) | List of before-init scripts | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_context_filters"></a> [context\_filters](#input\_context\_filters) | Context filters to create stacks for specific context information. Valid lists are `namespaces`, `environments`, `tenants`, `stages`. | `map(list(string))` | `{}` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_drift_detection_enabled"></a> [drift\_detection\_enabled](#input\_drift\_detection\_enabled) | Flag to enable/disable drift detection on the infrastructure stacks | `bool` | `true` | no |
| <a name="input_drift_detection_reconcile"></a> [drift\_detection\_reconcile](#input\_drift\_detection\_reconcile) | Flag to enable/disable infrastructure stacks drift automatic reconciliation. If drift is detected and `reconcile` is turned on, Spacelift will create a tracked run to correct the drift | `bool` | `true` | no |
| <a name="input_drift_detection_schedule"></a> [drift\_detection\_schedule](#input\_drift\_detection\_schedule) | List of cron expressions to schedule drift detection for the infrastructure stacks | `list(string)` | <pre>[<br>  "0 4 * * *"<br>]</pre> | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_external_execution"></a> [external\_execution](#input\_external\_execution) | Set this to true if you're calling this module from outside of a Spacelift stack (e.g. the `complete` example) | `bool` | `false` | no |
| <a name="input_git_branch"></a> [git\_branch](#input\_git\_branch) | The Git branch name | `string` | `"main"` | no |
| <a name="input_git_commit_sha"></a> [git\_commit\_sha](#input\_git\_commit\_sha) | The commit SHA for which to trigger a run. Requires `var.spacelift_run_enabled` to be set to `true` | `string` | `null` | no |
| <a name="input_git_repository"></a> [git\_repository](#input\_git\_repository) | The Git repository name | `string` | n/a | yes |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_infracost_enabled"></a> [infracost\_enabled](#input\_infracost\_enabled) | Flag to enable/disable infracost. If this is enabled, it will add infracost label to each stack. See [spacelift infracost](https://docs.spacelift.io/vendors/terraform/infracost) docs for more details. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_policies_available"></a> [policies\_available](#input\_policies\_available) | List of available default policies to create in Spacelift (these policies will not be attached to Spacelift stacks by default, use `var.policies_enabled`) | `any` | <pre>[<br>  "git_push.proposed-run",<br>  "git_push.tracked-run",<br>  "plan.default",<br>  "trigger.dependencies",<br>  "trigger.retries"<br>]</pre> | no |
| <a name="input_policies_by_id_enabled"></a> [policies\_by\_id\_enabled](#input\_policies\_by\_id\_enabled) | List of existing policy IDs to attach to all Spacelift stacks | `any` | `[]` | no |
| <a name="input_policies_enabled"></a> [policies\_enabled](#input\_policies\_enabled) | List of default policies to attach to all Spacelift stacks | `any` | <pre>[<br>  "git_push.proposed-run",<br>  "git_push.tracked-run",<br>  "plan.default",<br>  "trigger.dependencies"<br>]</pre> | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_runner_image"></a> [runner\_image](#input\_runner\_image) | Full address & tag of the Spacelift runner image (e.g. on ECR) | `any` | n/a | yes |
| <a name="input_spacelift_component_path"></a> [spacelift\_component\_path](#input\_spacelift\_component\_path) | The Spacelift Component Path | `string` | `"components/terraform"` | no |
| <a name="input_spacelift_run_enabled"></a> [spacelift\_run\_enabled](#input\_spacelift\_run\_enabled) | Enable/disable creation of the `spacelift_run` resource | `bool` | `false` | no |
| <a name="input_stack_config_path_template"></a> [stack\_config\_path\_template](#input\_stack\_config\_path\_template) | Stack config path template | `string` | `"stacks/%s.yaml"` | no |
| <a name="input_stack_destructor_enabled"></a> [stack\_destructor\_enabled](#input\_stack\_destructor\_enabled) | Flag to enable/disable the stack destructor to destroy the resources of a stack before deleting the stack itself | `bool` | `false` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | Default Terraform version for all stacks created by this project | `string` | n/a | yes |
| <a name="input_terraform_version_map"></a> [terraform\_version\_map](#input\_terraform\_version\_map) | A map to determine which Terraform patch version to use for each minor version | `map(string)` | `{}` | no |
| <a name="input_worker_pool_id"></a> [worker\_pool\_id](#input\_worker\_pool\_id) | DEPRECATED: Use worker\_pool\_name\_id\_map instead. Worker pool ID | `string` | `""` | no |
| <a name="input_worker_pool_name_id_map"></a> [worker\_pool\_name\_id\_map](#input\_worker\_pool\_name\_id\_map) | Map of worker pool names to worker pool IDs | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stacks"></a> [stacks](#output\_stacks) | Spacelift stacks |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/spacelift) - Cloud Posse's upstream component


[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
