# This file is included by default in terraform plans

enabled = false

name = "aws-node-termination-handler"

chart            = "aws-node-termination-handler"
chart_repository = "https://aws.github.io/eks-charts"
chart_version    = "0.15.3"

create_namespace     = true
kubernetes_namespace = "aws-node-termination-handler"

resources = {
  limits = {
    cpu    = "100m"
    memory = "128Mi"
  },
  requests = {
    cpu    = "50m"
    memory = "64Mi"
  }
}
