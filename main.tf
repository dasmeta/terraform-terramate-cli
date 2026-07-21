module "infra_yaml_loader" {
  #checkov:skip=CKV_TF_1: Registry module source uses version pin (CKV_TF_2)
  source  = "dasmeta/generic/renderer//modules/infra-yaml-loader"
  version = "1.2.1"

  yamldir = var.yamldir
}

module "terraform_setups" {
  source = "./modules/stack"

  for_each = local.stacks

  generated_dir     = var.targetdir
  stack_path        = each.key
  stack_id          = each.value.id
  stack_name        = each.value.name
  stack_description = each.value.description
  stack_after       = each.value.linked_workspaces
  linking_mode      = var.linking_mode
  mock_inputs = {
    enabled = try(each.value.mock_inputs.enabled, null) == null ? var.mock_inputs_enabled : each.value.mock_inputs.enabled
    values  = each.value.mock_inputs.values
  }
  module_config = {
    source           = each.value.module_source
    version          = each.value.module_version
    variables        = each.value.module_vars
    variable_options = each.value.module_var_options
    providers        = each.value.module_providers
    output = merge(
      coalesce(try(each.value.output, null), {}),
      { enabled = var.linking_mode == "remote_state" }
    )
  }
  linked = {
    setups = var.linking_mode == "terramate_outputs_sharing" ? {
      for linked_stack in each.value.linked_workspaces :
      linked_stack => {
        id        = local.stacks[linked_stack].id
        sensitive = try(local.stacks[linked_stack].output.sensitive, null)
        backend   = null
        config    = null
      }
      } : {
      for linked_stack in each.value.linked_workspaces :
      linked_stack => {
        id        = local.stacks[linked_stack].id
        sensitive = try(local.stacks[linked_stack].output.sensitive, null)
        backend   = local.stacks[linked_stack].terraform_backend.name
        config    = local.stacks[linked_stack].terraform_backend.configs
      }
      if try(local.stacks[linked_stack].terraform_backend.name, null) != null
    }
  }
  readme = {
    generated_by_module = "dasmeta/cli/terramate"
    setup_label         = "terramate stack name"
  }
  terraform = {
    version = var.terraform_version
    backend = each.value.terraform_backend
  }
  provider_configs    = var.provider_configs
  generated_by_module = "dasmeta/cli/terramate"
}

resource "local_file" "terramate_outputs_sharing_config" {
  count = var.linking_mode == "terramate_outputs_sharing" ? 1 : 0

  filename = "${trimsuffix(var.targetdir, "/")}/terramate.tm.hcl"
  content  = <<-EOT
  // This file and its content are generated based on config, pleas check README.md for more details
  // Terramate outputs-sharing also requires the experiment to be enabled at the real repository root.
  // This file only defines the sharing backend for the generated stack tree.
  sharing_backend "default" {
    type     = terraform
    filename = "terramate-outputs.tf"
    command  = ["terraform", "output", "-json"]
  }
  EOT
}
