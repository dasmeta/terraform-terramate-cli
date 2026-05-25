locals {
  files_to_generate = [
    {
      name = "stack.tm.hcl"
      content = templatefile("${path.module}/templates/stack.tm.hcl.tftpl", {
        generated_by_module = var.generated_by_module
        name                = var.stack_name
        description         = var.stack_description
        after               = var.stack_after
      })
    }
  ]
}
