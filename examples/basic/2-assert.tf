locals {
  expected_stack_paths = tolist([
    "module-a",
    "module-b",
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

check "stack_paths_match_basic_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the basic fixture."
  }
}

check "generated_files_match_basic_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_files
    error_message = "Generated file paths do not match the basic fixture."
  }
}
