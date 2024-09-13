# Mixin: `github-actions-iam-role.mixin.tf`

This mixin component is responsible for creating an IAM role that can be assumed by a GitHub action for a specific
purpose. It requires that the `github-oidc-provider` component be installed in the same account, that
`components/terraform/account-map/modules/team-assume-role-policy/github-assume-role-policy.mixin.tf` is present in the
repository, and that the component using this mixin contains a file (by convention named `github-actions-iam-policy.tf`)
which defines a JSON policy document that will be attached to the IAM role, contained in a local variable named
`github_actions_iam_policy`. It is up to the component using this mixin to define the policy to be associated with the
role. The policy should be as restrictive as possible.

At this time, only one role can be created per component (per account, per region). Generated role names include all the
`null-label` labels, so it is possible to create multiple roles in the same account, but not multiple roles in the same
component in the same region with different policies. This limitation of the mixin is somewhat intentional, in that each
role should be created for a specific component, and component can create its own specific role. If this limitation
turns out to be truly burdensome, note that `aws-teams` also supports GitHub actions assuming its roles.

## Usage

**Stack Level**: Global or Regional

This mixin provisions a specific IAM role that can be assumed by a GitHub action for a specific purpose, analogous to
how
[EKS IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
works for EKS.

### Define the role policy

Create a file named `github-actions-iam-policy.tf` that defines the desired policy for the role and saves it as a JSON
string in a local variable named `github_actions_iam_policy`. For example:

```hcl
locals {
  github_actions_iam_policy = join("", data.aws_iam_policy_document.github_actions_iam_policy.*.json)
}

data "aws_iam_policy_document" "github_actions_iam_policy" {
  count = var.github_actions_iam_role_enabled ? 1 : 0

  statement {
    sid       = "ECRGetAuthorizationToken"
    effect    = "Allow"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
}
```

### Create the role alongside the component

Define values for the variables defined in `github-actions-iam-role.mixin.tf` in the stack for the component. Most
importantly, set `github_actions_allowed_repos` to the list of GitHub repositories where installed GitHub actions will
be allowed to assume the role. Wildcards are allowed, so you can allow all repositories in your organization by setting
`github_actions_allowed_repos = ["<your-github-organization>/*"]`.

```yaml
components:
  terraform:
    example:
      vars:
        # whatever vars are needed for the component
        # ...
        github_actions_iam_role_enabled: true
        github_actions_allowed_repos:
          - "my-org/my-repo"
          - "my-org/my-other-repo"
```

### Configure the GitHub Action workflow

#### Add required workflow permissions

In the GitHub action workflow, add required permissions at the top of the workflow, or within the job. See the
[GitHub documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect#adding-permissions-settings)
for more details.

```yaml
permissions:
  id-token: write # This is required for requesting the JWT
  contents: read # This is required for actions/checkout
```

#### Configure settings via environment variables

Although you can configure the settings in various ways, including using GitHub Secrets and Environments, for a balance
of simplicity and visibility we recommend configuration by hard-coding settings in the following environment variables
at the top the workflow:

```yaml
env:
  AWS_REGION: us-east-1 # The AWS region where the workflow should run
  ECR_REPOSITORY: infrastructure # The ECR repository where the workflow should push the image
  ECR_REGISTRY: 123456789012.dkr.ecr.us-east-1.amazonaws.com # The ECR registry where the workflow should push the image
  GHA_IAM_ROLE: arn:aws:iam::123456789012:role/eg-mgmt-use1-art-gha # The ARN of the IAM role to assume
```

Then add the following step to assume the role:

```yaml
- name: Configure AWS credentials for ECR
  uses: aws-actions/configure-aws-credentials@v1
  with:
    role-to-assume: ${{ env.GHA_IAM_ROLE }}
    role-session-name: infra-gha-docker-build-and-push # This can be any name. It shows up in audit logs.
    aws-region: ${{ env.AWS_REGION }}
```
