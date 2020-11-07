# Bootstrap Process

Perform these steps in each account, the very first time, in order to setup the tfstate bucket. 

## Create

Provision the bucket:
```
make init
```

Follow the instructions at the end. Ensure the environment variables have been set in the `Dockerfile`.
They look something like this:
```
ENV TF_BUCKET="cpco-staging-terraform-state"
ENV TF_BUCKET_REGION="us-west-2"
ENV TF_DYNAMODB_TABLE="cpco-staging-terraform-state-lock"
```

## Destroy

To destroy the state bucket, first make sure all services in the account have already been destroyed. 

Then run:
```
make destroy
```

**NOTE:** This will only work if the state was previously initialized with `force_destroy=true`. If not, set `force_destroy=true`, rerun `terraform apply`, then run `make destroy`.
