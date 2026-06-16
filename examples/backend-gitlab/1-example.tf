module "this" {
  source = "../.."

  yamldir      = path.module
  targetdir    = "./_terraform"
  linking_mode = "remote_state"
  terraform_backend = {
    name = "http"
    configs = {
      address        = var.backend_gitlab_base_url
      lock_address   = var.backend_gitlab_base_url
      unlock_address = var.backend_gitlab_base_url
      lock_method    = "POST"
      unlock_method  = "DELETE"
      retry_wait_min = 5
      username       = var.backend_gitlab_username
      password       = var.backend_gitlab_password
    }
  }
}
