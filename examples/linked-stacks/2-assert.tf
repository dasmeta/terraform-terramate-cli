locals {
  expected_stack_paths = tolist([
    "group-0/module-a",
    "group-0/module-b",
  ])

  expected_files = sort(flatten([
    for stack_path in local.expected_stack_paths : [
      "./_terraform/${stack_path}/README.md",
      "./_terraform/${stack_path}/main.tf",
      "./_terraform/${stack_path}/outputs.tf",
      "./_terraform/${stack_path}/stack.tm.hcl",
      "./_terraform/${stack_path}/versions.tf",
    ]
  ]))
}

data "local_file" "module_b_main_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/main.tf"
  depends_on = [module.this]
}

data "local_file" "module_b_outputs_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/outputs.tf"
  depends_on = [module.this]
}

data "local_file" "module_b_stack_tm_hcl" {
  filename   = "${path.module}/_terraform/group-0/module-b/stack.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_a_versions_tf" {
  filename   = "${path.module}/_terraform/group-0/module-a/versions.tf"
  depends_on = [module.this]
}

data "local_file" "module_b_versions_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/versions.tf"
  depends_on = [module.this]
}

check "stack_paths_match_linked_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the linked-stacks fixture."
  }
}

check "generated_files_match_linked_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_files
    error_message = "Generated file paths do not match the linked-stacks fixture."
  }
}

check "linked_stack_declares_terramate_dependency" {
  assert {
    condition     = strcontains(data.local_file.module_b_stack_tm_hcl.content, "../module-a")
    error_message = "The linked Terramate stack does not declare dependency metadata for group-0/module-a."
  }
}

check "linked_stack_uses_remote_state_for_interpolations" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_b_main_tf.content, "terraform_remote_state"),
      strcontains(data.local_file.module_b_main_tf.content, "group-0/module-a"),
      strcontains(data.local_file.module_b_main_tf.content, "outputs.results[\"first-string-variable\"]"),
      strcontains(data.local_file.module_b_outputs_tf.content, "value = module.this"),
    ])
    error_message = "The linked Terraform stack does not render backend-aware output wiring for module-a interpolations."
  }
}

check "linked_stacks_render_isolated_backend_state" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_a_versions_tf.content, "backend \"local\""),
      strcontains(data.local_file.module_b_versions_tf.content, "backend \"local\""),
      strcontains(data.local_file.module_a_versions_tf.content, "path = \"./state/group-0/module-a/terraform.tfstate\""),
      strcontains(data.local_file.module_b_versions_tf.content, "path = \"./state/group-0/module-b/terraform.tfstate\""),
    ])
    error_message = "Linked stacks do not render isolated backend state paths from the global backend default."
  }
}
