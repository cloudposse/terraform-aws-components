global:
  image:
    imagePullPolicy: IfNotPresent

crds:
  install: true

dex:
  image:
    imagePullPolicy: IfNotPresent
    tag: v2.30.2

controller:
  replicas: 1

server:
  replicas: 2

  ingress:
    enabled: true
    annotations:
      cert-manager.io/cluster-issuer: ${cert_issuer}
      external-dns.alpha.kubernetes.io/hostname: ${ingress_host}
      external-dns.alpha.kubernetes.io/ttl: "60"
      kubernetes.io/ingress.class: alb
%{ if alb_group_name != "" ~}
      alb.ingress.kubernetes.io/group.name: ${alb_group_name}
%{ endif ~}
%{ if alb_name != "" ~}
      alb.ingress.kubernetes.io/load-balancer-name: ${alb_name}
%{ endif ~}
      alb.ingress.kubernetes.io/scheme: internet-facing
      alb.ingress.kubernetes.io/backend-protocol: HTTPS
      alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80},{"HTTPS":443}]'
      alb.ingress.kubernetes.io/ssl-redirect: '443'
      alb.ingress.kubernetes.io/load-balancer-attributes:
            routing.http.drop_invalid_header_fields.enabled=true,
%{ if alb_logs_bucket != "" ~}
            access_logs.s3.enabled=true,
            access_logs.s3.bucket=${alb_logs_bucket},
            access_logs.s3.prefix=${alb_logs_prefix}
%{ endif ~}
%{ if forecastle_enabled == true ~}
      forecastle.stakater.com/appName: "ArgoCD"
      forecastle.stakater.com/expose: "true"
      forecastle.stakater.com/group: "portal"
      forecastle.stakater.com/icon: https://argoproj.github.io/argo-cd/assets/logo.png
      forecastle.stakater.com/instance: default
%{ endif ~}
    hosts:
      - ${argocd_host}
    extraPaths:
      # Must use implementation specific wildcard paths
      # https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/1702#issuecomment-736890777
      - path: /*
        pathType: ImplementationSpecific
        backend:
          service:
            name: ${name}-server
            port:
              name: https
    tls:
      - hosts:
        - ${argocd_host}
        secretName: argocd-tls
    https: false

  service:
    type: ${service_type}

  secret:
    create: true

  config:
    url: https://${argocd_host}
    admin.enabled: "${admin_enabled}"
    users.anonymous_enabled: "${anonymous_enabled}"

    # https://github.com/argoproj/argo-cd/issues/7835
    kustomize.buildOptions: --enable-helm

#    overridden in main.tf
#    oidc.conf : ~
#    dex.config: ~

    repositories: |
%{ for name, url in application_repos ~}
      - url: ${url}
        sshPrivateKeySecret:
          name: argocd-repo-creds-${name}
          key: sshPrivateKey
%{ endfor ~}
    resource.customizations: |
        admissionregistration.k8s.io/MutatingWebhookConfiguration:
          ignoreDifferences: |
            jsonPointers:
            - /webhooks/0/clientConfig/caBundle
        argoproj.io/Application:
          health.lua: |
            hs = {}
            hs.status = "Progressing"
            hs.message = ""
            if obj.status ~= nil then
              if obj.status.health ~= nil then
                hs.status = obj.status.health.status
                if obj.status.health.message ~= nil then
                  hs.message = obj.status.health.message
                end
              end
            end
            return hs

  rbacConfig:
    policy.default: ${rbac_default_policy}
    policy.csv: |
%{ for policy in rbac_policies ~}
      ${policy}
%{ endfor ~}
%{for item in rbac_groups ~}
      g, ${item.group}, role:${item.role}
%{ endfor ~}

%{ if oidc_enabled == true ~}
    scopes: '${oidc_rbac_scopes}'
%{ endif ~}
%{ if saml_enabled == true ~}
    scopes: '${saml_rbac_scopes}'
%{ endif ~}

    policy.default: role:readonly

repoServer:
  replicas: 2

applicationSet:
  replicas: 2
