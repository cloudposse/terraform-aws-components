# This file has been programmatically generated and committed by the argocd-repo Terraform component in the infrastructure
# monorepo. It can be updated to contain further entries by adjusting var.gitignore_entries in the aforementioned component.

%{ for entry in entries ~}
${entry}
%{ endfor ~}