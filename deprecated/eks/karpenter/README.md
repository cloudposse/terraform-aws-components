# Component: `eks/karpenter`

This component provisions [Karpenter](https://karpenter.sh) on an EKS cluster. It requires at least version 0.19.0 of
Karpenter, though you are encouraged to use the latest version.

## Usage

**Stack Level**: Regional

These instructions assume you are provisioning 2 EKS clusters in the same account and region, named "blue" and "green",
and alternating between them. If you are only using a single cluster, you can ignore the "blue" and "green" references
and remove the `metadata` block from the `karpenter` module.

```yaml
components:
  terraform:
    # Base component of all `karpenter` components
    eks/karpenter:
      metadata:
        type: abstract
      vars:
        enabled: true
        eks_component_name: "eks/cluster"
        name: "karpenter"
        # https://github.com/aws/karpenter/tree/main/charts/karpenter
        chart_repository: "oci://public.ecr.aws/karpenter"
        chart: "karpenter"
        chart_version: "v0.31.0"
        create_namespace: true
        kubernetes_namespace: "karpenter"
        resources:
          limits:
            cpu: "300m"
            memory: "1Gi"
          requests:
            cpu: "100m"
            memory: "512Mi"
        cleanup_on_fail: true
        atomic: true
        wait: true
        rbac_enabled: true
        # "karpenter-crd" can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs
        crd_chart_enabled: true
        crd_chart: "karpenter-crd"
        # Set `legacy_create_karpenter_instance_profile` to `false` to allow the `eks/cluster` component
        # to manage the instance profile for the nodes launched by Karpenter (recommended for all new clusters).
        legacy_create_karpenter_instance_profile: false
        # Enable interruption handling to deploy a SQS queue and a set of Event Bridge rules to handle interruption with Karpenter.
        interruption_handler_enabled: true

    # Provision `karpenter` component on the blue EKS cluster
    eks/karpenter-blue:
      metadata:
        component: eks/karpenter
        inherits:
          - eks/karpenter
      vars:
        eks_component_name: eks/cluster-blue
```

## Provision Karpenter on EKS cluster

Here we describe how to provision Karpenter on an EKS cluster. We will be using the `plat-ue2-dev` stack as an example.

### Provision Service-Linked Roles for EC2 Spot and EC2 Spot Fleet

**Note:** If you want to use EC2 Spot for the instances launched by Karpenter, you may need to provision the following
Service-Linked Role for EC2 Spot:

- Service-Linked Role for EC2 Spot

This is only necessary if this is the first time you're using EC2 Spot in the account. Since this is a one-time
operation, we recommend you do this manually via the AWS CLI:

```bash
aws --profile <namespace>-<tenamt>-gbl-<stage>-admin iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

Note that if the Service-Linked Roles already exist in the AWS account (if you used EC2 Spot or Spot Fleet before), and
you try to provision them again, you will see the following errors:

```text
An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation:
Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix
```

For more details, see:

- https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html
- https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html

The process of provisioning Karpenter on an EKS cluster consists of 3 steps.

### 1. Provision EKS Fargate Profile for Karpenter and IAM Role for Nodes Launched by Karpenter

EKS Fargate Profile for Karpenter and IAM Role for Nodes launched by Karpenter are provisioned by the `eks/cluster`
component:

```yaml
components:
  terraform:
    eks/cluster-blue:
      metadata:
        component: eks/cluster
        inherits:
          - eks/cluster
      vars:
        attributes:
          - blue
        eks_component_name: eks/cluster-blue
        node_groups:
          main:
            instance_types:
              - t3.medium
            max_group_size: 3
            min_group_size: 1
        fargate_profiles:
          karpenter:
            kubernetes_namespace: karpenter
            kubernetes_labels: null
        karpenter_iam_role_enabled: true
```

**Notes**:

- Fargate Profile role ARNs need to be added to the `aws-auth` ConfigMap to allow the Fargate Profile nodes to join the
  EKS cluster (this is done by EKS)
- Karpenter IAM role ARN needs to be added to the `aws-auth` ConfigMap to allow the nodes launched by Karpenter to join
  the EKS cluster (this is done by the `eks/cluster` component)

We use EKS Fargate Profile for Karpenter because It is recommended to run Karpenter on an EKS Fargate Profile.

```text
Karpenter is installed using a Helm chart. The Helm chart installs the Karpenter controller and
a webhook pod as a Deployment that needs to run before the controller can be used for scaling your cluster.
We recommend a minimum of one small node group with at least one worker node.

As an alternative, you can run these pods on EKS Fargate by creating a Fargate profile for the
karpenter namespace. Doing so will cause all pods deployed into this namespace to run on EKS Fargate.
Do not run Karpenter on a node that is managed by Karpenter.
```

See
[Run Karpenter Controller on EKS Fargate](https://aws.github.io/aws-eks-best-practices/karpenter/#run-the-karpenter-controller-on-eks-fargate-or-on-a-worker-node-that-belongs-to-a-node-group)
for more details.

We provision IAM Role for Nodes launched by Karpenter because they must run with an Instance Profile that grants
permissions necessary to run containers and configure networking.

We define the IAM role for the Instance Profile in `components/terraform/eks/cluster/karpenter.tf`.

Note that we provision the EC2 Instance Profile for the Karpenter IAM role in the `components/terraform/eks/karpenter`
component (see the next step).

Run the following commands to provision the EKS Fargate Profile for Karpenter and the IAM role for instances launched by
Karpenter on the blue EKS cluster and add the role ARNs to the `aws-auth` ConfigMap:

```bash
atmos terraform plan eks/cluster-blue -s plat-ue2-dev
atmos terraform apply eks/cluster-blue -s plat-ue2-dev
```

For more details, refer to:

- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-terraform
- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-eksctl

### 2. Provision `karpenter` component

In this step, we provision the `components/terraform/eks/karpenter` component, which deploys the following resources:

- EC2 Instance Profile for the nodes launched by Karpenter (note that the IAM role for the Instance Profile is
  provisioned in the previous step in the `eks/cluster` component)
- Karpenter Kubernetes controller using the Karpenter Helm Chart and the `helm_release` Terraform resource
- EKS IAM role for Kubernetes Service Account for the Karpenter controller (with all the required permissions)

Run the following commands to provision the Karpenter component on the blue EKS cluster:

```bash
atmos terraform plan eks/karpenter-blue -s plat-ue2-dev
atmos terraform apply eks/karpenter-blue -s plat-ue2-dev
```

Note that the stack config for the blue Karpenter component is defined in `stacks/catalog/eks/clusters/blue.yaml`.

```yaml
eks/karpenter-blue:
  metadata:
    component: eks/karpenter
    inherits:
      - eks/karpenter
  vars:
    eks_component_name: eks/cluster-blue
```

### 3. Provision `karpenter-provisioner` component

In this step, we provision the `components/terraform/eks/karpenter-provisioner` component, which deploys Karpenter
[Provisioners](https://karpenter.sh/v0.18.0/aws/provisioning) using the `kubernetes_manifest` resource.

**NOTE:** We deploy the provisioners in a separate step as a separate component since it uses `kind: Provisioner` CRD
which itself is created by the `karpenter` component in the previous step.

Run the following commands to deploy the Karpenter provisioners on the blue EKS cluster:

```bash
atmos terraform plan eks/karpenter-provisioner-blue -s plat-ue2-dev
atmos terraform apply eks/karpenter-provisioner-blue -s plat-ue2-dev
```

Note that the stack config for the blue Karpenter provisioner component is defined in
`stacks/catalog/eks/clusters/blue.yaml`.

```yaml
eks/karpenter-provisioner-blue:
  metadata:
    component: eks/karpenter-provisioner
    inherits:
      - eks/karpenter-provisioner
  vars:
    attributes:
      - blue
    eks_component_name: eks/cluster-blue
```

You can override the default values from the `eks/karpenter-provisioner` base component.

For your cluster, you will need to review the following configurations for the Karpenter provisioners and update it
according to your requirements:

- [requirements](https://karpenter.sh/v0.18.0/provisioner/#specrequirements):

  ```yaml
  requirements:
    - key: "karpenter.sh/capacity-type"
      operator: "In"
      values:
        - "on-demand"
        - "spot"
    - key: "node.kubernetes.io/instance-type"
      operator: "In"
      values:
        - "m5.xlarge"
        - "m5.large"
        - "m5.medium"
        - "c5.xlarge"
        - "c5.large"
        - "c5.medium"
    - key: "kubernetes.io/arch"
      operator: "In"
      values:
        - "amd64"
  ```

- `taints`, `startup_taints`, `ami_family`

- Resource limits/requests for the Karpenter controller itself:

  ```yaml
  resources:
    limits:
      cpu: "300m"
      memory: "1Gi"
    requests:
      cpu: "100m"
      memory: "512Mi"
  ```

- Total CPU and memory limits for all pods running on the EC2 instances launched by Karpenter:

  ```yaml
  total_cpu_limit: "1k"
  total_memory_limit: "1000Gi"
  ```

- Config to terminate empty nodes after the specified number of seconds. This behavior can be disabled by setting the
  value to `null` (never scales down if not set):

  ```yaml
  ttl_seconds_after_empty: 30
  ```

- Config to terminate nodes when a maximum age is reached. This behavior can be disabled by setting the value to `null`
  (never expires if not set):

  ```yaml
  ttl_seconds_until_expired: 2592000
  ```

## Node Interruption

Karpenter also supports listening for and responding to Node Interruption events. If interruption handling is enabled,
Karpenter will watch for upcoming involuntary interruption events that would cause disruption to your workloads. These
interruption events include:

- Spot Interruption Warnings
- Scheduled Change Health Events (Maintenance Events)
- Instance Terminating Events
- Instance Stopping Events

:::info

The Node Interruption Handler is not the same as the Node Termination Handler. The latter is always enabled and cleanly
shuts down the node in 2 minutes in response to a Node Termination event. The former gets advance notice that a node
will soon be terminated, so it can have 5-10 minutes to shut down a node.

:::

For more details, see refer to the [Karpenter docs](https://karpenter.sh/v0.32/concepts/disruption/#interruption) and
[FAQ](https://karpenter.sh/v0.32/faq/#interruption-handling)

To enable Node Interruption handling, set `var.interruption_handler_enabled` to `true`. This will create an SQS queue
and a set of Event Bridge rules to deliver interruption events to Karpenter.

## Custom Resource Definition (CRD) Management

Karpenter ships with a few Custom Resource Definitions (CRDs). In earlier versions of this component, when installing a
new version of the `karpenter` helm chart, CRDs were not be upgraded at the same time, requiring manual steps to upgrade
CRDs after deploying the latest chart. However Karpenter now supports an additional, independent helm chart for CRD
management. This helm chart, `karpenter-crd`, can be installed alongside the `karpenter` helm chart to automatically
manage the lifecycle of these CRDs.

To deploy the `karpenter-crd` helm chart, set `var.crd_chart_enabled` to `true`. (Installing the `karpenter-crd` chart
is recommended. `var.crd_chart_enabled` defaults to `false` to preserve backward compatibility with older versions of
this component.)

## Troubleshooting

For Karpenter issues, checkout the [Karpenter Troubleshooting Guide](https://karpenter.sh/docs/troubleshooting/)

### References

For more details, refer to:

- https://karpenter.sh/v0.28.0/provisioner/#specrequirements
- https://karpenter.sh/v0.28.0/aws/provisioning
- https://aws.github.io/aws-eks-best-practices/karpenter/#creating-provisioners
- https://aws.github.io/aws-eks-best-practices/karpenter
- https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html

<!-- prettier-ignore-start -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Version Requirements

| Requirement | Version |
| --- | --- |
| `terraform` | >= 1.0.0 |
| `aws` | >= 4.9.0 |
| `helm` | >= 2.0 |
| `kubernetes` | >= 2.7.1, != 2.21.0 |


## Providers

| Provider | Version |
| --- | --- |
| `aws` | >= 4.9.0 |
| `kubernetes` | >= 2.7.1, != 2.21.0 |


## Modules

Name | Version | Source | Description
--- | --- | --- | ---
`eks` | 1.5.0 | [`cloudposse/stack-config/yaml//modules/remote-state`](https://registry.terraform.io/modules/cloudposse/stack-config/yaml/modules/remote-state/1.5.0) | n/a
`iam_roles` | latest | [`../../account-map/modules/iam-roles`](https://registry.terraform.io/modules/../../account-map/modules/iam-roles/) | n/a
`karpenter` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | Deploy Karpenter helm chart
`karpenter_crd` | 0.10.1 | [`cloudposse/helm-release/aws`](https://registry.terraform.io/modules/cloudposse/helm-release/aws/0.10.1) | Deploy karpenter-crd helm chart "karpenter-crd" can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs
`this` | 0.25.0 | [`cloudposse/label/null`](https://registry.terraform.io/modules/cloudposse/label/null/0.25.0) | n/a


## Resources

The following resources are used by this module:

  - [`aws_cloudwatch_event_rule.interruption_handler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) (resource)(interruption_handler.tf#83)
  - [`aws_cloudwatch_event_target.interruption_handler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) (resource)(interruption_handler.tf#93)
  - [`aws_iam_instance_profile.default`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)(main.tf#20)
  - [`aws_sqs_queue.interruption_handler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) (resource)(interruption_handler.tf#47)
  - [`aws_sqs_queue_policy.interruption_handler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) (resource)(interruption_handler.tf#76)
  - [`kubernetes_namespace.default`](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) (resource)(main.tf#38)

## Data Sources

The following data sources are used by this module:

  - [`aws_eks_cluster_auth.eks`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) (data source)
  - [`aws_iam_policy_document.interruption_handler`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) (data source)
  - [`aws_partition.current`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) (data source)

## Outputs

<dl>
  <dt><code>instance_profile</code></dt>
  <dd>

  
  Provisioned EC2 Instance Profile for nodes launched by Karpenter<br/>

  </dd>
  <dt><code>metadata</code></dt>
  <dd>

  
  Block status of the deployed release<br/>

  </dd>
</dl>

## Required Variables

Required variables are the minimum set of variables that must be set to use this module.

> [!IMPORTANT]
>
> To customize the names and tags of the resources created by this module, see the [context variables](#context-variables).
>
### `chart` (`string`) <i>required</i>


Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `chart_repository` (`string`) <i>required</i>


Repository URL where to locate the requested chart<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `kubernetes_namespace` (`string`) <i>required</i>


The namespace to install the release into<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `region` (`string`) <i>required</i>


AWS Region<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>


### `resources` <i>required</i>


The CPU and memory of the deployment's limits and requests<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>Yes</dd>
>   <dt>Type</dt>
>   <dd>
>   
>
>   ```hcl
>   object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
>   ```
>
>   
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>unset</code>
>   </dd>
> </dl>
>



## Optional Variables
### `atomic` (`bool`) <i>optional</i>


If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `chart_description` (`string`) <i>optional</i>


Set release description attribute (visible in the history)<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `chart_values` (`any`) <i>optional</i>


Additional values to yamlencode as `helm_release` values<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `chart_version` (`string`) <i>optional</i>


Specify the exact chart version to install. If this is not specified, the latest version is installed<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `cleanup_on_fail` (`bool`) <i>optional</i>


Allow deletion of new resources created in this upgrade when upgrade fails<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `crd_chart` (`string`) <i>optional</i>


The name of the Karpenter CRD chart to be installed, if `var.crd_chart_enabled` is set to `true`.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"karpenter-crd"</code>
>   </dd>
> </dl>
>


### `crd_chart_enabled` (`bool`) <i>optional</i>


`karpenter-crd` can be installed as an independent helm chart to manage the lifecycle of Karpenter CRDs. Set to `true` to install this CRD helm chart before the primary karpenter chart.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `create_namespace` (`bool`) <i>optional</i>


Create the namespace if it does not yet exist. Defaults to `false`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `eks_component_name` (`string`) <i>optional</i>


The name of the eks component<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"eks/cluster"</code>
>   </dd>
> </dl>
>


### `helm_manifest_experiment_enabled` (`bool`) <i>optional</i>


Enable storing of the rendered manifest for helm_release so the full diff of what is changing can been seen in the plan<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `interruption_handler_enabled` (`bool`) <i>optional</i>


  If `true`, deploy a SQS queue and Event Bridge rules to enable interruption handling by Karpenter.<br/>
<br/>
  https://karpenter.sh/v0.27.5/concepts/deprovisioning/#interruption<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `interruption_queue_message_retention` (`number`) <i>optional</i>


The message retention in seconds for the interruption handler SQS queue.<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>300</code>
>   </dd>
> </dl>
>


### `kube_data_auth_enabled` (`bool`) <i>optional</i>


If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile` (`string`) <i>optional</i>


The AWS config profile for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_aws_profile_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_enabled` (`bool`) <i>optional</i>


If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br/>
Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn` (`string`) <i>optional</i>


The role ARN for `aws eks get-token` to use<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kube_exec_auth_role_arn_enabled` (`bool`) <i>optional</i>


If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `kubeconfig_context` (`string`) <i>optional</i>


Context to choose from the Kubernetes config file.<br/>
If supplied, `kubeconfig_context_format` will be ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_context_format` (`string`) <i>optional</i>


A format string to use for creating the `kubectl` context name when<br/>
`kubeconfig_file_enabled` is `true` and `kubeconfig_context` is not supplied.<br/>
Must include a single `%s` which will be replaced with the cluster name.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_exec_auth_api_version` (`string`) <i>optional</i>


The Kubernetes API version of the credentials returned by the `exec` auth plugin<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>"client.authentication.k8s.io/v1beta1"</code>
>   </dd>
> </dl>
>


### `kubeconfig_file` (`string`) <i>optional</i>


The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>""</code>
>   </dd>
> </dl>
>


### `kubeconfig_file_enabled` (`bool`) <i>optional</i>


If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>false</code>
>   </dd>
> </dl>
>


### `legacy_create_karpenter_instance_profile` (`bool`) <i>optional</i>


When `true` (the default), this component creates an IAM Instance Profile<br/>
for nodes launched by Karpenter, to preserve the legacy behavior.<br/>
Set to `false` to disable creation of the IAM Instance Profile, which<br/>
avoids conflict with having `eks/cluster` create it.<br/>
Use in conjunction with `eks/cluster` component `legacy_do_not_create_karpenter_instance_profile`,<br/>
which see for further details.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `rbac_enabled` (`bool`) <i>optional</i>


Enable/disable RBAC<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>true</code>
>   </dd>
> </dl>
>


### `timeout` (`number`) <i>optional</i>


Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `wait` (`bool`) <i>optional</i>


Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true`<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



## Context Variables

The following variables are defined in the `context.tf` file of this module and part of the [terraform-null-label](https://registry.terraform.io/modules/cloudposse/label/null) pattern. These are identical in all Cloud Posse modules.

<details>
<summary>Click to expand</summary>


### `additional_tag_map` (`map(string)`) <i>optional</i>


Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>
This is for some rare cases where resources want additional configuration of tags<br/>
and therefore take a list of maps with tag key, value, and additional configuration.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `attributes` (`list(string)`) <i>optional</i>


ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>
in the order they appear in the list. New attributes are appended to the<br/>
end of the list. The elements of the list are joined by the `delimiter`<br/>
and treated as a single ID element.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>[]</code>
>   </dd>
> </dl>
>


### `context` (`any`) <i>optional</i>


Single object for setting entire context at once.<br/>
See description of individual variables for details.<br/>
Leave string and numeric variables as `null` to use default value.<br/>
Individual variable settings (non-null) override settings in context object,<br/>
except for attributes, tags, and additional_tag_map, which are merged.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   {
>     "additional_tag_map": {},
>     "attributes": [],
>     "delimiter": null,
>     "descriptor_formats": {},
>     "enabled": true,
>     "environment": null,
>     "id_length_limit": null,
>     "label_key_case": null,
>     "label_order": [],
>     "label_value_case": null,
>     "labels_as_tags": [
>       "unset"
>     ],
>     "name": null,
>     "namespace": null,
>     "regex_replace_chars": null,
>     "stage": null,
>     "tags": {},
>     "tenant": null
>   }
>   ```
>
>   </dd>
> </dl>
>


### `delimiter` (`string`) <i>optional</i>


Delimiter to be used between ID elements.<br/>
Defaults to `-` (hyphen). Set to `""` to use no delimiter at all.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `descriptor_formats` (`any`) <i>optional</i>


Describe additional descriptors to be output in the `descriptors` output map.<br/>
Map of maps. Keys are names of descriptors. Values are maps of the form<br/>
`{<br/>
   format = string<br/>
   labels = list(string)<br/>
}`<br/>
(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>
`format` is a Terraform format string to be passed to the `format()` function.<br/>
`labels` is a list of labels, in order, to pass to `format()` function.<br/>
Label values will be normalized before being passed to `format()` so they will be<br/>
identical to how they appear in `id`.<br/>
Default is `{}` (`descriptors` output will be empty).<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>any</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `enabled` (`bool`) <i>optional</i>


Set to false to prevent the module from creating any resources<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>bool</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `environment` (`string`) <i>optional</i>


ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `id_length_limit` (`number`) <i>optional</i>


Limit `id` to this many characters (minimum 6).<br/>
Set to `0` for unlimited length.<br/>
Set to `null` for keep the existing setting, which defaults to `0`.<br/>
Does not affect `id_full`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>number</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_key_case` (`string`) <i>optional</i>


Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>
Does not affect keys of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper`.<br/>
Default value: `title`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_order` (`list(string)`) <i>optional</i>


The order in which the labels (ID elements) appear in the `id`.<br/>
Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>
You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>list(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `label_value_case` (`string`) <i>optional</i>


Controls the letter case of ID elements (labels) as included in `id`,<br/>
set as tag values, and output by this module individually.<br/>
Does not affect values of tags passed in via the `tags` input.<br/>
Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>
Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>
Default value: `lower`.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `labels_as_tags` (`set(string)`) <i>optional</i>


Set of labels (ID elements) to include as tags in the `tags` output.<br/>
Default is to include all labels.<br/>
Tags with empty values will not be included in the `tags` output.<br/>
Set to `[]` to suppress all generated tags.<br/>
**Notes:**<br/>
  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>
  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>
  changed in later chained modules. Attempts to change it will be silently ignored.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>set(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   
>
>   ```hcl
>   [
>     "default"
>   ]
>   ```
>
>   </dd>
> </dl>
>


### `name` (`string`) <i>optional</i>


ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>
This is the only ID element not also included as a `tag`.<br/>
The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `namespace` (`string`) <i>optional</i>


ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `regex_replace_chars` (`string`) <i>optional</i>


Terraform regular expression (regex) string.<br/>
Characters matching the regex will be removed from the ID elements.<br/>
If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `stage` (`string`) <i>optional</i>


ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>


### `tags` (`map(string)`) <i>optional</i>


Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>
Neither the tag keys nor the tag values will be modified by this module.<br/>
<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>map(string)</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>{}</code>
>   </dd>
> </dl>
>


### `tenant` (`string`) <i>optional</i>


ID element _(Rarely used, not included by default)_. A customer identifier, indicating who this instance of a resource is for<br/>

>
> <dl>
>   <dt>Required</dt>
>   <dd>No</dd>
>   <dt>Type</dt>
>   <dd>
>   <code>string</code>
>   </dd>
>
>   <dt>Default value</dt>
>   <dd>
>   <code>null</code>
>   </dd>
> </dl>
>



</details>
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- prettier-ignore-end -->

## References

- https://karpenter.sh
- https://aws.github.io/aws-eks-best-practices/karpenter
- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-terraform
- https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler
- https://github.com/aws/karpenter
- https://www.eksworkshop.com/beginner/085_scaling_karpenter
- https://ec2spotworkshops.com/karpenter.html
- https://www.eksworkshop.com/beginner/085_scaling_karpenter/install_karpenter
- https://karpenter.sh/v0.18.0/development-guide
- https://karpenter.sh/v0.18.0/aws/provisioning
- https://docs.aws.amazon.com/eks/latest/userguide/pod-execution-role.html
- https://aws.amazon.com/premiumsupport/knowledge-center/fargate-troubleshoot-profile-creation
- https://learn.hashicorp.com/tutorials/terraform/kubernetes-crd-faas
- https://github.com/hashicorp/terraform-provider-kubernetes/issues/1545
- https://issuemode.com/issues/hashicorp/terraform-provider-kubernetes-alpha/4840198
- https://bytemeta.vip/repo/hashicorp/terraform-provider-kubernetes/issues/1442
- https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
