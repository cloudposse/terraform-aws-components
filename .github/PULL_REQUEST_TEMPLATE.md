## what
* Describe high-level what changed as a result of these commits (i.e. in plain-english, what do these changes mean?)
* Use bullet points to be concise and to the point.

## why
* Provide the justifications for the changes (e.g. business case). 
* Describe why these changes were made (e.g. why do these commits fix the problem?)
* Use bullet points to be concise and to the point.

## references
* Link to any supporting github issues or helpful documentation to add some context (e.g. stackoverflow). 
* Use `closes #123`, if this PR closes a GitHub issue `#123`

## NOTE
* If you are adding a new component to `terraform-aws-components`, you must add a label to the pull request specifying the earliest major and minor versions of Terraform for which the component must remain backwards compatible. (E.g., `terraform/0.15`, `terraform/0.12`, etc.). If compatibility with pre-1.0 versions of Terraform is not required, just select the `terraform/1.x` label.
* The chosen label will determine the version of Terraform that will be used in this pull request's `pre-commit` status checks.
