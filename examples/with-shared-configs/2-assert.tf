locals {
  expected_stack_paths = tolist([
    "group-0/module-a",
    "group-1/nested/module-b",
  ])

  expected_files = sort(flatten([
    for stack_path in local.expected_stack_paths : [
      "./_terraform/${stack_path}/README.md",
      "./_terraform/${stack_path}/main.tf",
      "./_terraform/${stack_path}/sharing.tm.hcl",
      "./_terraform/${stack_path}/stack.tm.hcl",
      "./_terraform/${stack_path}/versions.tf",
    ]
  ]))
  expected_generated_files = sort(concat(local.expected_files, ["./_terraform/terramate.tm.hcl"]))
}

check "stack_paths_match_shared_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the shared-config fixture."
  }
}

check "generated_files_match_shared_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_generated_files
    error_message = "Generated file paths do not match the shared-config fixture."
  }
}

check "shared_config_was_applied_to_nested_stack" {
  assert {
    condition     = module.this.yaml_files["group-1/nested/module-b"].source == "dasmeta/empty/null" && module.this.yaml_files["group-1/nested/module-b"].version == "1.2.2"
    error_message = "The nested stack did not resolve the shared YAML source/version configuration."
  }
}
