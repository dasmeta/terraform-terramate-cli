terraform {
  required_version = "~> 1.3"
}

# Set with: export TF_VAR_backend_s3_bucket="my-real-state-bucket"
variable "backend_s3_bucket" {
  type        = string
  default     = "example-terraform-state"
  description = "S3 bucket name used by the generated backend example."
}

# Set with: export TF_VAR_backend_s3_region="eu-central-1"
variable "backend_s3_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region used by the generated S3 backend example."
}

# Set with: export TF_VAR_backend_s3_key_prefix="terramate"
variable "backend_s3_key_prefix" {
  type        = string
  default     = "terramate"
  description = "S3 key prefix that the Terramate driver extends per stack."
}
