## CodePipeline Setup

For GitHub, your personal access token must have the following scopes.

* `repo`: Grants full control of private repositories.
* `repo:status`: Grants access to commit statuses.
* `admin:repo_hook`: Grants full control of repository hooks. This scope is not required if your token has the repo scope.

We recommend creating the tokens from a "bot" account that has limited access to the repos you are using.

Read more: <https://docs.aws.amazon.com/codebuild/latest/userguide/sample-access-tokens.html#sample-access-tokens>


## Example Build Manifest

Add the following `buildspec.yml` to the root of the GitHub repo's project.

<details>
<summary>View Example `buildspec.yml`</summary>

```
version: 0.2
phases:
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - eval $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - REPOSITORY_URI=$AWS_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/$IMAGE_REPO_NAME
      - IMAGE_TAG=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - REPO_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - docker pull $REPO_URI:latest || true
      - docker build --cache-from $REPO_URI:latest --tag $REPO_URI:latest --tag $REPO_URI:$IMAGE_TAG .
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - REPO_URI=$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$IMAGE_REPO_NAME
      - docker push $REPO_URI:latest
      - docker push $REPO_URI:$IMAGE_TAG
      - echo Writing image definitions file...
      - printf '[{"name":"%s","imageUri":"%s"}]' "$CONTAINER_NAME" "$REPO_URI:$IMAGE_TAG" | tee imagedefinitions.json
artifacts:
  files: imagedefinitions.json
```

</details>

## Troubleshooting


### InvalidParameterException: Long arn format must be used for tagging operations

```sh
aws_ecs_service.default: error tagging ECS Cluster (arn:aws:ecs:us-west-2:223452713953:service/eg-example-fargate-atlantis): InvalidParameterException: Long arn format must be used for tagging operations
```

See: <https://stackoverflow.com/questions/53605033/adding-tags-to-ecs-service-invalidparameterexception/53625568#53625568>

After enabling the Long ARNs, the cluster needs to be rebuilt from scratch.

### InvalidParameterException: The target group with targetGroupArn ... does not have an associated load balancer.

```sh
InvalidParameterException: The target group with targetGroupArn arn:aws:elasticloadbalancing:us-west-2:223452713953:targetgroup/eg-example-backend/5f7241cb041d9356 does not have an associated load balancer.
```

This is a race condition. Rerun `terraform apply`.

### ObjectNotFoundException: No scalable target registered for service namespace

```sh
Error putting scaling policy: ObjectNotFoundException: No scalable target registered for service namespace: ecs, resource ID: service/cpco-testing-fargate/eg-example-fargate-atlantis, scalable dimension: ecs:service:DesiredCount
````

This is a race condition. Rerun `terraform apply`.

### Webhooks Do Not Trigger Builds

This could happen if the secrets between CodePipeline and GitHub do not match. Unfortunately, terraform cannot detect when the secrets change, so your best bet is to `taint` and reapply.

```sh
make taint/webhook
```
