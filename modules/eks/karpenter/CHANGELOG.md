## Components PR [#868](https://github.com/cloudposse/terraform-aws-components/pull/868)

This is a feature enhancement update. Actions are required to avoid destroying and recreating the `karpenter` Kubernetes namespace and everything in it as well as to prepare Karpenter CRDs for helm.

### Upgrading to `karpenter-crd` Helm Chart Support

The `karpenter-crd` helm chart can now be installed alongside the `karpenter` helm chart to automatically manage the lifecycle of Karpenter CRDs. However since this chart must be installed before the `karpenter` helm chart, the Kubernetes namespace must be available before either chart is deployed. Furthermore, this namespace should persist whether or not the `karpenter-crd` chart is deployed, so it should not be installed with that given `helm-release` resource. Therefore, we've moved namespace creation to a separate resource that runs before both charts.

With previous versions of the `eks/karpenter` component, the namespace was created with the `karpenter` module. In order to avoid destroying and recreating the old namespace and everything in it, move that resource to the new resource in Terraform state. Terraform will handle this migration for us with the `moved` block.

Next, update the installed Karpenter CRDs in order for Helm to automatically take over their management when the `karpenter-crd` chart is deployed. We have included a script to run that upgrade. Run the `./karpenter-crd-upgrade` script or run the following commands on the given cluster before deploying the chart.

```bash
kubectl label crd awsnodetemplates.karpenter.k8s.aws provisioners.karpenter.sh app.kubernetes.io/managed-by=Helm --overwrite
kubectl annotate crd awsnodetemplates.karpenter.k8s.aws provisioners.karpenter.sh meta.helm.sh/release-name=karpenter-crd --overwrite
kubectl annotate crd awsnodetemplates.karpenter.k8s.aws provisioners.karpenter.sh meta.helm.sh/release-namespace=karpenter --overwrite
```

:::info

Previously the `karpenter-crd-upgrade` script included deploying the `karpenter-crd` chart. Now that this chart is moved to Terraform, that helm deployment is no longer necessary.

For reference, the `karpenter-crd` chart can be installed with helm with the following:
```bash
helm upgrade --install karpenter-crd oci://public.ecr.aws/karpenter/karpenter-crd --version "$VERSION" --namespace karpenter
```

:::

Now that the namespace has been move in Terraform state and the CRDs are upgraded, the component is ready to be applied. Apply the `eks/karpenter` component and then apply `eks/karpenter-provisioner`.
