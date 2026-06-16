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

data "local_file" "module_a_versions_tf" {
  filename   = "${path.module}/_terraform/group-0/module-a/versions.tf"
  depends_on = [module.this]
}

data "local_file" "module_b_main_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/main.tf"
  depends_on = [module.this]
}

data "local_file" "module_b_stack_tm_hcl" {
  filename   = "${path.module}/_terraform/group-0/module-b/stack.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_b_versions_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/versions.tf"
  depends_on = [module.this]
}

check "stack_paths_match_backend_gitlab_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the backend-gitlab fixture."
  }
}

check "generated_files_match_backend_gitlab_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_files
    error_message = "Generated file paths do not match the backend-gitlab fixture."
  }
}

check "backend_gitlab_renders_isolated_http_state_urls" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_a_versions_tf.content, "backend \"http\""),
      strcontains(data.local_file.module_b_versions_tf.content, "backend \"http\""),
      strcontains(data.local_file.module_a_versions_tf.content, "address = \"${var.backend_gitlab_base_url}/group-0/module-a\""),
      strcontains(data.local_file.module_b_versions_tf.content, "address = \"${var.backend_gitlab_base_url}/group-0/module-b\""),
      strcontains(data.local_file.module_a_versions_tf.content, "lock_address = \"${var.backend_gitlab_base_url}/group-0/module-a/lock\""),
      strcontains(data.local_file.module_b_versions_tf.content, "unlock_address = \"${var.backend_gitlab_base_url}/group-0/module-b/lock\""),
    ])
    error_message = "Generated GitLab HTTP backend blocks do not isolate state endpoints per Terramate stack."
  }
}

check "backend_gitlab_uses_shared_config_and_autodetected_linking" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_b_stack_tm_hcl.content, "../module-a"),
      strcontains(data.local_file.module_b_main_tf.content, "terraform_remote_state"),
      strcontains(data.local_file.module_b_main_tf.content, "group-0/module-a"),
      strcontains(data.local_file.module_b_main_tf.content, "outputs.results[\"first-string-variable\"]"),
    ])
    error_message = "The GitLab backend example does not prove shared-config and autodetected linked-stack behavior."
  }
}
