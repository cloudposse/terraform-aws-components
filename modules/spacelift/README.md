---
tags:
  - layer/spacelift
  - provider/aws
  - provider/spacelift
---

# Component: `spacelift`

These components are responsible for setting up Spacelift and include three components: `spacelift/admin-stack`,
`spacelift/spaces`, and `spacelift/worker-pool`.

Spacelift is a specialized, Terraform-compatible continuous integration and deployment (CI/CD) platform for
infrastructure-as-code. It's designed and implemented by long-time DevOps practitioners based on previous experience
with large-scale installations - dozens of teams, hundreds of engineers and tens of thousands of cloud resources.

## Stack Configuration

Spacelift exists outside of the AWS ecosystem, so we define these components as unique to our standard stack
organization. Spacelift Spaces are required before tenant-specific stacks are created in Spacelift, and the root
administrator stack, referred to as `root-gbl-spacelift-admin-stack`, also does not belong to a specific tenant.
Therefore, we define both outside of the standard `core` or `plat` stacks directories. That root administrator stack is
responsible for creating the tenant-specific administrator stacks, `core-gbl-spacelift-admin-stack` and
`plat-gbl-spacelift-admin-stack`.

Our solution is to define a spacelift-specific configuration file per Spacelift Space. Typically our Spaces would be
`root`, `core`, and `plat`, so we add three files:

```diff
+ stacks/orgs/NAMESPACE/spacelift.yaml
+ stacks/orgs/NAMESPACE/core/spacelift.yaml
+ stacks/orgs/NAMESPACE/plat/spacelift.yaml
```

### Global Configuration

In order to apply common Spacelift configuration to all stacks, we need to set a few global Spacelift settings. The
`pr-comment-triggered` label will be required to trigger stacks with GitHub comments but is not required otherwise. More
on triggering Spacelift stacks to follow.

Add the following to `stacks/orgs/NAMESPACE/_defaults.yaml`:

```yaml
settings:
  spacelift:
    workspace_enabled: true # enable spacelift by default
    before_apply:
      - spacelift-configure-paths
    before_init:
      - spacelift-configure-paths
      - spacelift-write-vars
      - spacelift-tf-workspace
    before_plan:
      - spacelift-configure-paths
    labels:
      - pr-comment-triggered
```

Furthermore, specify additional tenant-specific Space configuration for both `core` and `plat` tenants.

For example, for `core` add the following to `stacks/orgs/NAMESPACE/core/_defaults.yaml`:

```yaml
terraform:
  settings:
    spacelift:
      space_name: core
```

And for `plat` add the following to `stacks/orgs/NAMESPACE/plat/_defaults.yaml`:

```yaml
terraform:
  settings:
    spacelift:
      space_name: plat
```

### Spacelift `root` Space

The `root` Space in Spacelift is responsible for deploying the root administrator stack, `admin-stack`, and the Spaces
component, `spaces`. This Spaces component also includes Spacelift policies. Since the root administrator stack is unique
to tenants, we modify the stack context to create a unique stack slug, `root-gbl-spacelift`.

`stacks/orgs/NAMESPACE/spacelift.yaml`:

```yaml
import:
  - mixins/region/global-region
  - orgs/NAMESPACE/_defaults
  - catalog/terraform/spacelift/admin-stack
  - catalog/terraform/spacelift/spaces

# These intentionally overwrite the default values
vars:
  tenant: root
  environment: gbl
  stage: spacelift

components:
  terraform:
    # This admin stack creates other "admin" stacks
    admin-stack:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - admin-stack/default
      settings:
        spacelift:
          root_administrative: true
          labels:
            - root-admin
            - admin
      vars:
        enabled: true
        root_admin_stack: true # This stack will be created in the root space and will create all the other admin stacks as children.
        context_filters: # context_filters determine which child stacks to manage with this admin stack
          administrative: true # This stack is managing all the other admin stacks
          root_administrative: false # We don't want this stack to also find itself in the config and add itself a second time
        labels:
          - admin
        # attachments only on the root stack
        root_stack_policy_attachments:
          - TRIGGER Global administrator
        # this creates policies for the children (admin) stacks
        child_policy_attachments:
          - TRIGGER Global administrator
```

#### Deployment

> [!TIP]
>
> The following steps assume that you've already authenticated with Spacelift locally.

First deploy Spaces and policies with the `spaces` component:

```bash
atmos terraform apply spaces -s root-gbl-spacelift
```

In the Spacelift UI, you should see each Space and each policy.

Next, deploy the `root` `admin-stack` with the following:

```bash
atmos terraform apply admin-stack -s root-gbl-spacelift
```

Now in the Spacelift UI, you should see the administrator stacks created. Typically these should look similar to the
following:

```diff
+ root-gbl-spacelift-admin-stack
+ root-gbl-spacelift-spaces
+ core-gbl-spacelift-admin-stack
+ plat-gbl-spacelift-admin-stack
+ core-ue1-auto-spacelift-worker-pool
```

> [!TIP]
>
> The `spacelift/worker-pool` component is deployed to a specific tenant, stage, and region but is still deployed by the
> root administrator stack. Verify the administrator stack by checking the `managed-by:` label.

Finally, deploy the Spacelift Worker Pool (change the stack-slug to match your configuration):

```bash
atmos terraform apply spacelift/worker-pool -s core-ue1-auto
```

### Spacelift Tenant-Specific Spaces

A tenant-specific Space in Spacelift, such as `core` or `plat`, includes the administrator stack for that specific Space
and _all_ components in the given tenant. This administrator stack uses `var.context_filters` to select all components
in the given tenant and create Spacelift stacks for each. Similar to the root administrator stack, we again create a
unique stack slug for each tenant. For example `core-gbl-spacelift` or `plat-gbl-spacelift`.

For example, configure a `core` administrator stack with `stacks/orgs/NAMESPACE/core/spacelift.yaml`.

```yaml
import:
  - mixins/region/global-region
  - orgs/NAMESPACE/core/_defaults
  - catalog/terraform/spacelift/admin-stack

vars:
  tenant: core
  environment: gbl
  stage: spacelift

components:
  terraform:
    admin-stack:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - admin-stack/default
      settings:
        spacelift:
          labels: # Additional labels for this stack
            - admin-stack-name:core
      vars:
        enabled: true
        context_filters:
          tenants: ["core"]
        labels: # Additional labels added to all children
          - admin-stack-name:core # will be used to automatically create the `managed-by:stack-name` label
        child_policy_attachments:
          - TRIGGER Dependencies
```

Deploy the `core` `admin-stack` with the following:

```bash
atmos terraform apply admin-stack -s core-gbl-spacelift
```

Create the same for the `plat` tenant in `stacks/orgs/NAMESPACE/plat/spacelift.yaml`, update the tenant and
configuration as necessary, and deploy with the following:

```bash
atmos terraform apply admin-stack -s plat-gbl-spacelift
```

Now all stacks for all components should be created in the Spacelift UI.

## Triggering Spacelift Runs

Cloud Posse recommends two options to trigger Spacelift stacks.

### Triggering with Policy Attachments

Historically, all stacks were triggered with three `GIT_PUSH` policies:

1. [GIT_PUSH Global Administrator](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.administrative.rego)
   triggers admin stacks
2. [GIT_PUSH Proposed Run](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.proposed-run.rego)
   triggers Proposed runs (typically Terraform Plan) for all non-admin stacks on Pull Requests
3. [GIT_PUSH Tracked Run](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.tracked-run.rego)
   triggers Tracked runs (typically Terraform Apply) for all non-admin stacks on merges into `main`

Attach these policies to stacks and Spacelift will trigger them on the respective git push.

### Triggering with GitHub Comments (Preferred)

Atmos support for `atmos describe affected` made it possible to greatly improve Spacelift's triggering workflow. Now we
can add a GitHub Action to collect all affected components for a given Pull Request and add a GitHub comment to the
given PR with a formatted list of the affected stacks. Then Spacelift can watch for a GitHub comment event and then
trigger stacks based on that comment.

In order to set up GitHub Comment triggers, first add the following `GIT_PUSH Plan Affected` policy to the `spaces`
component.

For example, `stacks/catalog/spacelift/spaces.yaml`

```yaml
components:
  terraform:
    spaces:
      metadata:
        component: spacelift/spaces
      settings:
        spacelift:
          administrative: true
          space_name: root
      vars:
        spaces:
          root:
            policies:
---
# This policy will automatically assign itself to stacks and is used to trigger stacks directly from the `cloudposse/github-action-atmos-affected-trigger-spacelift` GitHub action
# This is only used if said GitHub action is set to trigger on "comments"
"GIT_PUSH Plan Affected":
  type: GIT_PUSH
  labels:
    - autoattach:pr-comment-triggered
  body: |
    package spacelift

    # This policy runs whenever a comment is added to a pull request. It looks for the comment body to contain either:
    # /spacelift preview input.stack.id
    # /spacelift deploy input.stack.id
    #
    # If the comment matches those patterns it will queue a tracked run (deploy) or a proposed run (preview). In the case of
    # a proposed run, it will also cancel all of the other pending runs for the same branch.
    #
    # This is being used on conjunction with the GitHub actions `atmos-trigger-spacelift-feature-branch.yaml` and
    # `atmos-trigger-spacelift-main-branch.yaml` in .github/workflows to automatically trigger a preview or deploy run based
    # on the `atmos describe affected` output.

    track {
    	commented
    	contains(input.pull_request.comment, concat(" ", ["/spacelift", "deploy", input.stack.id]))
    }

    propose {
    	commented
    	contains(input.pull_request.comment, concat(" ", ["/spacelift", "preview", input.stack.id]))
    }

    # Ignore if the event is not a comment
    ignore {
    	not commented
    }

    # Ignore if the PR has a `spacelift-no-trigger` label
    ignore {
    	input.pull_request.labels[_] = "spacelift-no-trigger"
    }

    # Ignore if the PR is a draft and doesn't have a `spacelift-trigger` label
    ignore {
    	input.pull_request.draft
    	not has_spacelift_trigger_label
    }

    has_spacelift_trigger_label {
    	input.pull_request.labels[_] == "spacelift-trigger"
    }

    commented {
    	input.pull_request.action == "commented"
    }

    cancel[run.id] {
    	run := input.in_progress[_]
    	run.type == "PROPOSED"
    	run.state == "QUEUED"
    	run.branch == input.pull_request.head.branch
    }

    # This is a random sample of 10% of the runs
    sample {
      millis := round(input.request.timestamp_ns / 1e6)
      millis % 100 <= 10
    }
```

This policy will automatically attach itself to _all_ components that have the `pr-comment-triggered` label, already
defined in `stacks/orgs/NAMESPACE/_defaults.yaml` under `settings.spacelift.labels`.

Next, create two new GitHub Action workflows:

```diff
+ .github/workflows/atmos-trigger-spacelift-feature-branch.yaml
+ .github/workflows/atmos-trigger-spacelift-main-branch.yaml
```

The feature branch workflow will create a comment event in Spacelift to run a Proposed run for a given stack. Whereas
the main branch workflow will create a comment event in Spacelift to run a Deploy run for those same stacks.

#### Feature Branch

```yaml
name: "Plan Affected Spacelift Stacks"

on:
  pull_request:
    types:
      - opened
      - synchronize
      - reopened
    branches:
      - main

jobs:
  context:
    runs-on: ["self-hosted"]
    steps:
      - name: Atmos Affected Stacks Trigger Spacelift
        uses: cloudposse/github-action-atmos-affected-trigger-spacelift@v1
        with:
          atmos-config-path: ./rootfs/usr/local/etc/atmos
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

This will add a GitHub comment such as:

```
/spacelift preview plat-ue1-sandbox-foobar
```

#### Main Branch

```yaml
name: "Deploy Affected Spacelift Stacks"

on:
  pull_request:
    types: [closed]
    branches:
      - main

jobs:
  run:
    if: github.event.pull_request.merged == true
    runs-on: ["self-hosted"]
    steps:
      - name: Atmos Affected Stacks Trigger Spacelift
        uses: cloudposse/github-action-atmos-affected-trigger-spacelift@v1
        with:
          atmos-config-path: ./rootfs/usr/local/etc/atmos
          deploy: true
          github-token: ${{ secrets.GITHUB_TOKEN }}
          head-ref: ${{ github.sha }}~1
```

This will add a GitHub comment such as:

```
/spacelift deploy plat-ue1-sandbox-foobar
```
