enabled = false

name = "argocd-notifications"

chart            = "argocd-notifications"
chart_repository = "https://argoproj.github.io/argo-helm"
chart_version    = "1.8.0"

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