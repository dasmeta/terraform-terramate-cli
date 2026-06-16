# stack

Internal submodule that renders one complete Terramate stack folder for one
resolved YAML module definition.

This module is repository-internal. Consumers should use the root module.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | ~> 2.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_renderer"></a> [renderer](#module\_renderer) | dasmeta/generic/renderer | 1.0.4 |

## Resources

| Name | Type |
|------|------|
| [local_file.generated_files](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_generated_by_module"></a> [generated\_by\_module](#input\_generated\_by\_module) | Module identifier written into generated Terramate stack metadata. | `string` | n/a | yes |
| <a name="input_generated_dir"></a> [generated\_dir](#input\_generated\_dir) | Root directory where generated stack folders are written. | `string` | n/a | yes |
| <a name="input_linked"></a> [linked](#input\_linked) | Linked setup metadata passed to the shared renderer for this stack. | <pre>object({<br/>    setups = optional(map(object({<br/>      id        = optional(string) # Terramate stack ID used when linking to this setup via outputs-sharing.<br/>      sensitive = optional(bool)   # Whether outputs shared from this setup should be treated as sensitive in Terramate sharing mode.<br/>      backend   = optional(string) # Backend type used for linked setup remote-state access.<br/>      config    = optional(any)    # Backend arguments used for linked setup remote-state access.<br/>    })), {})                       # Linked setups keyed by stack path for interpolation and dependency support.<br/>  })</pre> | <pre>{<br/>  "setups": {}<br/>}</pre> | no |
| <a name="input_linking_mode"></a> [linking\_mode](#input\_linking\_mode) | Linked stack implementation mode used to choose between remote state and Terramate outputs sharing rendering. | `string` | n/a | yes |
| <a name="input_mock_inputs"></a> [mock\_inputs](#input\_mock\_inputs) | Terramate outputs-sharing mock configuration resolved for this consumer stack. | <pre>object({<br/>    enabled = bool              # Whether Terramate mock values should be rendered for this consumer stack.<br/>    values  = optional(any, {}) # Optional custom mock values keyed by linked stack name and output key.<br/>  })</pre> | <pre>{<br/>  "enabled": true,<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_module_config"></a> [module\_config](#input\_module\_config) | Generic Terraform setup configuration passed to the shared renderer for this stack. | <pre>object({<br/>    source           = string            # Terraform module source address rendered for this stack.<br/>    version          = string            # Terraform module version rendered for this stack.<br/>    variables        = optional(any, {}) # Terraform module input variables rendered for this stack.<br/>    variable_options = optional(any, {}) # Optional metadata about module input variables, including sensitivity intent for linked-sharing consumers.<br/>    providers        = optional(any, []) # Terraform provider configuration rendered for this stack.<br/>    output = optional(object({<br/>      enabled   = optional(bool, true) # Whether outputs.tf should be rendered for this stack.<br/>      sensitive = optional(bool)       # Whether the generated results output should be marked sensitive.<br/>    }), { enabled = true })<br/>  })</pre> | n/a | yes |
| <a name="input_note"></a> [note](#input\_note) | Note/comment text written at the top of generated Terramate stack metadata files. | `string` | `"This file and its content are generated based on config, pleas check README.md for more details"` | no |
| <a name="input_provider_configs"></a> [provider\_configs](#input\_provider\_configs) | Optional grouped provider-specific configuration passed through to the shared renderer. | `any` | `{}` | no |
| <a name="input_readme"></a> [readme](#input\_readme) | README metadata passed to the shared renderer for this stack. | <pre>object({<br/>    generated_by_module  = string           # Terraform Registry module identifier referenced in generated README content.<br/>    setup_label          = string           # Label used to describe the generated setup name in README content.<br/>    intro                = optional(string) # Optional descriptive README intro override.<br/>    module_url           = optional(string) # Optional module URL override used in generated README content.<br/>    module_source_label  = optional(string) # Optional label override for the Terraform module source line.<br/>    module_version_label = optional(string) # Optional label override for the Terraform module version line.<br/>  })</pre> | n/a | yes |
| <a name="input_stack_after"></a> [stack\_after](#input\_stack\_after) | Linked stack paths rendered as Terramate dependency metadata. | `list(string)` | `[]` | no |
| <a name="input_stack_description"></a> [stack\_description](#input\_stack\_description) | Terramate stack description to write in stack.tm.hcl. | `string` | n/a | yes |
| <a name="input_stack_id"></a> [stack\_id](#input\_stack\_id) | Terramate stack ID used for outputs-sharing references. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Terramate stack name to write in stack.tm.hcl. | `string` | n/a | yes |
| <a name="input_stack_path"></a> [stack\_path](#input\_stack\_path) | Relative path of the generated stack directory. | `string` | n/a | yes |
| <a name="input_terraform"></a> [terraform](#input\_terraform) | Terraform runtime configuration passed to the shared renderer for this stack. | <pre>object({<br/>    version = string # Terraform version constraint rendered for this stack.<br/>    backend = object({<br/>      name    = string            # Terraform backend type rendered for this stack.<br/>      configs = optional(any, {}) # Terraform backend arguments rendered for this stack.<br/>    })<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Generated file paths written for this stack. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
