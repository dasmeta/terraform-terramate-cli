locals {
  yaml_files                      = module.infra_yaml_loader.yaml_files
  auto_detected_linked_workspaces = module.infra_yaml_loader.auto_detected_linked_workspaces

  stack_backend_merged_configs = {
    for path, item in local.yaml_files :
    path => merge(
      coalesce(var.terraform_backend.configs, {}),
      coalesce(try(item.terraform_backend.configs, null), {}),
    )
  }

  stack_backend_state_slug = {
    for path in keys(local.yaml_files) :
    path => replace(path, "/[^a-zA-Z0-9_-]+/", "_")
  }

  stack_backend_state_suffix = {
    for path, configs in local.stack_backend_merged_configs :
    path => try(configs.state_key, null) != null ? configs.state_key : local.stack_backend_state_slug[path]
  }

  stack_backend_suffix_overrides = {
    for path, configs in local.stack_backend_merged_configs :
    path => merge(
      contains(keys(configs), "path") ? {
        path = (
          endswith(tostring(configs.path), ".tfstate") ?
          "${dirname(tostring(configs.path))}/${local.stack_backend_state_suffix[path]}/terraform.tfstate" :
          "${trimsuffix(tostring(configs.path), "/")}/${local.stack_backend_state_suffix[path]}/terraform.tfstate"
        )
      } : {},
      contains(keys(configs), "key") ? {
        key = "${trimsuffix(trimsuffix(tostring(configs.key), ".tfstate"), "/")}/${local.stack_backend_state_suffix[path]}/terraform.tfstate"
      } : {},
      contains(keys(configs), "workspace_key_prefix") ? {
        workspace_key_prefix = "${trimsuffix(tostring(configs.workspace_key_prefix), "/")}/${local.stack_backend_state_suffix[path]}"
      } : {},
      contains(keys(configs), "address") ? {
        address = "${trimsuffix(tostring(configs.address), "/")}/${local.stack_backend_state_suffix[path]}"
      } : {},
      contains(keys(configs), "lock_address") ? {
        lock_address = "${trimsuffix(tostring(configs.lock_address), "/")}/${local.stack_backend_state_suffix[path]}/lock"
      } : {},
      contains(keys(configs), "unlock_address") ? {
        unlock_address = "${trimsuffix(tostring(configs.unlock_address), "/")}/${local.stack_backend_state_suffix[path]}/lock"
      } : {}
    )
  }

  stacks = {
    for path, item in local.yaml_files :
    path => {
      id                 = join("_", compact([var.stack_id_prefix, replace(path, "/[^a-zA-Z0-9_-]+/", "_")]))
      name               = replace(path, "/[^a-zA-Z0-9_-]+/", "_")
      description        = "Generated stack for ${path}"
      module_source      = item.source
      module_version     = item.version
      module_vars        = try(item.variables, {})
      module_var_options = try(item.variable_options, {})
      module_providers   = try(item.providers, [])
      mock_inputs = {
        enabled = try(item.mock_inputs.enabled, null)
        values  = try(item.mock_inputs.values, {})
      }
      linked_workspaces = distinct(concat(try(item.linked_workspaces, []), try(local.auto_detected_linked_workspaces[path], [])))
      terraform_backend = try(item.terraform_backend.name, null) == null && var.terraform_backend.name == null ? {
        name    = null
        configs = {}
        } : {
        name = coalesce(try(item.terraform_backend.name, null), var.terraform_backend.name)
        configs = merge(
          {
            for key, value in local.stack_backend_merged_configs[path] : key => value
            if key != "state_key"
          },
          local.stack_backend_suffix_overrides[path]
        )
      }
      output = {
        enabled   = try(item.output.enabled, true)
        sensitive = try(item.output.sensitive, null)
      }
      raw = item
    }
  }
}
