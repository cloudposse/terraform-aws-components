---
tags:
  - component/eks/argocd
  - layer/software-delivery
  - provider/aws
  - provider/helm
---

# Component: `eks/argocd`

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
            - tenant-gbl-corp-argocd-deploy-non-prod
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
        run: docker build -t some.docker.repo/acme/app . & docker push some.docker.repo/acme/app
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
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | >= 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.6.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.9.0, != 2.21.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |
| <a name="provider_aws.config_secrets"></a> [aws.config\_secrets](#provider\_aws.config\_secrets) | >= 4.0 |
| <a name="provider_github"></a> [github](#provider\_github) | >= 4.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.9.0, != 2.21.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_argocd"></a> [argocd](#module\_argocd) | cloudposse/helm-release/aws | 0.10.1 |
| <a name="module_argocd_apps"></a> [argocd\_apps](#module\_argocd\_apps) | cloudposse/helm-release/aws | 0.10.1 |
| <a name="module_argocd_repo"></a> [argocd\_repo](#module\_argocd\_repo) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_dns_gbl_delegated"></a> [dns\_gbl\_delegated](#module\_dns\_gbl\_delegated) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_iam_roles_config_secrets"></a> [iam\_roles\_config\_secrets](#module\_iam\_roles\_config\_secrets) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_notifications_notifiers"></a> [notifications\_notifiers](#module\_notifications\_notifiers) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |
| <a name="module_notifications_templates"></a> [notifications\_templates](#module\_notifications\_templates) | cloudposse/config/yaml//modules/deepmerge | 1.0.2 |
| <a name="module_saml_sso_providers"></a> [saml\_sso\_providers](#module\_saml\_sso\_providers) | cloudposse/stack-config/yaml//modules/remote-state | 1.5.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [github_repository_webhook.default](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/repository_webhook) | resource |
| [random_password.webhook](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_ssm_parameter.github_api_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.github_deploy_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.oidc_client_id](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.oidc_client_secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameter.slack_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_ssm_parameters_by_path.argocd_notifications](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameters_by_path) | data source |
| [kubernetes_resources.crd](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_admin_enabled"></a> [admin\_enabled](#input\_admin\_enabled) | Toggles Admin user creation the deployed chart | `bool` | `false` | no |
| <a name="input_alb_group_name"></a> [alb\_group\_name](#input\_alb\_group\_name) | A name used in annotations to reuse an ALB (e.g. `argocd`) or to generate a new one | `string` | `null` | no |
| <a name="input_alb_logs_bucket"></a> [alb\_logs\_bucket](#input\_alb\_logs\_bucket) | The name of the bucket for ALB access logs. The bucket must have policy allowing the ELB logging principal | `string` | `""` | no |
| <a name="input_alb_logs_prefix"></a> [alb\_logs\_prefix](#input\_alb\_logs\_prefix) | `alb_logs_bucket` s3 bucket prefix | `string` | `""` | no |
| <a name="input_alb_name"></a> [alb\_name](#input\_alb\_name) | The name of the ALB (e.g. `argocd`) provisioned by `alb-controller`. Works together with `var.alb_group_name` | `string` | `null` | no |
| <a name="input_anonymous_enabled"></a> [anonymous\_enabled](#input\_anonymous\_enabled) | Toggles anonymous user access using default RBAC setting (Defaults to read-only) | `bool` | `false` | no |
| <a name="input_argocd_apps_chart"></a> [argocd\_apps\_chart](#input\_argocd\_apps\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | `"argocd-apps"` | no |
| <a name="input_argocd_apps_chart_description"></a> [argocd\_apps\_chart\_description](#input\_argocd\_apps\_chart\_description) | Set release description attribute (visible in the history). | `string` | `"A Helm chart for managing additional Argo CD Applications and Projects"` | no |
| <a name="input_argocd_apps_chart_repository"></a> [argocd\_apps\_chart\_repository](#input\_argocd\_apps\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | `"https://argoproj.github.io/argo-helm"` | no |
| <a name="input_argocd_apps_chart_values"></a> [argocd\_apps\_chart\_values](#input\_argocd\_apps\_chart\_values) | Additional values to yamlencode as `helm_release` values for the argocd\_apps chart | `any` | `{}` | no |
| <a name="input_argocd_apps_chart_version"></a> [argocd\_apps\_chart\_version](#input\_argocd\_apps\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `"0.0.3"` | no |
| <a name="input_argocd_apps_enabled"></a> [argocd\_apps\_enabled](#input\_argocd\_apps\_enabled) | Enable argocd apps | `bool` | `true` | no |
| <a name="input_argocd_create_namespaces"></a> [argocd\_create\_namespaces](#input\_argocd\_create\_namespaces) | ArgoCD create namespaces policy | `bool` | `false` | no |
| <a name="input_argocd_rbac_default_policy"></a> [argocd\_rbac\_default\_policy](#input\_argocd\_rbac\_default\_policy) | Default ArgoCD RBAC default role.<br><br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/#basic-built-in-roles for more information. | `string` | `"role:readonly"` | no |
| <a name="input_argocd_rbac_groups"></a> [argocd\_rbac\_groups](#input\_argocd\_rbac\_groups) | List of ArgoCD Group Role Assignment strings to be added to the argocd-rbac configmap policy.csv item.<br>e.g.<br>[<br>  {<br>    group: idp-group-name,<br>    role: argocd-role-name<br>  },<br>]<br>becomes: `g, idp-group-name, role:argocd-role-name`<br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information. | <pre>list(object({<br>    group = string,<br>    role  = string<br>  }))</pre> | `[]` | no |
| <a name="input_argocd_rbac_policies"></a> [argocd\_rbac\_policies](#input\_argocd\_rbac\_policies) | List of ArgoCD RBAC Permission strings to be added to the argocd-rbac configmap policy.csv item.<br><br>See https://argo-cd.readthedocs.io/en/stable/operator-manual/rbac/ for more information. | `list(string)` | `[]` | no |
| <a name="input_argocd_repositories"></a> [argocd\_repositories](#input\_argocd\_repositories) | Map of objects defining an `argocd_repo` to configure.  The key is the name of the ArgoCD repository. | <pre>map(object({<br>    environment = string # The environment where the `argocd_repo` component is deployed.<br>    stage       = string # The stage where the `argocd_repo` component is deployed.<br>    tenant      = string # The tenant where the `argocd_repo` component is deployed.<br>  }))</pre> | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_certificate_issuer"></a> [certificate\_issuer](#input\_certificate\_issuer) | Certificate manager cluster issuer | `string` | `"letsencrypt-staging"` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended. | `string` | `"argo-cd"` | no |
| <a name="input_chart_description"></a> [chart\_description](#input\_chart\_description) | Set release description attribute (visible in the history). | `string` | `null` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Repository URL where to locate the requested chart. | `string` | `"https://argoproj.github.io/argo-helm"` | no |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Additional values to yamlencode as `helm_release` values. | `any` | `{}` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed. | `string` | `"5.55.0"` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails. | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_github_webhook"></a> [create\_github\_webhook](#input\_create\_github\_webhook) | Enable GitHub webhook creation<br><br>  Use this to create the GitHub Webhook for the given ArgoCD repo using the value created when `var.github_webhook_enabled` is `true`. | `bool` | `true` | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_forecastle_enabled"></a> [forecastle\_enabled](#input\_forecastle\_enabled) | Toggles Forecastle integration in the deployed chart | `bool` | `false` | no |
| <a name="input_github_base_url"></a> [github\_base\_url](#input\_github\_base\_url) | This is the target GitHub base API endpoint. Providing a value is a requirement when working with GitHub Enterprise. It is optional to provide this value and it can also be sourced from the `GITHUB_BASE_URL` environment variable. The value must end with a slash, for example: `https://terraformtesting-ghe.westus.cloudapp.azure.com/` | `string` | `null` | no |
| <a name="input_github_default_notifications_enabled"></a> [github\_default\_notifications\_enabled](#input\_github\_default\_notifications\_enabled) | Enable default GitHub commit statuses notifications (required for CD sync mode) | `bool` | `true` | no |
| <a name="input_github_organization"></a> [github\_organization](#input\_github\_organization) | GitHub Organization | `string` | n/a | yes |
| <a name="input_github_token_override"></a> [github\_token\_override](#input\_github\_token\_override) | Use the value of this variable as the GitHub token instead of reading it from SSM | `string` | `null` | no |
| <a name="input_github_webhook_enabled"></a> [github\_webhook\_enabled](#input\_github\_webhook\_enabled) | Enable GitHub webhook integration<br><br>  Use this to create a secret value and pass it to the argo-cd chart | `bool` | `true` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_host"></a> [host](#input\_host) | Host name to use for ingress and ALB | `string` | `""` | no |
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
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | The namespace to install the release into. | `string` | `"argocd"` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_notifications_notifiers"></a> [notifications\_notifiers](#input\_notifications\_notifiers) | Notification Triggers to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352) | <pre>object({<br>    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")<br>    # service.webhook.<webhook-name>:<br>    webhook = optional(map(<br>      object({<br>        url = string<br>        headers = optional(list(<br>          object({<br>            name  = string<br>            value = string<br>          })<br>        ), [])<br>        insecureSkipVerify = optional(bool, false)<br>      })<br>    ))<br>  })</pre> | `{}` | no |
| <a name="input_notifications_templates"></a> [notifications\_templates](#input\_notifications\_templates) | Notification Templates to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/templates/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L158) | <pre>map(object({<br>    message = string<br>    alertmanager = optional(object({<br>      labels       = map(string)<br>      annotations  = map(string)<br>      generatorURL = string<br>    }))<br>    webhook = optional(map(<br>      object({<br>        method = optional(string)<br>        path   = optional(string)<br>        body   = optional(string)<br>      })<br>    ))<br>  }))</pre> | `{}` | no |
| <a name="input_notifications_triggers"></a> [notifications\_triggers](#input\_notifications\_triggers) | Notification Triggers to configure.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/triggers/<br>See: [Example value in argocd-notifications Helm Chart](https://github.com/argoproj/argo-helm/blob/a0a74fb43d147073e41aadc3d88660b312d6d638/charts/argocd-notifications/values.yaml#L352) | <pre>map(list(<br>    object({<br>      oncePer = optional(string)<br>      send    = list(string)<br>      when    = string<br>    })<br>  ))</pre> | `{}` | no |
| <a name="input_oidc_enabled"></a> [oidc\_enabled](#input\_oidc\_enabled) | Toggles OIDC integration in the deployed chart | `bool` | `false` | no |
| <a name="input_oidc_issuer"></a> [oidc\_issuer](#input\_oidc\_issuer) | OIDC issuer URL | `string` | `""` | no |
| <a name="input_oidc_name"></a> [oidc\_name](#input\_oidc\_name) | Name of the OIDC resource | `string` | `""` | no |
| <a name="input_oidc_rbac_scopes"></a> [oidc\_rbac\_scopes](#input\_oidc\_rbac\_scopes) | OIDC RBAC scopes to request | `string` | `"[argocd_realm_access]"` | no |
| <a name="input_oidc_requested_scopes"></a> [oidc\_requested\_scopes](#input\_oidc\_requested\_scopes) | Set of OIDC scopes to request | `string` | `"[\"openid\", \"profile\", \"email\", \"groups\"]"` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Enable Service Account for pods. | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region. | `string` | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | The cpu and memory of the deployment's limits and requests. | <pre>object({<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | `null` | no |
| <a name="input_saml_enabled"></a> [saml\_enabled](#input\_saml\_enabled) | Toggles SAML integration in the deployed chart | `bool` | `false` | no |
| <a name="input_saml_rbac_scopes"></a> [saml\_rbac\_scopes](#input\_saml\_rbac\_scopes) | SAML RBAC scopes to request | `string` | `"[email,groups]"` | no |
| <a name="input_saml_sso_providers"></a> [saml\_sso\_providers](#input\_saml\_sso\_providers) | SAML SSO providers components | <pre>map(object({<br>    component   = string<br>    environment = optional(string, null)<br>  }))</pre> | `{}` | no |
| <a name="input_service_type"></a> [service\_type](#input\_service\_type) | Service type for exposing the ArgoCD service. The available type values and their behaviors are:<br>  ClusterIP: Exposes the Service on a cluster-internal IP. Choosing this value makes the Service only reachable from within the cluster.<br>  NodePort: Exposes the Service on each Node's IP at a static port (the NodePort).<br>  LoadBalancer: Exposes the Service externally using a cloud provider's load balancer. | `string` | `"NodePort"` | no |
| <a name="input_slack_notifications"></a> [slack\_notifications](#input\_slack\_notifications) | ArgoCD Slack notification configuration. Requires Slack Bot created with token stored at the given SSM Parameter path.<br><br>See: https://argocd-notifications.readthedocs.io/en/stable/services/slack/ | <pre>object({<br>    token_ssm_path = optional(string, "/argocd/notifications/notifiers/slack/token")<br>    api_url        = optional(string, null)<br>    username       = optional(string, "ArgoCD")<br>    icon           = optional(string, null)<br>  })</pre> | `{}` | no |
| <a name="input_slack_notifications_enabled"></a> [slack\_notifications\_enabled](#input\_slack\_notifications\_enabled) | Whether or not to enable Slack notifications. See `var.slack_notifications.` | `bool` | `false` | no |
| <a name="input_ssm_github_api_key"></a> [ssm\_github\_api\_key](#input\_ssm\_github\_api\_key) | SSM path to the GitHub API key | `string` | `"/argocd/github/api_key"` | no |
| <a name="input_ssm_oidc_client_id"></a> [ssm\_oidc\_client\_id](#input\_ssm\_oidc\_client\_id) | The SSM Parameter Store path for the ID of the IdP client | `string` | `"/argocd/oidc/client_id"` | no |
| <a name="input_ssm_oidc_client_secret"></a> [ssm\_oidc\_client\_secret](#input\_ssm\_oidc\_client\_secret) | The SSM Parameter Store path for the secret of the IdP client | `string` | `"/argocd/oidc/client_secret"` | no |
| <a name="input_ssm_store_account"></a> [ssm\_store\_account](#input\_ssm\_store\_account) | Account storing SSM parameters | `string` | n/a | yes |
| <a name="input_ssm_store_account_region"></a> [ssm\_store\_account\_region](#input\_ssm\_store\_account\_region) | AWS region storing SSM parameters | `string` | n/a | yes |
| <a name="input_ssm_store_account_tenant"></a> [ssm\_store\_account\_tenant](#input\_ssm\_store\_account\_tenant) | Tenant of the account storing SSM parameters.<br><br>If the tenant label is not used, leave this as null. | `string` | `null` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `300` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_github_webhook_value"></a> [github\_webhook\_value](#output\_github\_webhook\_value) | The value of the GitHub webhook secret used for ArgoCD |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- [Argo CD](https://argoproj.github.io/cd/)
- [Argo CD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [Argo Helm Chart](https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/)

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
