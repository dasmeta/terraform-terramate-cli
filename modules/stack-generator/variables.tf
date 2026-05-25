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

variable "stack_description" {
  type        = string
  description = "Terramate stack description to write in stack.tm.hcl."
}

variable "stack_after" {
  type        = list(string)
  default     = []
  description = "Linked stack paths rendered as Terramate dependency metadata."
}

variable "generated_by_module" {
  type        = string
  description = "Module identifier written into generated Terramate stack metadata."
}
