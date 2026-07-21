check "empty_yaml_files_are_ignored" {
  assert {
    condition     = length(module.this.stack_paths) == 0
    error_message = "Empty YAML files must not generate Terramate stacks."
  }
}
