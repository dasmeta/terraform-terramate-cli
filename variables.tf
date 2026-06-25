variable "yamldir" {
  type        = string
  default     = "."
  description = "The directory where YAML module definitions are located."
}

variable "targetdir" {
  type        = string
  default     = "./generated/stacks"
  description = "The directory where generated Terramate stacks will be written."
}

variable "stack_id_prefix" {
  type        = string
  default     = null
  description = "Optional prefix added to generated Terramate stack IDs. Useful only when multiple generated stack trees live in the same Terramate repository and would otherwise collide."
}

variable "terraform_version" {
  type        = string
  default     = "~> 1.3"
  description = "The Terraform version constraint emitted into generated stack files."
}

variable "terraform_backend" {
  type = object({
    name    = string            # Terraform backend type applied to generated Terramate stacks by default.
    configs = optional(any, {}) # Backend configuration arguments applied to generated Terramate stacks by default.
  })
  default     = { name = null, configs = null } # Null backend values mean no default backend block is rendered.
  description = "Optional default Terraform backend configuration applied to generated stacks."
}

variable "linking_mode" {
  type        = string
  default     = "terramate_outputs_sharing"
  description = "Linked stack implementation mode. Defaults to Terramate experimental outputs sharing. Use remote_state for stable Terraform-native linking."

  validation {
    condition     = contains(["remote_state", "terramate_outputs_sharing"], var.linking_mode)
    error_message = "linking_mode must be one of: remote_state, terramate_outputs_sharing."
  }
}

variable "mock_inputs_enabled" {
  type        = bool
  default     = true
  description = "Whether Terramate outputs-sharing mock inputs are enabled by default for consumer stacks. Individual stack YAML can override this with mock_inputs.enabled."
}

variable "provider_configs" {
  type = any
  default = {
    aws = {
      default_tags = {
        enabled      = true        # Enables automatic aws.default_tags rendering for generated stacks.
        managed_by   = "terraform" # Value used for the ManagedBy default tag.
        applied_from = "terramate" # Value used for the AppliedFrom default tag.
        extra_tags   = {}          # Additional default tags merged into generated aws.default_tags content.
      }
      custom_var_blocks = {} # Optional additional provider-specific custom blocks merged into rendered provider configuration.
    }
  }
  description = "Optional grouped provider-specific configuration passed to generated Terramate stacks."
}
