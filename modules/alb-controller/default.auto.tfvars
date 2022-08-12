# This file is included by default in terraform plans

enabled = false

name = "alb-controller"

chart            = "aws-load-balancer-controller"
chart_repository = "https://aws.github.io/eks-charts"
chart_version    = "1.3.3"

create_namespace     = true
kubernetes_namespace = "alb-controller"

resources = {
  limits = {
    cpu    = "200m"
    memory = "256Mi"
  },
  requests = {
    cpu    = "100m"
    memory = "128Mi"
  }
}
