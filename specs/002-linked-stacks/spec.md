# Linked Stacks and Output Wiring

## Why

`terramate-poc` can currently discover YAML files, merge shared `_.yaml`
configuration, and generate Terramate stack folders with Terraform module calls.
That is enough for isolated stacks, but it does not yet cover real multi-stack
infrastructure behavior.

The existing `terraform-tfe-cloud` driver already supports a linked-workspace
model where stacks can refer to values from other stacks and where generation
logic understands cross-stack dependencies. The Terramate driver needs similar
behavior so it can support realistic YAML-managed infrastructure instead of only
independent module calls.

This repository should also stop carrying the old `scripts/` prototype path. The
root module and internal submodules are now the real implementation surface, so
the leftover prototype state should be removed.

## What

Extend `terramate-poc` so generated Terramate stacks can express and consume
cross-stack dependencies using a Terramate-compatible equivalent of the current
Terraform Cloud driver behavior.

The feature should include:

- explicit dependency declaration through YAML, using the current
  `linked_workspaces` style
- dependency detection from interpolation references inside YAML values, such as
  `${module-a.output_name}`
- generated Terramate dependency metadata so stack ordering is explicit
- generated Terraform output-linking between producer and consumer stacks
- backend configuration support for linked stacks:
  - global default backend config at the root module level
  - optional per-stack backend override in YAML
  - isolated state location per generated stack even when using a global backend
- an advanced executable example that proves linked stack ordering and generated
  output consumption while still using `dasmeta/empty/null`
- removal of the obsolete `scripts/` prototype path

## Scope

In scope:

- stack dependency detection
- interpolation parsing for cross-stack references
- generated Terramate dependency metadata
- generated producer outputs and consumer references
- backend config model for separate stack state
- advanced example-driven validation
- removal of obsolete prototype files

Out of scope:

- `meta-cli` integration
- generic multi-driver shared-core extraction
- parity with every Terraform Cloud-specific feature
- client-specific examples or backend details

## Design

### Dependency Sources

Dependencies should come from two inputs:

- explicit YAML `linked_workspaces`
- interpolation references inside YAML values

The generator should normalize both into stack-path references based on the
resolved YAML file set.

### Ordering

Generated `stack.tm.hcl` should contain dependency metadata so Terramate can
understand stack order from the generated graph instead of relying only on file
layout.

### Output Linking

Generated stack code should support producer/consumer linking in Terraform code.
For the first implementation, this should be backend-aware output linking rather
than Terramate-only local conventions.

Because `dasmeta/empty/null` does not provide meaningful real infrastructure
outputs, the advanced example may need generated synthetic outputs in stack code
so the linking behavior can be demonstrated safely.

### Backend Model

The root module should accept a default backend configuration that applies to all
generated stacks.

Each YAML stack entry may optionally override the backend configuration for that
stack.

Even when stacks share one backend type and one root-level configuration source,
each generated stack must get its own state identity, such as its own backend
key/path/name, derived from the normalized stack path.

### Repository Cleanup

The obsolete `scripts/` path should be removed as part of this feature, because
keeping it would leave two competing implementation stories in the same module.

## Acceptance Criteria

- The repository no longer relies on the prototype `scripts/` path.
- YAML `linked_workspaces` are parsed and reflected in generated stack metadata.
- Interpolation references of the form `${stack.output}` are detected inside YAML
  variable values.
- Generated `stack.tm.hcl` includes dependency metadata for linked stacks.
- Generated Terraform code supports output-linking between stacks.
- The root module accepts a global backend configuration.
- YAML stack entries may override the backend configuration.
- Each generated stack receives its own isolated state identity.
- A new advanced executable example proves:
  - stack dependency ordering
  - linked output consumption
  - separate generated stacks under Terramate discovery
- All docs and examples remain client-agnostic.
