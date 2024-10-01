---
tags:
  - component/tgw
  - layer/network
  - provider/aws
---

# Component: `tgw`

AWS Transit Gateway connects your Amazon Virtual Private Clouds (VPCs) and on-premises networks through a central hub.
This connection simplifies your network and puts an end to complex peering relationships. Transit Gateway acts as a
highly scalable cloud router—each new connection is made only once.

For more on Transit Gateway, see [the AWS documentation](https://aws.amazon.com/transit-gateway/).

## Requirements

In order to connect accounts with Transit Gateway, we deploy Transit Gateway to a central account, typically
`core-network`, and then deploy Transit Gateway attachments for each connected account. Each connected accounts needs a
Transit Gateway attachment for the given account's VPC, either by VPC attachment or by Peering Connection attachment.
Furthermore, each private subnet in each connected VPC needs to explicitly list the CIDRs for all allowed connections.

## Solution

First we deploy the Transit Gateway Hub, `tgw/hub`, to a central network account. The component prepares the Transit
Gateway network with the following steps:

1. Provision Transit Gateway in the network account
2. Collect VPC and EKS component output from every account connected to Transit Gateway
3. Share the Transit Gateway with the Organization using Resource Access Manager (RAM)

By using the `tgw/hub` component to collect Terraform output from connected accounts, only this single component
requires access to the Terraform state of all connected accounts.

Next we deploy `tgw/spoke` to the network account and then to every connected account. This spoke component connects the
given account to the central hub and any listed connection with the following steps:

1. Create a Transit Gateway VPC attachment in the spoke account. This connects the account's VPC to the shared Transit
   Gateway from the hub account.
2. Define all allowed routes for private subnets. Each private subnet in an account's VPC has it's own route table. This
   route table needs to explicitly list any allowed connection to another account's VPC CIDR.
3. (Optional) Create an EKS Cluster Security Group rule to allow traffic to the cluster in the given account.

## Implementation

1. Deploy `tgw/hub` to the network account. List every allowed connection:

```yaml
# stacks/catalog/tgw/hub
components:
  terraform:
    tgw/hub/defaults:
      metadata:
        type: abstract
        component: tgw/hub
      vars:
        enabled: true
        name: tgw-hub
        tags:
          Team: sre
          Service: tgw-hub

    tgw/hub:
      metadata:
        inherits:
          - tgw/hub/defaults
        component: tgw/hub
      vars:
        # These are all connections available for spokes in this region
        # Defaults environment to this region
        connections:
          - account:
              tenant: core
              stage: network
          - account:
              tenant: core
              stage: auto
            eks_component_names:
              - eks/cluster
          - account:
              tenant: plat
              stage: sandbox
            eks_component_names: [] # No clusters deployed for sandbox
          - account:
              tenant: plat
              stage: dev
            eks_component_names:
              - eks/cluster
          - account:
              tenant: plat
              stage: staging
            eks_component_names:
              - eks/cluster
          - account:
              tenant: plat
              stage: prod
            eks_component_names:
              - eks/cluster
```

2. Deploy `tgw/spoke` to network. List every account connected to network (all accounts):

```yaml
# stacks/catalog/tgw/spoke
components:
  terraform:
    tgw/spoke-defaults:
      metadata:
        type: abstract
        component: tgw/spoke
      vars:
        enabled: true
        name: tgw-spoke
        tgw_hub_tenant_name: core
        tgw_hub_stage_name: network # default, added for visibility
        tags:
          Team: sre
          Service: tgw-spoke
```

```yaml
# stacks/orgs/acme/core/network/us-east-1/network.yaml
tgw/spoke:
  metadata:
    inherits:
      - tgw/spoke-defaults
  vars:
    # This is what THIS spoke is allowed to connect to
    connections:
      - account:
          tenant: core
          stage: network
      - account:
          tenant: core
          stage: auto
      - account:
          tenant: plat
          stage: sandbox
      - account:
          tenant: plat
          stage: dev
      - account:
          tenant: plat
          stage: staging
      - account:
          tenant: plat
          stage: prod
```

3. Finally, deploy `tgw/spoke` for each connected account and list the allowed connections:

```yaml
# stacks/orgs/acme/plat/dev/us-east-1/network.yaml
tgw/spoke:
  metadata:
    inherits:
      - tgw/spoke-defaults
  vars:
    connections:
      # Always list self
      - account:
          tenant: plat
          stage: dev
      - account:
          tenant: core
          stage: network
      - account:
          tenant: core
          stage: auto
```

### Alternate Regions

In order to connect any account to the network, the given account needs:

1. Access to the shared Transit Gateway hub
2. An attachment for the given Transit Gateway hub
3. Routes to and from each private subnet

However, sharing the Transit Gateway hub via RAM is only supported in the same region as the primary hub. Therefore, we
must instead deploy a new hub in the alternate region and create a
[Transit Gateway Peering Connection](https://docs.aws.amazon.com/vpc/latest/tgw/tgw-peering.html) between the two
Transit Gateway hubs.

Furthermore, since this Transit Gateway hub for the alternate region is now peered, we must create a Peering Transit
Gateway attachment, opposed to a VPC Transit Gateway Attachment.

#### Cross Region Deployment

1. Deploy `tgw/hub` and `tgw/spoke` into the primary region as described in [Implementation](#implementation)

2. Deploy `tgw/hub` and `tgw/cross-region-hub` into the new region in the network account. See the following
   configuration:

```yaml
# stacks/catalog/tgw/cross-region-hub
import:
  - catalog/tgw/hub

components:
  terraform:
    # Cross region TGW requires additional hub in the alternate region
    tgw/hub:
      vars:
        # These are all connections available for spokes in this region
        # Defaults environment to this region
        connections:
          # Hub for this region is always required
          - account:
              tenant: core
              stage: network
          # VPN source
          - account:
              tenant: core
              stage: network
              environment: use1
          # Github Runners
          - account:
              tenant: core
              stage: auto
              environment: use1
            eks_component_names:
              - eks/cluster
          # All stacks where a spoke will be deployed
          - account:
              tenant: plat
              stage: dev
          - account:
              tenant: plat
              stage: staging
          - account:
              tenant: plat
              stage: prod

    # This alternate hub needs to be connected to the primary region's hub
    tgw/cross-region-hub-connector:
      vars:
        enabled: true
        primary_tgw_hub_region: us-east-1
```

3. Deploy a `tgw/spoke` for network in the new region. For example:

```yaml
# stacks/orgs/acme/core/network/us-west-2/network.yaml
tgw/spoke:
  metadata:
    inherits:
      - tgw/spoke-defaults
  vars:
    peered_region: true # Required for alternate region spokes
    connections:
      # This stack, always included
      - account:
          tenant: core
          stage: network
      # VPN
      - account:
          tenant: core
          environment: use1
          stage: network
      # Automation runners
      - account:
          tenant: core
          environment: use1
          stage: auto
        eks_component_names:
          - eks/cluster
      # All other connections
      - account:
          tenant: plat
          stage: dev
      - account:
          tenant: plat
          stage: staging
      - account:
          tenant: plat
          stage: prod
```

4. Deploy the `tgw/spoke` components for all connected accounts. For example:

```yaml
# stacks/orgs/acme/plat/dev/us-west-2/network.yaml
tgw/spoke:
  metadata:
    inherits:
      - tgw/spoke-defaults
  vars:
    peered_region: true # Required for alternate region spokes
    connections:
      # This stack, always included
      - account:
          tenant: plat
          stage: dev
      # TGW Hub, always included
      - account:
          tenant: core
          stage: network
      # VPN
      - account:
          tenant: core
          environment: use1
          stage: network
      # Automation runners
      - account:
          tenant: core
          environment: use1
          stage: auto
        eks_component_names:
          - eks/cluster
```

5. Update any existing `tgw/spoke` connections to allow the new account and region. For example:

```yaml
# stacks/orgs/acme/core/auto/us-east-1/network.yaml
tgw/spoke:
  metadata:
    inherits:
      - tgw/spoke-defaults
  vars:
    connections:
      - account:
          tenant: core
          stage: network
      - account:
          tenant: core
          stage: corp
      - account:
          tenant: core
          stage: auto
      - account:
          tenant: plat
          stage: sandbox
      - account:
          tenant: plat
          stage: dev
      - account:
          tenant: plat
          stage: staging
      - account:
          tenant: plat
          stage: prod

      # Alternate regions     <-------- These are added for alternate region
      - account:
          tenant: core
          stage: network
          environment: usw2
      - account:
          tenant: plat
          stage: dev
          environment: usw2
      - account:
          tenant: plat
          stage: staging
          environment: usw2
      - account:
          tenant: plat
          stage: prod
          environment: usw2
```

## Destruction

When destroying Transit Gateway components, order of operations matters. Always destroy any removed `tgw/spoke`
components before removing a connection from the `tgw/hub` component.

The `tgw/hub` component creates map of VPC resources that each `tgw/spoke` component references. If the required
reference is removed before the `tgw/spoke` is destroyed, Terraform will fail to destroy the given `tgw/spoke`
component.

:::info Pro Tip!

[Atmos Workflows](https://atmos.tools/core-concepts/workflows/) make applying and destroying Transit Gateway much
easier! For example, to destroy components in the correct order, use a workflow similar to the following:

```yaml
# stacks/workflows/network.yaml
workflows:
  destroy/tgw:
    description: Destroy the Transit Gateway "hub" and "spokes" for connecting VPCs.
    steps:
      - command: echo 'Destroying platform spokes for Transit Gateway'
        type: shell
        name: plat-spokes
      - command: terraform destroy tgw/spoke -s plat-use1-sandbox --auto-approve
      - command: terraform destroy tgw/spoke -s plat-use1-dev --auto-approve
      - command: terraform destroy tgw/spoke -s plat-use1-staging --auto-approve
      - command: terraform destroy tgw/spoke -s plat-use1-prod --auto-approve
      - command: echo 'Destroying core spokes for Transit Gateway'
        type: shell
        name: core-spokes
      - command: terraform destroy tgw/spoke -s core-use1-auto --auto-approve
      - command: terraform destroy tgw/spoke -s core-use1-network --auto-approve
      - command: echo 'Destroying Transit Gateway Hub'
        type: shell
        name: hub
      - command: terraform destroy tgw/hub -s core-use1-network --auto-approve
```

:::

# FAQ

## `tgw/spoke` Fails to Recreate VPC Attachment with `DuplicateTransitGatewayAttachment` Error

```bash
╷
│ Error: creating EC2 Transit Gateway VPC Attachment: DuplicateTransitGatewayAttachment: tgw-0xxxxxxxxxxxxxxxx has non-deleted Transit Gateway Attachments with same VPC ID.
│ 	status code: 400, request id: aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee
│
│   with module.tgw_spoke_vpc_attachment.module.standard_vpc_attachment.aws_ec2_transit_gateway_vpc_attachment.default["core-use2-network"],
│   on .terraform/modules/tgw_spoke_vpc_attachment.standard_vpc_attachment/main.tf line 43, in resource "aws_ec2_transit_gateway_vpc_attachment" "default":
│   43: resource "aws_ec2_transit_gateway_vpc_attachment" "default" {
│
╵
Releasing state lock. This may take a few moments...
exit status 1
```

This is caused by Terraform attempting to create the replacement VPC attachment before the original is completely
destroyed. Retry the apply. Now you should see only "create" actions.
