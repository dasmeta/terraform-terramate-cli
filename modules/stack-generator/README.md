# stack-generator

Internal submodule that writes one Terramate stack folder for one resolved YAML
module definition.

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

No modules.

## Resources

| Name | Type |
|------|------|
| [local_file.generated_files](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_generated_by_module"></a> [generated\_by\_module](#input\_generated\_by\_module) | Module identifier written into generated Terramate stack metadata. | `string` | n/a | yes |
| <a name="input_generated_dir"></a> [generated\_dir](#input\_generated\_dir) | Root directory where generated stack folders are written. | `string` | n/a | yes |
| <a name="input_stack_after"></a> [stack\_after](#input\_stack\_after) | Linked stack paths rendered as Terramate dependency metadata. | `list(string)` | `[]` | no |
| <a name="input_stack_description"></a> [stack\_description](#input\_stack\_description) | Terramate stack description to write in stack.tm.hcl. | `string` | n/a | yes |
| <a name="input_stack_name"></a> [stack\_name](#input\_stack\_name) | Terramate stack name to write in stack.tm.hcl. | `string` | n/a | yes |
| <a name="input_stack_path"></a> [stack\_path](#input\_stack\_path) | Relative path of the generated stack directory. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Generated file paths written for this stack. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
