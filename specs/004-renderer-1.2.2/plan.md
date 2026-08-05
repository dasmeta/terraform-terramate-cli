# Implementation Plan

## Scope

Move both upstream pins to renderer 1.2.2 and align the Terraform version
constraint with the provider functions this driver reaches.

## Current State

- `main.tf` pins the loader submodule at 1.2.1.
- `modules/stack/main.tf` pins the renderer root module at 1.0.4 — a different tag
  of the same repository.
- `versions.tf` and `modules/stack/versions.tf` declare `~> 1.3` while the renderer
  root module calls `provider::deepmerge::mergo`.
- Examples carry committed state and generated output; several are already drifted
  and emit `known after apply` check warnings.

## Steps

1. Bump the loader pin to 1.2.2 in `main.tf`.
2. Bump the renderer pin to 1.2.2 in `modules/stack/main.tf`.
3. Raise `required_version` to `~> 1.8` in the root module, `modules/stack`, and the
   example roots; update README requirement and module tables.
4. Establish a baseline by planning the examples against the **old** pins, then
   compare after the bump.
5. Plan every example and confirm no new failing checks.

## Validation

- Reviewed `v1.0.4..v1.2.2` in `terraform-renderer-generic`: the only root-module
  changes are the `~> 1.8` constraint and omitting the invalid `version` argument
  for local module sources. Root `locals.tf`, `variables.tf`, and `outputs.tf` are
  unchanged.
- Baseline: `examples/basic` and `examples/linked-stacks` produce identical plan
  counts on the old pins, so the observed drift predates this change.
- `terraform plan` for `examples/basic`, `examples/linked-stacks`,
  `examples/with-shared-configs`, `examples/empty-yaml`, `examples/backend-s3`,
  `examples/backend-gitlab` — no failing check assertions
- `terraform fmt -check -recursive .`
- `pre-commit` hooks on commit, including `terraform_docs`

## Breaking Changes

None for the YAML contract. Consumers pinned below Terraform 1.8 must upgrade,
which the renderer's provider functions already require in practice.

## Follow-Up

- Apply the same bump to `terraform-tfe-cloud`.
- Regenerating the drifted example output (`stack.tm.hcl` ids) is a separate
  cleanup; it is unrelated to the upstream bump.
