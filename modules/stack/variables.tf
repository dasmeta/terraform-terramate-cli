variable "generated_dir" {
  type        = string
  description = "Root directory where generated stack folders are written."
}

variable "stack_path" {
  type        = string
  description = "Relative path of the generated stack directory."
}

variable "stack_name" {
  type        = string
  description = "Terramate stack name to write in stack.tm.hcl."
}

variable "stack_id" {
  type        = string
  description = "Terramate stack ID used for outputs-sharing references."
}

variable "stack_description" {
  type        = string
  description = "Terramate stack description to write in stack.tm.hcl."
}

variable "stack_after" {
  type        = list(string)
  default     = []
  description = "Linked stack paths rendered as Terramate dependency metadata."
}

variable "linking_mode" {
  type        = string
  description = "Linked stack implementation mode used to choose between remote state and Terramate outputs sharing rendering."
}

variable "mock_inputs" {
  type = object({
    enabled = bool              # Whether Terramate mock values should be rendered for this consumer stack.
    values  = optional(any, {}) # Optional custom mock values keyed by linked stack name and output key.
  })
  default     = { enabled = true, values = {} }
  description = "Terramate outputs-sharing mock configuration resolved for this consumer stack."
}

variable "module_config" {
  type = object({
    source           = string            # Terraform module source address rendered for this stack.
    version          = string            # Terraform module version rendered for this stack.
    variables        = optional(any, {}) # Terraform module input variables rendered for this stack.
    variable_options = optional(any, {}) # Optional metadata about module input variables, including sensitivity intent for linked-sharing consumers.
    providers        = optional(any, []) # Terraform provider configuration rendered for this stack.
    output = optional(object({
      enabled   = optional(bool, true) # Whether outputs.tf should be rendered for this stack.
      sensitive = optional(bool)       # Whether the generated results output should be marked sensitive.
    }), { enabled = true })
  })
  description = "Generic Terraform setup configuration passed to the shared renderer for this stack."
}

variable "terraform" {
  type = object({
    version = string # Terraform version constraint rendered for this stack.
    backend = object({
      name    = string            # Terraform backend type rendered for this stack.
      configs = optional(any, {}) # Terraform backend arguments rendered for this stack.
    })
  })
  description = "Terraform runtime configuration passed to the shared renderer for this stack."
}

variable "linked" {
  type = object({
    setups = optional(map(object({
      id        = optional(string) # Terramate stack ID used when linking to this setup via outputs-sharing.
      sensitive = optional(bool)   # Whether outputs shared from this setup should be treated as sensitive in Terramate sharing mode.
      backend   = optional(string) # Backend type used for linked setup remote-state access.
      config    = optional(any)    # Backend arguments used for linked setup remote-state access.
    })), {})                       # Linked setups keyed by stack path for interpolation and dependency support.
  })
  default     = { setups = {} }
  description = "Linked setup metadata passed to the shared renderer for this stack."
}

variable "readme" {
  type = object({
    generated_by_module  = string           # Terraform Registry module identifier referenced in generated README content.
    setup_label          = string           # Label used to describe the generated setup name in README content.
    intro                = optional(string) # Optional descriptive README intro override.
    module_url           = optional(string) # Optional module URL override used in generated README content.
    module_source_label  = optional(string) # Optional label override for the Terraform module source line.
    module_version_label = optional(string) # Optional label override for the Terraform module version line.
  })
  description = "README metadata passed to the shared renderer for this stack."
}

variable "provider_configs" {
  type        = any
  default     = {}
  description = "Optional grouped provider-specific configuration passed through to the shared renderer."
}

variable "generated_by_module" {
  type        = string
  description = "Module identifier written into generated Terramate stack metadata."
}

variable "note" {
  type        = string
  default     = "This file and its content are generated based on config, pleas check README.md for more details"
  description = "Note/comment text written at the top of generated Terramate stack metadata files."
}
