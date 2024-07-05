# Component: `argocd`

This component is responsible for provisioning [Argo CD](https://argoproj.github.io/cd/).

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

> :warning::warning::warning: ArgoCD CRDs must be installed separately from this component/helm release.
> :warning::warning::warning:

```shell
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=<appVersion>"

# Eg. version v2.4.9
kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.4.9"
```

## Usage

### Preparing AppProject repos:

First, make sure you have a GitHub repo ready to go. We have a component for this called the `argocd-repo` component. It
will create a GitHub repo and adds some secrets and code owners. Most importantly, it configures an
`applicationset.yaml` that includes all the details for helm to create ArgoCD CRDs. These CRDs let ArgoCD know how to
fulfill changes to its repo.

```yaml
components:
  terraform:
    argocd-repo-defaults:
      metadata:
        type: abstract
      vars:
        enabled: true
        github_user: acme_admin
        github_user_email: infra@acme.com
        github_organization: ACME
        github_codeowner_teams:
          - "@ACME/acme-admins"
          - "@ACME/CloudPosse"
          - "@ACME/developers"
        gitignore_entries:
          - "**/.DS_Store"
          - ".DS_Store"
          - "**/.vscode"
          - "./vscode"
          - ".idea/"
          - ".vscode/"
        permissions:
          - team_slug: acme-admins
            permission: admin
          - team_slug: CloudPosse
            permission: admin
          - team_slug: developers
            permission: push
```

### Injecting infrastructure details into applications

Second, your application repos could use values to best configure their helm releases. We have an `eks/platform`
component for exposing various infra outputs. It takes remote state lookups and stores them into SSM. We demonstrate how
to pull the platform SSM parameters later. Here's an example `eks/platform` config:

```yaml
components:
  terraform:
    eks/platform:
      metadata:
        type: abstract
        component: eks/platform
      backend:
        s3:
          workspace_key_prefix: platform
      deps:
        - catalog/eks/cluster
        - catalog/eks/alb-controller-ingress-group
        - catalog/acm
      vars:
        enabled: true
        name: "platform"
        eks_component_name: eks/cluster
        ssm_platform_path: /platform/%s/%s
        references:
          default_alb_ingress_group:
            component: eks/alb-controller-ingress-group
            output: .group_name
          default_ingress_domain:
            component: dns-delegated
            environment: gbl
            output: "[.zones[].name][-1]"

    eks/platform/acm:
      metadata:
        component: eks/platform
        inherits:
          - eks/platform
      vars:
        eks_component_name: eks/cluster
        references:
          default_ingress_domain:
            component: acm
            environment: use2
            output: .domain_name

    eks/platform/dev:
      metadata:
        component: eks/platform
        inherits:
          - eks/platform
      vars:
        platform_environment: dev

    acm/qa2:
      settings:
        spacelift:
          workspace_enabled: true
      metadata:
        component: acm
      vars:
        enabled: true
        name: acm-qa2
        tags:
          Team: sre
          Service: acm
        process_domain_validation_options: true
        validation_method: DNS
        dns_private_zone_enabled: false
        certificate_authority_enabled: false
```

In the previous sample we create platform settings for a `dev` platform and a `qa2` platform. Understand that these are
arbitrary titles that are used to separate the SSM parameters so that if, say, a particular hostname is needed, we can
safely select the right hostname using a moniker such as `qa2`. These otherwise are meaningless and do not need to align
with any particular stage or tenant.

### ArgoCD on SAML / AWS Identity Center (formerly aws-sso)

Here's an example snippet for how to use this component:

```yaml
components:
  terraform:
    eks/argocd:
      settings:
        spacelift:
          workspace_enabled: true
          depends_on:
            - argocd-applicationset
            - tenant-gbl-corp-argocd-depoy-non-prod
      vars:
        enabled: true
        alb_group_name: argocd
        alb_name: argocd
        alb_logs_prefix: argocd
        certificate_issuer: selfsigning-issuer
        github_organization: MyOrg
        oidc_enabled: false
        saml_enabled: true
        ssm_store_account: corp
        ssm_store_account_region: us-west-2
        argocd_repo_name: argocd-deploy-non-prod
        argocd_rbac_policies:
          - "p, role:org-admin, applications, *, */*, allow"
          - "p, role:org-admin, clusters, get, *, allow"
          - "p, role:org-admin, repositories, get, *, allow"
          - "p, role:org-admin, repositories, create, *, allow"
          - "p, role:org-admin, repositories, update, *, allow"
          - "p, role:org-admin, repositories, delete, *, allow"
        # Note: the IDs for AWS Identity Center groups will change if you alter/replace them:
        argocd_rbac_groups:
          - group: deadbeef-dead-beef-dead-beefdeadbeef
            role: admin
          - group: badca7sb-add0-65ba-dca7-sbadd065badc
            role: reader
        chart_values:
          global:
            logging:
              format: json
              level: warn

    sso-saml/aws-sso:
      settings:
        spacelift:
          workspace_enabled: true
      metadata:
        component: sso-saml-provider
      vars:
        enabled: true
        ssm_path_prefix: "/sso/saml/aws-sso"
        usernameAttr: email
        emailAttr: email
        groupsAttr: groups
```

Note, if you set up `sso-saml-provider`, you will need to restart DEX on your EKS cluster manually:

```bash
kubectl delete pod <dex-pod-name> -n argocd
```

The configuration above will work for AWS Identity Center if you have the following attributes in a
[Custom SAML 2.0 application](https://docs.aws.amazon.com/singlesignon/latest/userguide/samlapps.html):

| attribute name | value           | type        |
| :------------- | :-------------- | :---------- |
| Subject        | ${user:subject} | persistent  |
| email          | ${user:email}   | unspecified |
| groups         | ${user:groups}  | unspecified |

You will also need to assign AWS Identity Center groups to your Custom SAML 2.0 application. Make a note of each group
and replace the IDs in the `argocd_rbac_groups` var accordingly.

### Google Workspace OIDC

To use Google OIDC:

```yaml
oidc_enabled: true
saml_enabled: false
oidc_providers:
  google:
    uses_dex: true
    type: google
    id: google
    name: Google
    serviceAccountAccess:
      enabled: true
      key: googleAuth.json
      value: /sso/oidc/google/serviceaccount
      admin_email: an_actual_user@acme.com
    config:
      # This filters emails when signing in with Google to only this domain. helpful for picking the right one.
      hostedDomains:
        - acme.com
      clientID: /sso/saml/google/clientid
      clientSecret: /sso/saml/google/clientsecret
```

### Working with ArgoCD and GitHub

Here's a simple GitHub action that will trigger a deployment in ArgoCD:

```yaml
# NOTE: Example will show dev, and qa2
name: argocd-deploy
on:
  push:
    branches:
      - main
jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2.1.0
        with:
          aws-region: us-east-2
          role-to-assume: arn:aws:iam::123456789012:role/github-action-worker
      - name: Build
        shell: bash
        run: docker build -t some.docker.repo/acme/app . & docker push some.docker.repo/acmo/app
      - name: Checkout Argo Configuration
        uses: actions/checkout@v3
        with:
          repository: acme/argocd-deploy-non-prod
          ref: main
          path: argocd-deploy-non-prod
      - name: Deploy to dev
        shell: bash
        run: |
          echo Rendering helmfile:
          helmfile \
            --namespace acme-app \
            --environment dev \
            --file deploy/app/release.yaml \
            --state-values-file <(aws ssm get-parameter --name /platform/dev),<(docker image inspect some.docker.repo/acme/app) \
            template > argocd-deploy-non-prod/plat/use2-dev/apps/my-preview-acme-app/manifests/resources.yaml
          echo Updating sha for app:
          yq e '' -i argocd-deploy-non-prod/plat/use2-dev/apps/my-preview-acme-app/config.yaml
          echo Committing new helmfile
          pushd argocd-deploy-non-prod
          git add --all
          git commit --message 'Updating acme-app'
          git push
          popd
```

In the above example, we make a few assumptions:

- You've already made the app in ArgoCD by creating a YAML file in your non-prod ArgoCD repo at the path
  `plat/use2-dev/apps/my-preview-acme-app/config.yaml` with contents:

```yaml
app_repository: acme/app
app_commit: deadbeefdeadbeef
app_hostname: https://some.app.endpoint/landing_page
name: my-feature-branch.acme-app
namespace: my-feature-branch
manifests: plat/use2-dev/apps/my-preview-acme-app/manifests
```

- you have set up `ecr` with permissions for github to push docker images to it
- you already have your `ApplicationSet` and `AppProject` crd's in `plat/use2-dev/argocd/applicationset.yaml`, which
  should be generated by our `argocd-repo` component.
- your app has a [helmfile template](https://helmfile.readthedocs.io/en/latest/#templating) in `deploy/app/release.yaml`
- that helmfile template can accept both the `eks/platform` config which is pulled from ssm at the path configured in
  `eks/platform/defaults`
- the helmfile template can update container resources using the output of `docker image inspect`

### Notifications

Here's a configuration for letting argocd send notifications back to GitHub:

1. [Create GitHub PAT](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token)
   with scope `repo:status`
2. Save the PAT to SSM `/argocd/notifications/notifiers/common/github-token`
3. Use this atmos stack configuration

```yaml
components:
  terraform:
    eks/argocd/notifications:
      metadata:
        component: eks/argocd
      vars:
        github_default_notifications_enabled: true
```

### Webhook

Here's a configuration Github notify ArgoCD on commit:

1. [Create GitHub PAT](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token)
   with scope `admin:repo_hook`
2. Save the PAT to SSM `/argocd/github/api_key`
3. Use this atmos stack configuration

```yaml
components:
  terraform:
    eks/argocd/notifications:
      metadata:
        component: eks/argocd
      vars:
        github_webhook_enabled: true
```

#### Creating Webhooks with `github-webhook`

If you are creating webhooks for ArgoCD deployment repos in multiple GitHub Organizations, you cannot use the same
Terraform GitHub provider. Instead, we can use Atmos to deploy multiple component. To do this, disable the webhook
creation in this component and deploy the webhook with the `github-webhook` component as such:

```yaml
components:
  terraform:
    eks/argocd:
      metadata:
        component: eks/argocd
        inherits:
          - eks/argocd/defaults
      vars:
        github_webhook_enabled: true # create webhook value; required for argo-cd chart
        create_github_webhook: false # created with github-webhook
        argocd_repositories:
          "argocd-deploy-non-prod/org1": # this is the name of the `argocd-repo` component for "org1"
            environment: ue2
            stage: auto
            tenant: core
          "argocd-deploy-non-prod/org2":
            environment: ue2
            stage: auto
            tenant: core

    webhook/org1/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: org1
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.acme.org/api/webhook"
        ssm_github_webhook: "/argocd/github/webhook"

    webhook/org2/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: org2
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.acme.org/api/webhook"
        ssm_github_webhook: "/argocd/github/webhook"
```

### Slack Notifications

ArgoCD supports Slack notifications on application deployments.

1. In order to enable Slack notifications, first create a Slack Application following the
   [ArgoCD documentation](https://argocd-notifications.readthedocs.io/en/stable/services/slack/).
1. Create an OAuth token for the new Slack App
1. Save the OAuth token to AWS SSM Parameter Store in the same account and region as Github tokens. For example,
   `core-use2-auto`
1. Add the app to the chosen Slack channel. _If not added, notifications will not work_
1. For this component, enable Slack integrations for each Application with `var.slack_notifications_enabled` and
   `var.slack_notifications`:

```yaml
slack_notifications_enabled: true
slack_notifications:
  channel: argocd-updates
```

6. In the `argocd-repo` component, set `var.slack_notifications_channel` to the name of the Slack notification channel
   to add the relevant ApplicationSet annotations

## Troubleshooting

## Login to ArgoCD admin UI

For ArgoCD v1.9 and later, the initial admin password is available from a Kubernetes secret named
`argocd-initial-admin-secret`. To get the initial password, execute the following command:

```shell
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode
```

Then open the ArgoCD admin UI and use the username `admin` and the password obtained in the previous step to log in to
the ArgoCD admin.

## Error "server.secretkey is missing"

If you provision a new version of the `eks/argocd` component, and some Helm Chart values get updated, you might
encounter the error "server.secretkey is missing" in the ArgoCD admin UI. To fix the error, execute the following
commands:

```shell
# Download `kubeconfig` and set EKS cluster
set-eks-cluster cluster-name

# Restart the `argocd-server` Pods
kubectl rollout restart deploy/argocd-server -n argocd

# Get the new admin password from the Kubernetes secret
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 --decode
```

Reference: https://stackoverflow.com/questions/75046330/argo-cd-error-server-secretkey-is-missing

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.0 |
| `github` | >= 4.0 |
| `helm` | >= 2.6.0 |
| `kubernetes` | >= 2.9.0, != 2.21.0 |
| `random` | >= 3.5 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.0 |
| `aws` | >= 4.0 |
| `github` | >= 4.0 |
| `kubernetes` | >= 2.9.0, != 2.21.0 |
| `random` | >= 3.5 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`argocd` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`argocd_apps` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | n/a
`argocd_repo` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`dns_gbl_delegated` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`iam_roles_config_secrets` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`notifications_notifiers` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a
`notifications_templates` | 1.0.2 | [`cloudposse/config/yaml//modules/deepmerge`](https://registry.terraform.io/modules/cloudposse/config/yaml/modules/deepmerge/1.0.2) | n/a
`saml_sso_providers` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`github_repository_webhook.default`](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) (resource)(github_webhook.tf#45)
  - [`random_password.webhook`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) (resource)(github_webhook.tf#32)

## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)
  - [`aws_ssm_parameter.github_api_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.github_deploy_key`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.oidc_client_id`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.oidc_client_secret`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameter.slack_notifications`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) (data source)
  - [`aws_ssm_parameters_by_path.argocd_notifications`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) (data source)
  - [`kubernetes_resources.crd`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resources) (data source)

## Outputs

<dl>
  <dt><code>github_webhook_value</code></dt>
  <dd>

  
  The value of the GitHub webhook secret used for ArgoCD<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `github_organization` (`string`) <i>required</i>


GitHub Organization<br/>

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


### `ssm_store_account` (`string`) <i>required</i>


Account storing SSM parameters<br/>

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


### `ssm_store_account_region` (`string`) <i>required</i>


AWS region storing SSM parameters<br/>

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
### `admin_enabled` (`bool`) <i>optional</i>


Toggles Admin user creation the deployed chart<br/>

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


### `alb_group_name` (`string`) <i>optional</i>


A name used in annotations to reuse an ALB (e.g. `argocd`) or to generate a new one<br/>

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


### `alb_logs_bucket` (`string`) <i>optional</i>


The name of the bucket for ALB access logs. The bucket must have policy allowing the ELB logging principal<br/>

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


### `alb_logs_prefix` (`string`) <i>optional</i>


`alb_logs_bucket` s3 bucket prefix<br/>

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


### `alb_name` (`string`) <i>optional</i>


The name of the ALB (e.g. `argocd`) provisioned by `alb-controller`. Works together with `var.alb_group_name`<br/>

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


### `anonymous_enabled` (`bool`) <i>optional</i>


Toggles anonymous user access using default RBAC setting (Defaults to read-only)<br/>

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


### `argocd_apps_chart` (`string`) <i>optional</i>


Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended.<br/>

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
>   <code>"argocd-apps"</code>
>   </dd>
> </dl>
>


### `argocd_apps_chart_description` (`string`) <i>optional</i>


Set release description attribute (visible in the history).<br/>

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
>   <code>"A Helm chart for managing additional Argo CD Applications and Projects"</code>
>   </dd>
> </dl>
>


### `argocd_apps_chart_repository` (`string`) <i>optional</i>


Repository URL where to locate the requested chart.<br/>

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
>   <code>"https://argoproj.github.io/argo-helm"</code>
>   </dd>
> </dl>
>


### `argocd_apps_chart_values` (`any`) <i>optional</i>


Additional values to yamlencode as `helm_release` values for the argocd_apps chart<br/>

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


### `argocd_apps_chart_version` (`string`) <i>optional</i>


Specify the exact chart version to install. If this is not specified, the latest version is installed.<br/>

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
>   <code>"0.0.3"</code>
>   </dd>
> </dl>
>


### `argocd_apps_enabled` (`bool`) <i>optional</i>


Enable argocd apps<br/>

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


### `argocd_create_namespaces` (`bool`) <i>optional</i>


ArgoCD create namespaces policy<br/>

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


### `argocd_rbac_default_policy` (`string`) <i>optional</i>


Default ArgoCD RBAC default role.<br/>
<br/>
See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#basic-built-in-roles for more information.<br/>
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
>   <code>"role:readonly"</code>
>   </dd>
> </dl>
>


### `argocd_rbac_groups` <i>optional</i>


List of ArgoCD Group Role Assignment strings to be added to the argocd-rbac configmap policy.csv item.<br/>
e.g.<br/>
[<br/>
  {<br/>
    group: idp-group-name,<br/>
    role: argocd-role-name<br/>
  },<br/>
]<br/>
becomes: `g, idp-group-name, role:argocd-role-name`<br/>
See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information.<br/>
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
>   list(object({
    group = string,
    role  = string
  }))
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `argocd_rbac_policies` (`list(string)`) <i>optional</i>


List of ArgoCD RBAC Permission strings to be added to the argocd-rbac configmap policy.csv item.<br/>
<br/>
See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information.<br/>
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


### `argocd_repositories` <i>optional</i>


Map of objects defining an `argocd_repo` to configure.  The key is the name of the ArgoCD repository.<br/>

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
    environment = string # The environment where the `argocd_repo` component is deployed.
    stage       = string # The stage where the `argocd_repo` component is deployed.
    tenant      = string # The tenant where the `argocd_repo` component is deployed.
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


### `atomic` (`bool`) <i>optional</i>


If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used.<br/>

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


### `certificate_issuer` (`string`) <i>optional</i>


Certificate manager cluster issuer<br/>

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
>   <code>"letsencrypt-staging"</code>
>   </dd>
> </dl>
>


### `chart` (`string`) <i>optional</i>


Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended.<br/>

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
>   <code>"argo-cd"</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `chart_repository` (`string`) <i>optional</i>


Repository URL where to locate the requested chart.<br/>

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
>   <code>"https://argoproj.github.io/argo-helm"</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"5.19.12"</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `create_github_webhook` (`bool`) <i>optional</i>


  Enable GitHub webhook creation<br/>
<br/>
  Use this to create the GitHub Webhook for the given ArgoCD repo using the value created when `var.github_webhook_enabled` is `true`.<br/>
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


### `create_namespace` (`bool`) <i>optional</i>


Create the namespace if it does not yet exist. Defaults to `false`.<br/>

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


### `forecastle_enabled` (`bool`) <i>optional</i>


Toggles Forecastle integration in the deployed chart<br/>

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


### `github_base_url` (`string`) <i>optional</i>


This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/`<br/>

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


### `github_default_notifications_enabled` (`bool`) <i>optional</i>


Enable default GitHub commit statuses notifications (required for CD sync mode)<br/>

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


### `github_token_override` (`string`) <i>optional</i>


Use the value of this variable as the GitHub token instead of reading it from SSM<br/>

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


### `github_webhook_enabled` (`bool`) <i>optional</i>


  Enable GitHub webhook integration<br/>
<br/>
  Use this to create a secret value and pass it to the argo-cd chart<br/>
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


### `host` (`string`) <i>optional</i>


Host name to use for ingress and ALB<br/>

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


### `kubernetes_namespace` (`string`) <i>optional</i>


The namespace to install the release into.<br/>

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
>   <code>"argocd"</code>
>   </dd>
> </dl>
>


### `notifications_notifiers` <i>optional</i>


Notification Triggers to configure.<br/>
<br/>
See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br/>
See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)<br/>
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
    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")
    # service.webhook.<webhook-name>:
    webhook = optional(map(
      object({
        url = string
        headers = optional(list(
          object({
            name  = string
            value = string
          })
        ), [])
        insecureSkipVerify = optional(bool, false)
      })
    ))
  })
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


### `notifications_templates` <i>optional</i>


Notification Templates to configure.<br/>
<br/>
See: https://argocd-notifications.readthedocs.io/en/stable/templates/<br/>
See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158)<br/>
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
    message = string
    alertmanager = optional(object({
      labels       = map(string)
      annotations  = map(string)
      generatorURL = string
    }))
    webhook = optional(map(
      object({
        method = optional(string)
        path   = optional(string)
        body   = optional(string)
      })
    ))
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


### `notifications_triggers` <i>optional</i>


Notification Triggers to configure.<br/>
<br/>
See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br/>
See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352)<br/>
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
>   map(list(
    object({
      oncePer = optional(string)
      send    = list(string)
      when    = string
    })
  ))
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


### `oidc_enabled` (`bool`) <i>optional</i>


Toggles OIDC integration in the deployed chart<br/>

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


### `oidc_issuer` (`string`) <i>optional</i>


OIDC issuer URL<br/>

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


### `oidc_name` (`string`) <i>optional</i>


Name of the OIDC resource<br/>

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


### `oidc_rbac_scopes` (`string`) <i>optional</i>


OIDC RBAC scopes to request<br/>

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
>   <code>"[argocd_realm_access]"</code>
>   </dd>
> </dl>
>


### `oidc_requested_scopes` (`string`) <i>optional</i>


Set of OIDC scopes to request<br/>

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
>   <code>"[\"openid\", \"profile\", \"email\", \"groups\"]"</code>
>   </dd>
> </dl>
>


### `rbac_enabled` (`bool`) <i>optional</i>


Enable Service Account for pods.<br/>

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


### `resources` <i>optional</i>


The cpu and memory of the deployment's limits and requests.<br/>

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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `saml_enabled` (`bool`) <i>optional</i>


Toggles SAML integration in the deployed chart<br/>

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


### `saml_rbac_scopes` (`string`) <i>optional</i>


SAML RBAC scopes to request<br/>

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
>   <code>"[email,groups]"</code>
>   </dd>
> </dl>
>


### `saml_sso_providers` <i>optional</i>


SAML SSO providers components<br/>

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
    component   = string
    environment = optional(string, null)
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


### `service_type` (`string`) <i>optional</i>


Service type for exposing the ArgoCD service. The available type values and their behaviors are:<br/>
  ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster.<br/>
  NodePort: Exposes the Service on each Node's IP at a static port (the NodePort).<br/>
  LoadBalancer: Exposes the Service externally using a cloud provider's load balancer.<br/>
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
>   <code>"NodePort"</code>
>   </dd>
> </dl>
>


### `slack_notifications` <i>optional</i>


ArgoCD Slack notification configuration. Requires Slack Bot created with token stored at the given SSM Parameter path.<br/>
<br/>
See: https://argocd-notifications.readthedocs.io/en/stable/services/slack/<br/>
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
    token_ssm_path = optional(string, "/argocd/notifications/notifiers/slack/token")
    api_url        = optional(string, null)
    username       = optional(string, "ArgoCD")
    icon           = optional(string, null)
  })
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


### `slack_notifications_enabled` (`bool`) <i>optional</i>


Whether or not to enable Slack notifications. See `var.slack_notifications.<br/>

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


### `ssm_github_api_key` (`string`) <i>optional</i>


SSM path to the GitHub API key<br/>

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
>   <code>"/argocd/github/api_key"</code>
>   </dd>
> </dl>
>


### `ssm_oidc_client_id` (`string`) <i>optional</i>


The SSM Parameter Store path for the ID of the IdP client<br/>

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
>   <code>"/argocd/oidc/client_id"</code>
>   </dd>
> </dl>
>


### `ssm_oidc_client_secret` (`string`) <i>optional</i>


The SSM Parameter Store path for the secret of the IdP client<br/>

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
>   <code>"/argocd/oidc/client_secret"</code>
>   </dd>
> </dl>
>


### `ssm_store_account_tenant` (`string`) <i>optional</i>


Tenant of the account storing SSM parameters.<br/>
<br/>
If the tenant label is not used, leave this as null.<br/>
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


### `timeout` (`number`) <i>optional</i>


Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds<br/>

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
>   <code>300</code>
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
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
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

- [Argo CD](https://argoproj.github.io/cd/)
- [Argo CD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [Argo Helm Chart](https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
