---
tags:
  - component/sso-saml-provider
  - layer/software-delivery
  - provider/aws
---

# Component: `sso-saml-provider`

This component reads sso credentials from SSM Parameter store and provides them as outputs

## Usage

**Stack Level**: Regional

Use this in the catalog or use these variables to overwrite the catalog values.

```yaml
components:
  terraform:
    sso-saml-provider:
      settings:
        spacelift:
          workspace_enabled: true
      vars:
        enabled: true
        ssm_path_prefix: "/sso/saml/google"
```
