# Terramate Driver Module Bootstrap Plan

## Current Repository State

- The repository contains a validated Terramate POC workspace.
- Generation logic lives under `scripts/mapper`.
- YAML input lives under `input/`.
- Generated files live under `generated/`.
- The repository root is not yet the public Terraform module interface.
- Examples exist, but the repository should use executable examples as the
  validation surface instead of maintaining a separate test tree.

## Gaps Versus Internal Standards

- Missing root module file set.
- Missing `modules/` submodule layout for internal reusable logic.
- Missing executable module-oriented examples that double as validation cases.
- Missing repository-local Speckit package until this bootstrap change.
- README describes a POC workspace instead of a stable module contract.

## Wrapper Preservation Assessment

The intended repository role is an opinionated driver module, not a broad
runtime abstraction. The root module should expose a small interface centered on
YAML input discovery and generated output location. Terramate-specific file
generation should stay internal to a submodule.

## New-Module Sourcing Check

- Target domain: Terraform/Terramate driver module, not a cloud-provider
  infrastructure module.
- Checked provider-maintained collections: no suitable upstream module exists
  for this repository type.
- Fallback rationale: this repository must implement repository-specific driver
  behavior directly.

## Governance Source

Shared module-governance guidance comes from the constitution skill references:

- `internal-module-standards.md`
- `planning-checklist.md`

## Proposed File Changes

- Create root module files:
  - `main.tf`
  - `locals.tf`
  - `variables.tf`
  - `outputs.tf`
  - `providers.tf`
  - `versions.tf`
- Create internal submodule:
  - `modules/stack-generator/*`
- Replace the current root `README.md` with module-facing documentation.
- Add executable examples:
  - `examples/basic/*`
  - `examples/with-shared-configs/*`
- Keep POC background notes under `docs/`.
- Retire `scripts/mapper` from the public module surface after logic migration.

## Potential Breaking Changes

- The repository stops presenting `scripts/mapper` as the primary entrypoint and
  instead uses the root Terraform module.
- The existing POC layout remains as implementation history, but the consumer
  contract changes to the new root module interface.

This is acceptable because the repository is not released as a stable public
module yet.

## Potential Interface-Widening Changes

None proposed. The standardization effort narrows the interface into a proper
module shape instead of broadening it.

## Conflicts Requiring Approval

None. The requested direction is to make this repository a real Terraform
module repo, and the proposed structure matches that requirement.
