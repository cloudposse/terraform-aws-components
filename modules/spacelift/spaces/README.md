# Component: `spacelift/spaces`

This component is responsible for creating and managing the [spaces](https://docs.spacelift.io/concepts/spaces/) in the
spacelift organization.

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
    spacelift/spaces:
      settings:
        spacelift:
          administrative: true
          space_name: root
      vars:
        spaces:
          # root is a special space that is the parent of all other spaces and cannot be deleted or renamed. Only the
          # policies block is actually consumed by the component to create policies for the root space.
          root:
            parent_space_id: root
            description: The root space
            inherit_entities: true
            policies:
              GIT_PUSH Global Administrator:
                type: GIT_PUSH
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/git_push.administrative.rego
              TRIGGER Global Administrator:
                type: TRIGGER
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/trigger.administrative.rego
              GIT_PUSH Proposed Run:
                type: GIT_PUSH
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/git_push.proposed-run.rego
              GIT_PUSH Tracked Run:
                type: GIT_PUSH
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/git_push.tracked-run.rego
              PLAN Default:
                type: PLAN
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/plan.default.rego
              TRIGGER Dependencies:
                type: TRIGGER
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/trigger.dependencies.rego
              PLAN Warn On Resource Changes Except Image ID:
                type: PLAN
                body_url: https://raw.githubusercontent.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/%s/catalog/policies/plan.warn-on-resource-changes-except-image-id.rego
          core:
            parent_space_id: root
            description: The space for the core tenant
            inherit_entities: true
            labels:
              - core
          plat:
            parent_space_id: root
            description: The space for platform tenant
            inherit_entities: true
            labels:
              - plat
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
