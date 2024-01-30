# Component: `github-webhook`

This component provisions a GitHub webhook for a single GitHub repository.

You may want to use this component if you are provisioning webhooks for multiple ArgoCD deployment repositories across GitHub organizations.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    webhook/cloudposse/argocd:
      metadata:
        component: github-webhook
      vars:
        github_organization: cloudposse
        github_repository: argocd-deploy-non-prod
        webhook_url: "https://argocd.ue2.dev.plat.cloudposse.org/api/webhook"
        ssm_github_webhook: "/argocd/github/webhook"
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
