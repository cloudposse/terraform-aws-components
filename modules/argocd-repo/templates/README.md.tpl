# `${repository_name}`

${repository_description}.

## What This Repository Does

This repository accepts inbound commits from CD workflows using the `cd/argocd` composite action in `${github_organization}/github_actions`.

In particular, these CD workflows render application Kubernetes manifests using their respective Helm charts and commits
them to an `apps/[app name]/` subdirectory in each environment's directory.

The `applicationset.yaml` file in each environment directory's `argocd/` subdirectory is referenced by ArgoCD deployment
in each environment's dedicated EKS cluster. This ApplicationSet manifest makes use of [Git Generators](https://argocd-applicationset.readthedocs.io/en/stable/Generators-Git/)
in order to dynamically create ArgoCD Application objects based on the manifests in the `apps/[app name]/` directory.