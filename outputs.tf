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
  value       = sort(flatten(concat([for _, setup in module.terraform_setups : setup.generated_files], [for _, generator in module.stack_generators : generator.generated_files])))
  description = "Generated file paths written by the stack generator submodule."
}
