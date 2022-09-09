# This file has been programmatically generated and committed by the argocd-repo Terraform component in the infrastructure
# monorepo. It can be adjusted by modifying templates/applicationset.yaml.tpl in the aforementioned component.

apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  annotations:
    argocd-autopilot.argoproj-labs.io/default-dest-server: https://kubernetes.default.svc
    argocd.argoproj.io/sync-options: PruneLast=true
    argocd.argoproj.io/sync-wave: "-2"
    notifications.argoproj.io/subscribe.on-deployed.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-health-degraded.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-failed.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-running.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-status-unknown.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-sync-succeeded.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-deployed.datadog: ""
    notifications.argoproj.io/subscribe.on-health-degraded.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-failed.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-running.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-status-unknown.datadog: ""
    notifications.argoproj.io/subscribe.on-sync-succeeded.datadog: ""
    notifications.argoproj.io/subscribe.on-deleted.slack: ${slack_channel}
    notifications.argoproj.io/subscribe.on-deployed.github-deployment: ""
    notifications.argoproj.io/subscribe.on-deployed.github-commit-status: ""
    notifications.argoproj.io/subscribe.on-deleted.github-deployment: ""
  creationTimestamp: null
  name: cluster-config
  namespace: ${namespace}
spec:
  clusterResourceWhitelist:
    - group: '*'
      kind: '*'
  description: cluster-config project
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
  name: cluster-config
  namespace: ${namespace}
spec:
  generators:
    - git:
        repoURL: ${ssh_url}
        revision: HEAD
        directories:
          - path: ${environment}/config/*
  template:
    metadata:
      name: '${environment_normalized}-{{path.basename}}'
    spec:
      project: cluster-config
      source:
        repoURL: ${ssh_url}
        targetRevision: HEAD
        path: '{{path}}'
      destination:
        server: https://kubernetes.default.svc
%{if auto-sync || auto-sync-namespaces ~}
      syncPolicy:
%{ endif ~}
%{if auto-sync ~}
        automated:
          prune: true
          selfHeal: true
%{ endif ~}
%{if auto-sync-namespaces ~}
        syncOptions:
          - CreateNamespace=true
%{ endif ~}
