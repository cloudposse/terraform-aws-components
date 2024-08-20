## Release 1.470.1

Components PR [#1077](https://github.com/cloudposse/terraform-aws-components/pull/1077)

Bugfix:

- Fix templating of document separators in Helm chart template. Affects users who are not using
  `running_pod_annotations`.

## Release 1.470.0

Components PR [#1075](https://github.com/cloudposse/terraform-aws-components/pull/1075)

New Features:

- Add support for
  [scheduled overrides](https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides)
  of Runner Autoscaler min and max replicas.
- Add option `tmpfs_enabled` to have runners use RAM-backed ephemeral storage (`tmpfs`, `emptyDir.medium: Memory`)
  instead of disk-backed storage.
- Add `wait_for_docker_seconds` to allow configuration of the time to wait for the Docker daemon to be ready before
  starting the runner.
- Add the ability to have the runner Pods add annotations to themselves once they start running a job. (Actually
  released in release 1.454.0, but not documented until now.)

Changes:

- Previously, `syncPeriod`, which sets the period in which the controller reconciles the desired runners count, was set
  to 120 seconds in `resources/values.yaml`. This setting has been removed, reverting to the default value of 1 minute.
  You can still set this value by setting the `syncPeriod` value in the `values.yaml` file or by setting `syncPeriod` in
  `var.chart_values`.
- Previously, `RUNNER_GRACEFUL_STOP_TIMEOUT` was hardcoded to 90 seconds. That has been reduced to 80 seconds to expand
  the buffer between that and forceful termination from 10 seconds to 20 seconds, increasing the chances the runner will
  successfully deregister itself.
- The inaccurately named `webhook_startup_timeout` has been replaced with `max_duration`. `webhook_startup_timeout` is
  still supported for backward compatibility, but is deprecated.

Bugfixes:

- Create and deploy the webhook secret when an existing secret is not supplied
- Restore proper order of operations in creating resources (broken in release 1.454.0 (PR #1055))
- If `docker_storage` is set and `dockerdWithinRunnerContainer` is `true` (which is hardcoded to be the case), properly
  mount the docker storage volume into the runner container rather than the (non-existent) docker sidecar container.

### Discussion

#### Scheduled overrides

Scheduled overrides allow you to set different min and max replica values for the runner autoscaler at different times.
This can be useful if you have predictable patterns of load on your runners. For example, you might want to scale down
to zero at night and scale up during the day. This feature is implemented by adding a `scheduled_overrides` field to the
`var.runners` map.

See the
[Actions Runner Controller documentation](https://github.com/actions/actions-runner-controller/blob/master/docs/automatically-scaling-runners.md#scheduled-overrides)
for details on how they work and how to set them up.

#### Use RAM instead of Disk via `tmpfs_enabled`

The standard `gp3` EBS volume used for EC2 instance's disk storage is limited (unless you pay extra) to 3000 IOPS and
125 MB/s throughput. This is fine for average workloads, but it does not scale with instance size. A `.48xlarge`
instance could host 90 Pods, but all 90 would still be sharing the same single 3000 IOPS and 125 MB/s throughput EBS
volume attached to the host. This can lead to severe performance issues, as the whole Node gets locked up waiting for
disk I/O.

To mitigate this issue, we have added the `tmpfs_enabled` option to the `runners` map. When set to `true`, the runner
Pods will use RAM-backed ephemeral storage (`tmpfs`, `emptyDir.medium: Memory`) instead of disk-backed storage. This
means the Pod's impact on the Node's disk I/O is limited to the overhead required to launch and manage the Pod (e.g.
downloading the container image and writing logs to the disk). This can be a significant performance improvement,
allowing you to run more Pods on a single Node without running into disk I/O bottlenecks. Without this feature enabled,
you may be limited to running something like 14 Runners on an instance, regardless of instance size, due to disk I/O
limits. With this feature enabled, you may be able to run 50-100 Runners on a single instance.

The trade-off is that the Pod's data is stored in RAM, which increases its memory usage. Be sure to increase the amount
of memory allocated to the runner Pod to account for this. This is generally not a problem, as Runners typically use a
small enough amount of disk space that it can be reasonably stored in the RAM allocated to a single CPU in an EC2
instance, so it is the CPU that remains the limiting factor in how many Runners can be run on an instance.

> [!WARNING]
>
> #### You must configure a memory request for the runner Pod
>
> When using `tmpfs_enabled`, you must configure a memory request for the runner Pod. If you do not, a single Pod would
> be allowed to consume half the Node's memory just for its disk storage.

#### Configure startup timeout via `wait_for_docker_seconds`

When the runner starts and Docker-in-Docker is enabled, the runner waits for the Docker daemon to be ready before
registering marking itself ready to run jobs. This is done by polling the Docker daemon every second until it is ready.
The default timeout for this is 120 seconds. If the Docker daemon is not ready within that time, the runner will exit
with an error. You can configure this timeout by setting `wait_for_docker_seconds` in the `runners` map.

As a general rule, the Docker daemon should be ready within a few seconds of the runner starting. However, particularly
when there are disk I/O issues (see the `tmpfs_enabled` feature above), the Docker daemon may take longer to respond.

#### Add annotations to runner Pods once they start running a job

You can now configure the runner Pods to add annotations to themselves once they start running a job. The idea is to
allow you to have idle pods allow themselves to be interrupted, but then mark themselves as uninterruptible once they
start running a job. This is done by setting the `running_pod_annotations` field in the `runners` map. For example:

```yaml
running_pod_annotations:
  # Prevent Karpenter from evicting or disrupting the worker pods while they are running jobs
  # As of 0.37.0, is not 100% effective due to race conditions.
  "karpenter.sh/do-not-disrupt": "true"
```

As noted in the comments above, this was intended to prevent Karpenter from evicting or disrupting the worker pods while
they are running jobs, while leaving Karpenter free to interrupt idle Runners. However, as of Karpenter 0.37.0, this is
not 100% effective due to race conditions: Karpenter may decide to terminate the Node the Pod is running on but not
signal the Pod before it accepts a job and starts running it. Without the availability of transactions or atomic
operations, this is a difficult problem to solve, and will probably require a more complex solution than just adding
annotations to the Pods. Nevertheless, this feature remains available for use in other contexts, as well as in the hope
that it will eventually work with Karpenter.

#### Bugfix: Deploy webhook secret when existing secret is not supplied

Because deploying secrets with Terraform causes the secrets to be stored unencrypted in the Terraform state file, we
give users the option of creating the configuration secret externally (e.g. via
[SOPS](https://github.com/getsops/sops)). Unfortunately, at some distant time in the past, when we enabled this option,
we broke this component insofar as the webhook secret was no longer being deployed when the user did not supply an
existing secret. This PR fixes that.

The consequence of this bug was that, since the webhook secret was not being deployed, the webhook did not reject
unauthorized requests. This could have allowed an attacker to trigger the webhook and perform a DOS attack by killing
jobs as soon as they were accepted from the queue. A more practical and unintentional consequence was if a repo webhook
was installed alongside an org webhook, it would not keep guard against the webhook receiving the same payload twice if
one of the webhooks was missing the secret or had the wrong secret.

#### Bugfix: Restore proper order of operations in creating resources

In release 1.454.0 (PR [#1055](https://github.com/cloudposse/terraform-aws-components/pull/1055)), we reorganized the
RunnerDeployment template in the Helm chart to put the RunnerDeployment resource first, since it is the most important
resource, merely to improve readability. Unfortunately, the order of operations in creating resources is important, and
this change broke the deployment by deploying the RunnerDeployment before creating the resources it depends on. This PR
restores the proper order of operations.
