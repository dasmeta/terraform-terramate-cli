# Adopt Renderer 1.2.2

## Why

This driver consumed two different releases of the same upstream repository:
`dasmeta/generic/renderer//modules/infra-yaml-loader` at 1.2.1 and
`dasmeta/generic/renderer` at 1.0.4. Two tags of one repository were downloaded
side by side, so a fix landing in one did not necessarily apply to the other.

Loader 1.2.1 contains a defect that aborts evaluation for any workspace path
matching a hardcoded directory convention
(`2-products/<product>/<cluster>/setups/<name>`): it interpolates `regex()` capture
lists into a string and fails with

```
Error: Invalid template interpolation value
  Cannot include the given value in a string template: string required, but have tuple.
```

Renderer 1.2.2 removes that directory-inferred linking. Stack links are declared —
through the YAML `linked_workspaces` list or through a `${stack.output}` reference
that already names the stack — and never guessed from folder names. See
`specs/006-infra-yaml-loader-path-linking/` in `terraform-renderer-generic`.

Separately, `modules/stack` renders through the renderer root module, which calls
`provider::deepmerge::mergo`. Terraform supports provider-defined functions only
from 1.8, while this driver declared `required_version = "~> 1.3"`, so a consumer on
an older Terraform failed while parsing instead of reporting an unsupported version.

## What

- Bump both upstream pins to **1.2.2**: the loader in `main.tf` and the renderer in
  `modules/stack/main.tf`, so one tag of the upstream repository is used.
- Raise `required_version` to `~> 1.8` for the root module and `modules/stack`.
- Add `AGENTS.md`, a diagnostic guide for this driver.

## Acceptance Criteria

- both pins reference the same upstream release
- no workspace path can abort evaluation, whatever the directory layout
- explicit `linked_workspaces` and interpolation-detected links still produce
  `stack_after` ordering and generated output wiring in both linking modes
- every example plans without new failing `check` assertions
- module code and README requirement tables agree on the version constraints

## Notes

- Renderer 1.0.4 to 1.2.2 changes exactly one thing in generated output: a local
  module source no longer emits an invalid `version` argument. Verified against the
  examples — the renderer-generated files (`main.tf`, `versions.tf`, `outputs.tf`,
  `README.md`) are unchanged by the bump.
- Several examples show pre-existing drift between committed state and generated
  `stack.tm.hcl` (stack id prefixing) and emit `known after apply` check warnings.
  Reproduced identically against the old pins, so it is not caused by this change
  and is left alone.
- No YAML contract change for consumers. A repository that relied on the implicit
  setup-to-cluster link must declare it, as every other managed repository does.
