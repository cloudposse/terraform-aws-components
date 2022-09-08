enabled = false

name = "actions-runner" # avoids hitting name length limit on IAM role

chart            = "actions-runner-controller"
chart_repository = "https://actions-runner-controller.github.io/actions-runner-controller"
chart_version    = "0.18.0"

kubernetes_namespace = "actions-runner-system"
create_namespace     = true

# Purposely omit resource limits and requests
# https://github.com/actions-runner-controller/actions-runner-controller/blob/91102c8088b6c01645bbb218b3d4552e774672bf/charts/actions-runner-controller/values.yaml#L100-L111
# resources = {
#   limits = {
#     cpu    = "200m"
#     memory = "256Mi"
#   },
#   requests = {
#     cpu    = "100m"
#     memory = "128Mi"
#   }
# }
resources = null
