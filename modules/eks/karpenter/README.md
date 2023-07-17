# Component: `eks/karpenter`

This component provisions [Karpenter](https://karpenter.sh) on an EKS cluster.
It requires at least version 0.19.0 of Karpenter, though you are encouraged to
use the latest version.

## Usage

**Stack Level**: Regional

These instructions assume you are provisioning 2 EKS clusters in the same account
and region, named "blue" and "green", and alternating between them.
If you are only using a single cluster, you can ignore the "blue" and "green"
references and remove the `metadata` block from the `karpenter` module.

```yaml
components:
  terraform:

    # Base component of all `karpenter` components
    eks/karpenter:
      metadata:
        type: abstract
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        tags:
          Team: sre
          Service: karpenter
        eks_component_name: eks/cluster
        name: "karpenter"
        chart: "karpenter"
        chart_repository: "https://charts.karpenter.sh"
        chart_version: "v0.16.3"
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

Here we describe how to provision Karpenter on an EKS cluster.
We will be using the `plat-ue2-dev` stack as an example.

### Provision Service-Linked Roles for EC2 Spot and EC2 Spot Fleet

__Note:__ If you want to use EC2 Spot for the instances launched by Karpenter,
you may need to provision the following Service-Linked Role for EC2 Spot:

- Service-Linked Role for EC2 Spot

This is only necessary if this is the first time you're using EC2 Spot in the account.
Since this is a one-time operation, we recommend you do this manually via
the AWS CLI:

```bash
aws --profile <namespace>-<tenamt>-gbl-<stage>-admin iam create-service-linked-role --aws-service-name spot.amazonaws.com
```

Note that if the Service-Linked Roles already exist in the AWS account (if you used EC2 Spot or Spot Fleet before),
and you try to provision them again, you will see the following errors:

```text
An error occurred (InvalidInput) when calling the CreateServiceLinkedRole operation:
Service role name AWSServiceRoleForEC2Spot has been taken in this account, please try a different suffix
```

For more details, see:
 - https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html
 - https://docs.aws.amazon.com/IAM/latest/UserGuide/using-service-linked-roles.html

The process of provisioning Karpenter on an EKS cluster consists of 3 steps.

### 1. Provision EKS Fargate Profile for Karpenter and IAM Role for Nodes Launched by Karpenter

EKS Fargate Profile for Karpenter and IAM Role for Nodes launched by Karpenter are provisioned by the `eks/cluster` component:

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

__Notes__:
  - Fargate Profile role ARNs need to be added to the `aws-auth` ConfigMap to allow the Fargate Profile nodes to join the EKS cluster (this is done by EKS)
  - Karpenter IAM role ARN needs to be added to the `aws-auth` ConfigMap to allow the nodes launched by Karpenter to join the EKS cluster (this is done by the `eks/cluster` component)

We use EKS Fargate Profile for Karpenter because It is recommended to run Karpenter on an EKS Fargate Profile.

```text
Karpenter is installed using a Helm chart. The Helm chart installs the Karpenter controller and
a webhook pod as a Deployment that needs to run before the controller can be used for scaling your cluster.
We recommend a minimum of one small node group with at least one worker node.

As an alternative, you can run these pods on EKS Fargate by creating a Fargate profile for the
karpenter namespace. Doing so will cause all pods deployed into this namespace to run on EKS Fargate.
Do not run Karpenter on a node that is managed by Karpenter.
```

See [Run Karpenter Controller on EKS Fargate](https://aws.github.io/aws-eks-best-practices/karpenter/#run-the-karpenter-controller-on-eks-fargate-or-on-a-worker-node-that-belongs-to-a-node-group)
for more details.

We provision IAM Role for Nodes launched by Karpenter because they must run with an Instance Profile that grants
permissions necessary to run containers and configure networking.

We define the IAM role for the Instance Profile in `components/terraform/eks/cluster/karpenter.tf`.

Note that we provision the EC2 Instance Profile for the Karpenter IAM role in the `components/terraform/eks/karpenter` component (see the next step).

Run the following commands to provision the EKS Fargate Profile for Karpenter and the IAM role for instances launched by Karpenter
on the blue EKS cluster and add the role ARNs to the `aws-auth` ConfigMap:

```bash
atmos terraform plan eks/cluster-blue -s plat-ue2-dev
atmos terraform apply eks/cluster-blue -s plat-ue2-dev
```

For more details, refer to:

- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-terraform
- https://karpenter.sh/v0.18.0/getting-started/getting-started-with-eksctl


### 2. Provision `karpenter` component

In this step, we provision the `components/terraform/eks/karpenter` component, which deploys the following resources:

 - EC2 Instance Profile for the nodes launched by Karpenter (note that the IAM role for the Instance Profile is provisioned in the previous step in the `eks/cluster` component)
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

In this step, we provision the `components/terraform/eks/karpenter-provisioner` component, which deploys Karpenter [Provisioners](https://karpenter.sh/v0.18.0/aws/provisioning)
using the `kubernetes_manifest` resource.

__NOTE:__ We deploy the provisioners in a separate step as a separate component since it uses `kind: Provisioner` CRD which itself is created by
the `karpenter` component in the previous step.

Run the following commands to deploy the Karpenter provisioners on the blue EKS cluster:

```bash
atmos terraform plan eks/karpenter-provisioner-blue -s plat-ue2-dev
atmos terraform apply eks/karpenter-provisioner-blue -s plat-ue2-dev
```

Note that the stack config for the blue Karpenter provisioner component is defined in `stacks/catalog/eks/clusters/blue.yaml`.

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

For your cluster, you will need to review the following configurations for the Karpenter provisioners and update it according to your requirements:

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

  - Config to terminate empty nodes after the specified number of seconds. This behavior can be disabled by setting the value to `null` (never scales down if not set):

    ```yaml
      ttl_seconds_after_empty: 30
    ```

  - Config to terminate nodes when a maximum age is reached. This behavior can be disabled by setting the value to `null` (never expires if not set):

    ```yaml
      ttl_seconds_until_expired: 2592000
    ```

For more details, refer to:

 - https://karpenter.sh/v0.28.0/provisioner/#specrequirements
 - https://karpenter.sh/v0.28.0/aws/provisioning
 - https://aws.github.io/aws-eks-best-practices/karpenter/#creating-provisioners
 - https://aws.github.io/aws-eks-best-practices/karpenter
 - https://docs.aws.amazon.com/batch/latest/userguide/spot_fleet_IAM_role.html


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.7.1, != 2.21.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | cloudposse/stack-config/yaml//modules/remote-state | 1.4.1 |
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../../account-map/modules/iam-roles | n/a |
| <a name="module_karpenter"></a> [karpenter](#module\_karpenter) | cloudposse/helm-release/aws | 0.7.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.interruption_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.interruption_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_instance_profile.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_sqs_queue.interruption_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.interruption_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [aws_eks_cluster_auth.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy_document.interruption_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br>This is for some rare cases where resources want additional configuration of tags<br>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_atomic"></a> [atomic](#input\_atomic) | If set, installation process purges chart on fail. The wait flag will be set automatically if atomic is used | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br>in the order they appear in the list. New attributes are appended to the<br>end of the list. The elements of the list are joined by the `delimiter`<br>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_chart"></a> [chart](#input\_chart) | Chart name to be installed. The chart name can be local path, a URL to a chart, or the name of the chart if `repository` is specified. It is also possible to use the `<repository>/<chart>` format here if you are running Terraform on a system that the repository has been added to with `helm repo add` but this is not recommended | `string` | n/a | yes |
| <a name="input_chart_description"></a> [chart\_description](#input\_chart\_description) | Set release description attribute (visible in the history) | `string` | `null` | no |
| <a name="input_chart_repository"></a> [chart\_repository](#input\_chart\_repository) | Repository URL where to locate the requested chart | `string` | n/a | yes |
| <a name="input_chart_values"></a> [chart\_values](#input\_chart\_values) | Additional values to yamlencode as `helm_release` values | `any` | `{}` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Specify the exact chart version to install. If this is not specified, the latest version is installed | `string` | `null` | no |
| <a name="input_cleanup_on_fail"></a> [cleanup\_on\_fail](#input\_cleanup\_on\_fail) | Allow deletion of new resources created in this upgrade when upgrade fails | `bool` | `true` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "descriptor_formats": {},<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_key_case": null,<br>  "label_order": [],<br>  "label_value_case": null,<br>  "labels_as_tags": [<br>    "unset"<br>  ],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {},<br>  "tenant": null<br>}</pre> | no |
| <a name="input_create_namespace"></a> [create\_namespace](#input\_create\_namespace) | Create the namespace if it does not yet exist. Defaults to `false` | `bool` | `null` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br>Map of maps. Keys are names of descriptors. Values are maps of the form<br>`{<br>   format = string<br>   labels = list(string)<br>}`<br>(Type is `any` so the map values can later be enhanced to provide additional options.)<br>`format` is a Terraform format string to be passed to the `format()` function.<br>`labels` is a list of labels, in order, to pass to `format()` function.<br>Label values will be normalized before being passed to `format()` so they will be<br>identical to how they appear in `id`.<br>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_eks_component_name"></a> [eks\_component\_name](#input\_eks\_component\_name) | The name of the eks component | `string` | `"eks/cluster"` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_helm_manifest_experiment_enabled"></a> [helm\_manifest\_experiment\_enabled](#input\_helm\_manifest\_experiment\_enabled) | Enable storing of the rendered manifest for helm\_release so the full diff of what is changing can been seen in the plan | `bool` | `false` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br>Set to `0` for unlimited length.<br>Set to `null` for keep the existing setting, which defaults to `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_interruption_handler_enabled"></a> [interruption\_handler\_enabled](#input\_interruption\_handler\_enabled) | If `true`, deploy a SQS queue and Event Bridge rules to enable interruption handling by Karpenter.<br><br>  https://karpenter.sh/v0.27.5/concepts/deprovisioning/#interruption | `bool` | `false` | no |
| <a name="input_interruption_queue_message_retention"></a> [interruption\_queue\_message\_retention](#input\_interruption\_queue\_message\_retention) | The message retention in seconds for the interruption handler SQS queue. | `number` | `300` | no |
| <a name="input_kube_data_auth_enabled"></a> [kube\_data\_auth\_enabled](#input\_kube\_data\_auth\_enabled) | If `true`, use an `aws_eks_cluster_auth` data source to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled` or `kube_exec_auth_enabled`. | `bool` | `false` | no |
| <a name="input_kube_exec_auth_aws_profile"></a> [kube\_exec\_auth\_aws\_profile](#input\_kube\_exec\_auth\_aws\_profile) | The AWS config profile for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_aws_profile_enabled"></a> [kube\_exec\_auth\_aws\_profile\_enabled](#input\_kube\_exec\_auth\_aws\_profile\_enabled) | If `true`, pass `kube_exec_auth_aws_profile` as the `profile` to `aws eks get-token` | `bool` | `false` | no |
| <a name="input_kube_exec_auth_enabled"></a> [kube\_exec\_auth\_enabled](#input\_kube\_exec\_auth\_enabled) | If `true`, use the Kubernetes provider `exec` feature to execute `aws eks get-token` to authenticate to the EKS cluster.<br>Disabled by `kubeconfig_file_enabled`, overrides `kube_data_auth_enabled`. | `bool` | `true` | no |
| <a name="input_kube_exec_auth_role_arn"></a> [kube\_exec\_auth\_role\_arn](#input\_kube\_exec\_auth\_role\_arn) | The role ARN for `aws eks get-token` to use | `string` | `""` | no |
| <a name="input_kube_exec_auth_role_arn_enabled"></a> [kube\_exec\_auth\_role\_arn\_enabled](#input\_kube\_exec\_auth\_role\_arn\_enabled) | If `true`, pass `kube_exec_auth_role_arn` as the role ARN to `aws eks get-token` | `bool` | `true` | no |
| <a name="input_kubeconfig_context"></a> [kubeconfig\_context](#input\_kubeconfig\_context) | Context to choose from the Kubernetes kube config file | `string` | `""` | no |
| <a name="input_kubeconfig_exec_auth_api_version"></a> [kubeconfig\_exec\_auth\_api\_version](#input\_kubeconfig\_exec\_auth\_api\_version) | The Kubernetes API version of the credentials returned by the `exec` auth plugin | `string` | `"client.authentication.k8s.io/v1beta1"` | no |
| <a name="input_kubeconfig_file"></a> [kubeconfig\_file](#input\_kubeconfig\_file) | The Kubernetes provider `config_path` setting to use when `kubeconfig_file_enabled` is `true` | `string` | `""` | no |
| <a name="input_kubeconfig_file_enabled"></a> [kubeconfig\_file\_enabled](#input\_kubeconfig\_file\_enabled) | If `true`, configure the Kubernetes provider with `kubeconfig_file` and use that kubeconfig file for authenticating to the EKS cluster | `bool` | `false` | no |
| <a name="input_kubernetes_namespace"></a> [kubernetes\_namespace](#input\_kubernetes\_namespace) | The namespace to install the release into | `string` | n/a | yes |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br>Does not affect keys of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper`.<br>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br>set as tag values, and output by this module individually.<br>Does not affect values of tags passed in via the `tags` input.<br>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br>Default is to include all labels.<br>Tags with empty values will not be included in the `tags` output.<br>Set to `[]` to suppress all generated tags.<br>**Notes:**<br>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br>  "default"<br>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br>This is the only ID element not also included as a `tag`.<br>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_rbac_enabled"></a> [rbac\_enabled](#input\_rbac\_enabled) | Enable/disable RBAC | `bool` | `true` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br>Characters matching the regex will be removed from the ID elements.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_resources"></a> [resources](#input\_resources) | The CPU and memory of the deployment's limits and requests | <pre>object({<br>    limits = object({<br>      cpu    = string<br>      memory = string<br>    })<br>    requests = object({<br>      cpu    = string<br>      memory = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Time in seconds to wait for any individual kubernetes operation (like Jobs for hooks). Defaults to `300` seconds | `number` | `null` | no |
| <a name="input_wait"></a> [wait](#input\_wait) | Will wait until all resources are in a ready state before marking the release as successful. It will wait for as long as `timeout`. Defaults to `true` | `bool` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_profile"></a> [instance\_profile](#output\_instance\_profile) | Provisioned EC2 Instance Profile for nodes launched by Karpenter |
| <a name="output_metadata"></a> [metadata](#output\_metadata) | Block status of the deployed release |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

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
