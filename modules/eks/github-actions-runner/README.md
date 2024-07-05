# Component: `github-actions-runner`

This component deploys self-hosted GitHub Actions Runners and a
[Controller](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/quickstart-for-actions-runner-controller#introduction)
on an EKS cluster, using
"[runner scale sets](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/deploying-runner-scale-sets-with-actions-runner-controller#runner-scale-set)".

This solution is supported by GitHub and supersedes the
[actions-runner-controller](https://github.com/actions/actions-runner-controller/blob/master/docs/about-arc.md)
developed by Summerwind and deployed by Cloud Posse's
[actions-runner-controller](https://docs.cloudposse.com/components/library/aws/eks/actions-runner-controller/)
component.

### Current limitations

The runner image used by Runner Sets contains
[no more packages than are necessary](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#about-the-runner-container-image)
to run the runner. This is in contrast to the Summerwind implementation, which contains some commonly needed packages
like `build-essential`, `curl`, `wget`, `git`, and `jq`, and the GitHub hosted images which contain a robust set of
tools. (This is a limitation of the official Runner Sets implementation, not this component per se.) You will need to
install any tools you need in your workflows, either as part of your workflow (recommended), by maintaining a
[custom runner image](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image),
or by running such steps in a
[separate container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container) that has the tools
pre-installed. Many tools have publicly available actions to install them, such as `actions/setup-node` to install
NodeJS or `dcarbone/install-jq-action` to install `jq`. You can also install packages using
`awalsh128/cache-apt-pkgs-action`, which has the advantage of being able to skip the installation if the package is
already installed, so you can more efficiently run the same workflow on GitHub hosted as well as self-hosted runners.

:::info There are (as of this writing) open feature requests to add some commonly needed packages to the official Runner
Sets runner image. You can upvote these requests
[here](https://github.com/actions/actions-runner-controller/discussions/3168) and
[here](https://github.com/orgs/community/discussions/80868) to help get them implemented.

:::

In the current version of this component, only "dind" (Docker in Docker) mode has been tested. Support for "kubernetes"
mode is provided, but has not been validated.

Many elements in the Controller chart are not directly configurable by named inputs. To configure them, you can use the
`controller.chart_values` input or create a `resources/values-controller.yaml` file in the component to supply values.

Almost all the features of the Runner Scale Set chart are configurable by named inputs. The exceptions are:

- There is no specific input for specifying an outbound HTTP proxy.
- There is no specific input for supplying a
  [custom certificate authority (CA) certificate](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/deploying-runner-scale-sets-with-actions-runner-controller#custom-tls-certificates)
  to use when connecting to GitHub Enterprise Server.

You can specify these values by creating a `resources/values-runner.yaml` file in the component and setting values as
shown by the default Helm
[values.yaml](https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml),
and they will be applied to all runners.

Currently, this component has some additional limitations. In particular:

- The controller and all runners and listeners share the Image Pull Secrets. You cannot use different ones for different
  runners.
- All the runners use the same GitHub secret (app or PAT). Using a GitHub app is preferred anyway, and the single GitHub
  app serves the entire organization.
- Only one controller is supported per cluster, though it can have multiple replicas.

These limitations could be addressed if there is demand. Contact
[Cloud Posse Professional Services](https://cloudposse.com/professional-services/) if you would be interested in
sponsoring the development of any of these features.

### Ephemeral work storage

The runners are configured to use ephemeral storage for workspaces, but the details and defaults can be a bit confusing.

When running in "dind" ("Docker in Docker") mode, the default is to use `emptyDir`, which means space on the `kubelet`
base directory, which is usually the root disk. You can manage the amount of storage allowed to be used with
`ephemeral_storage` requests and limits, or you can just let it use whatever free space there is on the root disk.

When running in `kubernetes` mode, the only supported local disk storage is an ephemeral `PersistentVolumeClaim`, which
causes a separate disk to be allocated for the runner pod. This disk is ephemeral, and will be deleted when the runner
pod is deleted. When combined with the recommended ephemeral runner configuration, this means that a new disk will be
created for each job, and deleted when the job is complete. That is a lot of overhead and will slow things down
somewhat.

The size of the attached PersistentVolume is controlled by `ephemeral_pvc_storage` (a Kubernetes size string like "1G")
and the kind of storage is controlled by `ephemeral_pvc_storage_class` (which can be omitted to use the cluster default
storage class).

This mode is also optionally available when using `dind`. To enable it, set `ephemeral_pvc_storage` to the desired size.
Leave `ephemeral_pvc_storage` at the default value of `null` to use `emptyDir` storage (recommended).

Beware that using a PVC may significantly increase the startup of the runner. If you are using a PVC, you may want to
keep idle runners available so that jobs can be started without waiting for a new runner to start.

## Usage

**Stack Level**: Regional

Once the catalog file is created, the file can be imported as follows.

```yaml
import:
  - catalog/eks/github-actions-runner
  ...
```

The default catalog values `e.g. stacks/catalog/eks/github-actions-runner.yaml`

```yaml
components:
  terraform:
    eks/github-actions-runner:
      vars:
        enabled: true
        ssm_region: "us-east-2"
        name: "gha-runner-controller"
        charts:
          controller:
            chart_version: "0.7.0"
          runner_sets:
            chart_version: "0.7.0"
        controller:
          kubernetes_namespace: "gha-runner-controller"
          create_namespace: true

        create_github_kubernetes_secret: true
        ssm_github_secret_path: "/github-action-runners/github-auth-secret"
        github_app_id: "123456"
        github_app_installation_id: "12345678"
        runners:
          config-default: &runner-default
            enabled: false
            github_url: https://github.com/cloudposse
            # group: "default"
            # kubernetes_namespace: "gha-runner-private"
            create_namespace: true
            # If min_replicas > 0 and you also have do-not-evict: "true" set
            # then the idle/waiting runner will keep Karpenter from deprovisioning the node
            # until a job runs and the runner is deleted.
            # override by setting `pod_annotations: {}`
            pod_annotations:
              karpenter.sh/do-not-evict: "true"
            min_replicas: 0
            max_replicas: 8
            resources:
              limits:
                cpu: 1100m
                memory: 1024Mi
                ephemeral-storage: 5Gi
              requests:
                cpu: 500m
                memory: 256Mi
                ephemeral-storage: 1Gi
          self-hosted-default:
            <<: *runner-default
            enabled: true
            kubernetes_namespace: "gha-runner-private"
            # If min_replicas > 0 and you also have do-not-evict: "true" set
            # then the idle/waiting runner will keep Karpenter from deprovisioning the node
            # until a job runs and the runner is deleted. So we override the default.
            pod_annotations: {}
            min_replicas: 1
            max_replicas: 12
            resources:
              limits:
                cpu: 1100m
                memory: 1024Mi
                ephemeral-storage: 5Gi
              requests:
                cpu: 500m
                memory: 256Mi
                ephemeral-storage: 1Gi
          self-hosted-large:
            <<: *runner-default
            enabled: true
            resources:
              limits:
                cpu: 6000m
                memory: 7680Mi
                ephemeral-storage: 90G
              requests:
                cpu: 4000m
                memory: 7680Mi
                ephemeral-storage: 40G
```

### Authentication and Secrets

The GitHub Action Runners need to authenticate to GitHub in order to do such things as register runners and pickup jobs.
You can authenticate using either a
[GitHub App](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/authenticating-to-the-github-api#authenticating-arc-with-a-github-app)
or a
[Personal Access Token (classic)](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/authenticating-to-the-github-api#authenticating-arc-with-a-personal-access-token-classic).
The preferred way to authenticate is by _creating_ and _installing_ a GitHub App. This is the recommended approach as it
allows for much more restricted access than using a Personal Access Token (classic), and the Action Runners do not
currently support using a fine-grained Personal Access Token.

#### Site note about SSM and Regions

This component supports using AWS SSM to store and retrieve secrets. SSM parameters are regional, so if you want to
deploy to multiple regions you have 2 choices:

1. Create the secrets in each region. This is the most robust approach, but requires you to create the secrets in each
   region and keep them in sync.
2. Create the secrets in one region and use the `ssm_region` input to specify the region where they are stored. This is
   the easiest approach, but does add some obstacles to managing deployments during a region outage. If the region where
   the secrets are stored goes down, there will be no impact on runners in other regions, but you will not be able to
   deploy new runners or modify existing runners until the SSM region is restored or until you set up SSM parameters in
   a new region.

Alternatively, you can create Kubernetes secrets outside of this component (perhaps using
[SOPS](https://github.com/getsops/sops)) and reference them by name. We describe here how to save the secrets to SSM,
but you can save the secrets wherever and however you want to, as long as you deploy them as Kubernetes secret the
runners can reference. If you store them in SSM, this component will take care of the rest, but the standard Terraform
caveat applies: any secrets referenced by Terraform will be stored unencrypted in the Terraform state file.

#### Creating and Using a GitHub App

Follow the instructions
[here](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/authenticating-to-the-github-api#authenticating-arc-with-a-github-app)
to create and install a GitHub App for the runners to use for authentication.

At the App creation stage, you will be asked to generate a private key. This is the private key that will be used to
authenticate the Action Runner. Download the file and store the contents in SSM using the following command, adjusting
the profile, region, and file name. The profile should be the `terraform` role in the account to which you are deploying
the runner controller. The region should be the region where you are deploying the primary runner controller. If you are
deploying runners to multiple regions, they can all reference the same SSM parameter by using the `ssm_region` input to
specify the region where they are stored. The file name (argument to `cat`) should be the name of the private key file
you downloaded.

```
# Adjust profile name and region to suit your environment, use file name you chose for key
AWS_PROFILE=acme-core-gbl-auto-terraform AWS_REGION=us-west-2 chamber write github-action-runners github-auth-secret -- "$(cat APP_NAME.DATE.private-key.pem)"
```

You can verify the file was correctly written to SSM by matching the private key fingerprint reported by GitHub with:

```
AWS_PROFILE=acme-core-gbl-auto-terraform AWS_REGION=us-west-2 chamber read -q github-action-runners github-auth-secret | openssl rsa -in - -pubout -outform DER | openssl sha256 -binary | openssl base64
```

At this stage, record the Application ID and the private key fingerprint in your secrets manager (e.g. 1Password). You
may want to record the private key as well, or you may consider it sufficient to have it in SSM. You will need the
Application ID to configure the runner controller, and want the fingerprint to verify the private key. (You can see the
fingerprint in the GitHub App settings, under "Private keys".)

Proceed to install the GitHub App in the organization or repository you want to use the runner controller for, and
record the Installation ID (the final numeric part of the URL, as explained in the instructions linked above) in your
secrets manager. You will need the Installation ID to configure the runner controller.

In your stack configuration, set the following variables, making sure to quote the values so they are treated as
strings, not numbers.

```
github_app_id: "12345"
github_app_installation_id: "12345"
```

#### OR (obsolete): Creating and Using a Personal Access Token (classic)

Though not recommended, you can use a Personal Access Token (classic) to authenticate the runners. To do so, create a
PAT (classic) as described in the
[GitHub Documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/authenticating-to-the-github-api#authenticating-arc-with-a-personal-access-token-classic).
Save this to the value specified by `ssm_github_token_path` using the following command, adjusting the AWS profile and
region as explained above:

```
AWS_PROFILE=acme-core-gbl-auto-terraform AWS_REGION=us-west-2 chamber write github-action-runners github-auth-secret -- "<PAT>"
```

### Using Runner Groups

GitHub supports grouping runners into distinct
[Runner Groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups),
which allow you to have different access controls for different runners. Read the linked documentation about creating
and configuring Runner Groups, which you must do through the GitHub Web UI. If you choose to create Runner Groups, you
can assign one or more Runner Sets (from the `runners` map) to groups (only one group per runner set, but multiple sets
can be in the same group) by including `group: <Runner Group Name>` in the runner configuration. We recommend including
it immediately after `github_url`.

### Interaction with Karpenter or other EKS autoscaling solutions

Kubernetes cluster autoscaling solutions generally expect that a Pod runs a service that can be terminated on one Node
and restarted on another with only a short duration needed to finish processing any in-flight requests. When the cluster
is resized, the cluster autoscaler will do just that. However, GitHub Action Runner Jobs do not fit this model. If a Pod
is terminated in the middle of a job, the job is lost. The likelihood of this happening is increased by the fact that
the Action Runner Controller Autoscaler is expanding and contracting the size of the Runner Pool on a regular basis,
causing the cluster autoscaler to more frequently want to scale up or scale down the EKS cluster, and, consequently, to
move Pods around.

To handle these kinds of situations, Karpenter respects an annotation on the Pod:

```yaml
spec:
  template:
    metadata:
      annotations:
        karpenter.sh/do-not-evict: "true"
```

When you set this annotation on the Pod, Karpenter will not voluntarily evict it. This means that the Pod will stay on
the Node it is on, and the Node it is on will not be considered for deprovisioning (scale down). This is good because it
means that the Pod will not be terminated in the middle of a job. However, it also means that the Node the Pod is on
will remain running until the Pod is terminated, even if the node is underutilized and Karpenter would like to get rid
of it.

Since the Runner Pods terminate at the end of the job, this is not a problem for the Pods actually running jobs.
However, if you have set `minReplicas > 0`, then you have some Pods that are just idling, waiting for jobs to be
assigned to them. These Pods are exactly the kind of Pods you want terminated and moved when the cluster is
underutilized. Therefore, when you set `minReplicas > 0`, you should **NOT** set `karpenter.sh/do-not-evict: "true"` on
the Pod.

### Updating CRDs

When updating the chart or application version of `gha-runner-scale-set-controller`, it is possible you will need to
install new CRDs. Such a requirement should be indicated in the `gha-runner-scale-set-controller` release notes and may
require some adjustment to this component.

This component uses `helm` to manage the deployment, and `helm` will not auto-update CRDs. If new CRDs are needed,
follow the instructions in the release notes for the Helm chart or `gha-runner-scale-set-controller` itself.

### Useful Reference

- Runner Scale Set Controller's Helm chart
  [values.yaml](https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set-controller/values.yaml)
- Runner Scale Set's Helm chart
  [values.yaml](https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/values.yaml)
- Runner Scale Set's
  [Docker image](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#about-the-runner-container-image)
  and
  [how to create your own](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image)

When reviewing documentation, code, issues, etc. for self-hosted GitHub action runners or the Actions Runner Controller
(ARC), keep in mind that there are 2 implementations going by that name. The original implementation, which is now
deprecated, uses the `actions.summerwind.dev` API group, and is at times called the Summerwind or Legacy implementation.
It is primarily described by documentation in the
[actions/actions-runner-controller](https://github.com/actions/actions-runner-controller) GitHub repository itself.

The new implementation, which is the one this component uses, uses the `actions.github.com` API group, and is at times
called the GitHub implementation or "Runner Scale Sets" implementation. The new implementation is described in the
official
[GitHub documentation](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller).

Feature requests about the new implementation are officially directed to the
[Actions category of GitHub community discussion](https://github.com/orgs/community/discussions/categories/actions).
However, Q&A and community support is directed to the `actions/actions-runner-controller` repo's
[Discussion section](https://github.com/actions/actions-runner-controller/discussions), though beware that discussions
about the old implementation are mixed in with discussions about the new implementation.

Bug reports for the new implementation are still filed under the `actions/actions-runner-controller` repo's
[Issues](https://github.com/actions/actions-runner-controller/issues) tab, though again, these are mixed in with bug
reports for the old implementation. Look for the `gha-runner-scale-set` label to find issues specific to the new
implementation.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | ![>= 1.3.0](https://img.shields.io/badge/>=_1.3.0-success.svg?style=for-the-badge) |
| `aws` | ![>= 4.9.0](https://img.shields.io/badge/>=_4.9.0-success.svg?style=for-the-badge) |
| `helm` | ![>= 2.0](https://img.shields.io/badge/>=_2.0-success.svg?style=for-the-badge) |
| `kubernetes` | ![>= 2.0, != 2.21.0](https://img.shields.io/badge/>=_2.0,_!=_2.21.0-success.svg?style=for-the-badge) |


## Providers

| Provider | Version |
| --- | --- |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | ![>= 4.9.0](https://img.shields.io/badge/>=_4.9.0-success.svg?style=for-the-badge) |
| [`aws`](https://registry.terraform.io/providers/aws/latest) | ![>= 4.9.0](https://img.shields.io/badge/>=_4.9.0-success.svg?style=for-the-badge) |
| [`kubernetes`](https://registry.terraform.io/providers/kubernetes/latest) | ![>= 2.0, != 2.21.0](https://img.shields.io/badge/>=_2.0,_!=_2.21.0-success.svg?style=for-the-badge) |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | [![1.5.0](https://img.shields.io/badge/1.5.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/1.5.0/submodules/remote-state) | n/a
`gha_runner_controller` | [![0.10.0](https://img.shields.io/badge/0.10.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.0) | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.0) | n/a
`gha_runners` | [![0.10.0](https://img.shields.io/badge/0.10.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.0) | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.0) | n/a
`iam_roles` | [![latest](https://img.shields.io/badge/latest-success.svg?style=for-the-badge)](../../account-map/modules/iam-roles) | [`../../account-map/modules/iam-roles`](../../account-map/modules/iam-roles) | n/a
`this` | [![0.25.0](https://img.shields.io/badge/0.25.0-success.svg?style=for-the-badge)](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`kubernetes_namespace.controller`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) (resource)(main.tf#52)
  - [`kubernetes_namespace.runner`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) (resource)(runners.tf#26)
  - [`kubernetes_secret_v1.controller_image_pull_secret`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)(main.tf#66)
  - [`kubernetes_secret_v1.controller_ns_github_secret`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)(main.tf#81)
  - [`kubernetes_secret_v1.github_secret`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)(runners.tf#39)
  - [`kubernetes_secret_v1.image_pull_secret`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) (resource)(runners.tf#52)

## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)
  - [`aws_ssm_parameter.github_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.image_pull_secret`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

## Outputs

<dl>
  <dt><code>metadata</code></dt>
  <dd>

  
  Block status of the deployed release<br/>

  </dd>
  <dt><code>runners</code></dt>
  <dd>

  
  Human-readable summary of the deployed runners<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `charts` <i>required</i>


Map of Helm charts to install. Keys are "controller" and "runner_sets".<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   map(object({
    chart_version     = string
    chart             = optional(string, null) # defaults according to the key to "gha-runner-scale-set-controller" or "gha-runner-scale-set"
    chart_description = optional(string, null) # visible in Helm history
    chart_repository  = optional(string, "oci://ghcr.io/actions/actions-runner-controller-charts")
    wait              = optional(bool, true)
    atomic            = optional(bool, true)
    cleanup_on_fail   = optional(bool, true)
    timeout           = optional(number, null)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `controller` <i>required</i>


Configuration for the controller.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    image = optional(object({
      repository  = optional(string, null)
      tag         = optional(string, null) # Defaults to the chart appVersion
      pull_policy = optional(string, null)
    }), null)
    replicas             = optional(number, 1)
    kubernetes_namespace = string
    create_namespace     = optional(bool, true)
    chart_values         = optional(any, null)
    affinity             = optional(map(string), {})
    labels               = optional(map(string), {})
    node_selector        = optional(map(string), {})
    priority_class_name  = optional(string, "")
    resources = optional(object({
      limits = optional(object({
        cpu    = optional(string, null)
        memory = optional(string, null)
      }), null)
      requests = optional(object({
        cpu    = optional(string, null)
        memory = optional(string, null)
      }), null)
    }), null)
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
    })), [])
    log_level       = optional(string, "info")
    log_format      = optional(string, "json")
    update_strategy = optional(string, "immediate")
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `region` (`string`) <i>required</i>


AWS Region.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `create_github_kubernetes_secret` (`bool`) <i>optional</i>


If `true`, this component will create the Kubernetes Secret that will be used to get<br/>
the GitHub App private key or GitHub PAT token, based on the value retrieved<br/>
from SSM at the `var.ssm_github_secret_path`. WARNING: This will cause<br/>
the secret to be stored in plaintext in the Terraform state.<br/>
If `false`, this component will not create a secret and you must create it<br/>
(with the name given by `var.github_kubernetes_secret_name`) in every<br/>
namespace where you are deploying runners (the controller does not need it).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `create_image_pull_kubernetes_secret` (`bool`) <i>optional</i>


If `true` and `image_pull_secret_enabled` is `true`, this component will create the Kubernetes image pull secret resource,<br/>
using the value in SSM at the path specified by `ssm_image_pull_secret_path`.<br/>
WARNING: This will cause the secret to be stored in plaintext in the Terraform state.<br/>
If `false`, this component will not create a secret and you must create it<br/>
(with the name given by `var.github_kubernetes_secret_name`) in every<br/>
namespace where you are deploying controllers or runners.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `eks_component_name` (`string`) <i>optional</i>


The name of the eks component<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"eks/cluster"</code>
>   </dd>
> </dl>
>


### `github_app_id` (`string`) <i>optional</i>


The ID of the GitHub App to use for the runner controller. Leave empty if using a GitHub PAT.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `github_app_installation_id` (`string`) <i>optional</i>


The "Installation ID" of the GitHub App to use for the runner controller. Leave empty if using a GitHub PAT.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `github_kubernetes_secret_name` (`string`) <i>optional</i>


Name of the Kubernetes Secret that will be used to get the GitHub App private key or GitHub PAT token.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"gha-github-secret"</code>
>   </dd>
> </dl>
>


### `helm_manifest_experiment_enabled` (`bool`) <i>optional</i>


Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `image_pull_kubernetes_secret_name` (`string`) <i>optional</i>


Name of the Kubernetes Secret that will be used as the imagePullSecret.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"gha-image-pull-secret"</code>
>   </dd>
> </dl>
>


### `image_pull_secret_enabled` (`bool`) <i>optional</i>


Whether to configure the controller and runners with an image pull secret.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `kube_data_auth_enabled` (`bool`) <i>optional</i>


If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile` (`string`) <i>optional</i>


The AWS config profile for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_enabled` (`bool`) <i>optional</i>


If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn` (`string`) <i>optional</i>


The role ARN for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `kubeconfig_context` (`string`) <i>optional</i>


Context to choose from the Kubernetes config file.<br/>
If supplied, `kubeconfig_context_format` will be ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_context_format` (`string`) <i>optional</i>


A format string to use for creating the `kubectl` context name when<br/>
`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br/>
Must include a single `%s` which will be replaced with the cluster name.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_exec_auth_api_version` (`string`) <i>optional</i>


The Kubernetes API version of the credentials returned by the `exec` auth plugin<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"client.authentication.k8s.io/v1beta1"</code>
>   </dd>
> </dl>
>


### `kubeconfig_file` (`string`) <i>optional</i>


The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_file_enabled` (`bool`) <i>optional</i>


If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `runners` <i>optional</i>


Map of Runner Scale Set configurations, with the key being the name of the runner set.<br/>
Please note that the name must be in kebab-case (no underscores).<br/>
<br/>
For example:<br/>
<br/>
```hcl<br/>
organization-runner = {<br/>
  # Specify the scope (organization or repository) and the target<br/>
  # of the runner via the `github_url` input.<br/>
  # ex: https://github.com/myorg/myrepo or https://github.com/myorg<br/>
  github_url = https://github.com/myorg<br/>
  group = "core-automation" # Optional. Assigns the runners to a runner group, for access control.<br/>
  min_replicas = 1<br/>
  max_replicas = 5<br/>
}<br/>
```<br/>
<br/>

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
    # we allow a runner to be disabled because Atmos cannot delete an inherited map object
    enabled              = optional(bool, true)
    github_url           = string
    group                = optional(string, null)
    kubernetes_namespace = optional(string, null) # defaults to the controller's namespace
    create_namespace     = optional(bool, true)
    image                = optional(string, "ghcr.io/actions/actions-runner:latest") # repo and tag
    mode                 = optional(string, "dind")                                  # Optional. Can be "dind" or "kubernetes".
    pod_labels           = optional(map(string), {})
    pod_annotations      = optional(map(string), {})
    affinity             = optional(map(string), {})
    node_selector        = optional(map(string), {})
    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
      # tolerationSeconds is not supported, because Terraform requires all objects in a list to have the same keys,
      # but tolerationSeconds must be omitted to get the default behavior of "tolerate forever".
      # If really needed, could use a default value of 1,000,000,000 (one billion seconds = about 32 years).
    })), [])
    min_replicas = number
    max_replicas = number

    # ephemeral_pvc_storage and _class are ignored for "dind" mode but required for "kubernetes" mode
    ephemeral_pvc_storage       = optional(string, null) # ex: 10Gi
    ephemeral_pvc_storage_class = optional(string, null)

    kubernetes_mode_service_account_annotations = optional(map(string), {})

    resources = optional(object({
      limits = optional(object({
        cpu               = optional(string, null)
        memory            = optional(string, null)
        ephemeral-storage = optional(string, null)
      }), null)
      requests = optional(object({
        cpu               = optional(string, null)
        memory            = optional(string, null)
        ephemeral-storage = optional(string, null)
      }), null)
    }), null)
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `ssm_github_secret_path` (`string`) <i>optional</i>


The path in SSM to the GitHub app private key file contents or GitHub PAT token.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"/github-action-runners/github-auth-secret"</code>
>   </dd>
> </dl>
>


### `ssm_image_pull_secret_path` (`string`) <i>optional</i>


SSM path to the base64 encoded `dockercfg` image pull secret.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"/github-action-runners/image-pull-secrets"</code>
>   </dd>
> </dl>
>


### `ssm_region` (`string`) <i>optional</i>


AWS Region where SSM secrets are stored. Defaults to `var.region`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/actions-runner-controller) -
  Cloud Posse's upstream component
- [alb-controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller) - Helm Chart
- [alb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) - AWS Load Balancer Controller
- [actions-runner-controller Webhook Driven Scaling](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#webhook-driven-scaling)
- [actions-runner-controller Chart Values](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/charts/actions-runner-controller/values.yaml)
- [How to set service account for workers spawned in Kubernetes mode](https://github.com/actions/actions-runner-controller/issues/2992#issuecomment-1764855221)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
