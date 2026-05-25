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
  source = "dasmeta/terraform-terramate-cli"

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
