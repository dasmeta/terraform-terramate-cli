# Architecture Findings

Use this note to record what the standardized module proves about the future
driver boundary.

It should eventually separate:

- YAML/model responsibilities
- mapping/generation responsibilities
- runtime-driver responsibilities

## Initial Expectation

- YAML/model handling should become driver-agnostic later
- generation logic may split into shared and runtime-specific pieces
- Terramate runtime behavior should stay in the driver layer

## Current POC Evidence

### YAML/Model Layer

The following behavior looks driver-agnostic:

- recursive YAML file discovery
- exclusion of shared `_.yaml` files from direct module generation
- prepend-style merge of root and nested shared YAML content
- validation that a module entry must have `source` and `version`
- preservation of relative path structure from input to generated stack path

### Mapping/Generation Layer

The following behavior looks like a likely shared-core candidate later:

- resolve input YAML into normalized module entries
- derive one generated unit per module entry
- emit Terraform module invocation files from normalized data

The following parts are currently generation details but may or may not remain shared:

- stack naming normalization for nested paths
- exact generated file set per runtime

### Runtime Driver Layer

The following behavior is Terramate-specific in this repository:

- `stack.tm.hcl` generation
- Terramate stack discovery from the generated target directory
- orchestration through `terramate run`
- current execution nuances such as serial `plan` with `-lock=false`

The following behavior remains Terraform Cloud-specific in the existing implementation:

- workspace creation and naming as TFC workspaces
- TFC execution settings
- agent pool selection
- variable set attachment
- OAuth and VCS linking
- workspace output sharing through TFC-specific data sources

## Current Module Validation Gate

The Terramate driver module is considered structurally ready for further
implementation when all of the following remain true:

- multi-file YAML input works
- shared `_.yaml` behavior works for the chosen scope
- generated Terramate stacks are discoverable from the module target directory
- the root module remains the public generation entrypoint
- examples and tests stay aligned with the root module interface
- copied and adapted logic is documented
- the driver boundary is explicit enough to guide the durable implementation
