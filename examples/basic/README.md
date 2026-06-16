# Basic Example

This example is also the basic executable validation case for the repository.

It verifies that the root driver module:

- reads YAML files directly from the example root
- merges shared `_.yaml` content from the example root
- generates one Terramate stack per YAML file
- writes the expected Terraform and Terramate files to the `_terraform/` target directory
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | ../.. | n/a |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
