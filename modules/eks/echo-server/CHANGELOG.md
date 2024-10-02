## Changes in PR #893, components version ~v1.337.0

- Moved `eks/echo-server` v1.147.0 to `/deprecated/eks/echo-server` for those who still need it and do not want to
  switch. It may later become the basis for an example app or something similar.
- Removed dependency on and connection to the `eks/alb-controller-ingress-group` component
- Added liveness probe, and disabled logging of probe requests. Probe request logging can be restored by setting
  `livenessProbeLogging: true` in `chart_values`
- This component no longer configures automatic redirects from HTTP to HTTPS. This is because for ALB controller,
  setting that on one ingress sets it for all ingresses in the same IngressGroup, and it is a design goal that deploying
  this component does not affect other Ingresses (with the obvious exception of possibly being the first to create the
  Application Load Balancer).
- Removed from `chart_values`:`ingress.nginx.class` (was set to "nginx") and `ingress.alb.class` (was set to "alb").
  IngressClass should usually not be set, as this component is intended to be used to test the defaults, including the
  default IngressClass. However, if you do want to set it, you can do so by setting `ingress.class` in `chart_values`.
- Removed the deprecated `kubernetes.io/ingress.class` annotation by default. It can be restored by setting
  `ingress.use_ingress_class_annotation: true` in `chart_values`. IngressClass is now set using the preferred
  `ingressClassName` field of the Ingress resource.
