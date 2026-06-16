module "this" {
  source = "../.."

  yamldir   = path.module
  targetdir = "./_terraform"
}
