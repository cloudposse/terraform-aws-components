# Component: `spacelift/admin-stack`

This component is responsible for creating an administrative [stack](https://docs.spacelift.io/concepts/stack/) and its
corresponding child stacks in the spacelift organization.

The component uses a series of `context_fiters` to select atmos component instances to manage as child stacks.

## Usage

**Stack Level**: Global

The following are example snippets of how to use this component:

```yaml
# stacks/orgs/acme/spacelift.yaml
import:
  - mixins/region/global-region
  - orgs/acme/_defaults

vars:
  tenant: infra
  environment: gbl
  stage: root

components:
  terraform:
    spacelift/admin-stack:
      metadata:
      settings:
        spacelift:
          administrative: true
          autodeploy: true
          before_apply:
            - spacelift-configure-paths
          before_init:
            - spacelift-configure-paths
            - spacelift-write-vars
            - spacelift-tf-workspace
          before_plan:
            - spacelift-configure-paths
          drift_detection_enabled: true
          drift_detection_reconcile: true
          drift_detection_schedule:
            - 0 4 * * *
          labels:
            - admin
            - folder:admin
          manage_state: false
          root_administrative: true
          labels:
            - root-admin
            - admin
          policies: {}
      vars:
        administrative: true
        branch: main
        child_policy_attachments:
          - GIT_PUSH Global Administrator
          - TRIGGER Global Administrator
        context_filters:
          administrative: true        # This stack is managing all the other admin stacks
          root_administrative: false  # We don't want this stack to also find itself in the config and add itself a second time
        component_root: components/terraform
        enabled: true
        labels:
         - admin-stack-name:root
        repository: infra-live
        root_admin_stack: true
        root_stack_policy_attachments:
          - GIT_PUSH Global Administrator
          - TRIGGER Global Administrator
        runner_image: 000000000000.dkr.ecr.us-east-2.amazonaws.com/acme/infra-live:latest
        spacelift_spaces_environment_name: gbl
        spacelift_spaces_stage_name: root
        spacelift_spaces_tenant_name: infra
        terraform_version: "1.3.9"
        worker_pool_name: acme-core-ue2-auto-spacelift-default-worker-pool
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
