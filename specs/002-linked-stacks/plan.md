# Linked Stacks and Output Wiring Plan

Implementation follows the approved linked-stacks spec by extending the Terramate
driver and the shared renderer together.

Execution shape:

- keep YAML discovery and stack iteration in `terramate-poc`
- move generic backend-aware remote-state/output rendering into
  `terraform-renderer-generic`
- derive linked stacks from explicit `linked_workspaces` plus
  `${stack.output}` interpolation detection
- render Terramate `after` metadata in `stack.tm.hcl`
- apply a root-level backend default with optional per-stack YAML override
- derive isolated state identity per stack from the normalized stack path
- prove behavior through an executable advanced example using
  `dasmeta/empty/null`
- remove obsolete `scripts/` leftovers after the feature is in place
