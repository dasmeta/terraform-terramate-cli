# terraform-terramate-cli

`terraform-terramate-cli` is a Terraform driver module that reads DasMeta-style YAML
definitions and generates Terramate-managed Terraform stack folders.

The repository currently focuses on the Terramate execution path. It keeps the
consumer interface intentionally small and preserves room for later extraction of
shared driver-agnostic mapping logic.

## What It Does

- reads multiple YAML files from a directory tree
- merges shared `_.yaml` content into child YAML files
- filters input down to module definitions that provide `source` and `version`
- generates one Terramate stack per resolved YAML file
- renders generic Terraform files through the shared `terraform-renderer-generic`
  module
- writes Terramate stack metadata into the target directory
- supports explicit `linked_workspaces` and auto-detected `${stack.output}`
  interpolation references
- renders backend-aware Terraform remote-state wiring for linked stacks
- supports a root-level backend default with per-stack YAML override and isolated
  state identity per generated stack

## Minimal Example

```hcl
module "this" {
  source = "dasmeta/terramate/cli"

  yamldir   = "${path.module}/infra"
  targetdir = "${path.module}/generated/stacks"
}
```

Example YAML:

```yaml
source: dasmeta/empty/null
version: 1.2.2
```

## Inputs

- `yamldir`: directory containing YAML module definitions
- `targetdir`: output directory where generated stacks are written
- `terraform_version`: Terraform version constraint emitted into generated
  `versions.tf`
- `terraform_backend`: optional default backend configuration applied to
  generated stacks unless overridden in YAML

## Outputs

- `generated_files`: generated file paths
- `stack_paths`: generated stack-relative paths
- `stacks`: normalized stack definitions derived from YAML
- `yaml_files`: normalized YAML documents after shared-config merge

## Repository Layout

- root module: public driver interface
- `modules/stack-generator`: internal Terramate-only stack metadata generator
- `examples/basic`: basic usage and executable validation case
- `examples/with-shared-configs`: shared `_.yaml` executable validation case
- `examples/linked-stacks`: linked-stack and backend-aware executable validation
  case
- `docs/`: architecture and migration notes carried from the prototype phase
- `specs/`: Speckit evidence for module-impacting changes

## Local Validation

Basic test:

```bash
terraform -chdir=examples/basic init -input=false
terraform -chdir=examples/basic apply -auto-approve
```

Shared-config test:

```bash
terraform -chdir=examples/with-shared-configs init -input=false
terraform -chdir=examples/with-shared-configs apply -auto-approve
```

Linked-stacks test:

```bash
terraform -chdir=examples/linked-stacks init -input=false
terraform -chdir=examples/linked-stacks apply -auto-approve
cd examples/linked-stacks/output && terramate list
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_stack_generators"></a> [stack\_generators](#module\_stack\_generators) | ./modules/stack-generator | n/a |
| <a name="module_terraform_setups"></a> [terraform\_setups](#module\_terraform\_setups) | dasmeta/generic/renderer | 1.0.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_provider_custom_var_blocks"></a> [provider\_custom\_var\_blocks](#input\_provider\_custom\_var\_blocks) | Optional provider-specific custom blocks passed to the shared renderer. | `any` | `{}` | no |
| <a name="input_provider_default_tags"></a> [provider\_default\_tags](#input\_provider\_default\_tags) | Optional provider-specific default tag settings passed to the shared renderer. | `any` | <pre>{<br/>  "aws": {<br/>    "applied_from": "terramate",<br/>    "enabled": true,<br/>    "extra_tags": {},<br/>    "managed_by": "terraform"<br/>  }<br/>}</pre> | no |
| <a name="input_targetdir"></a> [targetdir](#input\_targetdir) | The directory where generated Terramate stacks will be written. | `string` | `"./generated/stacks"` | no |
| <a name="input_terraform_backend"></a> [terraform\_backend](#input\_terraform\_backend) | Optional default Terraform backend configuration applied to generated stacks. | <pre>object({<br/>    name    = string<br/>    configs = optional(any, {})<br/>  })</pre> | <pre>{<br/>  "configs": null,<br/>  "name": null<br/>}</pre> | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | The Terraform version constraint emitted into generated stack files. | `string` | `"~> 1.3"` | no |
| <a name="input_yamldir"></a> [yamldir](#input\_yamldir) | The directory where YAML module definitions are located. | `string` | `"."` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Generated file paths written by the stack generator submodule. |
| <a name="output_stack_paths"></a> [stack\_paths](#output\_stack\_paths) | Relative stack paths generated from the YAML directory tree. |
| <a name="output_stacks"></a> [stacks](#output\_stacks) | Normalized stack definitions derived from YAML input. |
| <a name="output_yaml_files"></a> [yaml\_files](#output\_yaml\_files) | Resolved YAML files after shared-config merge and filtering. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
