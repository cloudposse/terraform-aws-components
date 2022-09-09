# `${repository_name}`

${repository_description}.

## What This Repository Does
%{ if applicationset_template == "apps.applicationset.yaml.tpl" ~}

This repository accepts inbound commits from CD workflows using the `cd/argocd` composite action in `${github_organization}/github_actions`.

In particular, these CD workflows render application Kubernetes manifests using their respective Helm charts and commits
them to an `apps/[app name]/` subdirectory in each environment's directory.

The `applicationset.yaml` file in each environment directory's `argocd/` subdirectory is referenced by ArgoCD deployment
in each environment's dedicated EKS cluster. This ApplicationSet manifest makes use of [Git Generators](https://argocd-applicationset.readthedocs.io/en/stable/Generators-Git/)
in order to dynamically create ArgoCD Application objects based on the manifests in the `apps/[app name]/` directory.
%{ endif ~}
%{ if applicationset_template == "config.applicationset.yaml.tpl" ~}

This repository define [kustomizeable](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/) Kubernetes manifests meant for cluster configurations.

The `applicationset.yaml` file in each environment directory's `argocd/` subdirectory is referenced by ArgoCD deployment
in each environment's dedicated EKS cluster. This ApplicationSet manifest makes use of [Git Generators](https://argocd-applicationset.readthedocs.io/en/stable/Generators-Git/)
in order to dynamically create ArgoCD Application objects based on the manifests in the `config/<config_type>/` directory.

The `<tenant>/<region>-<stage>/config/<config_type>/kustomization.yaml` files will include all resources defined in the corresponding `<tenant>/<config_type>/` at render time.

The `<tenant>/<config_type>/kustomization.yaml` files will include all resources defined in the corresponding `global/<config_type>/` at render time.

```shell
.
├── global
│   ├── namespaces
│   ├── policies
│   ├── rbac
│   └── resourcequotas
└── <tenant>
    ├── namespaces
    ├── policies
    ├── rbac
    ├── resourcequotas
    ├── <region>-<stage>
    │   ├── argocd
    │   │   └── applicationset.yaml
    │   └── config
    │       ├── namespaces
    │       ├── policies
    │       ├── rbac
    │       └── resourcequotas
    └── <region>-<stage>
    │   ├── argocd
    │   │   └── applicationset.yaml
    │   └── config
    │       ├── namespaces
    │       ├── policies
    │       ├── rbac
    │       └── resourcequotas
```
%{ endif ~}