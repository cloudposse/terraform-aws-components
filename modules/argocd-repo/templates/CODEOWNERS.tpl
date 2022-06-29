# Use this file to define individuals or teams that are responsible for code in a repository.
# Read more: https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-on-github/about-code-owners

* %{ for codeowner in codeowners }${codeowner} %{ endfor }
