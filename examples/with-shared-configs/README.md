# Shared Config Example

This example is also the shared-config executable validation case for the
repository.

It verifies that the root driver module:

- merges shared `_.yaml` content into child module YAML files
- preserves nested stack paths in generated output
- writes the expected Terramate and Terraform files for nested modules
