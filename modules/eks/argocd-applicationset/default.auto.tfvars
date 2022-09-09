enabled = false

name = "argocd-applicationset"

chart            = "argocd-applicationset"
chart_repository = "https://argoproj.github.io/argo-helm"
chart_version    = "1.9.1"

kubernetes_namespace = "argocd"

resources = {
  limits = {
    cpu    = "100m"
    memory = "128Mi"
  },
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
}