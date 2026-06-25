locals {
  yaml_files                      = module.infra_yaml_fetched.yaml_files
  auto_detected_linked_workspaces = module.infra_yaml_fetched.auto_detected_linked_workspaces

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
          coalesce(var.terraform_backend.configs, {}),
          coalesce(try(item.terraform_backend.configs, null), {}),
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "path") ? {
            path = (
              endswith(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).path), ".tfstate") ?
              "${dirname(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).path))}/${path}/terraform.tfstate" :
              "${trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).path), "/")}/${path}/terraform.tfstate"
            )
          } : {},
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "key") ? {
            key = "${trimsuffix(trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).key), ".tfstate"), "/")}/${path}/terraform.tfstate"
          } : {},
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "workspace_key_prefix") ? {
            workspace_key_prefix = "${trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).workspace_key_prefix), "/")}/${path}"
          } : {},
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "address") ? {
            address = "${trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).address), "/")}/${path}"
          } : {},
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "lock_address") ? {
            lock_address = "${trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).lock_address), "/")}/${path}/lock"
          } : {},
          contains(keys(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {}))), "unlock_address") ? {
            unlock_address = "${trimsuffix(tostring(merge(coalesce(var.terraform_backend.configs, {}), coalesce(try(item.terraform_backend.configs, null), {})).unlock_address), "/")}/${path}/lock"
          } : {}
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
