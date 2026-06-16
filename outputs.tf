output "yaml_files" {
  value       = local.yaml_files
  description = "Resolved YAML files after shared-config merge and filtering."
}

output "stacks" {
  value       = local.stacks
  description = "Normalized stack definitions derived from YAML input."
}

output "stack_paths" {
  value       = sort(keys(local.stacks))
  description = "Relative stack paths generated from the YAML directory tree."
}

output "generated_files" {
  value       = sort(flatten(concat([for _, stack in module.terraform_setups : stack.generated_files], [for item in local_file.terramate_outputs_sharing_config : item.filename])))
  description = "Generated file paths written by the stack submodule."
}
