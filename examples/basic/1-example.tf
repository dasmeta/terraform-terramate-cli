module "this" {
  source = "../.."

  yamldir         = path.module
  targetdir       = "./_terraform"
  stack_id_prefix = "basic"
}
