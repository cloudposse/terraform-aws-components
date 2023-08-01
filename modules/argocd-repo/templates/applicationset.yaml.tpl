# This file has been programmatically generated and committed by the argocd-repo Terraform component in the infrastructure
# monorepo. It can be adjusted by modifying templates/applicationset.yaml.tpl in the aforementioned component.

apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  annotations:
    argocd-autopilot.argoproj-labs.io/default-dest-server: https://kubernetes.default.svc
    argocd.argoproj.io/sync-options: PruneLast=true
    argocd.argoproj.io/sync-wave: "-2"
%{if slack_channel != "" && slack_channel != null ~}
    notifications.argoproj.io/subscribe.on-deployed.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-health-degraded.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-failed.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-running.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-succeeded.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-deleted.slack: ${slack_channel}
%{ endif ~}
    notifications.argoproj.io/subscribe.on-deployed.datadog: ""
    notifications.argoproj.io/subscribe.on-health-degraded.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-failed.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-running.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-status-unknown.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-succeeded.datadog: ""
    notifications.argoproj.io/subscribe.on-deployed.github-deployment: ""
    notifications.argoproj.io/subscribe.on-deployed.github-commit-status: ""
    notifications.argoproj.io/subscribe.on-deleted.github-deployment: ""
  name: ${name}
  namespace: ${namespace}
spec:
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  description: ${name} project
  destinations:
    - namespace: '*'
      server: '*'
  namespaceResourceWhitelist:
    - group: '*'
      kind: '*'
  sourceRepos:
    - '*'
status: {}

---
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"
  name: ${name}
  namespace: ${namespace}
spec:
  generators:
    - git:
        repoURL: ${ssh_url}
        revision: HEAD
        files:
          - path: ${environment}/apps/*/*/config.yaml
  template:
    metadata:
      annotations:
        deployment_id: '{{deployment_id}}'
        app_repository: '{{app_repository}}'
        app_commit: '{{app_commit}}'
        app_hostname: 'https://{{app_hostname}}'
        notifications.argoproj.io/subscribe.on-deployed.github: ""
        notifications.argoproj.io/subscribe.on-deployed.github-commit-status: ""
      name: '{{name}}'
    spec:
      project: ${name}
      source:
        repoURL: ${ssh_url}
        targetRevision: HEAD
        path: '{{manifests}}'
      destination:
        server: https://kubernetes.default.svc
        namespace: '{{namespace}}'
      syncPolicy:
%{if auto-sync ~}
        automated:
          prune: true
          selfHeal: true
%{ endif ~}
        syncOptions:
          - CreateNamespace=true
%{if length(ignore-differences) > 0 ~}
          - RespectIgnoreDifferences=true
      ignoreDifferences:
%{for item in ignore-differences ~}
        - group: "${item.group}"
          kind: "${item.kind}"
          jsonPointers:
%{for pointer in item.json-pointers ~}
            - ${pointer}
%{ endfor ~}
%{ endfor ~}
%{ endif ~}
