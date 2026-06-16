module "this" {
  source = "../.."

  yamldir      = path.module
  targetdir    = "./_terraform"
  linking_mode = "remote_state"
  terraform_backend = {
    name = "local"
    configs = {
      path = "./state"
    }
  }
}
