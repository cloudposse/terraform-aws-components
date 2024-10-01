---
tags:
  - component/eks/actions-runner-controller
  - layer/github
  - provider/aws
  - provider/helm
---

# Component: `eks/actions-runner-controller`

This component creates a Helm release for
[actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller) on an EKS cluster.

## Usage

**Stack Level**: Regional

Once the catalog file is created, the file can be imported as follows.

```yaml
import:
  - catalog/eks/actions-runner-controller
  ...
```

The default catalog values `e.g. stacks/catalog/eks/actions-runner-controller.yaml`

```yaml
components:
  terraform:
    eks/actions-runner-controller:
      vars:
        enabled: true
        name: "actions-runner" # avoids hitting name length limit on IAM role
        chart: "actions-runner-controller"
        chart_repository: "https://actions-runner-controller.github.io/actions-runner-controller"
        chart_version: "0.23.7"
        kubernetes_namespace: "actions-runner-system"
        create_namespace: true
        kubeconfig_exec_auth_api_version: "client.authentication.k8s.io/v1beta1"
        # helm_manifest_experiment_enabled feature causes inconsistent final plans with charts that have CRDs
        # see https://github.com/hashicorp/terraform-provider-helm/issues/711#issuecomment-836192991
        helm_manifest_experiment_enabled: false

        ssm_github_secret_path: "/github_runners/controller_github_app_secret"
        github_app_id: "REPLACE_ME_GH_APP_ID"
        github_app_installation_id: "REPLACE_ME_GH_INSTALLATION_ID"

        # use to enable docker config json secret, which can login to dockerhub for your GHA Runners
        docker_config_json_enabled: true
        # The content of this param should look like:
        # {
        #  "auths": {
        #    "https://index.docker.io/v1/": {
        #      "username": "your_username",
        #      "password": "your_password
        #      "email": "your_email",
        #      "auth": "$(echo "your_username:your_password" | base64)"
        #    }
        #  }
        # } | base64
        ssm_docker_config_json_path: "/github_runners/docker/config-json"

        # ssm_github_webhook_secret_token_path: "/github_runners/github_webhook_secret_token"
        # The webhook based autoscaler is much more efficient than the polling based autoscaler
        webhook:
          enabled: true
          hostname_template: "gha-webhook.%[3]v.%[2]v.%[1]v.acme.com"

        eks_component_name: "eks/cluster"
        resources:
          limits:
            cpu: 500m
            memory: 256Mi
          requests:
            cpu: 250m
            memory: 128Mi
        runners:
          infra-runner:
            node_selector:
              kubernetes.io/os: "linux"
              kubernetes.io/arch: "amd64"
            type: "repository" # can be either 'organization' or 'repository'
            dind_enabled: true # If `true`, a Docker daemon will be started in the runner Pod.
            # To run Docker in Docker (dind), change image to summerwind/actions-runner-dind
            # If not running Docker, change image to summerwind/actions-runner use a smaller image
            image: summerwind/actions-runner-dind
            # `scope` is org name for Organization runners, repo name for Repository runners
            scope: "org/infra"
            min_replicas: 0 # Default, overridden by scheduled_overrides below
            max_replicas: 20
            # Scheduled overrides. See https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides
            # Order is important. The earlier entry is prioritized higher than later entries. So you usually define
            # one-time overrides at the top of your list, then yearly, monthly, weekly, and lastly daily overrides.
            scheduled_overrides:
              # Override the daily override on the weekends
              - start_time: "2024-07-06T00:00:00-08:00" # Start of Saturday morning Pacific Standard Time
                end_time: "2024-07-07T23:59:59-07:00" # End of Sunday night Pacific Daylight Time
                min_replicas: 0
                recurrence_rule:
                  frequency: "Weekly"
              # Keep a warm pool of runners during normal working hours
              - start_time: "2024-07-01T09:00:00-08:00" # 9am Pacific Standard Time (8am PDT), start of workday
                end_time: "2024-07-01T17:00:00-07:00" # 5pm Pacific Daylight Time (6pm PST), end of workday
                min_replicas: 2
                recurrence_rule:
                  frequency: "Daily"
            scale_down_delay_seconds: 100
            resources:
              limits:
                cpu: 200m
                memory: 512Mi
              requests:
                cpu: 100m
                memory: 128Mi
            webhook_driven_scaling_enabled: true
            # max_duration is the duration after which a job will be considered completed,
            # (and the runner killed) even if the webhook has not received a "job completed" event.
            # This is to ensure that if an event is missed, it does not leave the runner running forever.
            # Set it long enough to cover the longest job you expect to run and then some.
            # See https://github.com/actions/actions-runner-controller/blob/9afd93065fa8b1f87296f0dcdf0c2753a0548cb7/docs/automatically-scaling-runners.md?plain=1#L264-L268
            max_duration: "90m"
            # Pull-driven scaling is obsolete and should not be used.
            pull_driven_scaling_enabled: false
            # Labels are not case-sensitive to GitHub, but *are* case-sensitive
            # to the webhook based autoscaler, which requires exact matches
            # between the `runs-on:` label in the workflow and the runner labels.
            labels:
              - "Linux"
              - "linux"
              - "Ubuntu"
              - "ubuntu"
              - "X64"
              - "x64"
              - "x86_64"
              - "amd64"
              - "AMD64"
              - "core-auto"
              - "common"
          # Uncomment this additional runner if you want to run a second
          # runner pool for `arm64` architecture
          #infra-runner-arm64:
          #  node_selector:
          #    kubernetes.io/os: "linux"
          #    kubernetes.io/arch: "arm64"
          #  # Add the corresponding taint to the Kubernetes nodes running `arm64` architecture
          #  # to prevent Kubernetes pods without node selectors from being scheduled on them.
          #  tolerations:
          #  - key: "kubernetes.io/arch"
          #    operator: "Equal"
          #    value: "arm64"
          #    effect: "NoSchedule"
          #  type: "repository" # can be either 'organization' or 'repository'
          #  dind_enabled: false # If `true`, a Docker sidecar container will be deployed
          #  # To run Docker in Docker (dind), change image to summerwind/actions-runner-dind
          #  # If not running Docker, change image to summerwind/actions-runner use a smaller image
          #  image: summerwind/actions-runner-dind
          #  # `scope` is org name for Organization runners, repo name for Repository runners
          #  scope: "org/infra"
          #  group: "ArmRunners"
          #  # Tell Karpenter not to evict this pod while it is running a job.
          #  # If we do not set this, Karpenter will feel free to terminate the runner while it is running a job,
          #  # as part of its consolidation efforts, even when using "on demand" instances.
          #  running_pod_annotations:
          #    karpenter.sh/do-not-disrupt: "true"
          #  min_replicas: 0 # Set to so that no ARM instance is running idle, set to 1 for faster startups
          #  max_replicas: 20
          #  scale_down_delay_seconds: 100
          #  resources:
          #    limits:
          #      cpu: 200m
          #      memory: 512Mi
          #    requests:
          #      cpu: 100m
          #      memory: 128Mi
          #  webhook_driven_scaling_enabled: true
          #  max_duration: "90m"
          #  pull_driven_scaling_enabled: false
          #  # Labels are not case-sensitive to GitHub, but *are* case-sensitive
          #  # to the webhook based autoscaler, which requires exact matches
          #  # between the `runs-on:` label in the workflow and the runner labels.
          #  # Leave "common" off the list so that "common" jobs are always
          #  # scheduled on the amd64 runners. This is because the webhook
          #  # based autoscaler will not scale a runner pool if the
          #  # `runs-on:` labels in the workflow match more than one pool.
          #  labels:
          #    - "Linux"
          #    - "linux"
          #    - "Ubuntu"
          #    - "ubuntu"
          #    - "amd64"
          #    - "AMD64"
          #    - "core-auto"
```

### Generating Required Secrets

AWS SSM is used to store and retrieve secrets.

Decide on the SSM path for the GitHub secret (PAT or Application private key) and GitHub webhook secret.

Since the secret is automatically scoped by AWS to the account and region where the secret is stored, we recommend the
secret be stored at `/github_runners/controller_github_app_secret` unless you plan on running multiple instances of the
controller. If you plan on running multiple instances of the controller, and want to give them different access
(otherwise they could share the same secret), then you can add a path component to the SSM path. For example
`/github_runners/cicd/controller_github_app_secret`.

```
ssm_github_secret_path: "/github_runners/controller_github_app_secret"
```

The preferred way to authenticate is by _creating_ and _installing_ a GitHub App. This is the recommended approach as it
allows for more much more restricted access than using a personal access token, at least until
[fine-grained personal access token permissions](https://github.blog/2022-10-18-introducing-fine-grained-personal-access-tokens-for-github/)
are generally available. Follow the instructions
[here](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#deploying-using-github-app-authentication)
to create and install the GitHub App.

At the creation stage, you will be asked to generate a private key. This is the private key that will be used to
authenticate the Action Runner Controller. Download the file and store the contents in SSM using the following command,
adjusting the profile and file name. The profile should be the `admin` role in the account to which you are deploying
the runner controller. The file name should be the name of the private key file you downloaded.

```
AWS_PROFILE=acme-mgmt-use2-auto-admin chamber write github_runners controller_github_app_secret -- "$(cat APP_NAME.DATE.private-key.pem)"
```

You can verify the file was correctly written to SSM by matching the private key fingerprint reported by GitHub with:

```
AWS_PROFILE=acme-mgmt-use2-auto-admin chamber read -q github_runners controller_github_app_secret | openssl rsa -in - -pubout -outform DER | openssl sha256 -binary | openssl base64
```

At this stage, record the Application ID and the private key fingerprint in your secrets manager (e.g. 1Password). You
will need the Application ID to configure the runner controller, and want the fingerprint to verify the private key.

Proceed to install the GitHub App in the organization or repository you want to use the runner controller for, and
record the Installation ID (the final numeric part of the URL, as explained in the instructions linked above) in your
secrets manager. You will need the Installation ID to configure the runner controller.

In your stack configuration, set the following variables, making sure to quote the values so they are treated as
strings, not numbers.

```
github_app_id: "12345"
github_app_installation_id: "12345"
```

OR (obsolete)

- A PAT with the scope outlined in
  [this document](https://github.com/actions-runner-controller/actions-runner-controller#deploying-using-pat-authentication).
  Save this to the value specified by `ssm_github_token_path` using the following command, adjusting the AWS_PROFILE to
  refer to the `admin` role in the account to which you are deploying the runner controller:

```
AWS_PROFILE=acme-mgmt-use2-auto-admin chamber write github_runners controller_github_app_secret -- "<PAT>"
```

2. If using the Webhook Driven autoscaling (recommended), generate a random string to use as the Secret when creating
   the webhook in GitHub.

Generate the string using 1Password (no special characters, length 45) or by running

```bash
dd if=/dev/random bs=1 count=33  2>/dev/null | base64
```

Store this key in AWS SSM under the same path specified by `ssm_github_webhook_secret_token_path`

```
ssm_github_webhook_secret_token_path: "/github_runners/github_webhook_secret"
```

### Dockerhub Authentication

Authenticating with Dockerhub is optional but when enabled can ensure stability by increasing the number of pulls
allowed from your runners.

To get started set `docker_config_json_enabled` to `true` and `ssm_docker_config_json_path` to the SSM path where the
credentials are stored, for example `github_runners/docker`.

To create the credentials file, fill out a JSON file locally with the following content:

```json
{
  "auths": {
    "https://index.docker.io/v1/": {
      "username": "your_username",
      "password": "your_password",
      "email": "your_email",
      "auth": "$(echo "your_username: your_password" | base64)"
    }
  }
}
```

Then write the file to SSM with the following Atmos Workflow:

```yaml
save/docker-config-json:
  description: Prompt for uploading Docker Config JSON to the AWS SSM Parameter Store
  steps:
    - type: shell
      command: |-
        echo "Please enter the Docker Config JSON file path"
        echo "See https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry for information on how to create the file"
        read -p "Docker Config JSON file path: " -r DOCKER_CONFIG_JSON_FILE_PATH
        if [ -z "DOCKER_CONFIG_JSON_FILE_PATH" ]
        then
            echo 'Inputs cannot be blank please try again!'
            exit 0
        fi

        DOCKER_CONFIG_JSON=$(<$DOCKER_CONFIG_JSON_FILE_PATH);
        ENCODED_DOCKER_CONFIG_JSON=$(echo "$DOCKER_CONFIG_JSON" | base64 -w 0 );

        echo $DOCKER_CONFIG_JSON
        echo $ENCODED_DOCKER_CONFIG_JSON

        AWS_PROFILE=acme-core-gbl-auto-admin

        set -e

        chamber write github_runners/docker config-json -- "$ENCODED_DOCKER_CONFIG_JSON"

        echo 'Saved Docker Config JSON to the AWS SSM Parameter Store'
```

Don't forget to update the AWS Profile in the script.

### Using Runner Groups

GitHub supports grouping runners into distinct
[Runner Groups](https://docs.github.com/en/actions/hosting-your-own-runners/managing-access-to-self-hosted-runners-using-groups),
which allow you to have different access controls for different runners. Read the linked documentation about creating
and configuring Runner Groups, which you must do through the GitHub Web UI. If you choose to create Runner Groups, you
can assign one or more Runner pools (from the `runners` map) to groups (only one group per runner pool) by including
`group: <Runner Group Name>` in the runner configuration. We recommend including it immediately after `scope`.

### Using Webhook Driven Autoscaling (recommended)

We recommend using Webhook Driven Autoscaling until GitHub's own autoscaling solution is as capable as the Summerwind
solution this component deploys. See
[this discussion](https://github.com/actions/actions-runner-controller/discussions/3340) for some perspective on why the
Summerwind solution is currently (summer 2024) considered superior.

To use the Webhook Driven Autoscaling, in addition to setting `webhook_driven_scaling_enabled` to `true`, you must also
install the GitHub organization-level webhook after deploying the component (specifically, the webhook server). The URL
for the webhook is determined by the `webhook.hostname_template` and where it is deployed. Recommended URL is
`https://gha-webhook.[environment].[stage].[tenant].[service-discovery-domain]`.

As a GitHub organization admin, go to `https://github.com/organizations/[organization]/settings/hooks`, and then:

- Click"Add webhook" and create a new webhook with the following settings:
  - Payload URL: copy from Terraform output `webhook_payload_url`
  - Content type: `application/json`
  - Secret: whatever you configured in the `sops` secret above
  - Which events would you like to trigger this webhook:
    - Select "Let me select individual events"
    - Uncheck everything ("Pushes" is likely the only thing already selected)
    - Check "Workflow jobs"
  - Ensure that "Active" is checked (should be checked by default)
  - Click "Add webhook" at the bottom of the settings page

After the webhook is created, select "edit" for the webhook and go to the "Recent Deliveries" tab and verify that there
is a delivery (of a "ping" event) with a green check mark. If not, verify all the settings and consult the logs of the
`actions-runner-controller-github-webhook-server` pod.

### Configuring Webhook Driven Autoscaling

The `HorizontalRunnerAutoscaler scaleUpTriggers.duration` (see [Webhook Driven Scaling documentation](https://github.
com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#webhook-driven-scaling)) is
controlled by the `max_duration` setting for each Runner. The purpose of this timeout is to ensure, in case a job
cancellation or termination event gets missed, that the resulting idle runner eventually gets terminated.

#### How the Autoscaler Determines the Desired Runner Pool Size

When a job is queued, a `capacityReservation` is created for it. The HRA (Horizontal Runner Autoscaler) sums up all the
capacity reservations to calculate the desired size of the runner pool, subject to the limits of `minReplicas` and
`maxReplicas`. The idea is that a `capacityReservation` is deleted when a job is completed or canceled, and the pool
size will be equal to `jobsStarted - jobsFinished`. However, it can happen that a job will finish without the HRA being
successfully notified about it, so as a safety measure, the `capacityReservation` will expire after a configurable
amount of time, at which point it will be deleted without regard to the job being finished. This ensures that eventually
an idle runner pool will scale down to `minReplicas`.

If it happens that the capacity reservation expires before the job is finished, the Horizontal Runner Autoscaler (HRA)
will scale down the pool by 2 instead of 1: once because the capacity reservation expired, and once because the job
finished. This will also cause starvation of waiting jobs, because the next in line will have its timeout timer started
but will not actually start running because no runner is available. And if `minReplicas` is set to zero, the pool will
scale down to zero before finishing all the jobs, leaving some waiting indefinitely. This is why it is important to set
the `max_duration` to a time long enough to cover the full time a job may have to wait between the time it is queued and
the time it finishes, assuming that the HRA scales up the pool by 1 and runs the job on the new runner.

> [!TIP]
>
> If there are more jobs queued than there are runners allowed by `maxReplicas`, the timeout timer does not start on the
> capacity reservation until enough reservations ahead of it are removed for it to be considered as representing and
> active job. Although there are some edge cases regarding `max_duration` that seem not to be covered properly (see
> [actions-runner-controller issue #2466](https://github.com/actions/actions-runner-controller/issues/2466)), they only
> merit adding a few extra minutes to the timeout.

### Recommended `max_duration` Duration

#### Consequences of Too Short of a `max_duration` Duration

If you set `max_duration` to too short a duration, the Horizontal Runner Autoscaler will cancel capacity reservations
for jobs that have not yet finished, and the pool will become too small. This will be most serious if you have set
`minReplicas = 0` because in this case, jobs will be left in the queue indefinitely. With a higher value of
`minReplicas`, the pool will eventually make it through all the queued jobs, but not as quickly as intended due to the
incorrectly reduced capacity.

#### Consequences of Too Long of a `max_duration` Duration

If the Horizontal Runner Autoscaler misses a scale-down event (which can happen because events do not have delivery
guarantees), a runner may be left running idly for as long as the `max_duration` duration. The only problem with this is
the added expense of leaving the idle runner running.

#### Recommendation

As a result, we recommend setting `max_duration` to a period long enough to cover:

- The time it takes for the HRA to scale up the pool and make a new runner available
- The time it takes for the runner to pick up the job from GitHub
- The time it takes for the job to start running on the new runner
- The maximum time a job might take

Because the consequences of expiring a capacity reservation before the job is finished can be severe, we recommend
setting `max_duration` to a period at least 30 minutes longer than you expect the longest job to take. Remember, when
everything works properly, the HRA will scale down the pool as jobs finish, so there is little cost to setting a long
duration, and the cost looks even smaller by comparison to the cost of having too short a duration.

For lightly used runner pools expecting only short jobs, you can set `max_duration` to `"30m"`. As a rule of thumb, we
recommend setting `maxReplicas` high enough that jobs never wait on the queue more than an hour.

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
        karpenter.sh/do-not-disrupt: "true"
```

When you set this annotation on the Pod, Karpenter will not evict it. This means that the Pod will stay on the Node it
is on, and the Node it is on will not be considered for eviction. This is good because it means that the Pod will not be
terminated in the middle of a job. However, it also means that the Node the Pod is on will not be considered for
termination, which means that the Node will not be removed from the cluster, which means that the cluster will not
shrink in size when you would like it to.

Since the Runner Pods terminate at the end of the job, this is not a problem for the Pods actually running jobs.
However, if you have set `minReplicas > 0`, then you have some Pods that are just idling, waiting for jobs to be
assigned to them. These Pods are exactly the kind of Pods you want terminated and moved when the cluster is
underutilized. Therefore, when you set `minReplicas > 0`, you should **NOT** set `karpenter.sh/do-not-evict: "true"` on
the Pod via the `pod_annotations` attribute of the `runners` input. (**But wait**, _there is good news_!)

We have [requested a feature](https://github.com/actions/actions-runner-controller/issues/2562) that will allow you to
set `karpenter.sh/do-not-disrupt: "true"` and `minReplicas > 0` at the same time by only annotating Pods running jobs.
Meanwhile, **we have implemented this for you** using a job startup hook. This hook will set annotations on the Pod when
the job starts. When the job finishes, the Pod will be deleted by the controller, so the annotations will not need to be
removed. Configure annotations that apply only to Pods running jobs in the `running_pod_annotations` attribute of the
`runners` input.

### Updating CRDs

When updating the chart or application version of `actions-runner-controller`, it is possible you will need to install
new CRDs. Such a requirement should be indicated in the `actions-runner-controller` release notes and may require some
adjustment to our custom chart or configuration.

This component uses `helm` to manage the deployment, and `helm` will not auto-update CRDs. If new CRDs are needed,
install them manually via a command like

```
kubectl create -f https://raw.githubusercontent.com/actions-runner-controller/actions-runner-controller/master/charts/actions-runner-controller/crds/actions.summerwind.dev_horizontalrunnerautoscalers.yaml
```

### Useful Reference

Consult [actions-runner-controller](https://github.com/actions-runner-controller/actions-runner-controller)
documentation for further details.

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0, != 2.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_actions_runner"></a> [actions\_runner](#module\_actions\_runner) | cloudposse/helm-release/aws | 0.10.1 |
| <a name="module_actions_runner_controller"></a> [actions\_runner\_controller](#module\_actions\_runner\_controller) | cloudposse/helm-release/aws | 0.10.1 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_ssm_parameter.docker_config_json](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.github_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.github_webhook_secret_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | n/a | yes |
| <a name="input_chart_description"></a> [chart\_description](#input\_chart\_description) | Set release description attribute (visible in the history). | `string` | `null` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | n/a | yes |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails. | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_context_tags_enabled"></a> [context\_tags\_enabled](#input\_context\_tags\_enabled) | Whether or not to include all context tags as labels for each runner | `bool` | `false` | no |
| <a name="input_controller_replica_count"></a> [controller\_replica\_count](#input\_controller\_replica\_count) | The number of replicas of the runner-controller to run. | `number` | `2` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false`. | `bool` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_docker_config_json_enabled"></a> [docker\_config\_json\_enabled](#input\_docker\_config\_json\_enabled) | Whether the Docker config JSON is enabled | `bool` | `false` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_existing_kubernetes_secret_name"></a> [existing\_kubernetes\_secret\_name](#input\_existing\_kubernetes\_secret\_name) | If you are going to create the Kubernetes Secret the runner-controller will use<br>by some means (such as SOPS) outside of this component, set the name of the secret<br>here and it will be used. In this case, this component will not create a secret<br>and you can leave the secret-related inputs with their default (empty) values.<br>The same secret will be used by both the runner-controller and the webhook-server. | `string` | `""` | no |
| <a name="input_github_app_id"></a> [github\_app\_id](#input\_github\_app\_id) | The ID of the GitHub App to use for the runner controller. | `string` | `""` | no |
| <a name="input_github_app_installation_id"></a> [github\_app\_installation\_id](#input\_github\_app\_installation\_id) | The "Installation ID" of the GitHub App to use for the runner controller. | `string` | `""` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes config file.<br>If supplied, `kubeconfig_context_format` will be ignored. | `string` | `""` | no |
| <a name="input_kubeconfig_context_format"></a> [kubeconfig\_context\_format](#input\_kubeconfig\_context\_format) | A format string to use for creating the `kubectl` context name when<br>`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br>Must include a single `%s` which will be replaced with the cluster name. | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | The namespace to install the release into. | `string` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Service Account for pods. | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | The cpu and memory of the deployment's limits and requests. | <pre>object({<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_runners"></a> [runners](#input\_runners) | Map of Action Runner configurations, with the key being the name of the runner. Please note that the name must be in<br>kebab-case.<br><br>For example:<pre>hcl<br>organization_runner = {<br>  type = "organization" # can be either 'organization' or 'repository'<br>  dind_enabled: true # A Docker daemon will be started in the runner Pod<br>  image: summerwind/actions-runner-dind # If dind_enabled=false, set this to 'summerwind/actions-runner'<br>  scope = "ACME"  # org name for Organization runners, repo name for Repository runners<br>  group = "core-automation" # Optional. Assigns the runners to a runner group, for access control.<br>  scale_down_delay_seconds = 300<br>  min_replicas = 1<br>  max_replicas = 5<br>  labels = [<br>    "Ubuntu",<br>    "core-automation",<br>  ]<br>}</pre> | <pre>map(object({<br>    type                = string<br>    scope               = string<br>    group               = optional(string, null)<br>    image               = optional(string, "summerwind/actions-runner-dind")<br>    auto_update_enabled = optional(bool, true)<br>    dind_enabled        = optional(bool, true)<br>    node_selector       = optional(map(string), {})<br>    pod_annotations     = optional(map(string), {})<br><br>    # running_pod_annotations are only applied to the pods once they start running a job<br>    running_pod_annotations = optional(map(string), {})<br><br>    # affinity is too complex to model. Whatever you assigned affinity will be copied<br>    # to the runner Pod spec.<br>    affinity = optional(any)<br><br>    tolerations = optional(list(object({<br>      key      = string<br>      operator = string<br>      value    = optional(string, null)<br>      effect   = string<br>    })), [])<br>    scale_down_delay_seconds = optional(number, 300)<br>    min_replicas             = number<br>    max_replicas             = number<br>    # Scheduled overrides. See https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides<br>    # Order is important. The earlier entry is prioritized higher than later entries. So you usually define<br>    # one-time overrides at the top of your list, then yearly, monthly, weekly, and lastly daily overrides.<br>    scheduled_overrides = optional(list(object({<br>      start_time   = string # ISO 8601 format, eg,  "2021-06-01T00:00:00+09:00"<br>      end_time     = string # ISO 8601 format, eg,  "2021-06-01T00:00:00+09:00"<br>      min_replicas = optional(number)<br>      max_replicas = optional(number)<br>      recurrence_rule = optional(object({<br>        frequency  = string           # One of Daily, Weekly, Monthly, Yearly<br>        until_time = optional(string) # ISO 8601 format time after which the schedule will no longer apply<br>      }))<br>    })), [])<br>    busy_metrics = optional(object({<br>      scale_up_threshold    = string<br>      scale_down_threshold  = string<br>      scale_up_adjustment   = optional(string)<br>      scale_down_adjustment = optional(string)<br>      scale_up_factor       = optional(string)<br>      scale_down_factor     = optional(string)<br>    }))<br>    webhook_driven_scaling_enabled = optional(bool, true)<br>    # max_duration is the duration after which a job will be considered completed,<br>    # even if the webhook has not received a "job completed" event.<br>    # This is to ensure that if an event is missed, it does not leave the runner running forever.<br>    # Set it long enough to cover the longest job you expect to run and then some.<br>    # See https://github.com/actions/actions-runner-controller/blob/9afd93065fa8b1f87296f0dcdf0c2753a0548cb7/docs/automatically-scaling-runners.md?plain=1#L264-L268<br>    # Defaults to 1 hour programmatically (to be able to detect if both max_duration and webhook_startup_timeout are set).<br>    max_duration = optional(string)<br>    # The name `webhook_startup_timeout` was misleading and has been deprecated.<br>    # It has been renamed `max_duration`.<br>    webhook_startup_timeout = optional(string)<br>    # Adjust the time (in seconds) to wait for the Docker in Docker daemon to become responsive.<br>    wait_for_docker_seconds     = optional(string, "")<br>    pull_driven_scaling_enabled = optional(bool, false)<br>    labels                      = optional(list(string), [])<br>    # If not null, `docker_storage` specifies the size (as `go` string) of<br>    # an ephemeral (default storage class) Persistent Volume to allocate for the Docker daemon.<br>    # Takes precedence over `tmpfs_enabled` for the Docker daemon storage.<br>    docker_storage = optional(string, null)<br>    # storage is deprecated in favor of docker_storage, since it is only storage for the Docker daemon<br>    storage = optional(string, null)<br>    # If `pvc_enabled` is true, a Persistent Volume Claim will be created for the runner<br>    # and mounted at /home/runner/work/shared. This is useful for sharing data between runners.<br>    pvc_enabled = optional(bool, false)<br>    # If `tmpfs_enabled` is `true`, both the runner and the docker daemon will use a tmpfs volume,<br>    # meaning that all data will be stored in RAM rather than on disk, bypassing disk I/O limitations,<br>    # but what would have been disk usage is now additional memory usage. You must specify memory<br>    # requests and limits when using tmpfs or else the Pod will likely crash the Node.<br>    tmpfs_enabled = optional(bool)<br>    resources = optional(object({<br>      limits = optional(object({<br>        cpu    = optional(string, "1")<br>        memory = optional(string, "1Gi")<br>        # ephemeral-storage is the Kubernetes name, but `ephemeral_storage` is the gomplate name,<br>        # so allow either. If both are specified, `ephemeral-storage` takes precedence.<br>        ephemeral-storage = optional(string)<br>        ephemeral_storage = optional(string, "10Gi")<br>      }), {})<br>      requests = optional(object({<br>        cpu    = optional(string, "500m")<br>        memory = optional(string, "256Mi")<br>        # ephemeral-storage is the Kubernetes name, but `ephemeral_storage` is the gomplate name,<br>        # so allow either. If both are specified, `ephemeral-storage` takes precedence.<br>        ephemeral-storage = optional(string)<br>        ephemeral_storage = optional(string, "1Gi")<br>      }), {})<br>    }), {})<br>  }))</pre> | n/a | yes |
| <a name="input_s3_bucket_arns"></a> [s3\_bucket\_arns](#input\_s3\_bucket\_arns) | List of ARNs of S3 Buckets to which the runners will have read-write access to. | `list(string)` | `[]` | no |
| <a name="input_ssm_docker_config_json_path"></a> [ssm\_docker\_config\_json\_path](#input\_ssm\_docker\_config\_json\_path) | SSM path to the Docker config JSON | `string` | `null` | no |
| <a name="input_ssm_github_secret_path"></a> [ssm\_github\_secret\_path](#input\_ssm\_github\_secret\_path) | The path in SSM to the GitHub app private key file contents or GitHub PAT token. | `string` | `""` | no |
| <a name="input_ssm_github_webhook_secret_token_path"></a> [ssm\_github\_webhook\_secret\_token\_path](#input\_ssm\_github\_webhook\_secret\_token\_path) | The path in SSM to the GitHub Webhook Secret token. | `string` | `""` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `null` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`. | `bool` | `null` | no |
| <a name="input_webhook"></a> [webhook](#input\_webhook) | Configuration for the GitHub Webhook Server.<br>`hostname_template` is the `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"<br>Typically something like `"echo.%[3]v.%[2]v.example.com"`.<br>`queue_limit` is the maximum number of webhook events that can be queued up for processing by the autoscaler.<br>When the queue gets full, webhook events will be dropped (status 500). | <pre>object({<br>    enabled           = bool<br>    hostname_template = string<br>    queue_limit       = optional(number, 1000)<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "hostname_template": null,<br>  "queue_limit": 1000<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed release |
| <a name="output_metadata_action_runner_releases"></a> [metadata\_action\_runner\_releases](#output\_metadata\_action\_runner\_releases) | Block statuses of the deployed actions-runner chart releases |
| <a name="output_webhook_payload_url"></a> [webhook\_payload\_url](#output\_webhook\_payload\_url) | Payload URL for GitHub webhook |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/actions-runner-controller) -
  Cloud Posse's upstream component
- [alb-controller](https://artifacthub.io/packages/helm/aws/aws-load-balancer-controller) - Helm Chart
- [alb-controller](https://github.com/kubernetes-sigs/aws-load-balancer-controller) - AWS Load Balancer Controller
- [actions-runner-controller Webhook Driven Scaling](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#webhook-driven-scaling)
- [actions-runner-controller Chart Values](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/charts/actions-runner-controller/values.yaml)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
