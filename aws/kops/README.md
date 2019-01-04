# Kubernetes Ops (kops)

This project provisions dependencies for `kops` clusters including the DNS zone, S3 bucket for state storage, SSH keypair. 

It also writes the computed settings to SSM for usage by other modules or tools.

## Configuration Settings


The minimum recommended settings are the following (`terraform.tfvars`):

```
# EC2 Virtual Network
network_cidr = "10.100.0.0/16"
# Service discovery domain (should exist)
zone_name = "staging.example.io"
# Desired region of cluster
region = "us-west-2"
```

## Quick Start

This is roughly the process to get up and running. These instructions assume you're running inside of a [Geodesic shell](https://github.com/cloudposse/geodesic).
1. Update the `terraform.tfvars` with [desired settings](#configuration-settings). Rebuild the container if necessary.
2. Run `assume-role` to obtain a session.
3. Run `make apply` to provision kops dependencies with terraform (not the cluster itself)
4. Run `make kops/shell` to drop into a shell with configured environment for `kops`. Do this any time you want to interact with the cluster.
5. Run `make kops/build-manifest` to compile the configuration template with current environment settings
6. Run `make kops/create` to submit the cluster state manifest to the cluster state store. Note, no resources will be provisioned.
7. Run `make kops/create-secret-sshpublickey` to provision the SSH public key. Note, the public key was created in the `make apply` step and requires `/secrets/tf` to be mounted. Mount this directory by running `mount -a`.
8. Run `make kops/plan` to view the proposed cluster
9. Run `make kops/apply` to build the cluster
10. Run `make kops/validate` to view cluster status. Note, it will take ~10 minutes to come online (depending on cluster size)

Once the cluster is online, you can interact with it using `kubectl`. 

To start, first run this to export `kubecfg` from the `kops` state store (required to access the cluster):
```
make kops/export
```

Then all the standard `kubectl` commands will work (e.g. `kubectl get nodes`).

