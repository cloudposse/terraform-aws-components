## Components PR [#905](https://github.com/cloudposse/terraform-aws-components/pull/905)

The `notifications.tf` file has been renamed to `notifications.tf`. Delete `notifications.tf` after vendoring these
changes.

## Components PR [#851](https://github.com/cloudposse/terraform-aws-components/pull/851)

This is a bug fix and feature enhancement update. There are few actions necessary to upgrade.

## Upgrade actions

1. Update atmos stack yaml config
   1. Add `github_default_notifications_enabled: true`
   2. Add `github_webhook_enabled: true`
   3. Remove `notifications_triggers`
   4. Remove `notifications_templates`
   5. Remove `notifications_notifiers`

```diff
 components:
   terraform:
     argocd:
       settings:
         spacelift:
           workspace_enabled: true
       metadata:
         component: eks/argocd
       vars:
+        github_default_notifications_enabled: true
+        github_webhook_enabled: true
-        notifications_triggers:
-          trigger_on-deployed:
-            - when: app.status.operationState.phase in ['Succeeded'] and app.status.health.status == 'Healthy'
-              oncePer: app.status.sync.revision
-              send: [app-deployed]
-        notifications_templates:
-          template_app-deployed:
-            message: |
-              Application {{.app.metadata.name}} is now running new version of deployments manifests.
-            github:
-              status:
-                state: success
-                label: "continuous-delivery/{{.app.metadata.name}}"
-                targetURL: "{{.context.argocdUrl}}/applications/{{.app.metadata.name}}?operation=true"
-        notifications_notifiers:
-          service_github:
-            appID: xxxxxxx
-            installationID: xxxxxxx
```

2. Move secrets from `/argocd/notifications/notifiers/service_webhook_github-commit-status/github-token` to
   `argocd/notifications/notifiers/common/github-token`

```bash
chamber read -q argocd/notifications/notifiers/service_webhook_github-commit-status github-token | chamber write argocd/notifications/notifiers/common github-token
chamber delete argocd/notifications/notifiers/service_webhook_github-commit-status github-token
```

3.  [Create GitHub PAT](https://docs.github.com/en/enterprise-server@3.6/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#creating-a-personal-access-token)
    with scope `admin:repo_hook`
4.  Save the PAT to SSM `/argocd/github/api_key`

```bash
chamber write argocd/github api_key ${PAT}
```

5. Apply changes with atmos

## Features

- [Git Webhook Configuration](https://argo-cd.readthedocs.io/en/stable/operator-manual/webhook/) - makes GitHub trigger
  ArgoCD sync on each commit into argocd repo
- Replace
  [GitHub notification service](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/github/)
  with predefined
  [Webhook notification service](https://argo-cd.readthedocs.io/en/stable/operator-manual/notifications/services/webhook/)
- Added predefined GitHub commit status notifications for CD sync mode:
  - `on-deploy-started`
    - `app-repo-github-commit-status`
    - `argocd-repo-github-commit-status`
  - `on-deploy-succeeded`
    - `app-repo-github-commit-status`
    - `argocd-repo-github-commit-status`
  - `on-deploy-failed`
    - `app-repo-github-commit-status`
    - `argocd-repo-github-commit-status`
- Support SSM secrets (`/argocd/notifications/notifiers/common/*`) common for all notification services. (Can be
  referenced with `$common_{secret-name}` )

### Bug Fixes

- ArgoCD notifications pods recreated on deployment that change notifications related configs and secrets
- Remove `metadata` output that expose helm values configs (used in debug purpose)
- Remove legacy unnecessary helm values used in old ArgoCD versions (ex. `workflow auth` configs) and dropped
  notifications services

## Breaking changes

- Removed `service_github` from `notifications_notifiers` variable structure
- Renamed `service_webhook` to `webhook` in `notifications_notifiers` variable structure

```diff
variable "notifications_notifiers" {
  type = object({
    ssm_path_prefix = optional(string, "/argocd/notifications/notifiers")
-    service_github = optional(object({
-      appID          = number
-      installationID = number
-      privateKey     = optional(string)
-    }))
    # service.webhook.<webhook-name>:
-    service_webhook = optional(map(
+    webhook = optional(map(
      object({
        url = string
        headers = optional(list(
      })
    ))
  })
```

- Removed `github` from `notifications_templates` variable structure

```diff
variable "notifications_templates" {
  type = map(object({
    message = string
    alertmanager = optional(object({
      labels       = map(string)
      annotations  = map(string)
      generatorURL = string
    }))
-    github = optional(object({
-      status = object({
-        state     = string
-        label     = string
-        targetURL = string
-      })
-    }))
    webhook = optional(map(
      object({
        method = optional(string)
        path   = optional(string)
        body   = optional(string)
      })
    ))
 }))
```
