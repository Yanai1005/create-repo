# Minimal Terraform configuration for 50 basic GitHub repositories

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

# Create repositories with minimal configuration
resource "github_repository" "repositories" {
  for_each = toset(local.repositories)

  name       = each.value
  visibility = var.repository_visibility
  auto_init  = true
}

# Outputs
output "repository_urls" {
  description = "URLs of all created repositories"
  value = {
    for repo in local.repositories : repo => github_repository.repositories[repo].html_url
  }
}

output "repository_count" {
  description = "Total number of repositories created"
  value = length(local.repositories)
}