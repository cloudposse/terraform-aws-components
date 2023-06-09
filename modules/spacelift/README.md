# Component: `spacelift`

This component is responsible for provisioning Spacelift stacks.

Spacelift is a specialized, Terraform-compatible continuous integration and deployment (CI/CD) platform for
infrastructure-as-code. It's designed and implemented by long-time DevOps practitioners based on previous experience with
large-scale installations - dozens of teams, hundreds of engineers and tens of thousands of cloud resources.

## Usage

**Stack Level**: Regional

This component provisions an administrative Spacelift stack and assigns it to a worker pool. Although
the stack can manage stacks in any region, it should be provisioned in the same region as the worker pool.

```yaml
components:
  terraform:
    spacelift/defaults:
      metadata:
        type: abstract
        component: spacelift
      settings:
        spacelift:
          workspace_enabled: true
          administrative: true
          autodeploy: true
          before_init:
            - spacelift-configure
            - spacelift-write-vars
            - spacelift-tf-workspace
          before_plan:
            - spacelift-configure
          before_apply:
            - spacelift-configure
          component_root: components/terraform/spacelift
          description: Spacelift Administrative stack
          stack_destructor_enabled: false
          # TODO: replace with the name of the worker pool
          worker_pool_name: WORKER_POOL_NAME
          repository: infra
          branch: main
          labels:
            - folder:admin
          # Do not add normal set of child policies to admin stacks
          policies_enabled: []
          policies_by_id_enabled: []
      vars:
        enabled: true
        spacelift_api_endpoint: https://TODO.app.spacelift.io
        administrative_stack_drift_detection_enabled: true
        administrative_stack_drift_detection_reconcile: true
        administrative_stack_drift_detection_schedule: ["0 4 * * *"]
        administrative_trigger_policy_enabled: false
        autodeploy: false
        aws_role_enabled: false
        drift_detection_enabled: true
        drift_detection_reconcile: true
        drift_detection_schedule: ["0 4 * * *"]
        external_execution: true
        git_repository: infra # TODO: replace with your repository name
        git_branch: main

        # List of available default Rego policies to create in Spacelift.
        # These policies are defined in the catalog https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/tree/master/catalog/policies
        # These policies will not be attached to Spacelift stacks by default (but will be created in Spacelift, and could be attached to a stack manually).
        # For specify policies to attach to each Spacelift stack, use `var.policies_enabled`.
        policies_available:
          - "git_push.proposed-run"
          - "git_push.tracked-run"
          - "plan.default"
          - "trigger.dependencies"
          - "trigger.retries"

        # List of default Rego policies to attach to all Spacelift stacks.
        # These policies are defined in the catalog https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/tree/master/catalog/policies
        policies_enabled:
          - "git_push.proposed-run"
          - "git_push.tracked-run"
          - "plan.default"
          - "trigger.dependencies"

        # List of custom policy names to attach to all Spacelift stacks
        # These policies must exist in `components/terraform/spacelift/rego-policies`
        policies_by_name_enabled: []

        runner_image: 000000000000.dkr.ecr.us-west-2.amazonaws.com/infra #TODO: replace with your ECR repository
        spacelift_component_path: components/terraform
        stack_config_path_template: stacks/%s.yaml
        stack_destructor_enabled: false
        worker_pool_name_id_map:
          <core-region-auto>-spacelift-worker-pool: SOMEWORKERPOOLID #TODO: replace with your worker pool ID
        infracost_enabled: false # TODO: decide on infracost
        terraform_version: "1.3.6"
        terraform_version_map:
          "1": "1.3.6"

        # These could be moved to $PROJECT_ROOT/.spacelift/config.yml
        before_init:
          - spacelift-configure
          - spacelift-write-vars
          - spacelift-tf-workspace
        before_plan:
          - spacelift-configure
        before_apply:
          - spacelift-configure

    # Manages policies, admin stacks, and core OU accounts
    spacelift:
      metadata:
        component: spacelift
        inherits:
          - spacelift/defaults
      settings:
        spacelift:
          policies_by_id_enabled:
            # This component also creates this policy so this is omitted prior to the first apply
            # then added so it's consistent with all admin stacks.
            - trigger-administrative-policy
      vars:
        enabled: true
        # Use context_filters to split up admin stack management
        # context_filters:
        #   stages:
        #     - artifacts
        #     - audit
        #     - auto
        #     - corp
        #     - dns
        #     - identity
        #     - marketplace
        #     - network
        #     - public
        #     - security
        # These are the policies created from https://github.com/cloudposse/terraform-spacelift-cloud-infrastructure-automation/tree/master/catalog/policies
        # Make sure to remove the .rego suffix
        policies_available:
          - git_push.proposed-run
          - git_push.tracked-run
          - plan.default
          - trigger.dependencies
          - trigger.retries
          # This is to auto deploy launch template image id changes
          - plan.warn-on-resource-changes-except-image-id
          # This is the global admin policy
          - trigger.administrative
        # These are the policies added to each spacelift stack created by this admin stack
        policies_enabled:
          - git_push.proposed-run
          - git_push.tracked-run
          - plan.default
          - trigger.dependencies
        # Keep these empty
        policies_by_id_enabled: []

```

## Prerequisites

### GitHub Integration

1. The GitHub owner will need to sign up for a [free trial of Spacelift](https://spacelift.io/free-trial.html)
1. Once an account is created take note of the URL - usually its `https://<GITHUBORG>.app.spacelift.io/`
1. Create a Login Policy

   - Click on Policies then Add Policy
   - Use the following policy and replace `GITHUBORG` with the GitHub Organization slug and DEV with the GitHub id for the Dev setting up the Spacelift module.

   ```rego
   package spacelift

   # See https://docs.spacelift.io/concepts/policy/login-policy for implementation details.
   # Note: Login policies don't affect GitHub organization or SSO admins.
   # Note 2: Enabling SSO requires that all users have an IdP (G Suite) account, so we'll just use
   #          GitHub authentication in the meantime while working with external collaborators.
   # Map session input data to human friendly variables to use in policy evaluation

   username	:= input.session.login
   member_of   := input.session.teams # Input is friendly name, e.g. "SRE" not "sre" or "@GITHUBORG/sre"
   GITHUBORG   := input.session.member # Is this user a member of the CUSTOMER GitHub org?

   # Define GitHub usernames of non org external collaborators with admin vs. user access
   admin_collaborators := { "DEV" }
   user_collaborators  := { "GITHUBORG" } # Using GITHUBORG as a placeholder to avoid empty set

   # Grant admin access to GITHUBORG org members in the CloudPosse group
   admin {
     GITHUBORG
     member_of[_] == "CloudPosse"
   }

   # Grant admin access to non-GITHUBORG org accounts in the admin_collaborators set
   admin {
     # not GITHUBORG
     admin_collaborators[username]
   }

   # Grant user access to GITHUBORG org members in the Developers group
   # allow {
   # 	GITHUBORG
   # 	member_of[_] == "Developers"
   # }

   # Grant user access to non-GITHUBORG org accounts in the user_collaborators set
   allow {
     not GITHUBORG
     user_collaborators[username]
   }

   # Deny access to any non-GITHUBORG org accounts who aren't defined in external collaborators sets
   deny {
     not GITHUBORG
     not user_collaborators[username]
     not admin_collaborators[username]
   }

   # Grant spaces read only user access to all members
   space_read[space.id] {
     space := input.spaces[_]
     GITHUBORG
   }

   # Grant spaces write access to GITHUBORG org members in the Developers group
   # space_write[space.id] {
   #   space := input.spaces[_]
   #   member_of[_] == "Developers"
   # }
   ```

## Spacelift Layout

[Runtime configuration](https://docs.spacelift.io/concepts/configuration/runtime-configuration) is a piece of setup
that is applied to individual runs instead of being global to the stack.
It's defined in `.spacelift/config.yml` YAML file at the root of your repository.
It is required for Spacelift to work with `atmos`.

### Create Spacelift helper scripts

[/rootfs/usr/local/bin/spacelift-tf-workspace](/rootfs/usr/local/bin/spacelift-tf-workspace) manages selecting or creating a Terraform workspace; similar to how `atmos` manages workspaces
during a Terraform run.

[/rootfs/usr/local/bin/spacelift-write-vars](/rootfs/usr/local/bin/spacelift-write-vars) writes the component config using `atmos` to the `spacelift.auto.tfvars.json` file.

**NOTE**: make sure they are all executable:

```bash
chmod +x rootfs/usr/local/bin/spacelift*
```
This folder contains a set of components used to manage [Spacelift](https://docs.spacelift.io/) in an
[atmos-opinionated](https://atmos.tools/) way.

## Bootstrapping

### Environment Setup

Since `spacelift` is designed to automate the plan/apply/destroy cycles of each component instance in an atmos
environment, we have a chicken-and-egg problem where spacelift needs to be configured manually before it can manage the
rest of the infrastructure. This section walks through the initial bootstrapping process.

1. First, to authenticate to `spacelift` from outside of the spacelift environment, we are going to use the
   [spacectl](https://github.com/spacelift-io/spacectl) command-line interface tool. If you use a
   [geodesic](https://github.com/cloudposse/geodesic) shell configured by Cloud Posse, this is already installed. If you
   use another method, follow the installation instructions in the [spacectl](https://github.com/spacelift-io/spacectl)
   repo.

1. Now that we have `spacectl` installed, let's configure it for our `spacelift` instance:

   1. Run `spacectl profile login acme` replacing `acme` with your company's name.
   1. Enter your company's spacelift URL when prompted (e.g., https://acme.app.spacelift.io)
   1. Select `for login with a web browser` as your authentication type
   1. Your browser will be opened, and you will log in to spacelift.

1. We can now use the `spacectl` CLI to export an environment variable, allowing Terraform to manage spacelift resources.

```bash
export SPACELIFT_API_TOKEN=$(spacectl profile export-token)
```

4. Finally, log in to [AWS using Leapp](https://docs.cloudposse.com/howto/geodesic/authenticate-with-leapp) so that you have access to the Terraform state bucket.

### Applying Components

With our environment configured, we can now apply the base components necessary for `spacelift` to manage the rest of the environment.

1. Create spacelift [spaces](https://docs.spacelift.io/concepts/spaces/) by configuring and applying the [spaces](./spaces/) component.

```bash
atmos terraform apply spacelift/spaces -s infra-gbl-root
```

2. Create one or more spacelift [worker pools](https://docs.spacelift.io/concepts/worker-pools) by configuring and applying the [worker-pool](./worker-pool/) component.

```bash
atmos terraform apply spacelift/worker-pool -s core-ue2-auto
```

3. Create the root spacelift [stack](https://docs.spacelift.io/concepts/stack/) by configuring and applying the [admin-stack](./admin-stack/) component.

NOTE: Before running this command, make sure all of your code changes to configure these components have been merged to your `main` branch, and you have `main` checked out.

```bash
atmos terraform apply spacelift/admin-stack -s infra-gbl-root -var "spacelift_run_enabled=true" -var "commit_sha=$(git rev-parse HEAD)"
```

Running this command will create the `root` spacelift admin stack, which will, in turn, read your atmos stack config and create all other spacelift admin stacks defined in the config.

Each of these non-root spacelift admin stacks will then be triggered, planned, and applied by spacelift, and they, in turn, will create each of the spacelift stacks they are responsible for managing.
