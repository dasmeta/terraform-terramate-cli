# Terramate Driver Module Bootstrap Spec

## Why

`terramate-poc` currently proves the core idea: multiple YAML files can be
resolved into generated Terraform stacks and executed through Terramate. That
prototype is useful, but it is not structured as a real Terraform module
repository yet.

We need to turn this repository into a proper driver module, similar in role to
`terraform-tfe-cloud`, so it has:

- a stable root module interface
- internal submodules under `modules/`
- repository-local executable examples
- module-facing documentation in `README.md`
- Speckit evidence for module-impacting changes

This repository must remain client-agnostic. It should model Terramate first
while keeping later shared-core extraction possible.

## What

Standardize `terramate-poc` into a Terraform driver-module repository that:

- accepts a YAML directory and generated output directory as root-module inputs
- resolves multi-file YAML input, including `_.yaml` shared configuration
- generates Terramate stack files and Terraform module calls through an internal
  generator submodule
- documents the root module and internal module usage in README files
- includes executable examples in a Terraform-module repository layout
- preserves the existing validated POC behavior as the first supported use case

## Scope

In scope:

- root module file set
- internal Terramate stack generator submodule
- README updates
- executable examples
- repo-local Speckit package
- migration of existing POC logic into the module layout

Out of scope:

- generic multi-driver shared-core extraction
- Terraform Cloud compatibility inside this repository
- meta-cli integration
- cloud-specific provider scenarios

## Acceptance Criteria

- Repository root is a valid Terraform module with `main.tf`, `variables.tf`,
  `outputs.tf`, `versions.tf`, `providers.tf`, `locals.tf`, and `README.md`.
- YAML discovery and merge behavior is handled by the root module, not by an ad
  hoc script-only entrypoint.
- Internal generation logic lives under `modules/`.
- At least one example demonstrates the supported root module interface.
- At least two executable examples exist:
  - basic multi-file generation
  - shared `_.yaml` configuration handling
- Existing generated-stack behavior remains reproducible through the new root
  module interface.
- All repo-bound docs and examples remain client-agnostic.
