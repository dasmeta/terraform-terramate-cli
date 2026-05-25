module "terraform_setups" {
  source = "../terraform-renderer-generic"

  for_each = local.stacks

  name       = each.value.name
  setup_path = each.key
  module_config = {
    source    = each.value.module_source
    version   = each.value.module_version
    variables = each.value.module_vars
    providers = each.value.module_providers
  }
  provider_custom_var_blocks = var.provider_custom_var_blocks
  linked_setups = {
    for linked_stack in each.value.linked_workspaces :
    linked_stack => {
      backend = local.stacks[linked_stack].terraform_backend.name
      config  = local.stacks[linked_stack].terraform_backend.configs
    }
    if try(local.stacks[linked_stack].terraform_backend.name, null) != null
  }
  output     = each.value.output
  target_dir = var.targetdir
  terraform = {
    version = var.terraform_version
    backend = each.value.terraform_backend
  }
  provider_default_tags = var.provider_default_tags
  generated_by_module   = "dasmeta/terraform-terramate-cli"
}

module "stack_generators" {
  source = "./modules/stack-generator"

  for_each = local.stacks

  generated_dir       = var.targetdir
  stack_path          = each.key
  stack_name          = each.value.name
  stack_description   = each.value.description
  stack_after         = each.value.linked_workspaces
  generated_by_module = "dasmeta/terraform-terramate-cli"
}
