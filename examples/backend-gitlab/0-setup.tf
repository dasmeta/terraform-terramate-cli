terraform {
  required_version = "~> 1.3"
}

# Set with: export TF_VAR_backend_gitlab_base_url="https://gitlab.example.com/api/v4/projects/123/terraform/state"
variable "backend_gitlab_base_url" {
  type        = string
  default     = "https://gitlab.example.com/api/v4/projects/123/terraform/state"
  description = "Base GitLab Terraform state URL used by the generated HTTP backend example."
}

# Set with: export TF_VAR_backend_gitlab_username="gitlab-ci-token"
variable "backend_gitlab_username" {
  type        = string
  default     = "gitlab-ci-token"
  description = "Username used by the generated GitLab HTTP backend example."
}

# Set with: export TF_VAR_backend_gitlab_password="your-real-token"
variable "backend_gitlab_password" {
  type        = string
  default     = "replace-with-token"
  sensitive   = true
  description = "Token or password used by the generated GitLab HTTP backend example."
}
