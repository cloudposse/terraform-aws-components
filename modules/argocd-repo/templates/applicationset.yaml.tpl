# This file has been programmatically generated and committed by the argocd-repo Terraform component in the infrastructure
# monorepo. It can be adjusted by modifying templates/applicationset.yaml.tpl in the aforementioned component.

apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  annotations:
    argocd-autopilot.argoproj-labs.io/default-dest-server: https://kubernetes.default.svc
    argocd.argoproj.io/sync-options: PruneLast=true
    argocd.argoproj.io/sync-wave: "-2"
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
  creationTimestamp: null
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
%{for noti in notifications ~}
        ${noti}
%{ endfor ~}
%{if length(slack_notifications_channel) > 0 ~}
        notifications.argoproj.io/subscribe.on-created.slack: ${slack_notifications_channel}
        notifications.argoproj.io/subscribe.on-deleted.slack: ${slack_notifications_channel}
        notifications.argoproj.io/subscribe.on-success.slack: ${slack_notifications_channel}
        notifications.argoproj.io/subscribe.on-health-degraded.slack: ${slack_notifications_channel}
        notifications.argoproj.io/subscribe.on-failure.slack: ${slack_notifications_channel}
        notifications.argoproj.io/subscribe.on-started.slack: ${slack_notifications_channel}
%{ endif ~}
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
