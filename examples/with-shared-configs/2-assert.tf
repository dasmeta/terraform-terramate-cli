locals {
  expected_stack_paths = tolist([
    "module-a",
    "nested/module-b",
  ])

  expected_files = sort(flatten([
    for stack_path in local.expected_stack_paths : [
      "./output/${stack_path}/README.md",
      "./output/${stack_path}/main.tf",
      "./output/${stack_path}/outputs.tf",
      "./output/${stack_path}/stack.tm.hcl",
      "./output/${stack_path}/versions.tf",
    ]
  ]))
}

check "stack_paths_match_shared_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the shared-config fixture."
  }
}

check "generated_files_match_shared_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_files
    error_message = "Generated file paths do not match the shared-config fixture."
  }
}

check "shared_config_was_applied_to_nested_stack" {
  assert {
    condition     = module.this.yaml_files["nested/module-b"].source == "dasmeta/empty/null" && module.this.yaml_files["nested/module-b"].version == "1.2.2"
    error_message = "The nested stack did not resolve the shared YAML source/version configuration."
  }
}
