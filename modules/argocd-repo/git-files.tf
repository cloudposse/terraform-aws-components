resource "github_repository_file" "gitignore" {
  count = local.enabled ? 1 : 0

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = ".gitignore"
  content = templatefile("${path.module}/templates/.gitignore.tpl", {
    entries = var.gitignore_entries
  })
  commit_message      = "Create .gitignore file."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}

resource "github_repository_file" "readme" {
  count = local.enabled ? 1 : 0

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = "README.md"
  content = templatefile("${path.module}/templates/README.md.tpl", {
    repository_name        = join("", github_repository.default.*.name)
    repository_description = join("", github_repository.default.*.description)
    github_organization    = var.github_organization
  })
  commit_message      = "Create README.md file."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}

resource "github_repository_file" "codeowners_file" {
  count = local.enabled ? 1 : 0

  repository = join("", github_repository.default.*.name)
  branch     = join("", github_repository.default.*.default_branch)
  file       = ".github/CODEOWNERS"
  content = templatefile("${path.module}/templates/CODEOWNERS.tpl", {
    codeowners = var.github_codeowner_teams
  })
  commit_message      = "Create CODEOWNERS file."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}

resource "github_repository_file" "pull_request_template" {
  count = local.enabled ? 1 : 0

  repository          = join("", github_repository.default.*.name)
  branch              = join("", github_repository.default.*.default_branch)
  file                = ".github/PULL_REQUEST_TEMPLATE.md"
  content             = file("${path.module}/templates/PULL_REQUEST_TEMPLATE.md")
  commit_message      = "Create PULL_REQUEST_TEMPLATE.md file."
  commit_author       = var.github_user
  commit_email        = var.github_user_email
  overwrite_on_create = true
}
