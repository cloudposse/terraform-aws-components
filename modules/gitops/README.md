# Component: `gitops`

This component is used to deploy GitHub OIDC roles for accessing the `gitops` Team. We use this team to run Terraform from GitHub Actions.

Examples:

* [cloudposse/github-action-terraform-plan-storage](https://github.com/cloudposse/github-action-terraform-plan-storage/blob/main/.github/workflows/build-and-test.yml)

## Usage

**Stack Level**: Regional

Here are some example snippets for how to use this component:

```yaml
import:
  - catalog/s3-bucket/defaults
  - catalog/dynamodb/defaults

components:
  terraform:
    # S3 Bucket for storing Terraform Plans
    gitops/s3-bucket:
      metadata:
        component: s3-bucket
        inherits:
          - s3-bucket/defaults
      vars:
        name: gitops-plan-storage
        allow_encrypted_uploads_only: false

    # DynamoDB table used to store metadata for Terraform Plans
    gitops/dynamodb:
      metadata:
        component: dynamodb
        inherits:
          - dynamodb/defaults
      vars:
        name: gitops-plan-storage
        # These keys (case-sensitive) are required for the cloudposse/github-action-terraform-plan-storage action
        hash_key: id
        range_key: createdAt

    gitops:
      vars:
        enabled: true
        github_actions_iam_role_enabled: true
        github_actions_iam_role_attributes: [ "gitops" ]
        github_actions_allowed_repos:
          - "acmeOrg/infra"
        s3_bucket_component_name: gitops/s3-bucket
        dynamodb_component_name: gitops/dynamodb
```
