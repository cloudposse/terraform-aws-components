# Component: `actions-runner-controller`

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
            dind_enabled: false # If `true`, a Docker sidecar container will be deployed
            # To run Docker in Docker (dind), change image to summerwind/actions-runner-dind
            # If not running Docker, change image to summerwind/actions-runner use a smaller image
            image: summerwind/actions-runner-dind
            # `scope` is org name for Organization runners, repo name for Repository runners
            scope: "org/infra"
            # Tell Karpenter not to evict this pod while it is running a job.
            # If we do not set this, Karpenter will feel free to terminate the runner while it is running a job,
            # as part of its consolidation efforts, even when using "on demand" instances.
            running_pod_annotations:
              karpenter.sh/do-not-disrupt: "true"
            min_replicas: 1
            max_replicas: 20
            scale_down_delay_seconds: 100
            resources:
              limits:
                cpu: 200m
                memory: 512Mi
              requests:
                cpu: 100m
                memory: 128Mi
            webhook_driven_scaling_enabled: true
            # The name `webhook_startup_timeout` is misleading.
            # It is actually the duration after which a job will be considered completed,
            # (and the runner killed) even if the webhook has not received a "job completed" event.
            # This is to ensure that if an event is missed, it does not leave the runner running forever.
            # Set it long enough to cover the longest job you expect to run and then some.
            # See https://github.com/actions/actions-runner-controller/blob/9afd93065fa8b1f87296f0dcdf0c2753a0548cb7/docs/automatically-scaling-runners.md?plain=1#L264-L268
            webhook_startup_timeout: "90m"
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
          #  webhook_startup_timeout: "90m"
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
controlled by the `webhook_startup_timeout` setting for each Runner. The purpose of this timeout is to ensure, in case a
job cancellation or termination event gets missed, that the resulting idle runner eventually gets terminated.

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
the `webhook_startup_timeout` to a time long enough to cover the full time a job may have to wait between the time it is
queued and the time it finishes, assuming that the HRA scales up the pool by 1 and runs the job on the new runner.

:::info If there are more jobs queued than there are runners allowed by `maxReplicas`, the timeout timer does not start
on the capacity reservation until enough reservations ahead of it are removed for it to be considered as representing
and active job. Although there are some edge cases regarding `webhook_startup_timeout` that seem not to be covered
properly (see
[actions-runner-controller issue #2466](https://github.com/actions/actions-runner-controller/issues/2466)), they only
merit adding a few extra minutes to the timeout.

:::

### Recommended `webhook_startup_timeout` Duration

#### Consequences of Too Short of a `webhook_startup_timeout` Duration

If you set `webhook_startup_timeout` to too short a duration, the Horizontal Runner Autoscaler will cancel capacity
reservations for jobs that have not yet finished, and the pool will become too small. This will be most serious if you
have set `minReplicas = 0` because in this case, jobs will be left in the queue indefinitely. With a higher value of
`minReplicas`, the pool will eventually make it through all the queued jobs, but not as quickly as intended due to the
incorrectly reduced capacity.

#### Consequences of Too Long of a `webhook_startup_timeout` Duration

If the Horizontal Runner Autoscaler misses a scale-down event (which can happen because events do not have delivery
guarantees), a runner may be left running idly for as long as the `webhook_startup_timeout` duration. The only problem
with this is the added expense of leaving the idle runner running.

#### Recommendation

As a result, we recommend setting `webhook_startup_timeout` to a period long enough to cover:

- The time it takes for the HRA to scale up the pool and make a new runner available
- The time it takes for the runner to pick up the job from GitHub
- The time it takes for the job to start running on the new runner
- The maximum time a job might take

Because the consequences of expiring a capacity reservation before the job is finished are so severe, we recommend
setting `webhook_startup_timeout` to a period at least 30 minutes longer than you expect the longest job to take.
Remember, when everything works properly, the HRA will scale down the pool as jobs finish, so there is little cost to
setting a long duration, and the cost looks even smaller by comparison to the cost of having too short a duration.

For lightly used runner pools expecting only short jobs, you can set `webhook_startup_timeout` to `"30m"`. As a rule of
thumb, we recommend setting `maxReplicas` high enough that jobs never wait on the queue more than an hour.

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



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.3.0 |
| `aws` | >= 4.9.0 |
| `helm` | >= 2.0 |
| `kubernetes` | >= 2.0, != 2.21.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`actions_runner` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`actions_runner_controller` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:


## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)
  - [`aws_ssm_parameter.docker_config_json`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.github_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.github_webhook_secret_token`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)

## Required Variables
### `chart` (`string`) <i>required</i>


Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `chart_repository` (`string`) <i>required</i>


Repository URL where to locate the requested chart.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `kubernetes_namespace` (`string`) <i>required</i>


The namespace to install the release into.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `resources` <i>required</i>


The cpu and memory of the deployment's limits and requests.<br/>

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
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>


### `runners` <i>required</i>


Map of Action Runner configurations, with the key being the name of the runner. Please note that the name must be in<br/>
kebab-case.<br/>
<br/>
For example:<br/>
<br/>
```hcl<br/>
organization_runner = {<br/>
  type = "organization" # can be either 'organization' or 'repository'<br/>
  dind_enabled: true # A Docker daemon will be started in the runner Pod<br/>
  image: summerwind/actions-runner-dind # If dind_enabled=false, set this to 'summerwind/actions-runner'<br/>
  scope = "ACME"  # org name for Organization runners, repo name for Repository runners<br/>
  group = "core-automation" # Optional. Assigns the runners to a runner group, for access control.<br/>
  scale_down_delay_seconds = 300<br/>
  min_replicas = 1<br/>
  max_replicas = 5<br/>
  labels = [<br/>
    "Ubuntu",<br/>
    "core-automation",<br/>
  ]<br/>
}<br/>
```<br/>
<br/>

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
    type            = string
    scope           = string
    group           = optional(string, null)
    image           = optional(string, "summerwind/actions-runner-dind")
    dind_enabled    = optional(bool, true)
    node_selector   = optional(map(string), {})
    pod_annotations = optional(map(string), {})

    # running_pod_annotations are only applied to the pods once they start running a job
    running_pod_annotations = optional(map(string), {})

    # affinity is too complex to model. Whatever you assigned affinity will be copied
    # to the runner Pod spec.
    affinity = optional(any)

    tolerations = optional(list(object({
      key      = string
      operator = string
      value    = optional(string, null)
      effect   = string
    })), [])
    scale_down_delay_seconds = optional(number, 300)
    min_replicas             = number
    max_replicas             = number
    busy_metrics = optional(object({
      scale_up_threshold    = string
      scale_down_threshold  = string
      scale_up_adjustment   = optional(string)
      scale_down_adjustment = optional(string)
      scale_up_factor       = optional(string)
      scale_down_factor     = optional(string)
    }))
    webhook_driven_scaling_enabled = optional(bool, true)
    # The name `webhook_startup_timeout` is misleading.
    # It is actually the duration after which a job will be considered completed,
    # (and the runner killed) even if the webhook has not received a "job completed" event.
    # This is to ensure that if an event is missed, it does not leave the runner running forever.
    # Set it long enough to cover the longest job you expect to run and then some.
    # See https://github.com/actions/actions-runner-controller/blob/9afd93065fa8b1f87296f0dcdf0c2753a0548cb7/docs/automatically-scaling-runners.md?plain=1#L264-L268
    webhook_startup_timeout     = optional(string, "1h")
    pull_driven_scaling_enabled = optional(bool, false)
    labels                      = optional(list(string), [])
    docker_storage              = optional(string, null)
    # storage is deprecated in favor of docker_storage, since it is only storage for the Docker daemon
    storage     = optional(string, null)
    pvc_enabled = optional(bool, false)
    resources = optional(object({
      limits = optional(object({
        cpu               = optional(string, "1")
        memory            = optional(string, "1Gi")
        ephemeral_storage = optional(string, "10Gi")
      }), {})
      requests = optional(object({
        cpu               = optional(string, "500m")
        memory            = optional(string, "256Mi")
        ephemeral_storage = optional(string, "1Gi")
      }), {})
    }), {})
  }))
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code></code>
>   </dd>
> </dl>
>



## Optional Variables
### `atomic` (`bool`) <i>optional</i>


If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `chart_description` (`string`) <i>optional</i>


Set release description attribute (visible in the history).<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `chart_values` (`any`) <i>optional</i>


Additional values to yamlencode as `helm_release` values.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>{}</code>
>   </dd>
> </dl>
>


### `chart_version` (`string`) <i>optional</i>


Specify the exact chart version to install. If this is not specified, the latest version is installed.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `cleanup_on_fail` (`bool`) <i>optional</i>


Allow deletion of new resources created in this upgrade when upgrade fails.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `context_tags_enabled` (`bool`) <i>optional</i>


Whether or not to include all context tags as labels for each runner<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `controller_replica_count` (`number`) <i>optional</i>


The number of replicas of the runner-controller to run.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>2</code>
>   </dd>
> </dl>
>


### `create_namespace` (`bool`) <i>optional</i>


Create the namespace if it does not yet exist. Defaults to `false`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `docker_config_json_enabled` (`bool`) <i>optional</i>


Whether the Docker config JSON is enabled<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"eks/cluster"</code>
>   </dd>
> </dl>
>


### `existing_kubernetes_secret_name` (`string`) <i>optional</i>


If you are going to create the Kubernetes Secret the runner-controller will use<br/>
by some means (such as SOPS) outside of this component, set the name of the secret<br/>
here and it will be used. In this case, this component will not create a secret<br/>
and you can leave the secret-related inputs with their default (empty) values.<br/>
The same secret will be used by both the runner-controller and the webhook-server.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `github_app_id` (`string`) <i>optional</i>


The ID of the GitHub App to use for the runner controller.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `github_app_installation_id` (`string`) <i>optional</i>


The "Installation ID" of the GitHub App to use for the runner controller.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>"client.authentication.k8s.io/v1beta1"</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>false</code>
>   </dd>
> </dl>
>


### `rbac_enabled` (`bool`) <i>optional</i>


Service Account for pods.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>true</code>
>   </dd>
> </dl>
>


### `s3_bucket_arns` (`list(string)`) <i>optional</i>


List of ARNs of S3 Buckets to which the runners will have read-write access to.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>[]</code>
>   </dd>
> </dl>
>


### `ssm_docker_config_json_path` (`string`) <i>optional</i>


SSM path to the Docker config JSON<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
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
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `ssm_github_webhook_secret_token_path` (`string`) <i>optional</i>


The path in SSM to the GitHub Webhook Secret token.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>""</code>
>   </dd>
> </dl>
>


### `timeout` (`number`) <i>optional</i>


Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `wait` (`bool`) <i>optional</i>


Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>


### `webhook` <i>optional</i>


Configuration for the GitHub Webhook Server.<br/>
`hostname_template` is the `format()` string to use to generate the hostname via `format(var.hostname_template, var.tenant, var.stage, var.environment)`"<br/>
Typically something like `"echo.%[3]v.%[2]v.example.com"`.<br/>
`queue_limit` is the maximum number of webhook events that can be queued up for processing by the autoscaler.<br/>
When the queue gets full, webhook events will be dropped (status 500).<br/>
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
>   object({
    enabled           = bool
    hostname_template = string
    queue_limit       = optional(number, 1000)
  })
>   ```
>
>   
>  </dd>
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
>    {
>
>      "enabled": false,
>
>      "hostname_template": null,
>
>      "queue_limit": 1000
>
>    }
>
>    ```
>
>    
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
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
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
>  <dt>Default value</dt>
>  <dd>
>    
>
>    ```hcl
>>
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
>  <dt>Default value</dt>
>  <dd>
>    <code>null</code>
>   </dd>
> </dl>
>



</details>

## Outputs

<dl>
  <dt><code>metadata</code></dt>
  <dd>
    Block status of the deployed release<br/>

  </dd>
  <dt><code>metadata_action_runner_releases</code></dt>
  <dd>
    Block statuses of the deployed actions-runner chart releases<br/>

  </dd>
  <dt><code>webhook_payload_url</code></dt>
  <dd>
    Payload URL for GitHub webhook<br/>

  </dd>
</dl>
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
