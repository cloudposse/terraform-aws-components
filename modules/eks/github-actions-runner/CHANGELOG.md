## Initial Release

This release has been tested and used in production, but testing has not covered all available features. Please use with
caution and report any issues you encounter.

### Migration from `actions-runner-controller`

GitHub has released its own official self-hosted GitHub Actions Runner support, replacing the
`actions-runner-controller` implementation developed by Summerwind. (See the
[announcement from GitHub](https://github.com/actions/actions-runner-controller/discussions/2072).) Accordingly, this
component is a replacement for the
[`actions-runner-controller`](https://github.com/cloudposse/terraform-aws-components/tree/main/modules/eks/actions-runner-controller)
component. Although there are different defaults for some of the configuration options, if you are already using
`actions-runner-controller` you should be able to reuse the GitHub app or PAT and image pull secret you are already
using, making migration relatively straightforward.

We recommend deploying this component into a separate namespace (or namespaces) than `actions-runner-controller` and get
the new runners sets running before you remove the old ones. You can then migrate your workflows to use the new runners
sets and have zero downtime.

Major differences:

- The official GitHub runners deployed are different from the GitHub hosted runners and the Summerwind self-hosted
  runners in that
  [they have very few tools installed](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#about-the-runner-container-image).
  You will need to install any tools you need in your workflows, either as part of your workflow (recommended) or by
  maintaining a
  [custom runner image](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners-with-actions-runner-controller/about-actions-runner-controller#creating-your-own-runner-image),
  or by running such steps in a
  [separate container](https://docs.github.com/en/actions/using-jobs/running-jobs-in-a-container) that has the tools
  pre-installed. Many tools have publicly available actions to install them, such as `actions/setup-node` to install
  NodeJS or `dcarbone/install-jq-action` to install `jq`. You can also install packages using
  `awalsh128/cache-apt-pkgs-action`, which has the advantage of being able to skip the installation if the package is
  already installed, so you can more efficiently run the same workflow on GitHub hosted as well as self-hosted runners.
- Self-hosted runners, such as those deployed with the `actions-runner-controller` component, are targeted by a set of
  labels indicated by a workflow's `runs-on` array, of which the first must be "self-hosted". Runner Sets, such as are
  deployed with this component, are targeted by a single label, which is the name of the Runner Set. This means that you
  will need to update your workflows to target the new Runner Set label. See
  [here](https://github.com/actions/actions-runner-controller/discussions/2921#discussioncomment-7501051) for the
  reasoning behind GitHub's decision to use a single label instead of a set.
- The `actions-runner-controller` component uses the published Helm chart for the controller, but there is none for the
  runners, so it includes a custom Helm chart for them. However, for Runner Sets, GitHub has published 2 charts, one for
  the controller and one for the runners (runner sets). This means that this component requires configuration (e.g.
  version numbers) of 2 charts, although both should be kept at the same version.
- The `actions-runner-controller` component has a `resources/values.yaml` file that provided defaults for the controller
  Helm chart. This component does not have files like that by default, but supports a `resources/values-controller.yaml`
  file for the "gha-runner-scale-set-controller" chart and a `resources/values-runner.yaml` file for the
  "gha-runner-scale-set" chart.
- The default values for the SSM paths for the GitHub auth secret and the imagePullSecret have changed. Specify the old
  values explicitly to keep using the same secrets.
- The `actions-runner-controller` component creates an IAM Role (IRSA) for the runners to use. This component does not
  create an IRSA, because the chart does not support using one while in "dind" mode. Use GitHub OIDC authentication
  inside your workflows instead.
- The Runner Sets deployed by this component use a different autoscaling mechanism, so most of the
  `actions-runner-controller` configuration options related to autoscaling are not applicable.
- For the same reason, this component does not deploy a webhook listener or Ingress and does not require configuration
  of a GitHub webhook.
- The `actions-runner-controller` component has an input named `existing_kubernetes_secret_name`. The equivalent input
  for this component is `github_kubernetes_secret_name`, in order to clearly distinguish it from the
  `image_pull_kubernetes_secret_name` input.

### Translating configuration from `actions-runner-controller`

Here is an example configuration for the `github-actions-runner` controller, with comments indicating where in the
`actions-runner-controller` configuration the corresponding configuration option can be copied from.

```yaml
components:
  terraform:
    eks/github-actions-runner:
      vars:
        # This first set of values you can just copy from here.
        # However, if you had customized the standard Helm configuration
        # (such things as `cleanup_on_fail`, `atomic`, or `timeout`), you
        # now need to do that per chart under the `charts` input.
        enabled: true
        name: "gha-runner-controller"
        charts:
          controller:
            # As of the time of the creation of this component, 0.7.0 is the latest version
            # of the chart. If you use a newer version, check for breaking changes
            # and any updates to this component that may be required.
            # Find the latest version at https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set-controller/Chart.yaml#L18
            chart_version: "0.7.0"
          runner_sets:
            # We expect that the runner set chart will always be at the same version as the controller chart,
            # but the charts are still in pre-release so that may change.
            # Find the latest version at https://github.com/actions/actions-runner-controller/blob/master/charts/gha-runner-scale-set/Chart.yaml#L18
            chart_version: "0.7.0"
        controller:
          # These inputs from `actions-runner-controller` are now parts of the controller configuration input
          kubernetes_namespace: "gha-runner-controller"
          create_namespace: true
          replicas: 1 # From `actions-runner-controller` file `resources/values.yaml`, value `replicaCount`
          # resources from var.resources

        # These values can be copied directly from the `actions-runner-controller` configuration
        ssm_github_secret_path: "/github_runners/controller_github_app_secret"
        github_app_id: "250828"
        github_app_installation_id: "30395627"

        # These values require some conversion from the `actions-runner-controller` configuration
        # Set `create_github_kubernetes_secret` to `true` if `existing_kubernetes_secret_name` was not set, `false` otherwise.
        create_github_kubernetes_secret: true
        # If `existing_kubernetes_secret_name` was set, copy the setting to `github_kubernetes_secret_name` here.
        # github_kubernetes_secret_name: <existing_kubernetes_secret_name>

        # To configure imagePullSecrets:
        # Set `image_pull_secret_enabled` to the value of `docker_config_json_enabled` in `actions-runner-controller` configuration.
        image_pull_secret_enabled: true
        # Set `ssm_image_pull_secret_path` to the value of `ssm_docker_config_json_path` in `actions-runner-controller` configuration.
        ssm_image_pull_secret_path: "/github_runners/docker/config-json"

        # To configure the runner sets, there is still a map of `runners`, but most
        # of the configuration options from `actions-runner-controller` are not applicable.
        # Most of the applicable configuration options are the same as for `actions-runner-controller`.
        runners:
          # The name of the runner set is the key of the map. The name is now the only label
          # that is used to target the runner set.
          self-hosted-default:
            # Namespace is new. The `actions-runner-controller` always deployed the runners to the same namespace as the controller.
            # Runner sets support deploying the runners in a namespace other than the controller,
            # and it is recommended to do so. If you do not set kubernetes_namespace, the runners will be deployed
            # in the same namespace as the controller.
            kubernetes_namespace: "gha-runner-private"
            # Set create_namespace to false if the namespace has been created by another component.
            create_namespace: true

            # `actions-runner-controller` had a `dind_enabled` input that was switch between "kubernetes" and "dind" mode.
            # This component has a `mode` input that can be set to "kubernetes" or "dind".
            mode: "dind"

            # Where the `actions-runner-controller` configuration had `type` and `scope`,
            # the runner set has `github_url`. For organization scope runners, use https://github.com/myorg
            # (or, if you are using Enterprise GitHub, your GitHub Enterprise URL).
            # For repo runners, use the repo URL, e.g. https://github.com/myorg/myrepo
            github_url: https://github.com/cloudposse

            # These configuration options are the same as for `actions-runner-controller`
            #   group: "default"
            #   node_selector:
            #     kubernetes.io/os: "linux"
            #     kubernetes.io/arch: "arm64"
            #   tolerations:
            #   - key: "kubernetes.io/arch"
            #     operator: "Equal"
            #     value: "arm64"
            #     effect: "NoSchedule"
            # If min_replicas > 0 and you also have do-not-evict: "true" set
            # then the idle/waiting runner will keep Karpenter from deprovisioning the node
            # until a job runs and the runner is deleted. So we do not set it by default.
            # pod_annotations:
            #   karpenter.sh/do-not-evict: "true"
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
            # The rest of the `actions-runner-controller` configuration is not applicable.
            # This includes `labels` as well as anything to do with autoscaling.
```
