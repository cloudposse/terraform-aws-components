# Bootstrap Process

Run this process the very first time you setup the tfstate bucket. 

**IMPORTANT:** This has already been performed for this account, so this is documented here just for reference.

Ensure the following environment variables have been set in the `Dockerfile`:
```
ENV TF_BUCKET="cp-staging-terraform-state"
ENV TF_BUCKET_REGION="us-west-2"
ENV TF_DYNAMODB_TABLE="cp-staging-terraform-state-lock"
```

Then run these commands:

1. Comment out the `s3 { ... }` section in `main.tf`

2. Run `init-terraform`

3. Run `terraform apply`

4. Re-enable `s3 { ... }` section in `main.tf`

5. Re-run `init-terraform`

6. Re-run `terraform apply`, answer `yes` when asked to import state
