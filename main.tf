terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0"
}

# GitHub Provider configuration
provider "github" {
  token = var.github_token
  owner = var.github_organization
}

# Variables
variable "github_token" {
  description = "GitHub personal access token"
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "repository_visibility" {
  description = "Repository visibility (private, public, internal)"
  type        = string
  default     = "private"
}

variable "repository_names" {
  description = "List of repository names to create"
  type        = list(string)
  default     = []
}

variable "enable_issues" {
  description = "Enable Issues tab"
  type        = bool
  default     = true
}

variable "enable_wiki" {
  description = "Enable Wiki tab"
  type        = bool
  default     = true
}

variable "enable_projects" {
  description = "Enable Projects tab"
  type        = bool
  default     = true
}

variable "enable_discussions" {
  description = "Enable Discussions tab"
  type        = bool
  default     = false
}

resource "github_repository" "repositories" {
  for_each = toset(var.repository_names)

  name         = each.value
  visibility   = var.repository_visibility
  auto_init    = true
  
  # 機能の有効化
  has_issues      = var.enable_issues
  has_wiki        = var.enable_wiki
  has_projects    = var.enable_projects
  has_discussions = var.enable_discussions
  
  # その他の設定
  allow_merge_commit     = true
  allow_squash_merge     = true
  allow_rebase_merge     = true
  delete_branch_on_merge = true
  
  # ブランチ保護などの設定（必要に応じて）
  vulnerability_alerts = true
}

# Outputs
output "repository_urls" {
  description = "URLs of all created repositories"
  value = {
    for repo in var.repository_names : repo => github_repository.repositories[repo].html_url
  }
}

output "repository_settings" {
  description = "Repository settings summary"
  value = {
    for repo in var.repository_names : repo => {
      url           = github_repository.repositories[repo].html_url
      visibility    = github_repository.repositories[repo].visibility
      has_issues    = github_repository.repositories[repo].has_issues
      has_wiki      = github_repository.repositories[repo].has_wiki
      has_projects  = github_repository.repositories[repo].has_projects
    }
  }
}