# AGENTS.md — terraform-terramate-cli

Diagnostic guide for AI agents and engineers debugging this driver or a setup that
consumes it. Hand-maintained; keep the symptom table honest and evidence-based.

## What this repo is

The Terramate driver: it turns a repository of workspace YAML into a Terramate stack
tree — generic Terraform files plus Terramate metadata per stack. It generates
files; it never applies infrastructure itself.

```
YAML ──▶ infra-yaml-loader ──▶ locals.stacks ──▶ modules/stack ──┬─▶ renderer ──▶ main.tf, versions.tf,
         (registry submodule)   (this repo)                      │               providers.tf, outputs.tf
                                                                 └─▶ stack.tm.hcl (Terramate metadata)
```

- **`modules/stack`** — per stack: calls `dasmeta/generic/renderer` for the Terraform
  files, and writes the Terramate `stack.tm.hcl` (id, name, `after` ordering,
  outputs-sharing or remote-state wiring).
- Discovery, shared-config merge, and link detection are **not** in this repo. They
  live in `dasmeta/generic/renderer//modules/infra-yaml-loader` — see that repo's
  `AGENTS.md` for the YAML contract and loader-stage symptoms.

**Decide which stage owns the symptom first.** Stack missing or merged wrong →
loader. Wrong ordering → `locals.tf` here plus the loader's link detection. Wrong
Terraform file content → renderer templates. Wrong `stack.tm.hcl` → `modules/stack`.

## Linking modes

`linking_mode` decides how a linked stack consumes its producer:

| mode | mechanism | notes |
|---|---|---|
| `terramate_outputs_sharing` (default) | Terramate experimental outputs-sharing | needs `experiments = ["outputs-sharing"]` at the real repo root; renderer `outputs.tf` is forced **off** |
| `remote_state` | Terraform-native `terraform_remote_state` | stable path; renderer `outputs.tf` is forced **back on** |

Links themselves come from two declared sources merged in `locals.tf` — the explicit
YAML `linked_workspaces` list and `${stack.output}` references. **Nothing is
inferred from directory names**; renderer 1.2.2 removed a rule that guessed links
from `2-products/.../setups/` path shape.

## Diagnostics: symptom → cause → check

| symptom | likely cause | check / fix |
|---|---|---|
| `Invalid template interpolation value … have tuple` inside the loader module | loader ≤ 1.2.1 with a path matching the removed convention | bump the `infra-yaml-loader` pin to ≥ 1.2.2 |
| module fails while **parsing**, before any plan output | Terraform < 1.8 — the renderer calls `provider::deepmerge::mergo` | check the Terraform version actually running; this module declares `~> 1.8` |
| an upstream fix "did not land" | the loader and the renderer are **separate pins to the same repo** | check *both* `main.tf` and `modules/stack/main.tf`; they should reference one release |
| a stack is missing from the generated tree | its YAML resolved to no `source`/`version`, so the loader dropped it | probe the loader directly (see the renderer repo's `AGENTS.md`) and compare `yaml_files_raw` with `yaml_files` |
| `stack_after` references a stack that does not exist | a literal `${...}` in `variables`/`providers` was read as a reference — there is no existence filter | search the YAML for `${` values that are not stack paths |
| consumer stack plans with null/mock values | outputs-sharing with mocks enabled and no real producer outputs yet | `mock_inputs.enabled: false` in stack YAML forces real outputs; or use `linking_mode = "remote_state"` |
| `outputs.tf` missing (or unexpectedly present) | it is driven by `linking_mode`, not by YAML | see the linking-modes table above |
| terramate commands fail on generated stacks | the experiment is not enabled at the real repository root | `experiments = ["outputs-sharing"]` in the root `terramate.config` |
| edits to `_terraform/` disappear | generated directory, rewritten every apply | change YAML or the templates |

## Inspecting and validating

Examples are the test suite — there are no `.tftest.hcl` files. A `check` failure
prints as a **Warning**, so a plan that "succeeded" can still have failing
assertions:

```bash
for e in examples/*/; do
  terraform -chdir=$e init -backend=false >/dev/null
  terraform -chdir=$e plan -no-color | grep -E "Warning: Check|^Error|Plan:|No changes"
done
```

Two warning shapes mean different things:

- `Check block assertion known after apply` — benign; the assertion reads a value
  that only exists post-apply.
- `Check block assertion failed` — a real failure, investigate.

Before blaming a change here, re-run the example against the **previous** pin.
Examples carry committed state and generated output, and some are already drifted
(`stack.tm.hcl` ids), so a nonzero plan count is not by itself evidence of a
regression.

## Known traps

- **Two pins to one upstream repo.** `main.tf` pins the loader submodule and
  `modules/stack/main.tf` pins the renderer root. If they name different versions,
  two tags of the same repository are downloaded.
- **Unused module outputs are still evaluated.** A defect in a loader code path this
  driver never reads can still break its plan.
- **Constraint layering.** `required_version` here applies to whoever runs this
  module. The generated stacks' constraint comes from the `terraform_version` input
  and is deliberately independent.
- **`stack_id_prefix` changes generated ids**, so committed example output drifts
  until regenerated. Harmless, but it makes plans look noisy.

## Version compatibility

| component | constraint | why |
|---|---|---|
| root module | `~> 1.8` | reaches `provider::deepmerge::mergo` through `modules/stack` → renderer |
| `modules/stack` | `~> 1.8` | calls the renderer root module |
| generated stacks | `terraform_version` input | consumer policy, not a module requirement |

## Changing this repo

- Write a `specs/NNN-name/{spec,plan,tasks}.md` package before changing behavior.
- Add or extend an example with `check` blocks — the only test mechanism here.
- `pre-commit` runs on commit and rewrites README tables via `terraform_docs`; stage
  its changes and re-commit rather than hand-editing generated tables.
- Conventional commits drive semantic-release: `fix` → patch, `feat` → minor.
- Never commit client-specific names into this repo — it is published.
