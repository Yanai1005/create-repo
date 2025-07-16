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

resource "github_repository" "repositories" {
  for_each = toset(var.repository_names)

  name       = each.value
  visibility = var.repository_visibility
  auto_init  = true
}

# Outputs
output "repository_urls" {
  description = "URLs of all created repositories"
  value = {
    for repo in var.repository_names : repo => github_repository.repositories[repo].html_url
  }
}