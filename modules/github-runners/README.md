# Component: `github-runners`

This component is responsible for provisioning EC2 instances for GitHub runners.

## Usage

**Stack Level**: Regional

Here's an example snippet for how to use this component.

```yaml
components:
  terraform:
    github-runners:
      vars:
        github_scope: company
        instance_type: "t3.small"
        min_size: 1
        max_size: 10
        default_cooldown: 300
        scale_down_cooldown_seconds: 2700
        cpu_utilization_high_threshold_percent: 5
        cpu_utilization_low_threshold_percent: 1
        spot_maxprice: 0.02
        mixed_instances_policy:
          instances_distribution:
            on_demand_allocation_strategy: "prioritized"
            on_demand_base_capacity: 1
            on_demand_percentage_above_base_capacity: 0
            spot_allocation_strategy: "capacity-optimized"
            spot_instance_pools: null
            spot_max_price: null
          override:
            - instance_type: "t4g.large"
              weighted_capacity: null
            - instance_type: "m5.large"
              weighted_capacity: null
            - instance_type: "m5a.large"
              weighted_capacity: null
            - instance_type: "m5n.large"
              weighted_capacity: null
            - instance_type: "m5zn.large"
              weighted_capacity: null
            - instance_type: "m4.large"
              weighted_capacity: null
            - instance_type: "c5.large"
              weighted_capacity: null
            - instance_type: "c5a.large"
              weighted_capacity: null
            - instance_type: "c5n.large"
              weighted_capacity: null
            - instance_type: "c4.large"
              weighted_capacity: null
```

## Configuration

### API Token

Prior to deployment, the API Token must exist in SSM.

To generate the token, please follow [these instructions](https://cloudposse.atlassian.net/l/c/N4dH05ud). Once generated, write the API token to the SSM key store at the following location within the same AWS account and region where the GitHub Actions runner pool will reside.

| Key   | SSM Path        | Type           |
| ----- | --------------- | -------------- |
| Token | `/github/token` | `SecureString` |

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
* [cloudposse/terraform-aws-components](https://github.com/cloudposse/terraform-aws-components/tree/master/modules/TODO) - Cloud Posse's upstream component

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/component)
