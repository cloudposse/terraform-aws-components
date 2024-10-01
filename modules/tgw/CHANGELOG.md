## Upgrading to `v1.276.0`

Components PR [#804](https://github.com/cloudposse/terraform-aws-components/pull/804)

### Affected Components

- `tgw/hub`
- `tgw/spoke`
- `tgw/cross-region-hub-connector`

### Summary

This change to the Transit Gateway components,
[PR #804](https://github.com/cloudposse/terraform-aws-components/pull/804), added support for cross-region connections.

As part of that change, we've added `environment` to the component identifier used in the Terraform Output created by
`tgw/hub`. Because of that map key change, all resources in Terraform now have a new resource identifier and therefore
must be recreated with Terraform or removed from state and imported into the new resource ID.

Recreating the resources is the easiest solution but means that Transit Gateway connectivity will be lost while the
changes apply, which typically takes an hour. Alternatively, removing the resources from state and importing back into
the new resource ID is much more complex operationally but means no lost Transit Gateway connectivity.

Since we use Transit Gateway for VPN and GitHub Automation runner access, a temporarily lost connection is not a
significant concern, so we choose to accept lost connectivity and recreate all `tgw/spoke` resources.

### Steps

1. Notify your team of a temporary VPN and Automation outage for accessing private networks
2. Deploy all `tgw/hub` components. There should be a hub component in each region of your network account connected to
   Transit Gateway
3. Deploy all `tgw/spoke` components. There should be a spoke component in every account and every region connected to
   Transit Gateway

#### Tips

Use workflows to deploy `tgw` across many accounts with a single command:

```bash
atmos workflow deploy/tgw -f network
```

```yaml
# stacks/workflows/network.yaml
workflows:
  deploy/tgw:
    description: Provision the Transit Gateway "hub" and "spokes" for connecting VPCs.
    steps:
      - command: terraform deploy tgw/hub -s core-use1-network
        name: hub
      - command: terraform deploy tgw/spoke -s core-use1-network
      - command: echo 'Creating core spokes for Transit Gateway'
        type: shell
        name: core-spokes
      - command: terraform deploy tgw/spoke -s core-use1-corp
      - command: terraform deploy tgw/spoke -s core-use1-auto
      - command: terraform deploy tgw/spoke -s plat-use1-sandbox
      - command: echo 'Creating platform spokes for Transit Gateway'
        type: shell
        name: plat-spokes
      - command: terraform deploy tgw/spoke -s plat-use1-dev
      - command: terraform deploy tgw/spoke -s plat-use1-staging
      - command: terraform deploy tgw/spoke -s plat-use1-prod
```
