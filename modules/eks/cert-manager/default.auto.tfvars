# This file is included by default in terraform plans

enabled = false

name = "cert-manager"

create_namespace     = true
kubernetes_namespace = "cert-manager"

cert_manager_repository    = "https://charts.jetstack.io"
cert_manager_chart         = "cert-manager"
cert_manager_chart_version = "v1.5.4"

cert_manager_resources = {
  limits = {
    cpu    = "200m"
    memory = "256Mi"
  },
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
}

# use a local chart
cert_manager_issuer_chart = "./cert-manager-issuer/"
