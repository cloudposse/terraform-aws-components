enabled = false

name = "alb-controller"

chart            = "aws-load-balancer-controller"
chart_repository = "https://aws.github.io/eks-charts"
chart_version    = "1.2.7"

kubernetes_namespace = "kube-system"
