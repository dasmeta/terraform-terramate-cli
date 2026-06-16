locals {
  expected_stack_paths = tolist([
    "group-0/module-a",
    "group-0/module-b",
    "group-1/module-c",
    "group-2/dns-zone",
    "group-3/dns-records",
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

data "local_file" "module_a_sharing_tm_hcl" {
  filename   = "${path.module}/_terraform/group-0/module-a/sharing.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_b_sharing_tm_hcl" {
  filename   = "${path.module}/_terraform/group-0/module-b/sharing.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_c_sharing_tm_hcl" {
  filename   = "${path.module}/_terraform/group-1/module-c/sharing.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_b_versions_tf" {
  filename   = "${path.module}/_terraform/group-0/module-b/versions.tf"
  depends_on = [module.this]
}

data "local_file" "module_c_main_tf" {
  filename   = "${path.module}/_terraform/group-1/module-c/main.tf"
  depends_on = [module.this]
}

data "local_file" "module_c_stack_tm_hcl" {
  filename   = "${path.module}/_terraform/group-1/module-c/stack.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "module_c_versions_tf" {
  filename   = "${path.module}/_terraform/group-1/module-c/versions.tf"
  depends_on = [module.this]
}

data "local_file" "dns_zone_main_tf" {
  filename   = "${path.module}/_terraform/group-2/dns-zone/main.tf"
  depends_on = [module.this]
}

data "local_file" "dns_zone_versions_tf" {
  filename   = "${path.module}/_terraform/group-2/dns-zone/versions.tf"
  depends_on = [module.this]
}

data "local_file" "dns_records_main_tf" {
  filename   = "${path.module}/_terraform/group-3/dns-records/main.tf"
  depends_on = [module.this]
}

data "local_file" "dns_records_stack_tm_hcl" {
  filename   = "${path.module}/_terraform/group-3/dns-records/stack.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "dns_records_sharing_tm_hcl" {
  filename   = "${path.module}/_terraform/group-3/dns-records/sharing.tm.hcl"
  depends_on = [module.this]
}

data "local_file" "dns_records_versions_tf" {
  filename   = "${path.module}/_terraform/group-3/dns-records/versions.tf"
  depends_on = [module.this]
}

check "stack_paths_match_backend_s3_fixture" {
  assert {
    condition     = tolist(module.this.stack_paths) == local.expected_stack_paths
    error_message = "Generated stack paths do not match the backend-s3 fixture."
  }
}

check "generated_files_match_backend_s3_fixture" {
  assert {
    condition     = sort(module.this.generated_files) == local.expected_generated_files
    error_message = "Generated file paths do not match the backend-s3 fixture."
  }
}

check "backend_s3_renders_isolated_state_keys" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_a_versions_tf.content, "backend \"s3\""),
      strcontains(data.local_file.module_b_versions_tf.content, "backend \"s3\""),
      strcontains(data.local_file.module_c_versions_tf.content, "backend \"s3\""),
      strcontains(data.local_file.dns_zone_versions_tf.content, "backend \"s3\""),
      strcontains(data.local_file.dns_records_versions_tf.content, "backend \"s3\""),
      strcontains(data.local_file.module_a_versions_tf.content, "bucket = \"${var.backend_s3_bucket}\""),
      strcontains(data.local_file.module_b_versions_tf.content, "region = \"${var.backend_s3_region}\""),
      strcontains(data.local_file.module_c_versions_tf.content, "region = \"${var.backend_s3_region}\""),
      strcontains(data.local_file.dns_zone_versions_tf.content, "region = \"${var.backend_s3_region}\""),
      strcontains(data.local_file.dns_records_versions_tf.content, "region = \"${var.backend_s3_region}\""),
      strcontains(data.local_file.module_a_versions_tf.content, "key = \"${var.backend_s3_key_prefix}/group-0/module-a/terraform.tfstate\""),
      strcontains(data.local_file.module_b_versions_tf.content, "key = \"${var.backend_s3_key_prefix}/group-0/module-b/terraform.tfstate\""),
      strcontains(data.local_file.module_c_versions_tf.content, "key = \"${var.backend_s3_key_prefix}/group-1/module-c/terraform.tfstate\""),
      strcontains(data.local_file.dns_zone_versions_tf.content, "key = \"${var.backend_s3_key_prefix}/group-2/dns-zone/terraform.tfstate\""),
      strcontains(data.local_file.dns_records_versions_tf.content, "key = \"${var.backend_s3_key_prefix}/group-3/dns-records/terraform.tfstate\""),
    ])
    error_message = "Generated S3 backend blocks do not isolate state keys per Terramate stack."
  }
}

check "backend_s3_uses_shared_config_and_autodetected_linking" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_b_stack_tm_hcl.content, "../module-a"),
      strcontains(data.local_file.module_b_main_tf.content, "var.tm_linked_group_0_module_a[\"first-string-variable\"]"),
      strcontains(data.local_file.module_c_stack_tm_hcl.content, "../../group-0/module-a"),
      strcontains(data.local_file.module_c_stack_tm_hcl.content, "../../group-0/module-b"),
      strcontains(data.local_file.module_c_main_tf.content, "var.tm_linked_group_0_module_a[\"first-string-variable\"]"),
      strcontains(data.local_file.module_c_main_tf.content, "var.tm_linked_group_0_module_b[\"second-bool-variable\"]"),
    ])
    error_message = "The S3 backend example does not prove shared-config, autodetected linked-stack behavior, and nested linked-stack rendering."
  }
}

check "backend_s3_renders_real_dns_zone_and_records_stacks" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.dns_zone_main_tf.content, "source  = \"dasmeta/dns/aws\""),
      strcontains(data.local_file.dns_zone_main_tf.content, "version = \"1.0.4\""),
      strcontains(data.local_file.dns_zone_main_tf.content, "zone = \"terramate-test.devops.dasmeta.com\""),
      strcontains(data.local_file.dns_zone_main_tf.content, "create_zone = true"),
      strcontains(data.local_file.dns_records_main_tf.content, "source  = \"dasmeta/dns/aws\""),
      strcontains(data.local_file.dns_records_main_tf.content, "version = \"1.0.4\""),
      strcontains(data.local_file.dns_records_main_tf.content, "zone = \"terramate-test.devops.dasmeta.com\""),
      strcontains(data.local_file.dns_records_main_tf.content, "create_zone = false"),
      strcontains(data.local_file.dns_records_main_tf.content, "module-a.terramate-test.devops.dasmeta.com"),
      strcontains(data.local_file.dns_records_main_tf.content, "module-b.terramate-test.devops.dasmeta.com"),
      strcontains(data.local_file.dns_records_main_tf.content, "module-c.terramate-test.devops.dasmeta.com"),
      strcontains(data.local_file.dns_records_main_tf.content, "var.tm_linked_group_0_module_a[\"first-string-variable\"]"),
      strcontains(data.local_file.dns_records_main_tf.content, "var.tm_linked_group_0_module_b[\"example-static-value\"]"),
      strcontains(data.local_file.dns_records_main_tf.content, "some-prefix-$${var.tm_linked_group_1_module_c[\"example-static-value\"]}-some-suffix"),
    ])
    error_message = "The S3 backend example does not render the real DNS zone and aggregate records stacks as expected."
  }
}

check "backend_s3_renders_dns_stack_dependencies" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.dns_records_stack_tm_hcl.content, "../../group-0/module-a"),
      strcontains(data.local_file.dns_records_stack_tm_hcl.content, "../../group-0/module-b"),
      strcontains(data.local_file.dns_records_stack_tm_hcl.content, "../../group-1/module-c"),
      strcontains(data.local_file.dns_records_stack_tm_hcl.content, "../../group-2/dns-zone"),
    ])
    error_message = "The DNS records stack does not render the expected Terramate dependency ordering."
  }
}

check "backend_s3_propagates_sensitive_outputs_in_outputs_sharing" {
  assert {
    condition = alltrue([
      strcontains(data.local_file.module_a_sharing_tm_hcl.content, "sensitive = true"),
      strcontains(data.local_file.module_b_sharing_tm_hcl.content, "input \"tm_linked_group_0_module_a\""),
      !strcontains(data.local_file.module_b_sharing_tm_hcl.content, "mock          ="),
      !strcontains(data.local_file.module_b_sharing_tm_hcl.content, "sensitive     = true"),
      strcontains(data.local_file.module_c_sharing_tm_hcl.content, "input \"tm_linked_group_0_module_a\""),
      strcontains(data.local_file.module_c_sharing_tm_hcl.content, "sensitive     = true"),
      strcontains(data.local_file.module_c_sharing_tm_hcl.content, "input \"tm_linked_group_0_module_b\""),
      length(regexall("sensitive\\s*=\\s*true", data.local_file.module_c_sharing_tm_hcl.content)) == 2,
      strcontains(data.local_file.dns_records_sharing_tm_hcl.content, "input \"tm_linked_group_0_module_a\""),
      strcontains(data.local_file.dns_records_sharing_tm_hcl.content, "input \"tm_linked_group_1_module_c\""),
      strcontains(data.local_file.dns_records_sharing_tm_hcl.content, "\"first-string-variable\":\"mock-module-a\""),
      strcontains(data.local_file.dns_records_sharing_tm_hcl.content, "\"example-static-value\":\"mock-module-b\""),
      strcontains(data.local_file.dns_records_sharing_tm_hcl.content, "\"example-static-value\":\"mock-module-c\""),
      length(regexall("sensitive\\s*=\\s*true", data.local_file.dns_records_sharing_tm_hcl.content)) == 3,
    ])
    error_message = "The S3 backend example does not prove sensitivity propagation, local mock disabling, and custom Terramate outputs-sharing mock values."
  }
}
