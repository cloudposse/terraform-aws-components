# This file is included by default in terraform plans

enabled = false

name = "cluster-autoscaler"

create_namespace          = true
kubernetes_namespace      = "cluster-autoscaler"
service_account_namespace = "cluster-autoscaler"
service_account_name      = "cluster-autoscaler"

repository = "https://kubernetes.github.io/autoscaler"

chart = "cluster-autoscaler"

chart_version = "9.16.2"

timeout = 180

wait = true

atomic = true

cleanup_on_fail = true
