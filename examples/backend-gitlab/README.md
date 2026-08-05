# GitLab Backend Example

This example is a runnable validation case for Terramate stacks backed by a
GitLab-managed Terraform HTTP state backend.

It verifies that the root driver module:

- renders `backend "http"` into each generated stack
- keeps one shared backend configuration at the module root
- automatically derives stack-specific state `address`, `lock_address`, and
  `unlock_address` values
- reuses shared YAML config from the example-root `_.yaml`
- auto-detects the linked stack dependency from interpolation
- keeps linked stack support compatible with backend-aware remote state wiring

The values in this example are placeholders intended to show the generated
configuration shape. Replace the project URL and credentials before using the
generated stacks against a real GitLab state backend.

For plain example validation:

- `terraform init`
- `terraform apply`

No real GitLab credentials are required for that step because the example only
renders files and checks their content.

To try the generated stacks against a real GitLab backend, override the
settings as needed:

```bash
export TF_VAR_backend_gitlab_base_url="https://gitlab.example.com/api/v4/projects/123/terraform/state"
export TF_VAR_backend_gitlab_username="gitlab-ci-token"
export TF_VAR_backend_gitlab_password="your-real-token"
```

Then run Terramate/Terraform commands inside `_terraform/`.

When `linking_mode = "terramate_outputs_sharing"` is used, there are two
separate Terramate requirements:

1. The Terramate experiment must be enabled once at the real repository root:

```hcl
terramate {
  config {
    experiments = ["outputs-sharing"]
  }
}
```

2. The generated example writes `_terraform/terramate.tm.hcl` with the required
`sharing_backend "default"` block for the generated stack tree.

Terramate only accepts the `experiments` setting at the real repository root.
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.module_a_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_main_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_stack_tm_hcl](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |
| [local_file.module_b_versions_tf](https://registry.terraform.io/providers/hashicorp/local/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_gitlab_base_url"></a> [backend\_gitlab\_base\_url](#input\_backend\_gitlab\_base\_url) | Base GitLab Terraform state URL used by the generated HTTP backend example. | `string` | `"https://gitlab.example.com/api/v4/projects/123/terraform/state"` | no |
| <a name="input_backend_gitlab_password"></a> [backend\_gitlab\_password](#input\_backend\_gitlab\_password) | Token or password used by the generated GitLab HTTP backend example. | `string` | `"replace-with-token"` | no |
| <a name="input_backend_gitlab_username"></a> [backend\_gitlab\_username](#input\_backend\_gitlab\_username) | Username used by the generated GitLab HTTP backend example. | `string` | `"gitlab-ci-token"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
