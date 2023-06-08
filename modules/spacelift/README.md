# Component: `spacelift`

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
  $ export SPACELIFT_API_TOKEN=$(spacectl profile export-token)
```

4. Finally, log in to [AWS using Leapp](https://docs.cloudposse.com/howto/geodesic/authenticate-with-leapp) so that you have access to the Terraform state bucket.

### Applying Components

With our environment configured, we can now apply the base components necessary for `spacelift` to manage the rest of the environment.

1. Create spacelift [spaces](https://docs.spacelift.io/concepts/spaces/) by configuring and applying the [spaces](./spaces/) component.

```bash
$ atmos terraform apply spacelift/spaces -s infra-gbl-root
```

2. Create one or more spacelift [worker pools](https://docs.spacelift.io/concepts/worker-pools) by configuring and applying the [worker-pool](./worker-pool/) component.

```bash
$ atmos terraform apply spacelift/worker-pool -s core-ue2-auto
```

3. Create the root spacelift [stack](https://docs.spacelift.io/concepts/stack/) by configuring and applying the [admin-stack](./admin-stack/) component.

NOTE: Before running this command, make sure all of your code changes to configure these components have been merged to your `main` branch, and you have `main` checked out.

```bash
$ atmos terraform apply spacelift/admin-stack -s infra-gbl-root -var "spacelift_run_enabled=true" -var "commit_sha=$(git rev-parse HEAD)"
```

Running this command will create the `root` spacelift admin stack, which will, in turn, read your atmos stack config and create all other spacelift admin stacks defined in the config.

Each of these non-root spacelift admin stacks will then be triggered, planned, and applied by spacelift, and they, in turn, will create each of the spacelift stacks they are responsible for managing.
