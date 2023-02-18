enabled = false

name = "metrics-server"

chart            = "metrics-server"
chart_repository = "https://charts.bitnami.com/bitnami"
chart_version    = "6.2.6"

create_namespace     = true
kubernetes_namespace = "metrics-server"

resources = {
  limits = {
    cpu    = "100m"
    memory = "300Mi"
  },
  requests = {
    cpu    = "20m"
    memory = "60Mi"
  }
}
