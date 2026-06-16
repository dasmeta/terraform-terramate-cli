locals {
  expected_stack_paths = tolist([
    "group-0/module-a",
    "group-0/module-b",
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

check "stack_paths_match_basic_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the basic fixture."
  }
}

check "generated_files_match_basic_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_generated_files
    error_message = "Generated file paths do not match the basic fixture."
  }
}
