module "this" {
  source = "../.."

  yamldir         = path.module
  targetdir       = "./_terraform"
  stack_id_prefix = "backend-s3"
  terraform_backend = {
    name = "s3"
    configs = {
      bucket  = var.backend_s3_bucket
      region  = var.backend_s3_region
      key     = var.backend_s3_key_prefix
      encrypt = true
    }
  }
}
