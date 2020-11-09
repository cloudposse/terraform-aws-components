## Initialize terraform remote state
init:
	[ -f .terraform/terraform.tfstate ] || terraform $@

## Clean up the project
clean: kops/clean
	rm -rf .terraform *.tfstate*

## Pass arguments through to terraform which require remote state
apply console destroy graph plan output providers show: init
	terraform $@

## Pass arguments through to terraform which do not require remote state
get fmt validate version:
	terraform $@

## Launch a shell with the kops environment
kops/shell:
	chamber exec kops -- bash -l

## Render the kops manifest template
kops/build-manifest:
	build-kops-manifest

## Apply the kops manifest
kops/create:
	kops create -f $(KOPS_MANIFEST)

## Apply the kops manifest
kops/replace:
	kops replace -f $(KOPS_MANIFEST)

## Create the SSH Public Key secret
kops/create-secret-sshpublickey:
	echo "$${KOPS_SSH_PUBLIC_KEY}" > /dev/shm/$(KOPS_CLUSTER_NAME).pub
	kops create secret sshpublickey admin -i /dev/shm/$(KOPS_CLUSTER_NAME).pub

## Show update plan for the kops cluster
kops/plan:
	kops update cluster

## Apply changes to the kops cluster
kops/apply:
	kops update cluster --yes

## Verify that the cluster is healthy
kops/validate:
	kops validate cluster

## Export kubecfg (required to access cluster)
kops/export:
	kops export kubecfg

## Delete kubecfg
kops/clean:
	rm -f $(KUBECONFIG)
