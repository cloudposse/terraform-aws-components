# Spacelift

## Stack Configuration

Spacelift admininstrator stack and Space components are unique to our standard stack organization. Spaces are required before tenant-specific stacks are created in Spacelift, so we must define
unique stack configuration outside of the standard `core` or `plat` stacks. Similiarly, the root administrator stack, referred to as `spacelift/root`, is also outside the scope of tenants
`core` and `plat`. This root administrator stack is responsible for creating the tenant-specific administrator stacks, `spacelift/core` and `spacelift/plat`.

Our solution is to define a spacelift-specific configuration file per Spacelift Space. Typically our Spaces would be `root`, `core`, and `plat`, so we add three files:

```diff
+ stacks/orgs/NAMESPACE/root-spacelift.yaml
+ stacks/orgs/NAMESPACE/core/core-spacelift.yaml
+ stacks/orgs/NAMESPACE/plat/plat-spacelift.yaml
```

### Global Configuration

In order to apply common Spacelift configuration to all stacks, we need to set a few global Spacelift settings. The `pr-comment-triggered` label will be required to triggered stacks with GitHub comments but is not required otherwise. More on triggering Spacelift stacks to follow.

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

The `root` Space in Spacelift is responsible for deploying the root adminstrator stack, `spacelift/root`, and the Spaces component, `spacelift/spaces`. This Spaces component also includes
Spacelift policies. Since the root adminstrator stack is unique to tenants, we modify the stack configuration to create a unique stack slug, `NAMESPACE-gbl-root`.

`stacks/orgs/NAMESPACE/root-spacelift.yaml`:
```yaml
import:
  - mixins/region/global-region
  - orgs/NAMESPACE/_defaults
  - catalog/terraform/spacelift/admin-stack
  - catalog/terraform/spacelift/spaces

# These intentionally overwrite the default values
vars:
  tenant: NAMESPACE
  environment: gbl
  stage: root

components:
  terraform:
    # This admin stack creates other "admin" stacks: spacelift/core, spacelift/plat, spacelift/spaces, spacelift/worker-pool
    spacelift/root:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - spacelift/default
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

:::info

The following steps assume that you've already authenticated with Spacelift locally.

:::

First deploy Spaces and policies with the `spaces` component:
```bash
atmos terraform apply spacelift/spaces -s NAMESPACE-gbl-root
```

In the Spacelift UI, you should see each Space (https://example.app.spacelift.io/spaces) and each policy (https://example.app.spacelift.io/policies).

Next, deploy `spacelift/root` with the following:
```bash
atmos terraform apply spacelift/root -s NAMESPACE-gbl-root
```

Now in the Spacelift UI, you should see the administrator stacks created (https://example.app.spacelift.io/). Typically should look similiar to the following:

```
- NAMESPACE-gbl-root-spacelift-root
- NAMESPACE-gbl-root-spacelift-spaces
- NAMESPACE-gbl-core-spacelift-core
- NAMESPACE-gbl-plat-spacelift-plat
- NAMESPACE-ue1-auto-spacelift-worker-pool
```

:::info

The `spacelift/worker-pool` component is deployed to a specific tenant, stage, and region but is still deployed by the root administrator stack. Verify the administrator stack by checking the `managed-by:` label.

:::

Finally, deploy the Spacelift Worker Pool (change the stack-slug to match your configuration):
```bash
atmos terraform apply spacelift/worker-pool -s core-ue1-auto
```

### Spacelift Tenant-Specific Spaces

A tenant-specific Space in Spacelift, such as `core` or `plat`, includes the administrator stack for that specific Space and _all_ components in the given tenant.
This administrator stack uses `var.context_filters` to select all components in the given tenant and create Spacelift stacks for each. Similar to the root adminstrator stack,
we again create a unique stack slug for each tenant. For example `NAMESPACE-gbl-core`

For example, configure a `core` administrator stack with `stacks/orgs/NAMESPACE/core/core-spacelift.yaml`.

```yaml
import:
  - mixins/region/global-region
  - orgs/NAMESPACE/core/_defaults
  - catalog/terraform/spacelift/spacelift

vars:
  tenant: NAMESPACE
  environment: gbl
  stage: core

components:
  terraform:
    spacelift/core:
      metadata:
        component: spacelift/admin-stack
        inherits:
          - spacelift/default
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

Deploy `spacelift/core` with the following:
```bash
atmos terraform apply spacelift/core -s NAMESPACE-gbl-core
```

Create the same for the `plat` tenant in `stacks/orgs/NAMESPACE/plat/plat-spacelift.yaml` and deploy with the following:
```bash
atmos terraform apply spacelift/plat -s NAMESPACE-gbl-plat
```

## Triggering Spacelift Runs

Cloud Posse recommends two options to trigger Spacelift stacks.

### Triggering with Policy Attachments

Historically, all stacks were triggered with three `GIT_PUSH` policies:

  1. [GIT_PUSH Global Administrator](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.administrative.rego) triggers admin stacks
  2. [GIT_PUSH Proposed Run](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.proposed-run.rego) triggers Proposed runs (typically Terraform Plan) all non-admin stacks on Pull Requests
  3. [GIT_PUSH Tracked Run](https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/blob/main/catalog/policies/git_push.tracked-run.rego) triggers Tracked runs (typically Terraform Apply) all non-admin stacks on merges into `main`

Attach these policies to stacks and Spacelift will trigger them on the respective git push.


### Triggering with GitHub Comments (Preferred)

Atmos support for `atmos describe affected` made it possible to greatly improve Spacelift's triggering workflow. Now we can add a GitHub Action to collect all affected components for a given Pull Request, and add a GitHub comment to the given PR
with a formatted list of each. Then Spacelift can watch for a GitHub comment event, and then trigger stacks based on that comment.

![CleanShot 2023-06-01 at 17 45 37](https://github.com/cloudposse/github-action-atmos-affected-trigger-spacelift/assets/930247/5ff21d9d-be51-482a-a1b0-f3d6b7027e3a)
