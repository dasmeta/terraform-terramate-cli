module "this" {
  source = "../.."

  yamldir         = path.module
  targetdir       = "./_terraform"
  stack_id_prefix = "linked-stacks"
  linking_mode    = "remote_state"
  terraform_backend = {
    name = "local"
    configs = {
      path = "./state"
    }
  }
}
