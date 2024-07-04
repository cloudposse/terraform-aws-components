# Component: `github-action-runners`

This component deploys a controller to operate self-hosted runners for GitHub Actions on your Kubernetes cluster.

## Usage

**Stack Level**: Regional

```yaml
components:
  terraform:
    github-actions-runner:
      vars:
        enabled: true
        runner_configurations:
          - repo: infrastructure
            runner_type: small # Optional field (defaults to small)
            autoscale_type: low_concurrency # Optional field (defaults to low_concurrency)
          - repo: another-repo
          - repo: yet-another-repo
```

### Runner Types

#### small

```yaml
resources:
  limits:
    cpu: "3"
    memory: "12Gi"
  requests:
    cpu: "1"
    memory: "1Gi"
```

#### medium

```yaml
resources:
  limits:
    cpu: "6"
    memory: "12Gi"
  requests:
    cpu: "2"
    memory: "1Gi"
```

#### large

```yaml
resources:
  limits:
    cpu: "8"
    memory: "12Gi"
  requests:
    cpu: "4"
    memory: "1Gi"
```

### Autoscale Types

#### low_concurrency

```yaml
minReplicas: 1
maxReplicas: 8
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: "0.75"
  scaleDownThreshold: "0.3"
  scaleUpAdjustment: 1
  scaleDownAdjustment: 1
```

#### medium_concurrency

```yaml
minReplicas: 1
maxReplicas: 16
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: "0.75"
  scaleDownThreshold: "0.3"
  scaleUpAdjustment: 4
  scaleDownAdjustment: 2
```

#### high_concurrency

```yaml
minReplicas: 1
maxReplicas: 32
metrics:
  type: PercentageRunnersBusy
  scaleUpThreshold: "0.75"
  scaleDownThreshold: "0.3"
  scaleUpAdjustment: 8
  scaleDownAdjustment: 4
```

## Managing the Runner Docker Image

```bash
cd components/terraform/github-actions-runner/runners/runner
```

Run `make help` to get a quick list of the commands.

Run `make TAG=0.0.6 help` to get the same commands with a specific tag for ease of copy/paste.

### ECR Authentication

There are multiple ways to authenticate with ECR. The commands provided by AWS with the `docker login` approach is available with the target:

```bash
make auth
```

_NOTE_: You cannot run the build or push from inside Geodesic, you need to run those on your host to avoid docker-in-docker issues so ensure you authentication is handled outside of Geodesic as well.

### Manually Building and Tagging the Image

We create our own runner image with amazon-ecr-credential-helper installed. For actions-runner-controller 0.16.0 we used runners_image: `"summerwind/actions-runner-dind:v2.275.1"` -> `action-runner:v0.1.0`.

For `actions-runner-controller` 0.18.0 we tried `runners_image: "summerwind/actions-runner-dind:v2.277.1"` -> `action-runner:0.2.0` but that did not work (see https://github.com/summerwind/actions-runner-controller/issues/274) so we reverted to `runners_image: "summerwind/actions-runner-dind:v2.274.2"` -> `action-runner:0.2.1` based on the [issue comment](https://github.com/summerwind/actions-runner-controller/blob/bc6e499e4f72f60024781d99ec66a665bedb5e1f/runner/Dockerfile#L4) and the runner version configured in the controller release.

Edit Dockerfile to set base runner version and `ecr-credential-helper-version`. Create the image before deploying the Helmfile.

```bash
make TAG=xxx build
```

_Hint_: find the existing tags with `make list-tags`.

### Manually Pushing a Tagged Image

Push the image with `make TAG=xxx push`.

## Managing the `GITHUB_TOKEN`

According to the above docs, do not use the Github App if Github Enterprise is used or planned to be used. The best way is to use a Github PAT.

See the [official documentation](https://github.com/actions-runner-controller/actions-runner-controller#deploying-using-pat-authentication) on how to generate and configure the `GITHUB_TOKEN` (Personal Access Token).

Install `GITHUB_TOKEN` with:

```bash
kubectl create secret generic controller-manager -n actions-runner-system \
  --from-literal=github_token=${GITHUB_TOKEN}
```

_NOTE_: configure the desired cluster in Geodesic using `set-cluster account` (where `account` is the AWS account name; ex: `set-cluster auto`). The region may be required as well as a tenant, if the project uses tenants; ex: `set-cluster apse1-auto`.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 3.0 |
| `helm` | >= 2.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 3.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`actions_runner` | 0.3.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.3.1) | n/a
`actions_runner_controller` | 0.3.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.3.1) | You cannot have a directory with the same name as the chart you are installing from repo https://github.com/hashicorp/terraform-provider-helm/issues/735
`eks` | 0.22.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/0.22.0) | n/a
`eks_iam_policy` | 0.2.2 | [`cloudposse/iam-policy/aws`](https://registry.terraform.io/modules/cloudposse/iam-policy/aws/0.2.2) | n/a
`eks_iam_role` | 0.10.3 | [`cloudposse/eks-iam-role/aws`](https://registry.terraform.io/modules/cloudposse/eks-iam-role/aws/0.10.3) | n/a
`github_action_controller_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`github_action_helm_label` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a
`iam_primary_roles` | 0.22.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/0.22.0) | n/a
`iam_roles` | latest | [`../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_iam_policy.github_action_runner_kms`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) (resource)(iam.tf#137)
  - [`aws_iam_role_policy_attachment.github_action_runner_kms`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) (resource)(iam.tf#148)
  - [`aws_kms_alias.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) (resource)(kms.tf#10)
  - [`aws_kms_key.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) (resource)(kms.tf#1)

## Data Sources

The following data sources are used by this module:

  - [`aws_caller_identity.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) (data source)
  - [`aws_eks_cluster.kubernetes`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) (data source)
  - [`aws_eks_cluster_auth.kubernetes`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)
  - [`aws_iam_policy_document.github_action_runner`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_iam_policy_document.github_action_runner_kms`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)

## Outputs

<dl>
  <dt><code>kms_alias</code></dt>
  <dd>
    KMS alias<br/>

  </dd>
  <dt><code>kms_key_arn</code></dt>
  <dd>
    KMS key ARN<br/>

  </dd>
  <dt><code>release_name</code></dt>
  <dd>
    Name of the release<br/>

  </dd>
  <dt><code>release_namespace</code></dt>
  <dd>
    Namespace of the release<br/>

  </dd>
  <dt><code>service_account_role_arn</code></dt>
  <dd>
    Service Account role ARN<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `runner_configurations` (`list(map(string))`) <i>required</i>


List of maps to create runners from<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(map(string))</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `autoscale_type` (`string`) <i>optional</i>


Default choice if not defined in autoscale_types<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"low_concurrency"</code>
>   </dd>
> </dl>
>


### `autoscale_types` <i>optional</i>


Map to define HRA CRD scaling configurations<br/>

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
    minReplicas = number,
    maxReplicas = number
    metrics = object({
      type                = string,
      scaleUpThreshold    = number,
      scaleDownThreshold  = number,
      scaleUpAdjustment   = number,
      scaleDownAdjustment = number
    })
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    {
>
>      "low_concurrency": {
>
>        "maxReplicas": 8,
>
>        "metrics": {
>
>          "scaleDownAdjustment": 1,
>
>          "scaleDownThreshold": 0.3,
>
>          "scaleUpAdjustment": 1,
>
>          "scaleUpThreshold": 0.75,
>
>          "type": "PercentageRunnersBusy"
>
>        },
>
>        "minReplicas": 1
>
>      }
>
>    }
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `controller_chart_image` (`string`) <i>optional</i>


Image to use for controller<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"summerwind/actions-runner-controller"</code>
>   </dd>
> </dl>
>


### `controller_chart_image_tag` (`string`) <i>optional</i>


Tag to use for controller image<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"v0.19.0"</code>
>   </dd>
> </dl>
>


### `controller_chart_name` (`string`) <i>optional</i>


Controller Helm chart name.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"actions-runner-controller"</code>
>   </dd>
> </dl>
>


### `controller_chart_namespace` (`string`) <i>optional</i>


Controller kubernetes namespace.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"actions-runner-system"</code>
>   </dd>
> </dl>
>


### `controller_chart_namespace_create` (`bool`) <i>optional</i>


Controller kubernetes namespace created if not present<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `controller_chart_release_name` (`string`) <i>optional</i>


Controller Helm chart release name.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"actions-runner-controller"</code>
>   </dd>
> </dl>
>


### `controller_chart_repo` (`string`) <i>optional</i>


Controller Helm chart repository name.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"https://actions-runner-controller.github.io/actions-runner-controller"</code>
>   </dd>
> </dl>
>


### `controller_chart_values` (`any`) <i>optional</i>


Additional values to yamlencode as `helm_release` values.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `controller_chart_version` (`string`) <i>optional</i>


Controller Helm chart version.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"0.12.8"</code>
>   </dd>
> </dl>
>


### `iam_policy_statements` (`any`) <i>optional</i>


IAM policy for the service account. Required if `var.iam_role_enabled` is `true`. This will not do variable replacements. Please see `var.iam_policy_statements_template_path`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `iam_primary_roles_environment_name` (`string`) <i>optional</i>


The name of the environment where global `iam_primary_roles` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"gbl"</code>
>   </dd>
> </dl>
>


### `iam_primary_roles_stage_name` (`string`) <i>optional</i>


The name of the stage where `iam_primary_roles` is provisioned<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"identity"</code>
>   </dd>
> </dl>
>


### `iam_role_enabled` (`bool`) <i>optional</i>


Whether to create an IAM role. Setting this to `true` will also replace any occurrences of `{service_account_role_arn}` in `var.values_template_path` with the ARN of the IAM role created by this module.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `iam_source_json_url` (`string`) <i>optional</i>


IAM source json policy to download. This will be used as the `source_json` meaning the `var.iam_policy_statements` and `var.iam_policy_statements_template_path` can override it.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `import_profile_name` (`string`) <i>optional</i>


AWS Profile name to use when importing a resource<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `import_role_arn` (`string`) <i>optional</i>


IAM Role ARN to use when importing a resource<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `runner_chart_image` (`string`) <i>optional</i>


Controller Helm chart name.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"actions-runner"</code>
>   </dd>
> </dl>
>


### `runner_chart_values` (`any`) <i>optional</i>


Additional values to yamlencode as `helm_release` values.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `runner_type` (`string`) <i>optional</i>


Default choice if not defined in runner_configurations<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>"small"</code>
>   </dd>
> </dl>
>


### `runner_types` <i>optional</i>


Map to define resources limits and requests<br/>

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
    resources = object({
      limits = object({
        cpu    = string,
        memory = string
      }),
      requests = object({
        cpu    = string,
        memory = string
      })
    })
  }))
>   ```
>
>   
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
>    {
>
>      "small": {
>
>        "resources": {
>
>          "limits": {
>
>            "cpu": "3",
>
>            "memory": "12Gi"
>
>          },
>
>          "requests": {
>
>            "cpu": "1",
>
>            "memory": "1Gi"
>
>          }
>
>        }
>
>      }
>
>    }
>
>    ```
>
>    
>   </dd>
> </dl>
>


### `service_account_name` (`string`) <i>optional</i>


Kubernetes ServiceAccount name. Required if `var.iam_role_enabled` is `true`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `service_account_namespace` (`string`) <i>optional</i>


Kubernetes Namespace where service account is deployed. Required if `var.iam_role_enabled` is `true`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



## Context Variables

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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
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
>
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
>
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
>
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
>
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
>
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
>
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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>    >
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
>
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
>
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
>
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
>
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
>
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
>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References

- [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) - Github Repo
- [summerwind/actions-runner-controller source](https://github.com/summerwind/actions-runner-controller/blob/master/charts/actions-runner-controller/values.yaml) - Helm Chart

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
