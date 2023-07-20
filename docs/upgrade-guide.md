## Upgrading to `v1.238.0`

Our AWS Teams architecture is going through some changes that will ultimately improve, enhance, and simplify our identity design. As a result, several components have major updates - including `account-map`, `tfstate-backend`, `aws-teams`, and `aws-team-roles`. Part of this update involves an updated `providers.tf` that is already included with every component upstream. In order to use the new `providers.tf`, simply pull in the latest version of `account-map` greater than or equal to `1.227`. This update is backwards compatible with previous `providers.tf` versions, so you do not need to update every other component.

When you pull the recent change for `github-oidc-provider`, you will find this new `providers.tf` file. We can apply this component with the `account-map` change mentioned above in all accounts except identity. All components in both `core-identity` and `core-root` are expected to be applied with SuperAdmin at this time. The update to AWS Teams will create a new team that can apply changes in these privileged accounts, but we do not need to make that upgrade now.

However, we still need a way to apply `github-oidc-provider` to `core-identity` in the meanwhile. To do that, we need to also (1) update the `tfstate-backend` component and (2) grant SuperAdmin the ability to assume roles to access that backend. Please see the extended documentation below for that process.

Finally, once `account-map`, `tfstate-backend`, `aws-teams`, and `aws-team-roles` are all reapplied, now you can reapply `github-oidc-provider` in `core-identity` using the SuperAdmin user.

We know this is an extensive upgrade for a single change, but these upgrades will ultimately improve the experience across all components and simplify the authentication process going forward. Please reach out if you have questions.

### Tips

#### Spacelift

Customers using Spacelift with drift detection enabled should take additional steps to prevent Spacelift from triggering invalid stacks.

When the `account-map` component is updated in code and Spacelift triggers drift detection for all components, Spacelift is unaware of the `account-map` dependency. Thus Spacelift does not use the latest commit for most components triggered, meaning these will all fail.

In order to avoid Spacelift stack failures, follow these steps in order:

1. Upgrade the `account-map` component in code and _do not apply_ it
2. Merge that upgrade into `main`
3. Bulk "Sync Commit" every single Spacelift stack after updating and merging the `account-map` component
4. Finally after `account-map` is merged and synced across all Spacelift stacks, apply the component

##### Bulk Actions in Spacelift UI

You can only select the number of stacks on your screen. Meaning that when you load 50 stacks, you can only select 50 of them. Simply scroll down on the page until all stacks are load (400+). Then you can select them all with 1 Bulk Action
