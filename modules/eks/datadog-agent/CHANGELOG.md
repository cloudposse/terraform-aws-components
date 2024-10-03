## PR [#814](https://github.com/cloudposse/terraform-aws-components/pull/814)

### Possible Breaking Change

Removed inputs `iam_role_enabled` and `iam_policy_statements` because the Datadog agent does not need an IAM (IRSA) role
or any special AWS permissions because it works solely within the Kubernetes environment. (Datadog has AWS integrations
to handle monitoring that requires AWS permissions.)

This only a breaking change if you were setting these inputs. If you were, simply remove them from your configuration.

### Possible Breaking Change

Previously this component directly created the Kubernetes namespace for the agent when `create_namespace` was set to
`true`. Now this component delegates that responsibility to the `helm-release` module, which better coordinates the
destruction of resources at destruction time (for example, ensuring that the Helm release is completely destroyed and
finalizers run before deleting the namespace).

Generally the simplest upgrade path is to destroy the Helm release, then destroy the namespace, then apply the new
configuration. Alternatively, you can use `terraform state mv` to move the existing namespace to the new Terraform
"address", which will preserve the existing deployment and reduce the possibility of the destroy failing and leaving the
Kubernetes cluster in a bad state.

### Cluster Agent Redundancy

In this PR we have defaulted the number of Cluster Agents to 2. This is because when there are no Cluster Agents, all
cluster metrics are lost. Having 2 agents makes it possible to keep 1 agent running at all times, even when the other is
on a node being drained.

### DNS Resolution Enhancement

If Datadog processes are looking for where to send data and are configured to look up
`datadog.monitoring.svc.cluster.local`, by default the cluster will make a DNS query for each of the following:

1. `datadog.monitoring.svc.cluster.local.monitoring.svc.cluster.local`
2. `datadog.monitoring.svc.cluster.local.svc.cluster.local`
3. `datadog.monitoring.svc.cluster.local.cluster.local`
4. `datadog.monitoring.svc.cluster.local.ec2.internal`
5. `datadog.monitoring.svc.cluster.local`

due to the DNS resolver's
[search path](https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#namespaces-of-services). Because
this lookup happens so frequently (several times a second in a production environment), it can cause a lot of
unnecessary work, even if the DNS query is cached.

In this PR we have set `ndots: 2` in the agent and cluster agent configuration so that only the 5th query is made. (In
Kubernetes, the default value for `ndots` is 5. DNS queries having fewer than `ndots` dots in them will be attempted
using each component of the search path in turn until a match is found, while those with more dots, or with a final dot,
are looked up as is.)

Alternately, where you are setting the host name to be resolved, you can add a final dot at the end so that the search
path is not used, e.g. `datadog.monitoring.svc.cluster.local.`

### Note for Bottlerocket users

If you are using Bottlerocket, you will want to uncomment the following from `values.yaml` or add it to your `values`
input:

```yaml
criSocketPath: /run/dockershim.sock # Bottlerocket Only
env: # Bottlerocket Only
  - name: DD_AUTOCONFIG_INCLUDE_FEATURES # Bottlerocket Only
    value: "containerd" # Bottlerocket Only
```

See the [Datadog documentation](https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#EKS) for
details.
