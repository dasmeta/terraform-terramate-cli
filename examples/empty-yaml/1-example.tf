module "this" {
  source = "../.."

  yamldir         = "${path.module}/example-infra"
  targetdir       = "./output"
  stack_id_prefix = "empty-yaml"
}
