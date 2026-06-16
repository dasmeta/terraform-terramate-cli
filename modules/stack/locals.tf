locals {
  stack_path_segments = split("/", var.stack_path)
  stack_after_relative = [
    for dependency_path in var.stack_after :
    format(
      "%s%s",
      join("", [
        for _ in range(
          length(local.stack_path_segments) - length([
            for i in range(min(length(local.stack_path_segments), length(split("/", dependency_path)))) :
            i
            if slice(local.stack_path_segments, 0, i + 1) == slice(split("/", dependency_path), 0, i + 1)
          ])
        ) : "../"
      ]),
      join(
        "/",
        slice(
          split("/", dependency_path),
          length([
            for i in range(min(length(local.stack_path_segments), length(split("/", dependency_path)))) :
            i
            if slice(local.stack_path_segments, 0, i + 1) == slice(split("/", dependency_path), 0, i + 1)
          ]),
          length(split("/", dependency_path))
        )
      )
    )
  ]
  linked_reference_expressions = flatten([
    for content in concat([for var_value in values(try(var.module_config.variables, {})) : var_value], try(var.module_config.providers, [])) :
    [for expression in regexall("\\$${([^}]+)}", jsonencode(content)) : replace(expression[0], "\\\"", "\"")]
  ])
  linked_reference_expressions_by_variable = {
    for var_name, var_value in try(var.module_config.variables, {}) :
    var_name => [for expression in regexall("\\$${([^}]+)}", jsonencode(var_value)) : replace(expression[0], "\\\"", "\"")]
  }
  sensitive_consumer_linked_setups = distinct(flatten([
    for var_name, expressions in local.linked_reference_expressions_by_variable : [
      for expression in expressions :
      replace(expression, "/(\\..+|\\[.+)/", "")
    ]
    if try(var.module_config.variable_options[var_name].sensitive, false)
  ]))
  linked_input_variable_names = {
    for setup_name in keys(try(var.linked.setups, {})) :
    setup_name => "tm_linked_${replace(setup_name, "/[^a-zA-Z0-9_]+/", "_")}"
  }
  linked_input_from_stack_ids = {
    for setup_name in keys(try(var.linked.setups, {})) :
    setup_name => try(var.linked.setups[setup_name].id, setup_name)
  }
  linked_input_sensitive = {
    for setup_name in keys(try(var.linked.setups, {})) :
    setup_name => (
      try(var.linked.setups[setup_name].sensitive, null) == true &&
      contains(local.sensitive_consumer_linked_setups, setup_name) ?
      true :
      null
    )
  }
  effective_output_sensitive = (
    try(var.module_config.output.sensitive, null) == true ||
    contains(values(local.linked_input_sensitive), true)
  ) ? true : null
  linked_input_mock_keys = {
    for setup_name in keys(try(var.linked.setups, {})) :
    setup_name => distinct(compact(concat(
      [
        for expression in local.linked_reference_expressions :
        trimsuffix(trimprefix(expression, "${setup_name}[\""), "\"]")
        if startswith(expression, "${setup_name}[\"") && endswith(expression, "\"]")
      ],
      [
        for expression in local.linked_reference_expressions :
        trimprefix(expression, "${setup_name}.")
        if startswith(expression, "${setup_name}.")
      ]
    )))
  }
  linked_input_mock_values = {
    for setup_name, output_keys in local.linked_input_mock_keys :
    setup_name => merge(
      { for output_key in output_keys : output_key => null },
      try(var.mock_inputs.values[setup_name], {})
    )
  }
  renderer_linked = var.linking_mode == "terramate_outputs_sharing" ? {
    setups = try(var.linked.setups, {})
    result_mapping = {
      for setup_name in keys(try(var.linked.setups, {})) :
      setup_name => "var.${local.linked_input_variable_names[setup_name]}"
    }
  } : merge(var.linked, { result_mapping = null })
  files_to_generate = concat(
    [
      {
        name = "stack.tm.hcl"
        content = templatefile("${path.module}/templates/stack.tm.hcl.tftpl", {
          generated_by_module = var.generated_by_module
          note                = var.note
          id                  = var.stack_id
          name                = var.stack_name
          description         = var.stack_description
          after               = local.stack_after_relative
        })
      }
    ],
    var.linking_mode == "terramate_outputs_sharing" ? [
      {
        name = "sharing.tm.hcl"
        content = templatefile("${path.module}/templates/sharing.tm.hcl.tftpl", {
          note                        = var.note
          output_sensitive            = local.effective_output_sensitive
          linked_setups               = keys(try(var.linked.setups, {}))
          linked_input_names          = local.linked_input_variable_names
          linked_input_from_stack_ids = local.linked_input_from_stack_ids
          linked_input_sensitive      = local.linked_input_sensitive
          mock_inputs_enabled         = var.mock_inputs.enabled
          linked_input_mocks          = local.linked_input_mock_values
        })
      }
    ] : []
  )
}
