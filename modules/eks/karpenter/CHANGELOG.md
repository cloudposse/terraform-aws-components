## Components PR [#868](https://github.com/cloudposse/terraform-aws-components/pull/868)

The `karpenter-crd` helm chart can now be installed alongside the `karpenter` helm chart to automatically manage the lifecycle of Karpenter CRDs. However since this chart must be installed before the `karpenter` helm chart, the Kubernetes namespace must be available before either chart is deployed. Furthermore, this namespace should persist whether or not the `karpenter-crd` chart is deployed, so it should not be installed with that given `helm-release` resource. Therefore, we've moved namespace creation to a separate resource that runs before both charts. Terraform will handle that namespace state migration with the `moved` block.

There are several scenarios that may or may not require additional steps. Please review the following scenarios and follow the steps for your given requirements.

### Upgrading an existing `eks/karpenter` deployment without changes

If you currently have `eks/karpenter` deployed to an EKS cluster and have upgraded to this version of the component, no changes are required. `var.crd_chart_enabled` will default to `false`.

### Upgrading an existing `eks/karpenter` deployment and deploying the `karpenter-crd` chart

If you currently have `eks/karpenter` deployed to an EKS cluster, have upgraded to this version of the component, do not currently have the `karpenter-crd` chart installed, and want to now deploy the `karpenter-crd` helm chart, a few addtional steps are required!

First, set `var.crd_chart_enabled` to `true`.

Next, update the installed Karpenter CRDs in order for Helm to automatically take over their management when the `karpenter-crd` chart is deployed. We have included a script to run that upgrade. Run the `./karpenter-crd-upgrade` script or run the following commands on the given cluster before deploying the chart. Please note that this script or commands will only need to be run on first use of the CRD chart.

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

Now that the CRDs are upgraded, the component is ready to be applied. Apply the `eks/karpenter` component and then apply `eks/karpenter-provisioner`.

### Upgrading an existing `eks/karpenter` deployment where the `karpenter-crd` chart is already deployed

If you currently have `eks/karpenter` deployed to an EKS cluster, have upgraded to this version of the component, and already have the `karpenter-crd` chart installed, simply set `var.crd_chart_enabled` to `true` and redeploy Terraform to have Terraform manage the helm release for `karpenter-crd`.

### Net new deployments

If you are initially deploying `eks/karpenter`, no changes are required, but we recommend installing the CRD chart. Set `var.crd_chart_enabled` to `true` and continue with deployment.
