# terraform-terramate-cli

`terraform-terramate-cli` is a Terraform driver module that reads DasMeta-style YAML
definitions and generates Terramate-managed Terraform stack folders.

The repository currently focuses on the Terramate execution path. It keeps the
consumer interface intentionally small and preserves room for later extraction of
shared driver-agnostic mapping logic.

Debugging this driver or a setup that consumes it? See [AGENTS.md](./AGENTS.md)
for the symptom-to-cause table, validation recipes, and known traps.

## What It Does

- reads multiple YAML files from a directory tree
- merges shared `_.yaml` content into child YAML files
- filters input down to module definitions that provide `source` (and `version` for registry modules; local paths default to `local`)
- generates one Terramate stack per resolved YAML file
- renders generic Terraform files through the shared `terraform-renderer-generic`
  module
- writes Terramate stack metadata into the target directory
- supports explicit `linked_workspaces` and auto-detected `${stack.output}` interpolation
- defaults linked stack handling to Terramate experimental outputs-sharing
- forces shared-renderer `outputs.tf` off in outputs-sharing mode and back on in
  explicit `remote_state` mode
- supports configurable Terramate mock inputs with a global default and per-stack
  YAML override
- renders backend-aware Terraform remote-state wiring for linked stacks
- supports a root-level backend default with per-stack YAML override and isolated
  state identity per generated stack

## Minimal Example

```hcl
module "this" {
  source = "dasmeta/cli/terramate"

  yamldir   = "${path.module}/infra"
  targetdir = "${path.module}/generated/stacks"
}
```

For the stable Terraform-native linking path, set:

```hcl
linking_mode = "remote_state"
```

If multiple generated stack trees live in the same Terramate repository, you can
optionally prefix stack IDs to keep them repo-wide unique:

```hcl
stack_id_prefix = "example-name"
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
  generated stacks unless overridden in YAML. Per-stack YAML may set only
  `configs.state_key` to pick a legacy GitLab/S3 state name; shared fields
  (URL, credentials, `lock_method`, …) stay in the module default. Without
  `state_key`, the Terramate stack name slug derived from the YAML path is used
  (same transform as the generated stack `name`: `/` → `_`).
- `mock_inputs_enabled`: optional default for Terramate outputs-sharing mocks;
  stack YAML may override it with `mock_inputs.enabled`

## Outputs

- `generated_files`: generated file paths
- `stack_paths`: generated stack-relative paths
- `stacks`: normalized stack definitions derived from YAML
- `yaml_files`: normalized YAML documents after shared-config merge

## Repository Layout

- root module: public driver interface
- `modules/stack`: internal Terramate stack wrapper that renders both generic
  Terraform files and Terramate metadata
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
cd examples/linked-stacks/_terraform && terramate list
```

## General Terramate Flow

For a real Terramate setup using outputs-sharing:

1. Generate the stack tree:

```bash
terraform -chdir=PATH/TO/EXAMPLE init -input=false
terraform -chdir=PATH/TO/EXAMPLE apply -auto-approve
```

2. Enable the experiment once at the real Terramate repository root:

```hcl
terramate {
  config {
    experiments = ["outputs-sharing"]
  }
}
```

3. Generate Terramate helper code:

```bash
terramate -C PATH/TO/GENERATED_STACKS generate
```

4. Initialize generated stacks:

```bash
terramate -C PATH/TO/GENERATED_STACKS run \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform init
```

5. Plan or apply with sharing enabled:

```bash
terramate -C PATH/TO/GENERATED_STACKS run \
  --enable-sharing \
  --mock-on-fail \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform plan
```

```bash
terramate -C PATH/TO/GENERATED_STACKS run \
  --enable-sharing \
  --mock-on-fail \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform apply -auto-approve
```

6. Destroy in reverse order:

```bash
terramate -C PATH/TO/GENERATED_STACKS run \
  --reverse \
  --enable-sharing \
  --disable-safeguards=git-untracked,git-uncommitted \
  -- terraform destroy -auto-approve
```

Notes:

- `terraform init` should normally run without `--enable-sharing`
- `--mock-on-fail` is useful for preview or bootstrap flows, but only for stacks
  that allow mocks
- if a stack sets `mock_inputs.enabled: false`, it requires real producer outputs
  before consumer `plan` can succeed
- `--mock-on-fail` should usually be omitted for destroy when null mock values
  would make resource arguments invalid
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.8 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_local"></a> [local](#provider\_local) | 2.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_infra_yaml_loader"></a> [infra\_yaml\_loader](#module\_infra\_yaml\_loader) | dasmeta/generic/renderer//modules/infra-yaml-loader | 1.2.2 |
| <a name="module_terraform_setups"></a> [terraform\_setups](#module\_terraform\_setups) | ./modules/stack | n/a |

## Resources

| Name | Type |
|------|------|
| [local_file.terramate_outputs_sharing_config](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_linking_mode"></a> [linking\_mode](#input\_linking\_mode) | Linked stack implementation mode. Defaults to Terramate experimental outputs sharing. Use remote\_state for stable Terraform-native linking. | `string` | `"terramate_outputs_sharing"` | no |
| <a name="input_mock_inputs_enabled"></a> [mock\_inputs\_enabled](#input\_mock\_inputs\_enabled) | Whether Terramate outputs-sharing mock inputs are enabled by default for consumer stacks. Individual stack YAML can override this with mock\_inputs.enabled. | `bool` | `true` | no |
| <a name="input_provider_configs"></a> [provider\_configs](#input\_provider\_configs) | Optional grouped provider-specific configuration passed to generated Terramate stacks. | `any` | <pre>{<br/>  "aws": {<br/>    "custom_var_blocks": {},<br/>    "default_tags": {<br/>      "applied_from": "terramate",<br/>      "enabled": true,<br/>      "extra_tags": {},<br/>      "managed_by": "terraform"<br/>    }<br/>  }<br/>}</pre> | no |
| <a name="input_stack_id_prefix"></a> [stack\_id\_prefix](#input\_stack\_id\_prefix) | Optional prefix added to generated Terramate stack IDs. Useful only when multiple generated stack trees live in the same Terramate repository and would otherwise collide. | `string` | `null` | no |
| <a name="input_targetdir"></a> [targetdir](#input\_targetdir) | The directory where generated Terramate stacks will be written. | `string` | `"./generated/stacks"` | no |
| <a name="input_terraform_backend"></a> [terraform\_backend](#input\_terraform\_backend) | Optional default Terraform backend configuration applied to generated stacks. | <pre>object({<br/>    name    = string            # Terraform backend type applied to generated Terramate stacks by default.<br/>    configs = optional(any, {}) # Backend configuration arguments applied to generated Terramate stacks by default.<br/>  })</pre> | <pre>{<br/>  "configs": null,<br/>  "name": null<br/>}</pre> | no |
| <a name="input_terraform_version"></a> [terraform\_version](#input\_terraform\_version) | The Terraform version constraint emitted into generated stack files. | `string` | `"~> 1.3"` | no |
| <a name="input_yamldir"></a> [yamldir](#input\_yamldir) | The directory where YAML module definitions are located. | `string` | `"."` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_generated_files"></a> [generated\_files](#output\_generated\_files) | Generated file paths written by the stack submodule. |
| <a name="output_stack_paths"></a> [stack\_paths](#output\_stack\_paths) | Relative stack paths generated from the YAML directory tree. |
| <a name="output_stacks"></a> [stacks](#output\_stacks) | Normalized stack definitions derived from YAML input. |
| <a name="output_yaml_files"></a> [yaml\_files](#output\_yaml\_files) | Resolved YAML files after shared-config merge and filtering. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
