module "renderer" {
  source  = "dasmeta/generic/renderer"
  version = "1.0.4"

  name       = var.stack_name
  setup_path = var.stack_path
  module_config = {
    source    = var.module_config.source
    version   = var.module_config.version
    variables = var.module_config.variables
    providers = var.module_config.providers
    output    = var.module_config.output
  }
  target_dir       = var.generated_dir
  terraform        = var.terraform
  provider_configs = var.provider_configs
  linked           = local.renderer_linked
  note             = var.note
  readme           = var.readme
}

resource "local_file" "generated_files" {
  for_each = {
    for file in local.files_to_generate :
    file.name => file
  }

  filename = "${trimsuffix(var.generated_dir, "/")}/${var.stack_path}/${each.value.name}"
  content  = each.value.content
}
