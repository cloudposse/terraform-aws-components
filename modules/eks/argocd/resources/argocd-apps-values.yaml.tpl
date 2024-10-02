applications:
%{ for name, url in application_repos ~}
- name: ${name}
  namespace: ${namespace}
  additionalLabels: {}
  additionalAnnotations: {}
  project: default
  source:
    repoURL: ${url}
    targetRevision: HEAD
    path: ./%{ if tenant != null }${tenant}/%{ endif }${environment}-${stage}%{ for attr in attributes }-${attr}%{ endfor }/${namespace}
    directory:
      recurse: false
  destination:
    server: https://kubernetes.default.svc
    namespace: ${namespace}
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=${create_namespaces}
%{ endfor ~}
