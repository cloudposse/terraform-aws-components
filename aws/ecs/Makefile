## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || terraform $@

## Clean up the project
clean:
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	terraform $@

taint/atlantis:
	terraform taint -module atlantis_web_app.ecs_alb_service_task aws_ecs_task_definition.default

taint/webhook:
	terraform taint -module atlantis_web_app.ecs_codepipeline aws_codepipeline_webhook.webhook
	terraform taint -module atlantis_web_app.ecs_codepipeline.github_webhooks github_repository_webhook.default
